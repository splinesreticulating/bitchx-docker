FROM debian:bookworm-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools
RUN apt-get update && apt-get install -y \
    git build-essential automake autoconf \
    libssl-dev libncurses-dev ca-certificates \
    cpio \
    && rm -rf /var/lib/apt/lists/*

# Clone BitchX 1.3
WORKDIR /src
RUN git clone https://github.com/BitchX/BitchX1.3.git .

# New block with explicit LDFLAGS for SSL compatibility
RUN ./autogen.sh && \
    ./configure --with-ssl --with-plugins --prefix=/usr/local LDFLAGS="-Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic" && \
    make && \
    make install

# --- Final Stage ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 libncurses6 ca-certificates \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Setup User Arguments
ARG USER_ID
ARG GROUP_ID
ARG USER_NAME=mute

# Create the matching user
RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USER_NAME}

# Copy compiled BitchX from builder
COPY --from=builder /usr/local /usr/local

# Switch to user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
RUN mkdir -p /home/${USER_NAME}/.BitchX /home/${USER_NAME}/osiris

# Copy entrypoint script
COPY --chown=${USER_NAME}:${USER_NAME} entrypoint.sh /home/mute/entrypoint.sh
RUN chmod +x /home/mute/entrypoint.sh

# Copy custom server list to home directory (BitchX checks here first)
COPY --chown=${USER_NAME}:${USER_NAME} config/.ircservers /home/mute/.ircservers

ENTRYPOINT ["/home/mute/entrypoint.sh"]
