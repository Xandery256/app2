#server.py


import os

#gui import
from flask import Flask, send_from_directory, send_file


#db import
from mysql.connector import connect

app = Flask(__name__)


@app.route('/')
def home():
    with open("homepage.html") as home:
        page = home.read()
        return page



#this part is just for aesthetic to make the app a bit nicer
#it adds an icon to the browser tab
#works with Chrome. Opera seemed to be having trouble
@app.route('/favicon.ico')
def favicon():
    return send_file('favicon.ico')