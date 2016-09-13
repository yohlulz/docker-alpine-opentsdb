FROM janeczku/alpine-kubernetes:3.3

ENV TIMEZONE Asia/Tokyo
ENV TSD_MAINTENANCE_VER 2.2.0


###################### timezone
RUN apk add --update tzdata
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
RUN echo "${TIMEZONE}" > /etc/timezone
#############################################

###################### sys
# testing repo
RUN sh -c "echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories"

RUN apk --update add \
    rsyslog \
    bash \
    openjdk8 \
    make \
    wget \
    supervisor \
    jq \
    curl \
    gnuplot@testing

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/bin/

RUN apk --update add --virtual builddeps \
    build-base \
    autoconf \
    automake \
    git \
    python
#############################################

############################## TSD specific
# Switch to root user
USER root

# Install TSD
RUN git clone -b tts_maintenance_v${TSD_MAINTENANCE_VER} --single-branch https://github.com/toraTSD/opentsdb /opt/opentsdb && \
        chmod +x /opt/opentsdb/bootstrap /opt/opentsdb/build.sh /opt/opentsdb/build-aux/*.sh && \
        cd /opt/opentsdb && ./build.sh && \
        mkdir -p /opt/opentsdb/bin /opt/data/cache /opt/data/tsdb /opt/data/tsdb/plugins && \
        ln -s /opt/opentsdb/build/tsdb /opt/opentsdb/bin/tsdb

# Add TSD to path
ENV PATH=/opt/opentsdb/build:$PATH
############################################

############################ Modify configs
ADD etc/conf/* /opt/data/tsdb/
ADD etc/bin/* /opt/opentsdb/bin/
ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/supervisord.d/* /etc/supervisord.d/
###########################################

############################# Cleanup
RUN apk del builddeps && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
###########################################

########################## Expose ports
# TSD
EXPOSE 4242
###########################################


VOLUME ["/opt/data/tsdb", "/opt/data/cache"]

#Start supervisor
CMD ["/opt/opentsdb/bin/startup.sh"]




