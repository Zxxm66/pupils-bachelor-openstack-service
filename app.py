from flask import Flask, jsonify
import json
import os

app = Flask(__name__)

# Path to the students data file
DATA_FILE = os.path.join(os.path.dirname(__file__), 'students.json')


def load_students():
    """Load students from JSON file."""
    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


@app.route('/students', methods=['GET'])
def get_all_students():
    """Return all students."""
    students = load_students()
    return jsonify(students)


@app.route('/bachelor', methods=['GET'])
def get_bachelor_candidates():
    """
    Return students eligible for bachelor's degree.

    Conditions:
        - grade >= 4         (GPA of 4 or higher)
        - course >= 3        (3rd year or above)
        - attended_labs >= 75 (attended at least 75% of lab sessions)
    """
    students = load_students()

    candidates = [
        student for student in students
        if student.get('grade', 0) >= 4
        and student.get('course', 0) >= 3
        and student.get('attended_labs', 0) >= 75
    ]

    return jsonify(candidates)


@app.route('/health', methods=['GET'])
def health_check():
    """Simple health check endpoint."""
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
