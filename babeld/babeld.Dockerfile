ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} AS build

WORKDIR /usr/src/babeld
RUN apk add --no-cache --update alpine-sdk linux-headers
COPY babeld /usr/src/babeld
ARG nproc=1

RUN make -j${nproc} && \
    strip babeld

FROM alpine:${ALPINE_VERSION}
RUN apk add --no-cache --update jq
COPY --from=build /usr/src/babeld/babeld /usr/local/bin/babeld

ENV BABELD_INTERFACES="" \
    BABELD_CONFIG_FILE="" \
    BABELD_STATIC_FILE="/data/babel-state" \
    BABELD_PORT="6696" \
    BABELD_MULTICAST_ADDRESS="" \
    BABELD_HELLO_INTERVAL_WIRELESS="" \
    BABELD_HELLO_INTERVAL_WIRED="" \
    BABELD_HALF_TIME="" \
    BABELD_KERNEL_ROUTE_PRIORITY="" \
    BABELD_EXTERNAL_PRIORITY_THRESHOLD="" \
    BABELD_IFF_RUNNING="" \
    BABELD_ASSUME_ALL_WIRELESS="" \
    BABELD_DISABLE_SPLIT_HORIZON_PROCESSING_WIRED="" \
    BABELD_RANDOMIZE_ROUTER_ID="" \
    BABELD_NO_FLUSH_UNFEASIBLE_ROUTE="" \
    BABELD_DEBUG_LEVEL="" \
    BABELD_LOCAL_CONFIG_SERVER_RO="" \
    BABELD_LOCAL_CONFIG_SERVER_RW="" \
    BABELD_INSERT_TO_TABLE="" \
    BABELD_EXPORT_FROM_TABLES="" \
    BABELD_CONFIG_VERBATIM="" \
    BABELD_DEMONISE="" \
    BABELD_LOGFILE="" \
    BABELD_PID_FILE="" \
    BABELD_EXTRA_OPTIONS=""

VOLUME /data

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
