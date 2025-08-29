import uuid
from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory stores
users = {}  # username -> {password, role}
tokens = {}  # token -> username
courses = {}  # course_id -> {title, content, instructor}
invites = {}  # invite_code -> {course_id, email}
progress = {}  # (course_id, username) -> progress


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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
