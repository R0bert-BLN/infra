FROM ghcr.io/opentofu/opentofu:1.13.9-minimal AS tofu
FROM alpine:3.22

RUN  apk add --no-cache ca-certificates git

COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

ENTRYPOINT ["tofu"]
