# DNS1 Argentina - Producción

## 🚀 STATUS: OPERATIVO

**Fecha**: 15 de mayo de 2026  
**IP**: 138.36.239.70  
**Puerto**: 53 (UDP/TCP)  
**Estado**: ✅ EN PRODUCCIÓN

---

## 📋 ESPECIFICACIONES

### Hardware
- **VPS**: 1 vCPU, 1GB RAM
- **SO**: Debian 13 (Stable)
- **Docker**: 29.5.0

### Software
- **BIND**: 9.20.21 (compilado)
- **Imagen**: ghcr.io/dagorret/dns1.com.ar:v1.1.0
- **Repositorio**: https://github.com/dagorret/dns1-argentina

### Configuración
- **Cache**: 256MB
- **DNSSEC**: Auto validation
- **Rate-limit**: 500 qps
- **Workers**: 1 (1vCPU)
- **Query randomize**: activo
- **CPU limit**: 0.9 (90%)

---

## 📊 ESTADÍSTICAS OPERACIONALES

### Métricas actuales
```
IPv4 queries procesadas: 9167
Cache hits: 40667 (99.8%)
Cache misses: 52 (0.2%)
DNSSEC validation succeeded: 1191
DNSSEC validation failed: 16
RTT < 10ms: 1713 queries
RTT 10-100ms: 3315 queries
Sockets activos: 11
```

### Performance
- **Cache hit ratio**: 99.8% ✅
- **RTT promedio**: < 100ms ✅
- **Uptime**: Continuo ✅
- **CPU usage**: 8-12% promedio ✅

---

## 🛡️ SEGURIDAD

### Firewall (UFW)
```
Status: active
Puertos abiertos:
├─ 53/udp (DNS)
├─ 53/tcp (DNS)
├─ 5743/tcp (SSH)
├─ 80/tcp (HTTP)
└─ 443/tcp (HTTPS)
```

### SSH
- **Puerto**: 5743
- **PermitRootLogin**: no
- **Autenticación**: password (motorola)
- **fail2ban**: activo

### DNSSEC
- **Validation**: auto
- **Status**: 1191 validaciones exitosas
- **Failed**: 16 (expected)

### Rate-limiting
```
responses-per-second: 500
nxdomains-per-second: 100
errors-per-second: 50
all-per-second: 1000
window: 15 segundos
slip: 2 (drop 50%)
```

---

## 🔧 OPERACIÓN

### Comandos útiles

```bash
# Ver estadísticas
./stats.sh

# Monitoreo en vivo
./live.sh

# Ver logs
docker compose logs -f dns1-bind9

# Recargar configuración
docker compose exec dns1-bind9 rndc reload

# Flush cache
docker compose exec dns1-bind9 rndc flush

# Restart
docker compose restart dns1-bind9

# Actualizar imagen
docker compose pull
docker compose up -d --force-recreate
```

### Testing

```bash
# Desde cualquier lugar
dig @138.36.239.70 google.com
dig @138.36.239.70 mit.edu
dig @138.36.239.70 cloudflare.com

# Load test (dns-crusher)
target/release/dns-crusher -s 138.36.239.70:53 -n 5000 -t 400 -d 0.05
```

---

## 📦 DEPLOYMENT

### Estructura VPS
```
~/work/bind9/dockers/dns/
├─ docker-compose.yml
├─ bind-config/
│  ├─ named.conf
│  └─ db.root
├─ stats.sh
└─ live.sh
```

### docker-compose.yml
```yaml
services:
  dns1-bind9:
    image: ghcr.io/dagorret/dns1.com.ar:v1.1.0
    container_name: dns1-bind9
    restart: always
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "853:853/tcp"
      - "8080:8080/tcp"
    volumes:
      - ./bind-config:/etc/bind
      - dns-cache:/var/cache/bind
      - dns-run:/var/run/named
    deploy:
      resources:
        limits:
          cpus: '0.9'
          memory: 512M

volumes:
  dns-cache:
  dns-run:
```

### named.conf (optimizado)
```bind
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { none; };
    recursion yes;
    allow-recursion { any; };
    max-cache-size 256M;
    query-source port * address *;
    dnssec-validation auto;
    rate-limit {
        responses-per-second 500;
        nxdomains-per-second 100;
        errors-per-second 50;
        all-per-second 1000;
        window 15;
        slip 2;
        qps-scale 250;
        ipv4-prefix-length 32;
        ipv6-prefix-length 56;
    };
    prefetch 3600;
    querylog no;
};

zone "." IN {
    type hint;
    file "/etc/bind/db.root";
};

logging {
    channel default_syslog {
        syslog local2;
        severity notice;
    };
    category default {
        default_syslog;
    };
};
```

---

## 🚀 PRÓXIMOS PASOS

### Fase 2 (Corto plazo)
- [ ] DoH (DNS over HTTPS) en puerto 443
- [ ] DoT (DNS over TLS) en puerto 853
- [ ] Certificado Let's Encrypt
- [ ] nginx proxy para DoH

### Fase 3 (Mediano plazo)
- [ ] Página web (dagorret.online)
- [ ] Documentación pública
- [ ] Sistema de donaciones
- [ ] Migración a dns1.com.ar

### Fase 4 (Largo plazo)
- [ ] Multi-VPS (HA)
- [ ] Multi-región (Argentina/Brasil)
- [ ] Anycast network
- [ ] Estadísticas públicas

---

## 📈 ESCALABILIDAD

### Limitaciones actuales (1vCPU/1GB)
- **Máximo**: 400-500 qps
- **CPU límite**: 90% (0.9)
- **Cache**: 256MB
- **RTT**: < 10-100ms

### Upgrade a 2vCPU/2GB
```
Máximo esperado: 1000+ qps
CPU límite: 1.8
Cache: 512M-1GB
RTT: < 5-50ms
```

### Load balancer (Multi-VPS)
```
3x VPS 2vCPU:
├─ 3000+ qps
├─ HAProxy frontend
├─ Redundancia geográfica
└─ Failover automático
```

---

## 📞 SOPORTE

### GitHub
- Repo: https://github.com/dagorret/dns1-argentina
- Issues: https://github.com/dagorret/dns1-argentina/issues
- Releases: https://github.com/dagorret/dns1-argentina/releases

### Acceso VPS
```bash
ssh -p 5743 motorola@138.36.239.70
```

### Monitoreo
```bash
# En VPS
./stats.sh    # Ver estadísticas
./live.sh     # Monitoreo en vivo
```

---

## 🎯 FILOSOFÍA

**DNS1 Argentina**: DNS público argentino sin censura, sin logs, privacidad total.

- ✅ Recursivo puro (sin forwarders)
- ✅ Sin logs de queries
- ✅ DNSSEC validado
- ✅ Rate-limited (anti-DDoS)
- ✅ Open source (MIT License)
- ✅ Gratuito para usuarios

---

## 📝 VERSIONES

| Versión | Fecha | Cambios |
|---------|-------|---------|
| v1.1.0 | 15-May-2026 | Cache 256M, DNSSEC auto, rate-limit |
| v1.0.0 | 14-May-2026 | Release inicial, BIND 9.20.21 |
| v0.0.1 | 14-May-2026 | Testing, multi-stage Docker |

---

## 📄 LICENCIA

MIT License - https://github.com/dagorret/dns1-argentina/blob/main/LICENSE

---

**DNS1 Argentina - Privacidad, sin censura, sin logs** 🛡️  
**Actualizado**: 15 de mayo de 2026
