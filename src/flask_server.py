from flask import Flask, request
from snappy import snappy

import remote_pb2

app = Flask(__name__)


@app.route('/', methods=['POST'])
def receive_remote_write():
    try:
        raw_data = request.data
        decompressed = snappy.uncompress(raw_data)

        read_metric = remote_pb2.WriteRequest()
        message = read_metric.ParseFromString(decompressed)
        with open('message.txt', 'w') as fp:
            fp.write(str(message))
            print(str(message))
    except RuntimeError as e:
        print(e)
    return '', 204
