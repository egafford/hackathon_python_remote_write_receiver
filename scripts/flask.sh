[[ $PYTHONPATH =~ "prom" ]] || PYTHONPATH=$PYTHONPATH:./prompb_protobuf
pip install requirements.txt
flask --app src/flask_server.py run