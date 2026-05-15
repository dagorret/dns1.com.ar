# STAGE 1: Builder - Compilar BIND 9.20.21
FROM debian:13-slim AS builder

RUN apt update && apt install -y \
    build-essential libssl-dev libexpat1-dev libuv1-dev \
    libjson-c-dev libnghttp2-dev libcap-dev pkg-config wget liburcu-dev

WORKDIR /usr/local/src

RUN wget https://downloads.isc.org/isc/bind9/9.20.21/bind-9.20.21.tar.xz && \
    tar xf bind-9.20.21.tar.xz && \
    cd bind-9.20.21 && \
    export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig && \
    ./configure \
      --prefix=/usr/local \
      --sysconfdir=/etc/bind \
      --localstatedir=/var \
      --with-openssl \
      --with-libuv \
      --with-nghttp2 \
      --enable-doh \
      --enable-tls && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /usr/local/src/*

# STAGE 2: Runtime
FROM debian:13-slim

# Instalar TODAS las dependencias de runtime
RUN apt update && apt install -y \
    libssl3 libuv1t64 libnghttp2-14 libjson-c5 libcap2 liburcu8t64 \
    ca-certificates dnsutils wget libc6 libz1 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copiar BINARIOS + LIBRERÍAS compiladas
COPY --from=builder /usr/local /usr/local

# ⭐ CRITICAL: ldconfig para registrar librerías custom
RUN ldconfig -n /usr/local/lib && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/bind9.conf && \
    ldconfig

# Verificar que carga bien
RUN /usr/local/sbin/named -V | head -5

# Crear usuario
RUN groupadd -r named && useradd -r -g named -s /sbin/nologin named

# Directorios
RUN mkdir -p /etc/bind /var/cache/bind /var/run/named /var/bind && \
    wget https://www.internic.net/domain/named.root -O /etc/bind/db.root && \
    chown -R named:named /etc/bind /var/cache/bind /var/run/named /var/bind

EXPOSE 53/udp 53/tcp 853/tcp 443/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD dig @127.0.0.1 google.com || exit 1

CMD ["/usr/local/sbin/named", "-g", "-u", "named", "-c", "/etc/bind/named.conf"]
