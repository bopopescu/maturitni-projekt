#!/usr/bin/env python3
# coding=utf-8
# neumim programovat
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO: http://flask.pocoo.org/docs/0.10/patterns/packages/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO2: http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
# TODO3: Check for invalid data in forms
# TODO3: Check for invalid data in forms
# TODO3: Check for invalid data in forms
# TODO3: Check for invalid data in forms
# TODO3: Check for invalid data in forms


# db access lib
import MySQLdb

# passlib for password hashing
from passlib.hash import sha512_crypt

# re for regular expressions parsing
import re

# randomness for session IDs
from os import urandom
from base64 import b64encode
from time import time

from flask import Flask, request, jsonify, redirect
app = Flask(__name__)


from werkzeug.exceptions import default_exceptions
from werkzeug.exceptions import HTTPException

def is_email_valid(email_to_check): # TODO: maybe move to api_utils or sth??????
    regexp = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"
    result = re.match(regexp, str(email_to_check)) # if we conv to string we don't have to care about checking if the string is None and the regexp will just say it's not a valid email address, i will forever wonder what is faster, probably checking for None, but we may never be sure and I am too lazy to test it out so instead I am writing out this long comment on a single line without word wrapping just to calm myself down
    if result is None:
        return False
    else:
        return True

def error(_status, _reason, _message):
    return jsonify(status=_status, reason=_reason, message=_message)


# this function checks for a sessionID in the database and joins it with the userID of a user
def get_userID_if_loggedin(request):
    if "sessionid" in request.cookies:
        session_id_cookie = request.cookies.get("sessionid")
        db=MySQLdb.connect(user="root", passwd="asdf", db="cloudchatdb", connect_timeout=30)
        print("session_id_cookie = ", session_id_cookie)
        cursor = db.cursor()
        result_code = cursor.execute("""SELECT * FROM `User_sessions` WHERE `session_id` = %s""", (session_id_cookie,))
        if result_code is not 0:
            result = cursor.fetchone()
            session_id = result[0]
            userID = result[2]
            if session_id == session_id_cookie:
                return (True, userID)
            else:
                return False
        else:
            return False
    else:
        return False


@app.after_request
def after_request(response):
  response.headers.add('Access-Control-Allow-Origin', '*')
  response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,Cookies')
  response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  return response


@app.route("/")
def hello_world():
    if "sessionid" in request.cookies:
        print("request.cookies", request.cookies)
        asdf = dict(status="ok", message=str(request.cookies["sessionid"]))
        return jsonify(asdf)
    else:
        asdf = dict(status="ok", message="API is up.")
        return jsonify(asdf)

@app.route("/get_messages")
def get_messages():
    return "get_messages()"

@app.route("/logout", methods=["POST"])
def logout(request):
    if "sessionid" in request.cookies:
        print("asdf")

@app.route("/upon_login", methods=["POST"])
def session_check():
    userID = get_userID_if_loggedin(request)
    if userID is not False:
        db=MySQLdb.connect(user="root", passwd="asdf", db="cloudchatdb", connect_timeout=30)
        cursor = db.cursor()
        cursor.execute("""SELECT * FROM `Registered_users` WHERE `userID` = %s""", (userID),)


