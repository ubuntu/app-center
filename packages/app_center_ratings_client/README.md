# Dart Client for Ubuntu App Ratings Service 

## Generating protos:

```shell
protoc \
    --dart_out=grpc:./lib/src/generated \
    -I./protos \
    ./protos/ratings_features_user.proto google/protobuf/timestamp.proto google/protobuf/empty.proto
```

```shell
protoc --dart_out=grpc:lib/src/generated -Iprotos protos/ratings_features_chart.proto
```

```shell
protoc --dart_out=grpc:lib/src/generated -Iprotos protos/ratings_features_app.proto 
```
