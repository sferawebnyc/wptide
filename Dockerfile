FROM alpine:3.7

MAINTAINER XWP <engage@xwp.co>

# Disable Lighthouse error reporting.
ENV CI true

# Copy the shell script.
COPY bin/lh /usr/bin/lh

# Install software.
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps \
        nodejs-npm \
    && apk add --no-cache --update --virtual .persistent-deps \
        chromium@community \
        grep \
        nodejs \
        ttf-freefont \
        udev \
    && npm i lighthouse -g \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf /var/lib/apk/lists/* /usr/share/doc/* /usr/share/man/* /usr/share/info/* /var/cache/apk/* \
    && chmod +x /usr/bin/lh

# Add the executable.
ADD bin/lh-server /

# Run the executable.
CMD ["/lh-server"]