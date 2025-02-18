from flask import Flask
from flask_cors import CORS
from forum.db import mongo
from forum.api.questions import questions_api
from forum.socket import socketio
import os
import configparser

# Load configuration
config = configparser.ConfigParser()
config.read(os.path.abspath(os.path.join(".ini")))

# Initialize Flask app
app = Flask(__name__)
CORS(app, methods=["GET", "POST"])

# Set MongoDB URI
app.config["MONGO_URI"] = config["PROD"]["DB_URI"]

# Register blueprints
app.register_blueprint(questions_api)

# Initialize extensions
mongo.init_app(app)
socketio.init_app(app)

if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5000, debug=True, allow_unsafe_werkzeug=True)
