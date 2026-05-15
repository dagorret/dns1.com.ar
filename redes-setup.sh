#!/bin/bash

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
NC='\033[0m'

echo -e "${COLOR_YELLOW}[*]${NC} Agregando reglas DNS Argentina..."
echo ""

# Función para ejecutar y mostrar si falla
run_ufw() {
    local num=$1
    shift
    local cmd="ufw $@"
    echo -ne "${COLOR_YELLOW}[$num]${NC} $cmd ... "
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${NC}"
    else
        echo -e "${COLOR_RED}✗ ERROR${NC}"
        echo -e "${COLOR_RED}Línea fallida:${NC} $cmd"
        exit 1
    fi
}

# DNS - ARGENTINA
run_ufw 1 "allow from 190.0.0.0/8 to any port 53 proto udp"
run_ufw 2 "allow from 190.0.0.0/8 to any port 53 proto tcp"

run_ufw 3 "allow from 200.0.0.0/8 to any port 53 proto udp"
run_ufw 4 "allow from 200.0.0.0/8 to any port 53 proto tcp"

run_ufw 5 "allow from 201.0.0.0/8 to any port 53 proto udp"
run_ufw 6 "allow from 201.0.0.0/8 to any port 53 proto tcp"

run_ufw 7 "allow from 177.0.0.0/8 to any port 53 proto udp"
run_ufw 8 "allow from 177.0.0.0/8 to any port 53 proto tcp"

run_ufw 9 "allow from 179.0.0.0/8 to any port 53 proto udp"
run_ufw 10 "allow from 179.0.0.0/8 to any port 53 proto tcp"

run_ufw 11 "allow from 181.0.0.0/8 to any port 53 proto udp"
run_ufw 12 "allow from 181.0.0.0/8 to any port 53 proto tcp"

run_ufw 13 "allow from 186.0.0.0/7 to any port 53 proto udp"
run_ufw 14 "allow from 186.0.0.0/7 to any port 53 proto tcp"

# HTTP/HTTPS - PARA TODOS
run_ufw 15 "allow 80"
run_ufw 16 "allow 443"

echo ""
echo -e "${COLOR_GREEN}[✓]${NC} Reglas agregadas exitosamente"
echo ""
echo "Reglas finales:"
ufw status numbered
echo ""

