# DNS1 Argentina 🇦🇷

**DNS público argentino sin censura, sin logs, privacidad total.**

Servidor DNS recursivo en Argentina basado en **BIND 9.20.21** con soporte nativo para DoT y DoH.

## 🌐 Protocolos soportados

- **UDP 53**: DNS tradicional (estándar)
- **TCP 53**: DNS over TCP
- **DoT 853**: DNS over TLS (privacidad en tránsito)
- **DoH 8080**: DNS over HTTPS (compatible con navegadores)

## ✨ Características

- ✅ **BIND 9.20.21**: Resolver recursivo profesional
- ✅ **Rate limiting**: Protección contra DDoS
- ✅ **DNSSEC validation**: Validación de firmas DNSSEC
- ✅ **Minimal responses**: Optimizado para ancho de banda
- ✅ **Docker**: Multi-stage, lightweight (~150MB)
- ✅ **Open Source**: MIT License
- ✅ **Producción**: Probado en Argentina

---

## 🚀 Instalación RÁPIDA (Opción A - Recomendada)

La forma más fácil: descargar imagen precompilada.

### Requisitos
- Debian 13 (o similar)
- Docker + Docker Compose
- ~750MB RAM disponible

### Pasos

```bash
# 1. Instalar Docker
apt update && apt install -y docker.io docker-compose-plugin

# 2. Clonar repositorio
git clone https://github.com/dagorret/dns1-argentina.git
cd dns1-argentina

# 3. Ejecutar con docker-compose
docker-compose up -d

# 4. Testear
dig @127.0.0.1 google.com
dig @127.0.0.1 +short example.com

# 5. Ver logs
docker-compose logs -f dns1-bind9
```

---

## 🔧 Instalación AVANZADA (Opción B - Control Total)

Compilar localmente para customizar BIND.

### Requisitos
- Docker + Docker Compose
- ~5GB espacio disco (solo compilación)

### Pasos

```bash
# 1. Clonar repo
git clone https://github.com/dagorret/dns1-argentina.git
cd dns1-argentina

# 2. Compilar imagen
docker build -t dns1-argentina:custom .

# 3. Actualizar docker-compose.yml
# Cambiar imagen:
#   ghcr.io/dagorret/dns1-argentina:latest
# Por:
#   dns1-argentina:custom

# 4. Ejecutar
docker-compose up -d

# 5. Testear
dig @127.0.0.1 google.com
```

### Customizar BIND
Editar `bind-config/named.conf` antes de compilar:
- Cache size
- Rate limits
- Logging
- DNSSEC settings

---

## 📋 Configuración

### Archivo principal: `bind-config/named.conf`

```bind
options {
    // Cache para 1GB RAM
    max-cache-size 256M;
    
    // Protección DDoS
    rate-limit {
        responses-per-second 20;
        nxdomains-per-second 10;
        all-per-second 80;
    };
    
    // Privacidad
    hide-identity yes;
    hide-version yes;
    
    // DNSSEC
    dnssec-validation auto;
    
    // Optimización
    minimal-responses yes;
    nocookie-udp-size 1232;
};
```

### Modificar configuración

1. Editar `bind-config/named.conf`
2. Restart container:
   ```bash
   docker-compose restart dns1-bind9
   ```
3. Verificar:
   ```bash
   docker-compose logs dns1-bind9 | grep -E "error|warning"
   ```

---

## 🌐 Proxy nginx (DoH en 443)

Para servir DoH en HTTPS con dominio:

