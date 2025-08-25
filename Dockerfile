FROM alpine:3.22.0

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    build-essential \
    pkg-config \
    libssl-dev \
    git-all \
    protobuf-compiler \
    libatomic1 \
    libclang-dev \
    lz4 \
    make \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /apps

RUN curl -sSf https://cli.nexus.xyz/ -o install.sh
RUN chmod +x install.sh
RUN NONINTERACTIVE=1 ./install.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]