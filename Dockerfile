FROM ubuntu:21.04

# install tools and dependencies
RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y autoconf \
        automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk \
        build-essential bison flex texinfo gperf \
        libtool patchutils bc zlib1g-dev libexpat-dev \
        device-tree-compiler git zsh gcc-riscv64-unknown-elf \
    && rm -rf /var/lib/apt/lists/*

# install riscv-gnu-toolchain
RUN cd $HOME && \
    curl -o riscv https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.12/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14.tar.gz && \
    tar -zxvf riscv && \
    cd /root && touch .zshrc && \
    cd $HOME && \
    rm -r riscv && \
    cd riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14 && \
    cp -r riscv64-unknown-elf /usr && \
    cp ./bin/riscv64-unknown-elf-gdb /usr/bin && \
    rm -r ../riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14 && \
    cd $HOME && \
    git clone --depth=1 https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd ../ && \
    rm -r riscv-isa-sim

# install zsh and zsh plugins
RUN git clone --depth=1 https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    chsh -s /bin/zsh && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git     ~/.oh-my-zsh/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting && \
    sed "s/plugins=(git)/plugins=(git kubectl docker zsh-autosuggestions zsh-syntax-highlighting)/g"  ~/.zshrc

# clone os lab repo
RUN cd /home && \
    mkdir user && \
    cd user && \
    git clone https://gitee.com/hustos/riscv-pke.git && \
    cd riscv-pke && \
    make