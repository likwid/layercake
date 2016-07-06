FROM gliderlabs/alpine

RUN apk --update add python py-pip openssl ca-certificates && \
    apk --update add --virtual build-dependencies python-dev build-base && \
    pip install --upgrade pip ansible boto six httplib2 awscli && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*
