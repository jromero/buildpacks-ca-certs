ARG BUILDER
FROM ${BUILDER}

ARG USER

USER root

COPY certs/** /usr/local/share/ca-certificates/
RUN update-ca-certificates

USER ${USER}