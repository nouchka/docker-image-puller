FROM python:3.5-slim
MAINTAINER Kévin Darcel <kevin.darcel@gmail.com>

WORKDIR /usr/src/docker-image-updater

COPY app.py requirements.txt /usr/src/docker-image-updater/

RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "app.py"]
