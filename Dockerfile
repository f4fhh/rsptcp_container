FROM debian:bullseye-slim as build_rsp_api

ARG SDRPLAY_API=https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-3.07.1.run
ARG BUILD_DIR=/build

RUN apt-get -y update \
    && apt-get -y --no-install-recommends install \
        curl \
        ca-certificates

WORKDIR ${BUILD_DIR}
RUN curl ${SDRPLAY_API} -o SDRplay_RSP_API.run \
    && chmod +x SDRplay_RSP_API.run \
    && ./SDRplay_RSP_API.run --tar -xvf \
    && cp x86_64/libsdrplay_api.so.3.07 /usr/lib/libsdrplay_api.so \
    && cp x86_64/libsdrplay_api.so.3.07 /usr/lib/libsdrplay_api.so.3.07 \
    && cp x86_64/sdrplay_apiService /usr/bin/sdrplay_apiService \
    && cp inc/* /usr/include \
    && chmod 644 /usr/lib/libsdrplay_api.so /usr/lib/libsdrplay_api.so.3.07 /usr/include/* \
    && chmod 755 /usr/bin/sdrplay_apiService
    
FROM debian:bullseye-slim as build_rsptcp

ARG RSP_TCP_REPO=https://github.com/SDRplay/RSPTCPServer
ARG BUILD_DIR=/build

RUN apt-get -y update --no-install-recommends \
    && apt-get -y install \
        libudev-dev \
        libusb-1.0-0-dev \
        git \
        ca-certificates \
        build-essential \
        cmake

COPY --from=build_rsp_api /usr/lib/libsdrplay_api.so /usr/lib/libsdrplay_api.so
COPY --from=build_rsp_api /usr/include/sdrplay_api* /usr/include/

WORKDIR ${BUILD_DIR}
RUN git clone --depth 1 ${RSP_TCP_REPO} . \
    && mkdir build && cd build \
    && cmake .. && make && make install

FROM debian:bullseye-slim

COPY --from=build_rsptcp /usr/local/bin/rsp_tcp /usr/bin/rsp_tcp
COPY --from=build_rsp_api /usr/lib/libsdrplay_api.so /usr/lib/libsdrplay_api.so
COPY --from=build_rsp_api /usr/bin/sdrplay_apiService /usr/bin/sdrplay_apiService
COPY entrypoint.sh /etc/entrypoint.sh

RUN apt-get -y update \
    && apt-get -y install --no-install-recommends \
        tini \
        libusb-1.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /etc/entrypoint.sh

ENTRYPOINT [ "/usr/bin/tini", "--", "/etc/entrypoint.sh" ]
CMD [ "-a", "0.0.0.0" ]
EXPOSE 1234/tcp