FROM golang:1-stretch

RUN go get -d -u github.com/privacybydesign/irmago
RUN go get -u github.com/golang/dep/cmd/dep
RUN apt-get update && apt-get install gettext-base

WORKDIR $GOPATH/src/github.com/privacybydesign/irmago

RUN go install ./irma

ADD ./configuration /configuration
ADD ./tools /tools
ADD entrypoint.bash entrypoint.bash


ENV HOST_URL "https://localhost:8080/"
ENV JWT_ISSUER "gids"
ENV JWT_PUBLIC_KEY ""
ENV JWT_PUBLIC_KEY_FILE "/configuration/jwt_public.pem"
ENV JWT_PRIVATE_KEY ""
ENV JWT_PRIVATE_KEY_FILE "/configuration/jwt_private.pem"
ENV CLIENT_KEY "testsp"
ENV CLIENT_SECRET ""
ENV SCHEMES="https://privacybydesign.foundation/schememanager/pbdf"
ENV DEBUG 0

EXPOSE 8080

ENTRYPOINT ["bash", "entrypoint.bash"]


