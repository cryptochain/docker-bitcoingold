FROM debian:stable-slim

ENV HOME /bitcoingold

ENV USER_ID 1000
ENV GROUP_ID 1000
ENV BTG_VERSION=0.15.2

RUN groupadd -g ${GROUP_ID} bitcoingold \
  && useradd -u ${USER_ID} -g bitcoingold -s /bin/bash -m -d /bitcoingold bitcoingold \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://github.com/BTCGPU/BTCGPU/releases/download/v$BTG_VERSION/bitcoin-gold-$BTG_VERSION-x86_64-linux-gnu.tar.gz | tar xz --strip=2 -C /usr/local/bin

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/btg_oneshot

VOLUME ["/bitcoingold"]

EXPOSE 8832 8833

WORKDIR /bitcoingold

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["btg_oneshot"]