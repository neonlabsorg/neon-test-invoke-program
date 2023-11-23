FROM solanalabs/rust:1.61.0 AS builder
RUN rustup toolchain install nightly
RUN rustup component add clippy --toolchain nightly
WORKDIR /opt
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.17.6/install)" && \
    /root/.local/share/solana/install/active_release/bin/sdk/bpf/scripts/install.sh
ENV PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY . /opt
WORKDIR /opt
RUN cargo +nightly clippy &&  cargo build-bpf

FROM ubuntu:20.04

COPY --from=builder /opt/neon_test_invoke_program-keypair.json /opt
COPY --from=builder /opt/target/deploy/neon_test_invoke_program.so /opt
COPY --from=builder /opt/neon-test-invoke-program.sh /opt
COPY --from=builder /root/.local/share/solana/install/active_release/bin/solana /opt/solana/bin/
COPY --from=builder /root/.local/share/solana/install/active_release/bin/solana-keygen /opt/solana/bin/

