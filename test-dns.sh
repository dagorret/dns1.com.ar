#!/bin/bash

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Test DNS1 Argentina"
echo "=========================================="
echo ""

# Test 1: Desde localhost
echo -e "${COLOR_YELLOW}[1] Test LOCALHOST (127.0.0.1)${NC}"
echo "Comando: dig @127.0.0.1 google.com"
dig @127.0.0.1 google.com +short
echo ""

# Test 2: Desde la VPS (IP pública)
echo -e "${COLOR_YELLOW}[2] Test VPS (138.36.239.70)${NC}"
echo "Comando: dig @138.36.239.70 google.com"
dig @138.36.239.70 google.com +short
echo ""

# Test 3: Verificar que el puerto 53 escucha
echo -e "${COLOR_YELLOW}[3] Verificar puerto 53 ESCUCHANDO${NC}"
echo "Comando: netstat -tuln | grep :53"
netstat -tuln | grep :53
echo ""

# Test 4: Ver las reglas UFW
echo -e "${COLOR_YELLOW}[4] Reglas UFW ACTIVAS${NC}"
echo "Comando: ufw status numbered"
ufw status numbered | head -20
echo ""

# Test 5: Test con nslookup
echo -e "${COLOR_YELLOW}[5] Test con nslookup${NC}"
echo "Comando: nslookup google.com 127.0.0.1"
nslookup google.com 127.0.0.1 2>/dev/null | grep -A5 "Name:"
echo ""

# Test 6: Ver qué está escuchando en el puerto 53
echo -e "${COLOR_YELLOW}[6] Procesos usando puerto 53${NC}"
echo "Comando: lsof -i :53"
lsof -i :53 2>/dev/null || echo "Instala: sudo apt install lsof"
echo ""

echo "=========================================="
echo -e "${COLOR_GREEN}✓ Tests completados${NC}"
echo "=========================================="
echo ""
echo -e "${COLOR_BLUE}[i]${NC} Interpretación:"
echo "  ✅ Si ves respuestas en [1] y [2]: DNS funciona"
echo "  ✅ Si [3] muestra puerto 53: BIND escucha"
echo "  ✅ Si [4] muestra reglas Argentina: UFW configurado"
echo ""

