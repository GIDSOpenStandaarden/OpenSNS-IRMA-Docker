FROM golang:1 as build

ENV CGO_ENABLED=0
ARG IRMA_VERSION="v0.13.2"

RUN git clone -b $IRMA_VERSION https://github.com/privacybydesign/irmago.git
WORKDIR /go/irmago

RUN go build -a -ldflags '-extldflags "-static"' -o "/bin/irma" ./irma

FROM alpine:3.11

COPY --from=build /bin/irma /usr/local/bin/irma

RUN apk update && apk add gettext bash openssl

ADD ./configuration /configuration
ADD ./tools /tools
ADD entrypoint.bash entrypoint.bash

ENV PORT "8080"
ENV HOST_URL "https://localhost:8081/"
ENV ADMIN_EMAIL ""
ENV JWT_ISSUER "gids"
ENV JWT_PUBLIC_KEY ""
ENV JWT_PUBLIC_KEY_FILE "/configuration/jwt_public.pem"
ENV JWT_PRIVATE_KEY ""
ENV JWT_PRIVATE_KEY_FILE "/configuration/jwt_private.pem"
ENV CLIENT_MAP "{}"
ENV EMAIL "info@example.com"
ENV SCHEMES="https://privacybydesign.foundation/schememanager/pbdf"
ENV DEBUG 0

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "entrypoint.bash"]
