# ------------------------
# Stage 1: Build Environment
# ------------------------
FROM almalinux:8 AS builder

# Install development tools, Perl modules, and OpenSSL dev libraries
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install \
        gcc-c++ \
        make \
        cmake \
        git \
        curl \
        wget \
        tar \
        bzip2 \
        gzip \
        xz \
        which \
        file \
        procps \
        perl \
        perl-IPC-Cmd \
        perl-core \
        perl-ExtUtils-MakeMaker \
        openssl-devel \
        && dnf clean all

# Install Rust (latest stable)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js 22 LTS via NodeSource
RUN curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - && \
    dnf install -y nodejs && \
    dnf clean all

# Install pnpm (required to build Weaver UI)
RUN npm install -g pnpm

# Verify versions
RUN rustc --version && cargo --version && node --version && npm --version

# Set working directory
WORKDIR /weaver

# Clone the Weaver repo and checkout v0.21.2
RUN git clone https://github.com/open-telemetry/weaver.git . && \
    git checkout v0.22.1

# Build Weaver UI assets (generates ui/dist used at compile time)
RUN cd ui && \
    pnpm install --frozen-lockfile && \
    pnpm build

# Build Weaver release
RUN cargo build --release

# ------------------------
# Stage 2: Minimal Image with Weaver Binary
# ------------------------
FROM almalinux:8 AS weaver-binary

WORKDIR /weaver

# Copy the Weaver binary from builder stage
COPY --from=builder /weaver/target/release/. .

# Default command: show the Weaver binary
CMD ["./weaver"]

