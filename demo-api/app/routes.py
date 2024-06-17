from flask import jsonify
from app import app
from app.status import get_rocket_status

@app.route('/status', methods=['GET'])
def status():
    status = get_rocket_status()
    return jsonify(status)