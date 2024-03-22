#!/bin/bash

docker buildx build --platform linux/arm64 --load --target source -t rknn-src:latest .

docker buildx build --platform linux/arm64 --load --target rknn-runtime -t ghcr.io/daedaluz/rknn-runtime:latest .
docker buildx build --platform linux/arm64 --load --target rknn-lite -t ghcr.io/daedaluz/rknn-lite:latest .


docker buildx build --platform linux/arm64 --load --target demo -t ghcr.io/daedaluz/rknn-lite-demo:latest .
docker buildx build --platform linux/arm64 --load --target yolov5-demo -t ghcr.io/daedaluz/rknn-yolov5-demo:latest .

docker push ghcr.io/daedaluz/rknn-runtime:latest
docker push ghcr.io/daedaluz/rknn-lite:latest
docker push ghcr.io/daedaluz/rknn-lite-demo:latest
docker push ghcr.io/daedaluz/rknn-yolov5-demo:latest
