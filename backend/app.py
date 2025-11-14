from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    # This is the line we are changing to test our new automated deployment
    return "SUCCESS: The new version of the CloudNorth Backend is live!"

@app.route('/api/status')
def api_status():
    return jsonify(status="ok", service="backend"), 200
