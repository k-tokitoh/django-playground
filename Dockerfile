# pull official base image
FROM --platform=linux/amd64 python:3.11.5-slim-bookworm

# set work directory
WORKDIR /usr/src/app

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt


# copy project
COPY ./awesome-django-project .

EXPOSE 80

CMD ["gunicorn", "wsgi", "--bind", "0.0.0.0:80"]
