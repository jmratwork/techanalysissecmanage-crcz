import uuid
import time
from flask import Flask, request, jsonify

import phishing_quiz
from open_edx_client import OpenEdXClient
from results_service import append_result, aggregate_results

app = Flask(__name__)

# In-memory stores
users = {}  # username -> {password, role}
tokens = {}  # token -> username
courses = {}  # course_id -> {title, content, instructor}
invites = {}  # invite_code -> {course_id, email}
progress = {}  # (course_id, username) -> progress
quiz_results = {}  # (course_id, username) -> {answers, score}
edx_failures = []  # list of Open edX reporting failures

open_edx = OpenEdXClient()


def authenticate(token):
    username = tokens.get(token)
    if not username:
        return None
    return users.get(username)


@app.route('/register', methods=['POST'])
def register():
    data = request.get_json(force=True)
    username = data.get('username')
    password = data.get('password')
    role = data.get('role', 'trainee')
    if not username or not password:
        return jsonify({'error': 'username and password required'}), 400
    if username in users:
        return jsonify({'error': 'user exists'}), 400
    users[username] = {'password': password, 'role': role}
    return jsonify({'status': 'registered'})


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json(force=True)
    username = data.get('username')
    password = data.get('password')
    user = users.get(username)
    if not user or user['password'] != password:
        return jsonify({'error': 'invalid credentials'}), 403
    token = str(uuid.uuid4())
    tokens[token] = username
    return jsonify({'token': token})


@app.route('/courses', methods=['POST'])
def create_course():
    data = request.get_json(force=True)
    token = data.get('token')
    user = authenticate(token)
    if not user or user['role'] != 'instructor':
        return jsonify({'error': 'unauthorized'}), 403
    title = data.get('title')
    content = data.get('content', '')
    course_id = str(uuid.uuid4())
    courses[course_id] = {
        'title': title,
        'content': content,
        'instructor': tokens[token]
    }
    return jsonify({'course_id': course_id})


@app.route('/courses', methods=['GET'])
def list_courses():
    token = request.args.get('token')
    user = authenticate(token)
    if not user:
        return jsonify({'error': 'unauthorized'}), 403
    return jsonify(courses)


@app.route('/invites', methods=['POST'])
def create_invite():
    data = request.get_json(force=True)
    token = data.get('token')
    user = authenticate(token)
    if not user or user['role'] != 'instructor':
        return jsonify({'error': 'unauthorized'}), 403
    course_id = data.get('course_id')
    email = data.get('email')
    code = str(uuid.uuid4())
    invites[code] = {'course_id': course_id, 'email': email}
    return jsonify({'invite_code': code})


@app.route('/progress', methods=['POST'])
def update_progress():
    data = request.get_json(force=True)
    token = data.get('token')
    user = authenticate(token)
    if not user:
        return jsonify({'error': 'unauthorized'}), 403
    course_id = data.get('course_id')
    username = data.get('username') or tokens[token]
    value = data.get('progress')
    progress[(course_id, username)] = value
    return jsonify({'status': 'updated'})


@app.route('/progress', methods=['GET'])
def get_progress():
    token = request.args.get('token')
    user = authenticate(token)
    if not user:
        return jsonify({'error': 'unauthorized'}), 403
    course_id = request.args.get('course_id')
    username = request.args.get('username') or tokens[token]
    value = progress.get((course_id, username), 0)
    return jsonify({'progress': value})


@app.route('/results', methods=['POST'])
def post_results():
    data = request.get_json(force=True)
    token = data.get('token')
    user = authenticate(token)
    if not user:
        return jsonify({'error': 'unauthorized'}), 403
    course_id = data.get('course_id')
    username = data.get('username') or tokens[token]
    start = data.get('start_time')
    end = data.get('end_time')
    score = data.get('score', 0)
    duration = None
    if start is not None and end is not None:
        try:
            duration = float(end) - float(start)
        except (TypeError, ValueError):
            duration = None
    result = {
        'course_id': course_id,
        'username': username,
        'score': score,
        'duration': duration,
        'details': data.get('details', {}),
        'timestamp': time.time(),
    }
    append_result(result)
    metrics = aggregate_results(course_id, username)
    progress[(course_id, username)] = metrics.get('score', score)
    ok, message = open_edx.update_progress(username, course_id, metrics)
    if not ok:
        edx_failures.append(
            {
                'course_id': course_id,
                'username': username,
                'error': message,
                'timestamp': time.time(),
            }
        )
    return jsonify({'status': 'recorded', 'metrics': metrics, 'edx_sync': ok})


@app.route('/edx_failures', methods=['GET'])
def get_edx_failures():
    token = request.args.get('token')
    user = authenticate(token)
    if not user or user.get('role') != 'instructor':
        return jsonify({'error': 'unauthorized'}), 403
    return jsonify({'failures': edx_failures})


@app.route('/kypo/launch', methods=['POST'])
def kypo_launch():
    """Generate an LTI launch URL for a KYPO lab.

    The endpoint expects a JSON body with a valid authentication token
    and ``lab_id`` identifying the KYPO exercise. The response contains
    a pre-signed LTI launch URL that the caller can redirect the user to
    in order to start the session.
    """

    data = request.get_json(force=True)
    token = data.get('token')
    lab_id = data.get('lab_id')

    user = authenticate(token)
    if not user or not lab_id:
        return jsonify({'error': 'unauthorized'}), 403

    username = tokens[token]
    try:
        launch_url = open_edx.generate_launch_url(username, lab_id)
    except Exception as exc:  # pragma: no cover - configuration errors
        return jsonify({'error': str(exc)}), 500

    return jsonify({'launch_url': launch_url})


phishing_quiz.init_app(app, authenticate, tokens, quiz_results)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
