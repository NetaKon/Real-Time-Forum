from datetime import datetime, timezone
from typing import Optional
from bson import ObjectId
from flask import g
import pymongo
from werkzeug.local import LocalProxy
from flask_pymongo import PyMongo


# Initialize PyMongo globally
mongo = PyMongo()


def get_db():
    """
    Configuration method to return db instance
    """
    if "db" not in g:
        g.db = mongo.db

    return g.db


# Use LocalProxy to read the global db instance
db = LocalProxy(get_db)


def create_question(title: str, content: str) -> ObjectId:
    """
    Creates a new question document in the database.

    :param title: Title of the question
    :param content: Content of the question
    :return: The inserted question's ObjectId
    """
    question_doc = {
        "title": title,
        "content": content,
        "answers": [],
        "created_at": datetime.now(timezone.utc),
    }

    result = db.questions.insert_one(question_doc)
    return result.inserted_id


def get_question(id: ObjectId):
    """
    Fetches a single question document by its ID.

    :param id: The ObjectId of the question
    :return: The question document or None if not found
    """
    return db.questions.find_one({"_id": id})


def get_questions(
    page: int = 0,
    limit: int = 10,
    sort_by: str = "created_at",
    sort_order: int = pymongo.DESCENDING,
):
    """
    Fetches a paginated list of questions.

    :param page: The page number (zero-based index)
    :param limit: Number of questions per page
    :param sort_by: Field to sort by
    :param sort_order: Sorting order (ASCENDING or DESCENDING)
    :return: A tuple containing the list of questions and the total count
    """
    skip = page * limit

    questions = list(
        db.questions.find().sort(sort_by, sort_order).skip(skip).limit(limit)
    )
    total_num_questions = db.questions.count_documents({})

    return questions, total_num_questions


def update_question(
    id: ObjectId, title: Optional[str] = None, content: Optional[str] = None
) -> bool:
    """
    Updates a question document with new title and/or content.

    :param id: The ObjectId of the question
    :param title: New title (optional)
    :param content: New content (optional)
    :return: True if the document was modified, False otherwise
    """
    modified_question = {}

    if title:
        modified_question["title"] = title

    if content:
        modified_question["content"] = content

    if not modified_question:
        return False  # Nothing to update

    result = db.questions.update_one({"_id": id}, {"$set": modified_question})
    return result.matched_count > 0


def delete_all_questions() -> int:
    """
    Deletes all question documents in the database.

    :return: The number of deleted documents
    """
    result = db.questions.delete_many({})
    return result.deleted_count


def delete_question(id: ObjectId) -> bool:
    """
    Deletes a question document by its ID.

    :param id: The ObjectId of the question
    :return: True if the document was deleted, False otherwise
    """
    result = db.questions.delete_one({"_id": id})
    return result.deleted_count > 0


def post_answer(question_id: ObjectId, content: str) -> bool:
    """
    Adds an answer to a question.

    :param question_id: The ObjectId of the question
    :param content: The content of the answer
    :return: True if the answer was added, False otherwise
    """
    answer_doc = {
        "content": content,
        "created_at": datetime.now(timezone.utc),
    }

    result = db.questions.update_one(
        {"_id": question_id}, {"$push": {"answers": answer_doc}}
    )
    return result.modified_count > 0
