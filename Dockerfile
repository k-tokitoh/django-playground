# pull official base image
FROM python:3.11.5-slim-bookworm

# set work directory
WORKDIR /usr/src/app

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt


# copy project
COPY ./awesome-django-project .
