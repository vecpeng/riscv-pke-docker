FROM ubuntu:21.04

# install tools and dependencies
RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y autoconf \
        automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk \
        build-essential bison flex texinfo gperf \
        libtool patchutils bc zlib1g-dev libexpat-dev \
        device-tree-compiler git \
        gcc-riscv64-unknown-elf

# clone and build newlib for riscv64-unknown-elf-gcc
# clone and build spike
# and remove them
RUN git clone --depth=1 https://github.com/riscv/riscv-newlib.git && \
    cd /riscv-newlib && \
    mkdir build && \
    cd build && \
    ../configure  --target=riscv64-unknown-elf && \
    make -j$(nproc) && \
    make install && \
    cd /usr/local && \
    cp -r riscv64-unknown-elf ../ && \
    rm -r riscv64-unknown-elf

RUN cd / && rm -r riscv-newlib && \
    git clone --depth=1 https://github.com/riscv/riscv-isa-sim.git && \
    cd /riscv-isa-sim && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr/local && \
    make && \
    make install && \
    cd / && rm -r riscv-isa-sim

# clone os lab repo
RUN cd $HOME && \
    git clone https://gitee.com/hustos/riscv-pke.git && \
    cd riscv-pke && \
    make