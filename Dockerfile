FROM container-registry.oracle.com/os/oraclelinux:9-slim AS builder
ENV CMARK_VERSION=0.29.0.gfm.10
# hadolint ignore=DL3003, DL3041
RUN microdnf -y install  curl cmake make gcc g++ \
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

FROM container-registry.oracle.com/os/oraclelinux:9-slim
COPY --from=builder /usr/local/ /usr/local/
ENV LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /work
ENTRYPOINT ["cmark-gfm"]
