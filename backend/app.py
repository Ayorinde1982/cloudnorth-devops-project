from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from the CloudNorth Backend API!"

@app.route('/api/status')
def api_status():
    return jsonify(status="ok", service="backend"), 200
