FROM ghcr.io/daedaluz/rknn-lite
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt && \
    apt update && apt install -y libgl1 libglib2.0-0 && \
    apt clean
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000", "--ssl-keyfile", "/app/ssl/key.pem", "--ssl-certfile", "/app/ssl/cert.pem"]