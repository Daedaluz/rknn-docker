# Huge repo, so clone with depth 1 and use this layer to get sources only
FROM ubuntu:22.04 AS source
RUN apt update && apt install -y git && git clone --depth 1 https://github.com/rockchip-linux/rknn-toolkit2.git /rknn-toolkit2

# Copy the runtime library and headers to the runtime image.
# useful as a base for running c/c++ applications that use the rknn runtime, no need for the python libraries
FROM ubuntu:22.04 AS rknn-runtime
COPY --from=source /rknn-toolkit2/rknpu2/runtime/Linux/librknn_api/include/* /usr/include/
COPY --from=source /rknn-toolkit2/rknpu2/runtime/Linux/librknn_api/aarch64/librknnrt.so /usr/lib/
RUN ldconfig

# Install the python lite version of the toolkit
FROM rknn-runtime AS rknn-lite
RUN apt update && apt upgrade -y && apt install -y virtualenv 
COPY --from=source /rknn-toolkit2/rknn_toolkit_lite2/packages/rknn_toolkit_lite2-1.6.0-cp310-cp310-linux_aarch64.whl /
RUN pip install /rknn_toolkit_lite2-1.6.0-cp310-cp310-linux_aarch64.whl && \
    rm /rknn_toolkit_lite2-1.6.0-cp310-cp310-linux_aarch64.whl && \
    apt clean

# Copy the examples and install dependencies to the demo image
# This image can be run on the RK3588 for testing the shipped examples.
# `docker run --rm -ti --privileged -v /dev:/dev -v /proc/device-tree:/proc/device-tree ghcr.io/daedaluz/rknn-lite-demo`
FROM rknn-lite AS demo
COPY --from=source /rknn-toolkit2/rknn_toolkit_lite2/examples /demo/lite
COPY --from=source /rknn-toolkit2/rknpu2/examples /demo/rknpu2
RUN apt update && apt install -y cmake libgl1 libglib2.0-0 && apt clean
RUN pip install opencv-python
WORKDIR /demo

##############################

# Build the yolov5 demo from the rknpu example directory
FROM rknn-runtime AS yolov5-demo-builder
COPY --from=source /rknn-toolkit2/rknpu2/examples/3rdparty /3rdparty
COPY --from=source /rknn-toolkit2/rknpu2/examples/rknn_yolov5_demo /yolov5
ADD yolov5/CMakeLists.txt /yolov5
WORKDIR /yolov5
RUN apt update && apt install -y vim cmake build-essential && \
    chmod +x build-linux_RK3588.sh && \
    bash -e ./build-linux_RK3588.sh 
COPY --from=source /rknn-toolkit2/rknpu2/examples/3rdparty/mpp/Linux/armhf/librockchip_mpp.so.1 /yolov5/install/rknn_yolov5_demo_Linux/lib/

# Copy the built demo to a new image to rid build environment and reduce imagesize
# This image should be able to run the yolov5 demo on the RK3588
# `docker run --rm -ti --privileged -v /dev:/dev -v /proc/device-tree:/proc/device-tree ghcr.io/daedaluz/rknn-yolov5:latest`
FROM rknn-runtime AS yolov5-demo
COPY --from=yolov5-demo-builder /yolov5/install/rknn_yolov5_demo_Linux /yolov5_rknn_demo
WORKDIR /yolov5_rknn_demo
CMD ["./rknn_yolov5_demo", "model/RK3588/yolov5s-640-640.rknn", "model/bus.jpg"]