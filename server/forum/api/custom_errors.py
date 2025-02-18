class APIError(Exception):
    """All custom API Exceptions"""

    code = 400


class InvalidIdError(APIError):
    code = 400
    description = "Invalid question ID."


class QuestionNotFoundError(APIError):
    code = 404
    description = "Question not found."
