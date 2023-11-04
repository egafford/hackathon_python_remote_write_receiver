brew install protobuf

mkdir prompb_protobuf
pushd prompb_protobuf
git clone git@github.com:gogo/protobuf.git
git clone git@github.com:prometheus/prometheus.git

mkdir -p gogoproto
cp -Rf protobuf/gogoproto/* ./gogoproto
cp prometheus/prompb/*.proto .

protoc --python_out=. gogoproto/gogo.proto
protoc -I=./ -I=./gogoproto --python_out=./ gogoproto/gogo.proto ./types.proto
protoc -I=. --python_out=./ ./remote.proto

rm -Rf protobuf/ prometheus/
touch __init__.py
touch gogoproto/__init__.py
popd
