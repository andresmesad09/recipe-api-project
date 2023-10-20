FROM python:3.9-alpine3.13

LABEL maintainer="andresmesad"

# Don't buffer the output - prevent delays
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app/ /app
WORKDIR /app
EXPOSE 8080

ARG DEV=false
# create a virtual environment to store dependencies
RUN python -m venv /py && \
    # update pip
    /py/bin/pip install --upgrade pip && \
    # install requirements.txt recursively
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Check if it's dev to install dev dependencies
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ;\
    fi && \
    # delete tmp folder - keep docker images as lightweight as possible
    rm -rf /tmp/ && \
    # Add django-user - if we don't this, the only user will be root
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

# swtich to django-user
USER django-user
