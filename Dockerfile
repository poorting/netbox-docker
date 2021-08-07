# docker exec -it 5e57902b199b /bin/bash
FROM python:3.9-slim

RUN apt-get update && apt-get install -y netcat

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create user
RUN adduser --system --group netbox
# create the appropriate directories
ENV HOME=/home/netbox

USER netbox
WORKDIR /home/netbox/

# Create venv and set ENV accordingly
ENV VIRTUAL_ENV=$HOME/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# update pip
RUN pip install --upgrade pip
# install wheel
RUN pip install wheel

COPY netbox/requirements.txt $HOME

RUN pip install --requirement requirements.txt

COPY --chown=netbox:netbox netbox/netbox/ $HOME/netbox/.
COPY --chown=netbox:netbox django/configuration.py $HOME/netbox/netbox/.

# copy entrypoint.sh
COPY django/entrypoint.sh $HOME

WORKDIR /home/netbox/netbox

ENTRYPOINT ["/home/netbox/entrypoint.sh"]

#WORKDIR /

#EXPOSE 80

#ENV PATH=/usr/sbin:$PATH
#CMD ["nginx", "-g", "daemon off;"]