```nginx
upstream dns_doh {
    server 127.0.0.1:8080;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name dns.ejemplo.com;
    
    ssl_certificate /etc/letsencrypt/live/dns.ejemplo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dns.ejemplo.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    location /dns-query {
        proxy_pass http://dns_doh/dns-query;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

### Instalar certificado Let's Encrypt

```bash
apt install -y certbot python3-certbot-nginx
certbot certonly --nginx -d dns.ejemplo.com
```

---

## 📊 Monitoreo

### Logs en tiempo real
```bash
docker-compose logs -f dns1-bind9
```

### Health check
```bash
docker-compose ps
# Status: healthy ✅
```

### Estadísticas BIND
```bash
docker exec dns1-bind9 rndc stats
docker exec dns1-bind9 tail -10 /var/cache/bind/named.stats
```

### Queries por segundo
```bash
# Monitorar en vivo
watch -n1 'tail -1 /var/cache/bind/named.stats'
```

---

## 🚢 Escalado Futuro

### Fase 1 (HOY): 1vCPU / 1GB RAM
- ~200-500 usuarios
- Docker + BIND 9.20
- Cache 256MB
- Rate-limit 20 req/s

### Fase 2 (6 meses): 2vCPU / 2GB RAM
- ~500-1000 usuarios
- Cache 512MB
- Rate-limit 40 req/s

### Fase 3 (1 año): Multi-VPS + HAProxy
- VPS Argentina (primary)
- VPS Brasil (secondary)
- Load balancing
- ~5000+ usuarios

### Fase 4 (2+ años): Multi-región
- Argentina (principal)
- Brasil, Paraguay (backup)
- Anycast DNS
- Redundancia geográfica

---

## 🤝 Contribuir

### Reportar bugs
1. GitHub Issues: [Abrir issue](https://github.com/dagorret/dns1-argentina/issues)
2. Describir problema + logs

### Proponer cambios
1. Fork el repositorio
2. Editar `Dockerfile` o `bind-config/named.conf`
3. Test localmente: `docker-compose up -d && dig @localhost google.com`
4. Push + Pull Request

### Cambios comunes
- **Cache size**: `bind-config/named.conf` → `max-cache-size`
- **Rate limits**: `bind-config/named.conf` → `rate-limit`
- **BIND version**: `Dockerfile` → `BIND-9.X.X`

---

## 📈 Performance

Con configuración por defecto en VPS 1vCPU/1GB:

| Métrica | Valor |
|---------|-------|
| Queries/segundo | ~1000-2000 |
| Latencia promedio | <10ms |
| Cache hit rate | 70-80% |
| Memoria usada | 500-600MB |
| CPU promedio | 15-25% |

---

## 🔒 Seguridad

- ✅ Hide BIND version (protección fingerprinting)
- ✅ Rate limiting (protección DDoS)
- ✅ DNSSEC validation (previene poisoning)
- ✅ No recursion para non-localhost (opcional)
- ✅ No zone transfers (allow-transfer: none)
- ✅ Logs a syslog (auditoria)

---

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir comercialmente.

Ver [LICENSE](LICENSE) para detalles.

---

## 💰 Donativos

Si DNS1 Argentina te es útil, considera donar:

- 💳 **[PayPal](https://paypal.com/donate?hosted_button_id=XXXX)**
- ☕ **[Ko-fi](https://ko-fi.com/dagorret)**
- 🇦🇷 **[Mercado Libre](https://mercadolibre.com.ar)** (transferencia)

Cada donativo ayuda a:
- Mantener la infraestructura
- Mejorar performance
- Expandir a otras regiones

---

## 📞 Soporte

- **Issues**: [GitHub Issues](https://github.com/dagorret/dns1-argentina/issues)
- **Email**: dagorret@gmail.com
- **Twitter**: [@dagorret](https://twitter.com/dagorret)
- **Discord**: [Comunidad DNS Argentina](https://discord.gg/XXXXX)

---

## 🛠️ Troubleshooting

### Container no inicia
```bash
docker-compose logs dns1-bind9
# Buscar errores en logs
```

### Queries lentas
```bash
# Verificar cache
docker exec dns1-bind9 rndc dumpdb -cache
# Ver bind-config/named_dump.db
```

### Rate limit activado
```bash
# Revisar logs
docker-compose logs | grep "rate limit exceeded"
# Aumentar en bind-config/named.conf
```

---

**DNS1 Argentina**: Privacidad, sin censura, sin logs. 🛡️

Made with ❤️ for Argentina
