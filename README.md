# DoH (DNS over HTTPS) - Setup Completo

Este proyecto contiene todo lo necesario para instalar y configurar un servidor **DNS over HTTPS (DoH)** en Debian/Ubuntu.

## 📦 Archivos Incluidos

| Archivo | Descripción |
|---------|-------------|
| `MANUAL_DoH_SETUP.md` | Manual detallado (arquitectura, configuración, troubleshooting) |
| `install-doh.sh` | Script de instalación automática |
| `uninstall-doh.sh` | Script de desinstalación y limpieza |
| `README.md` | Este archivo |

## 🚀 Inicio Rápido

### Requisitos
- Debian 12+ o Ubuntu 22.04+
- 1 vCPU y 1GB RAM mínimo
- Dominio con certificado SSL válido (Let's Encrypt)
- Acceso root

### Instalación en 1 línea

```bash
sudo bash install-doh.sh
```

El script te pedirá:
1. Tu dominio (ej: dns.ejemplo.com)
2. Verificará que tengas certificados Let's Encrypt

Luego instalará y configurará automáticamente:
- **Unbound** en puerto 53 (DNS tradicional)
- **doh-server** en puerto 443 (DNS over HTTPS)

### Verificación

Después de instalar, prueba con:

```bash
# DNS tradicional (UDP 53)
dig @tu-dominio.com google.com

# DoH (HTTPS 443)
kdig +https @tu-dominio.com google.com
curl 'https://tu-dominio.com/dns-query?dns=AAAA'
```

## 📋 ¿Qué hace cada componente?

```
┌─────────────┐
│   Cliente   │ (curl, kdig, navegador)
└──────┬──────┘
       │ HTTPS:443
       ▼
┌──────────────────┐
│  doh-server      │ ⭐ CONVIERTE HTTPS → DNS
│  (m13253/DoH)    │
└──────┬───────────┘
       │ UDP:53
       ▼
┌──────────────────┐
│  Unbound         │ Resolutor DNS
└──────────────────┘
```

## 🔧 Configuración Manual

Si prefieres hacer todo manualmente, sigue los pasos en `MANUAL_DoH_SETUP.md`.

Puntos clave de configuración:

**Unbound** (`/etc/unbound/unbound.conf.d/doh.conf`):
```
interface: 0.0.0.0
port: 53
access-control: 0.0.0.0/0 allow
num-threads: 1  # 1 vCPU
msg-cache-size: 64m
rrset-cache-size: 128m
```

**doh-server** (`/etc/doh-server.conf`):
```
listen = ["0.0.0.0:443"]
upstream = ["udp:127.0.0.1:53"]
cert = "/etc/letsencrypt/live/tu-dominio.com/fullchain.pem"
key = "/etc/letsencrypt/live/tu-dominio.com/privkey.pem"
```

## 📊 Monitoreo

### Ver estado
```bash
systemctl status unbound doh-server
```

### Ver logs
```bash
journalctl -u unbound -u doh-server -f
```

### Estadísticas DNS
```bash
unbound-control stats
```

## 🧹 Desinstalación

Para remover completamente:

```bash
sudo bash uninstall-doh.sh
```

O manualmente:

```bash
systemctl stop unbound doh-server
systemctl disable unbound doh-server
apt remove -y unbound
rm -rf /etc/unbound /etc/doh-server.conf /usr/local/bin/doh-server
systemctl daemon-reload
```

## 🐛 Troubleshooting

### "Port 53 already in use"
```bash
lsof -i :53
killall systemd-resolved  # Si es necesario
systemctl restart unbound
```

### "Certificate not found"
Asegúrate de que Let's Encrypt tiene certificados:
```bash
ls -la /etc/letsencrypt/live/tu-dominio.com/
```

### DoH no responde
```bash
# Verificar que Unbound responde
dig @127.0.0.1 google.com

# Ver logs
journalctl -u doh-server -n 30
```

Más soluciones en `MANUAL_DoH_SETUP.md`

## 📚 Información Técnica

- **Unbound:** Resolutor DNS caché, optimizado para bajo recurso
- **dns-over-https:** Implementación de RFC 8484 (DoH)
- **Compilación:** Go 1.20+, automática en script

## 🔐 Seguridad

- ✅ TLS 1.3 + HTTP/2
- ✅ Certificados Let's Encrypt
- ✅ Sin logging de queries por defecto
- ⚠️ Abierto a cualquier cliente (considera firewall)

Para restringir acceso:

```bash
# En /etc/unbound/unbound.conf.d/doh.conf
access-control: 0.0.0.0/0 deny
access-control: 192.168.1.0/24 allow  # Solo tu red
```

## 📞 Referencias

- [Unbound Docs](https://nlnetlabs.nl/projects/unbound/)
- [dns-over-https GitHub](https://github.com/m13253/dns-over-https)
- [RFC 8484 (DoH Standard)](https://tools.ietf.org/html/rfc8484)

## 📝 Notas de Versión

**v1.0 (Mayo 2026)**
- Setup inicial DoH en Debian
- Unbound + doh-server
- Scripts de instalación/desinstalación

## 💡 Tips

1. **Optimización de 1 vCPU:** Ya está configurada (1 thread, caché reducida)
2. **IPv6:** Configurado, verifica soporte de tu ISP
3. **Rate limiting:** Agregar si recibe ataques
4. **Backup:** Guarda `/etc/unbound` y `/etc/doh-server.conf`

---

**Última actualización:** Mayo 14, 2026  
**Estado:** Funcional y testeado en producción ✅
