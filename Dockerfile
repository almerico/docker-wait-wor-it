FROM bash:4.4
MAINTAINER introproventures <github@introproventures.com>

ADD wait-for-it.sh /wait-for-it.sh
RUN chmod a+x /wait-for-it.sh