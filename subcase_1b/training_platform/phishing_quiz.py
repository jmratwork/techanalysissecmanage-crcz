from flask import request, jsonify

# Sample phishing quiz questions
quiz_questions = [
    {
        'id': 'q1',
        'question': 'Which action is commonly associated with a phishing email?',
        'options': [
            'Requesting sensitive information urgently',
            'Providing official company updates',
            'Sending calendar invites only',
            'Confirming a meeting room booking'
        ],
        'answer': 0
    },
    {
        'id': 'q2',
        'question': 'What is a good first step when you suspect a link is malicious?',
        'options': [
            'Click it to verify contents',
            'Hover over the link to inspect the URL',
            'Forward it to colleagues',
            'Ignore and delete without reporting'
        ],
        'answer': 1
    }
]


def init_app(app, authenticate, tokens, quiz_results):
    """Register quiz endpoints on the given Flask app."""

    @app.route('/quiz/start', methods=['GET'])
    def quiz_start():
        token = request.args.get('token')
        user = authenticate(token)
        if not user:
            return jsonify({'error': 'unauthorized'}), 403
        course_id = request.args.get('course_id')
        questions = [{k: v for k, v in q.items() if k != 'answer'} for q in quiz_questions]
        return jsonify({'course_id': course_id, 'questions': questions})

    @app.route('/quiz/submit', methods=['POST'])
    def quiz_submit():
        data = request.get_json(force=True)
        token = data.get('token')
        user = authenticate(token)
        if not user:
            return jsonify({'error': 'unauthorized'}), 403
        course_id = data.get('course_id')
        answers = data.get('answers', {})
        score = 0
        for q in quiz_questions:
            qid = q['id']
            if str(answers.get(qid)) == str(q['answer']):
                score += 1
        username = tokens.get(token)
        quiz_results[(course_id, username)] = {'answers': answers, 'score': score}
        return jsonify({'score': score})

    @app.route('/quiz/score', methods=['GET'])
    def quiz_score():
        token = request.args.get('token')
        user = authenticate(token)
        if not user:
            return jsonify({'error': 'unauthorized'}), 403
        course_id = request.args.get('course_id')
        username = tokens.get(token)
        result = quiz_results.get((course_id, username))
        return jsonify({'score': result['score'] if result else 0})
