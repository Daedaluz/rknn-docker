# RKNPU Docker images

This repository contains a number of docker images ranging from small, base images only containing the runtime library to
demo containers that are able to run either the python demos or a pre-compiled yolov5 example

Todo: add containers for converting and working with the rknn models

## ghcr.io/daedaluz/rknn-runtime

This image only contains the runtime.

Use as a base for running pre-compiled applications

## ghcr.io/daedaluz/rknn-lite

This image has the rknn-lite python library installed

Use as a base for running python based applications

## ghcr.io/daedaluz/rknn-lite-demo

This image adds the rknn_toolkit_lite2 demos and installs required dependencies for them to run.

On RK3588

``` bash
docker run --rm -ti --privileged \
            -v /dev/dri/renderD129:/dev/dri/renderD129 \
            -v /proc/device-tree/compatible:/proc/device-tree/compatible \
            ghcr.io/daedaluz/rknn-lite-demo
```

Then to run eg. the resnet18 demo

``` bash
cd lite/resnet18
python3 test.py
``` 

## ghcr.io/daedaluz/rknn-yolov5-demo

This image is the pre-built yolov5 example ontop of the `ghcr.io/daedaluz/rknn-runtime` image.

On RK3588

``` bash
docker run --rm -ti --privileged \
            -v /dev/dri/renderD129:/dev/dri/renderD129 \
            -v /proc/device-tree/compatible:/proc/device-tree/compatible \
            ghcr.io/daedaluz/rknn-yolov5-demo
```

Output:

```
post process config: box_conf_threshold = 0.25, nms_threshold = 0.45
Loading mode...
sdk version: 1.6.0 (9a7b5d24c@2023-12-13T17:31:11) driver version: 0.9.2
model input num: 1, output num: 3
  index=0, name=images, n_dims=4, dims=[1, 640, 640, 3], n_elems=1228800, size=1228800, w_stride = 640, size_with_stride=1228800, fmt=NHWC, type=INT8, qnt_type=AFFINE, zp=-128, scale=0.003922
  index=0, name=output, n_dims=4, dims=[1, 255, 80, 80], n_elems=1632000, size=1632000, w_stride = 0, size_with_stride=1638400, fmt=NCHW, type=INT8, qnt_type=AFFINE, zp=-128, scale=0.003860
  index=1, name=283, n_dims=4, dims=[1, 255, 40, 40], n_elems=408000, size=408000, w_stride = 0, size_with_stride=491520, fmt=NCHW, type=INT8, qnt_type=AFFINE, zp=-128, scale=0.003922
  index=2, name=285, n_dims=4, dims=[1, 255, 20, 20], n_elems=102000, size=102000, w_stride = 0, size_with_stride=163840, fmt=NCHW, type=INT8, qnt_type=AFFINE, zp=-128, scale=0.003915
model is NHWC input fmt
model input height=640, width=640, channel=3
Read model/bus.jpg ...
img width = 640, img height = 640
once run use 29.713000 ms
loadLabelName ./model/coco_80_labels_list.txt
person @ (209 244 286 506) 0.884139
person @ (478 238 559 526) 0.867678
person @ (110 238 230 534) 0.824685
bus @ (94 129 553 468) 0.705055
person @ (79 354 122 516) 0.339254
save detect result to ./out.jpg
loop count = 10 , average run  23.933400 ms
```


## ghcr.io/daedaluz/rknn-sample-app

See [sample-app readme](sample-app/README.md)