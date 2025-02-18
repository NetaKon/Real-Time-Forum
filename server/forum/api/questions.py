from flask import Blueprint, jsonify, request
from flask_cors import CORS
from flask_socketio import join_room, leave_room
from forum.api.custom_errors import *
from forum.api.utils import (
    answer_to_boundary,
    expect,
    get_object_id,
    question_to_boundary,
)
from forum.db import *
from forum.socket import socketio

questions_api = Blueprint("questions_api", "questions_api", url_prefix="/questions")
CORS(questions_api)


# Error handlers
@questions_api.errorhandler(APIError)
def handle_exception(err):
    """Return custom JSON when APIError or its children are raised"""
    message = err.args[0] if err.args else err.description
    response = {"error": message}

    return jsonify(response), err.code


@questions_api.errorhandler(500)
def handle_internal_error(_):
    """Return JSON instead of HTML for any other server error"""
    response = {"error": "Sorry, that error is on us"}
    return jsonify(response), 500


# Routes
@questions_api.route("", methods=["POST"])
def api_create_question():
    """
    Creates a new question.
    """

    data = request.get_json()

    title = expect(data.get("title"), str, "title")
    content = expect(data.get("content"), str, "content")

    id = create_question(title, content)
    question = question_to_boundary(get_question(id))

    return jsonify({"data": [question]}), 201


@questions_api.route("/<question_id>", methods=["GET"])
def api_get_specific_question(question_id):
    """
    Retrieves a specific question by ID.
    """
    question = get_question(get_object_id(question_id))

    if not question:
        raise QuestionNotFoundError()

    return jsonify({"data": [question_to_boundary(question)]}), 200


@questions_api.route("/", methods=["GET"])
def api_get_questions():
    """
    Retrieves a paginated list of questions.
    """
    page = request.args.get("page", 0, type=int)
    limit = request.args.get("limit", 10, type=int)

    questions, total_num_questions = get_questions(page, limit)

    response = {
        "data": list(map(question_to_boundary, questions)),
        "page": page,
        "has_next": len(questions) == limit,
        "next": f"/questions?page={page + 1}&limit={limit}",
        "total_results": total_num_questions,
    }

    return jsonify(response), 200


@questions_api.route("/<question_id>", methods=["PUT"])
def api_update_question(question_id):
    """
    Updates an existing question (title or content, at least one required).
    """
    data = request.get_json()
    title, content = data.get("title"), data.get("content")

    if title is None and content is None:
        raise APIError("At least one field (title or content) is required.")

    if title:
        expect(title, str, "title")
    if content:
        expect(content, str, "content")

    question_id = get_object_id(question_id)

    if not update_question(question_id, title, content):
        raise QuestionNotFoundError()
    question = question_to_boundary(get_question(question_id))

    return jsonify({"data": [question]}), 200


@questions_api.route("/<question_id>", methods=["DELETE"])
def api_delete_question(question_id):
    """
    Deletes a question by ID.
    """
    question_id = get_object_id(question_id)

    if not delete_question(question_id):
        raise QuestionNotFoundError()

    return "", 204


@questions_api.route("/", methods=["DELETE"])
def api_delete_all_questions():
    """
    Deletes all questions.
    """
    delete_all_questions()
    return "", 204


@questions_api.route("/<question_id>", methods=["POST"])
def api_post_answer(question_id):
    """
    Posts an answer to a question
    """
    question_id = get_object_id(question_id)
    content = expect(request.get_json().get("content"), str, "content")

    post_answer(question_id, content)
    question = get_question(question_id)

    if not question:
        raise QuestionNotFoundError()

    updated_answers = list(map(answer_to_boundary, question["answers"]))

    # Emit event to the clients connected to the room for this specific question
    socketio.emit(
        "new_answer",
        {"question_id": str(question_id), "answers": updated_answers},
        room=str(question_id),
    )

    return jsonify({"answers": updated_answers}), 200


@socketio.on("join_room")
def connected(data):
    question_id = data.get("question_id")
    join_room(question_id)


@socketio.on("leave_room")
def disconnected(data):
    question_id = data.get("question_id")
    if question_id:
        leave_room(question_id)
