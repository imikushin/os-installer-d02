FROM aarch64/ubuntu:16.04

ENV TERM=xterm
RUN apt-get update && apt-get install -y parted git gcc make autoconf wget dosfstools

RUN mkdir -p /root && cd /root && \
    wget http://download.open-estuary.org/AllDownloads/DownloadsEstuary/releases/2.2/linux/Common/D02/grubaa64.efi && \
    ( md5sum grubaa64.efi | grep '04bc022152c10ea76bc36ac0dbdd9150' )

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    git clone https://git.linaro.org/people/takahiro.akashi/kexec-tools.git && \
    cd kexec-tools && git checkout kdump/for-14 && ./bootstrap && ./configure && make && make install

COPY ./scripts/installer /scripts

ARG VERSION
ENV VERSION=${VERSION}

RUN : ${VERSION:?"VERSION not set"}

COPY ./dist/artifacts/* /dist/

# check that we have all necessary files
RUN cd /dist && \
    ls initrd > /dev/null && [ "$(ls vmlinu? | wc -l)" = "1" ] && [ "$(ls | grep -E '^.+\.dtb$' | wc -l)" = "1" ] || \
    (echo 'vmlinu[z|x], initrd and .dtb needed' && exit 1)

ENTRYPOINT ["/scripts/lay-down-os"]
