import os

from flask import Flask, render_template, request, jsonify
from database import get_connection, insert_user, fetch_users
from prometheus_flask_exporter import PrometheusMetrics
from psycopg2.errors import UniqueViolation

app = Flask(__name__)
metrics = PrometheusMetrics(app, path=None)
metrics.start_http_server(8000)

@app.route("/")
def home():
    environment = os.getenv("APP_ENV") or "Development"
    return render_template("index.html", environment=environment)


@app.route("/health")
def health():
    return {"status": "healthy"}, 200


@app.route("/ready")
def ready():
    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT 1")

        cursor.close()
        connection.close()

        return {"status": "ready"}, 200

    except Exception:
        return {"status": "not ready"}, 503


@app.route("/test-db")
def test_db():

    try:
        connection = get_connection()
        connection.close()

        return {"status": "Database connection OK"}, 200

    except Exception:
        app.logger.exception("Database connection failed")
        return {"error": "Database unavailable"}, 503


@app.route("/users", methods=["POST"])
def create_user():

    data = request.get_json(silent=True)

    if not data:
        return {"error": "JSON body is required"}, 400

    username = data.get("username")
    email = data.get("email")

    if not username or not email:
        return {"error": "username and email are required"}, 400

    if "@" not in email:
        return {"error": "Email format is invalid"}, 400

    try:
        insert_user(username, email)

        return jsonify({
            "message": "User created"
        }), 201

    except UniqueViolation:
        app.logger.warning("Duplicate email rejected")
        return {"error": "Email already exists"}, 409

    except Exception:
        app.logger.exception("Failed to create user")
        return {"error": "Database unavailable"}, 503

@app.route("/users", methods=["GET"])
def get_users():
    try:
        users = fetch_users()

        return jsonify(users), 200

    except Exception:
        app.logger.exception("Failed to get users")
        return {"error": "Database unavailable"}, 503

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
