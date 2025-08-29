import numpy as np
from sklearn.tree import DecisionTreeClassifier
from flask import Flask, request, jsonify

app = Flask(__name__)

# Sample training data
# Features: [source, severity]
# source: 0 = NG-SIEM, 1 = BIPS
X = np.array([
    [0, 1], [0, 5], [0, 8],
    [1, 2], [1, 6], [1, 9],
])
y = np.array([0, 1, 2, 0, 1, 2])  # 0: monitor, 1: block_ip, 2: isolate_host

model = DecisionTreeClassifier()
model.fit(X, y)

MITIGATIONS = {
    0: "monitor",
    1: "block_ip",
    2: "isolate_host"
}

def encode_source(source: str) -> int:
    return 0 if source.lower() == "ng-siem" else 1

@app.post("/recommend")
def recommend():
    payload = request.get_json(force=True)
    source = payload.get("source", "ng-siem")
    severity = int(payload.get("severity", 0))
    features = np.array([[encode_source(source), severity]])
    prediction = model.predict(features)[0]
    mitigation = MITIGATIONS.get(prediction, "monitor")
    return jsonify({"mitigation": mitigation})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
