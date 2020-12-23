import os
import boto3
import smart_open
import traceback

from flask import request, jsonify, json
from flask_lambda import FlaskLambda
from datetime import datetime

import psycopg2
from psycopg2 import extras

from flask_cors import CORS

app = FlaskLambda(__name__)
CORS(app, resources={r"*": {"origins": "*"}})

boto_session = boto3.Session()

def db_connection():
    from urllib.parse import urlparse
    result = urlparse(os.environ['DB_URL'])

    username = result.username
    password = result.password
    database = result.path[1:]
    hostname = result.hostname

    return psycopg2.connect(dbname=database,
                            user=username,
                            password=password,
                            host=hostname)


@app.route('/events/', methods=('POST',))
def handle_event():
    req_data = request.get_json()

    now = datetime.utcnow()
    key_opts = {
        'bucket_name': os.environ['BUCKET_NAME'],
        'year': now.year,
        'month': now.month,
        'day': now.day,
        'hour': now.hour,
        'filename': now.strftime('%H%M%S') 
    }

    s3_url = "s3://{bucket_name}/sendgrid-events/{year}/{month}/{day}/{hour}/{filename}.json".format(**key_opts)
    with smart_open.open(s3_url, 'wb', transport_params={'session': boto_session}) as fout:
        fout.write(json.dumps(req_data).encode())


    return jsonify({'message': 'Success'})