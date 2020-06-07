from flask import Flask
from flask_cors import CORS
from flask import request
import json
import logging
import os

app = Flask(__name__)
CORS(app)


@app.route('/')
def hello_world():
    return 'Hello, World!'


@app.route('/seq',methods=["POST"])
def seq():
    try:
        datastr = request.get_data(cache=True, as_text=True)

        dd = json.loads(datastr)["body"]
        with open("./file.json","w") as fou:
            fou.write(dd)

        os.system("python3 readPulp.py")
        return 'ok.'
    except Exception as e:
        app.logger.warning(str(e))
        
