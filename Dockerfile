FROM docker.io/alpine:3.17
ENV CMARK_VERSION=0.29.0.gfm.8
# hadolint ignore=DL3003, DL3018
RUN apk --no-cache add --virtual build-dependencies curl cmake make gcc g++ \
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
  && rm -rf cmark-gfm-${CMARK_VERSION} \
  && apk del build-dependencies
WORKDIR /work
ENTRYPOINT ["cmark-gfm"]
