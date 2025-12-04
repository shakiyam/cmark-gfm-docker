FROM debian:trixie-slim AS builder
ENV CMARK_VERSION=0.29.0.gfm.13
# hadolint ignore=DL3003,DL3008
RUN apt-get update && apt-get install -y --no-install-recommends curl cmake make gcc g++ ca-certificates \
  && curl -sSL https://github.com/github/cmark/archive/${CMARK_VERSION}.tar.gz -o cmark_${CMARK_VERSION}.tar.gz \
  && tar xzf cmark_${CMARK_VERSION}.tar.gz \
  && cd cmark-gfm-${CMARK_VERSION} \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make \
  && make test \
  && make install \
  && cd ../.. \
  && rm -rf cmark-gfm-${CMARK_VERSION}

FROM debian:trixie-slim
COPY --from=builder /usr/local/ /usr/local/
ENV LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /work
ENTRYPOINT ["cmark-gfm"]
