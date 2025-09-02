# Phishing Awareness Questionnaire

Use this questionnaire to assess how well trainees can identify phishing threats. Questions can be served by the training platform and scored automatically.

## Sample Questions

1. **What is the safest response to an unexpected password reset email?**
   - A. Click the link and change your password
   - B. Ignore the email
   - C. Verify the request through an official channel
2. **Which URL is likely malicious?**
   - A. `https://accounts.example.com`
   - B. `http://login.example.com.security-update.co`
   - C. `https://intranet.example.com/profile`
3. **Why should you hover over links before clicking?**
   - A. To check the true destination
   - B. To download the attachment
   - C. To enable pop-up blockers

## Scoring via Training Platform

The training platform exposes endpoints that handle quiz distribution and scoring:

```bash
# Obtain questions
curl http://localhost:5000/quiz/start

# Submit answers for grading
curl -X POST http://localhost:5000/quiz/submit \
  -H 'Content-Type: application/json' \
  -d '{"user":"alice","answers":{"q1":"C","q2":"B","q3":"A"}}'

# Retrieve the stored score
curl http://localhost:5000/quiz/score?user=alice
```

These endpoints allow instructors to integrate phishing assessments into automated training workflows and track learner performance over time.
