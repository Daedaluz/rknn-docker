#!/bin/bash
docker buildx build -t ghcr.io/daedaluz/rknn-sample-app:latest --platform linux/arm64 --load .
docker push ghcr.io/daedaluz/rknn-sample-app:latest