FROM ubuntu:xenial
RUN apt-get -y update && apt-get -y install ruby ruby-dev build-essential git sox libsox-fmt-mp3 ffmpeg python-pip
RUN pip install --upgrade pip && \
    pip install youtube-dl
RUN git clone https://github.com/sashkavalent/cmt && \
    cd cmt && \
    cp secrets.yml.public secrets.yml && \
    gem install bundler && \
    bundle install --without development test
ENTRYPOINT cd cmt && \
           git fetch origin master && \
           git reset --hard origin/master && \
           cp secrets.yml.public secrets.yml
CMD ruby main.rb 'https://www.youtube.com/watch?v=ICz-edsOaFw' 2:46-3:40 3:40-4:30 4:30-5:17 5:17-6:06 6:06-7:00 7:00-7:30 7:30-7:50 8:04-8:32 8:32-8:59 8:59-9:35
