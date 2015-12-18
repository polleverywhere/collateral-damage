FROM node:0.12-slim

# Libs missing from the slim base image
RUN \
  apt-get update && \
  apt-get install -y libgtk2.0-0 libgconf-2-4 \
    libasound2 libxtst6 libxss1 libnss3 xvfb wget fontconfig && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists

# Install OSX fonts
RUN \
  wget https://www.dropbox.com/s/429so48gtf84w39/mac_fonts.tar.gz && \
  tar -xzf mac_fonts.tar.gz && \
  cp -r fonts/ /usr/share/fonts/ && \
  fc-cache -f -v

ADD . /app
WORKDIR /app

RUN rm -rf tmp && rm -rf node_modules && npm install