@app.route("/login", methods=["POST"])
def login():
    _email = request.form.get("email").lower() # WARNING: make lower() because USER@EXAMPLE.COM is the same as UsER@eXamPle.com !!!!!
    _password = request.form.get("password")
    _hashed_password = sha512_crypt.encrypt(_password, salt="CodedSaltIsBad")

    db=MySQLdb.connect(user="root", passwd="asdf", db="cloudchatdb", connect_timeout=30)

    cursor = db.cursor()
    result_code = cursor.execute("""SELECT * FROM `Registered_users` WHERE `email` = %s AND `password` = %s""", (_email, _hashed_password))

    if result_code is not 0: # use "is not" for extra speed (not like it matters, all code around here is slow anyway)
        values = cursor.fetchone()
        _id = values[0]

        if "sessionid" in request.cookies:
            cookies_sessionid = request.cookies.get("sessionid")
            cursor = db.cursor()
            result_code = cursor.execute("""SELECT * FROM `User_sessions` WHERE `Registred_users_userID` = %s""", (_id,))
            if result_code is not 0:
                session_id = cursor.fetchone()[0]

                session_id_cookie = request.cookies.get("sessionid")
                print("session_id DB:", session_id)
                print("session_id cookie:", session_id_cookie)

                if session_id == session_id_cookie:
                    print("At this point, we are already logged in. Redirect the user here!!!!")
                    return jsonify(status="ok", reason="already_loggedin", message="You are already logged in.")

            print("Reached the end of checking the session cookie with the one in DB.",
                  "The current cookie session does not exist. Gonna relog now.")

        # remove any original session we had (stupid, but whatever, I'd rather pass my last year of high school than have a good session system
        cursor = db.cursor()
        result_code = cursor.execute("DELETE FROM `User_sessions` WHERE `Registred_users_userID` = %s", (_id,))
        db.commit()

        generated_sessionID = b64encode(urandom(64)).decode("utf-8")
        print("Generated sessionID", generated_sessionID)

        result_code = cursor.execute("""INSERT INTO `User_sessions` (session_id, Registred_users_userID) values (%s, %s)""", (generated_sessionID, _id), )
        db.commit()

        if result_code != 0:
            a = jsonify(status="ok", reason="cookie_ok", message="Logged in successfully.", sessionid=generated_sessionID)

            response = app.make_response(a)
            response.set_cookie("session_id", value=generated_sessionID)
            print("RESPONSE", response)
            return response
        else:
            return error("error", "loginerror", "An error occurred while trying to log you in.")

    elif result_code is 0:
        return error("error", "badlogin", "The login information you have provided is incorrect. Check your email address and password and try again.")

    return jsonify(status="error", message="REACHED END OF LOGIN() WITHOUT RETURNING BEFORE THAT, THIS SHOULD NEVER HAPPEN.")


@app.route("/register", methods=["POST"])
def register():
    db=MySQLdb.connect(user="root", passwd="asdf", db="cloudchatdb", connect_timeout=30)
    _email = None
    _password = None
    try:
        _email = request.form.get("email").lower() or None # WARNING: make lower() because USER@EXAMPLE.COM is the same as UsER@eXamPle.com !!!!!
        _password = request.form.get("password") or None
    except:
        return jsonify(status="error", reason="email_invalid", message="The email address you have specified is invalid.")

    if is_email_valid(_email) == False: # checking for email's validness automatically already checks if it's empty
        return jsonify(status="error", reason="email_invalid", message="The email address you have specified is invalid.")
    if _password == None:
        return jsonify(status="error", reason="password_empty", message="The password is empty.")

    _email = str(_email).lower()
    _hashed_password = sha512_crypt.encrypt(_password, salt="CodedSaltIsBad")

    cursor = db.cursor()
    cursor.execute("""SELECT (email) FROM `Registered_users` WHERE `email` = %s;""", (_email,))
    exists_result = db.affected_rows()

    if exists_result is not 0:
        return jsonify(status="error", reason="account_exists", message="An account with this email address is already registered,<br>please login instead.")
    elif exists_result is 0:
        _result = cursor.execute("""INSERT INTO `Registered_users` (email, password, isActivated) values (%s, %s, %s);""", (_email, _hashed_password, 1),)
        db.commit()

        if _result == 1:
            return jsonify(status="ok", reason="reg_success", message="Your account was sucessfully registered. You can now login.")
        else:
            return jsonify(status="error", reason="insert_failed", message="Account registration failed.")
    else:
        return jsonify(status="error", reason="insert_failed", message="Account registration failed.")


@app.route("/get_servers", methods=["GET", "POST"])
def get_servers():
    db=MySQLdb.connect(user="root", passwd="asdf", db="cloudchatdb", connect_timeout=30)
    cursor = db.cursor()
    cursor.execute("SHOW TABLES;")

    tables = cursor.fetchall()

    return "get_servers();" + str(tables) + str(request.args.get("lol"))

if __name__ == '__main__':
    app.run(debug=True)