# RKNN Sample app

This is a small fast-api based web-app, heavily modified from an example provided from rknn-toolkit2 hosting the `mobilenet_v2_for_rk3588.rknn` 
model with a simple Web-UI to take pictures and then run the inference on the accellerator.

The app has to be hosted over tls / ssl because the use of getUserMedia api.

## Running
```
docker run --rm -ti --privileged \
            -v /dev/dri/renderD129:/dev/dri/renderD129 \
            -v /proc/device-tree/compatible:/proc/device-tree/compatible \
            ghcr.io/daedaluz/rknn-sample-app
```