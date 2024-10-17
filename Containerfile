FROM python:3.13.0-alpine3.20

ADD requirements.txt /apps/

RUN set -ex \
    && apk update \
    && apk add --no-cache --virtual .build-deps build-base \
#    && python -m venv /env \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r /apps/requirements.txt \
    && apk add --virtual rundeps openssl-dev gcc postgresql-dev libffi-dev musl-dev \
    && apk del .build-deps
    
WORKDIR /apps
COPY . /apps/

#ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH
#Prevents Python from writing .pyc files to disk, which can save space and reduce I/O operations.
ENV PYTHONDONTWRITEBYTECODE=1
#Ensures that the Python output is sent straight to the terminal (or log) without being buffered, which is useful for debugging and real-time logging
ENV PYTHONUNBUFFERED=1

#ENTRYPOINT ["/bin/sh", "/pyas2/config.sh"]
#CMD ["/usr/local/bin/python", "/apps/manage.py", "runserver", "0.0.0.0:8000"]
CMD ["gunicorn", "pyas2_ocp.wsgi:application", "--bind", "0.0.0.0:8000"]

EXPOSE 8000