from bson import ObjectId
from forum.api.custom_errors import APIError, InvalidIdError


def expect(input, expected_type, field):
    """
    Validates that the input is of the expected type and, if a string, is not empty.

    :param input: The value to validate
    :param expected_type: The expected data type (e.g., str, int)
    :param field: The name of the field (for error messages)
    :return: The validated input if correct
    :raises APIError: If validation fails
    """
    if input is None:
        raise APIError(f"Missing required field: {field}.")

    if not isinstance(input, expected_type):
        raise APIError(
            f"Invalid type for '{field}'. Expected {expected_type.__name__}, got {type(input).__name__}."
        )

    if expected_type is str and not input.strip():
        raise APIError(f"'{field}' cannot be empty.")

    return input


def get_object_id(object_id):
    """Converts string ID to ObjectId, raising InvalidIdError if invalid."""
    try:
        return ObjectId(object_id)
    except Exception:
        raise InvalidIdError()


def question_to_boundary(question):
    return {
        "id": str(question["_id"]),
        "title": question["title"],
        "content": question["content"],
        "created_at": question["created_at"].isoformat(),
        "answers": [answer_to_boundary(answer) for answer in question["answers"]],
    }


def answer_to_boundary(answer):
    return {
        "content": answer["content"],
        "created_at": answer["created_at"].isoformat(),
    }
