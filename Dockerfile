ARG DEBIAN_IMAGE=debian:bookworm-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251
ARG BITCHX_REF=b081e19913f2236c19d0cd710af103b38c0cf704

FROM ${DEBIAN_IMAGE} AS builder
ARG BITCHX_REF
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools
RUN apt-get update && apt-get install -y \
    git build-essential automake autoconf \
    libssl-dev libncurses-dev ca-certificates \
    cpio \
    && rm -rf /var/lib/apt/lists/*

# Fetch the reviewed BitchX 1.3 revision.
WORKDIR /src
RUN git init . && \
    git remote add origin https://github.com/BitchX/BitchX1.3.git && \
    git fetch --depth=1 origin "${BITCHX_REF}" && \
    git checkout --detach FETCH_HEAD

# New block with explicit LDFLAGS for SSL compatibility
RUN ./autogen.sh && \
    ./configure --with-ssl --with-plugins --prefix=/usr/local LDFLAGS="-Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic" && \
    make && \
    make install

# --- Final Stage ---
FROM ${DEBIAN_IMAGE}

RUN apt-get update && apt-get install -y \
    libssl3 libncurses6 ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Setup User Arguments
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=you

# Create the matching user. Reuse a base-image group when the host GID already
# exists (for example, macOS uses GID 20 for staff).
RUN if ! getent group "${GROUP_ID}" >/dev/null; then \
        groupadd -g "${GROUP_ID}" "${USER_NAME}"; \
    fi && \
    useradd -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash "${USER_NAME}"

# Copy compiled BitchX from builder
COPY --from=builder /usr/local /usr/local

# Copy entrypoint script (as root, before USER switch)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
RUN mkdir -p /home/${USER_NAME}/.BitchX /home/${USER_NAME}/osiris

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
