FROM alpine:3.15.3

ENV PACKAGES bash curl jq wget

RUN echo "Updating Base System" \
        && apk update \
        && apk upgrade \
        && echo "Install Required Packages" \
        && apk add --no-cache ${PACKAGES} 

CMD ["/bin/bash"]
