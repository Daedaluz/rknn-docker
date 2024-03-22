from typing import Annotated
import cv2
import numpy as np
import platform
from synset_label import labels
from rknnlite.api import RKNNLite

from fastapi import FastAPI, UploadFile
from fastapi.staticfiles import StaticFiles
import json
import ssl

app = FastAPI()

INPUT_SIZE = 224

RK3588_RKNN_MODEL = 'mobilenet_v2_for_rk3588.rknn'

def show_top5(result):
    output = result[0].reshape(-1)
    # Get the indices of the top 5 largest values
    output_sorted_indices = np.argsort(output)[::-1][:5]
    top5_str = '-----TOP 5-----\n'
    res = []
    for i, index in enumerate(output_sorted_indices):
        value = output[index]
        res.append({"score": json.dumps(eval(str(value))), "class": labels[index]})
        if value > 0:
            topi = '[{:>3d}] score:{:.6f} class:"{}"\n'.format(
                index, value, labels[index])
        else:
            topi = '-1: 0.0\n'
        top5_str += topi
    print(top5_str)
    return res


rknn = RKNNLite()
rknn.load_rknn(RK3588_RKNN_MODEL)
ret = rknn.init_runtime(core_mask=RKNNLite.NPU_CORE_0)
if ret != 0:
    print('Init runtime failed')
    exit(ret)


@app.get("/info")
def read_ai_accellerator_info():
    return {"sdk": rknn.get_sdk_version(), "devices": rknn.list_devices}


@app.post("/infer")
async def infer(file: UploadFile):
    binimg: bytes = await file.read()
    data = np.frombuffer(binimg, dtype=np.uint8)
    img = cv2.imdecode(data, cv2.IMREAD_UNCHANGED)
    real_img = cv2.resize(img, (224, 224))
    real_img = np.expand_dims(real_img, 0)
    real_img = np.transpose(real_img, (0, 3, 1, 2))
    outputs = rknn.inference(inputs=[real_img], data_format=['nchw'])
    # Show the classification results
    res = show_top5(outputs)
    return res

app.mount("/", StaticFiles(directory="ui", html=True), name="ui")
