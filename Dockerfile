FROM debian:12.1-slim as builder

ARG ANKI_VERSION=2.1.65
ARG ANKI_PACKAGE=anki-2.1.65-linux-qt6

RUN apt-get update && apt-get install -y wget zstd xdg-utils

RUN wget "https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/${ANKI_PACKAGE}.tar.zst"
RUN zstd -d ${ANKI_PACKAGE}.tar.zst && tar -xvf ${ANKI_PACKAGE}.tar
RUN cd ${ANKI_PACKAGE} && ./install.sh

FROM debian:12.1-slim

# Set the locale
RUN apt-get update && apt-get install -y locales

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
LANGUAGE=en_US:en \
LC_ALL=en_US.UTF-8

COPY --from=builder /usr/local/share/anki /usr/local/share/anki

EXPOSE 8080

CMD ["/usr/local/share/anki/anki", "--syncserver"]
