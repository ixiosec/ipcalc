#!/bin/bash

# Definir colores
COLOR_RESET="\033[0m"
COLOR_HEADER="\033[1;34m"  # Azul
COLOR_TITLE="\033[1;32m"   # Verde
COLOR_LABEL="\033[1;33m"   # Amarillo
COLOR_VALUE="\033[1;37m"   # Blanco

COLOR_BLACK="\033[0;30m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;34m"
COLOR_PURPLE="\033[0;35m"
COLOR_CYAN="\033[0;36m"
COLOR_WHITE="\033[0;37m"

# Mostrar encabezado
show_header() {
  echo -e "${COLOR_YELLOW} -- ~ CALCULADORA DE IP ~ -- ${COLOR_RESET}"
  echo -e "${COLOR_RED}   ixio     ${COLOR_RESET}"
  echo ""
}

# Mostrar ayuda
show_help() {
  show_header
  echo -e "${COLOR_LABEL}Uso:${COLOR_RESET} $0 <dirección IP con CIDR>"
  echo ""
  echo -e "${COLOR_LABEL}Ejemplo:${COLOR_RESET} $0 192.168.1.1/24"
  echo ""
  echo -e "${COLOR_LABEL}Descripción:${COLOR_RESET}"
  echo "Este script calcula información sobre la red basada en una dirección IP y una máscara CIDR."
  echo ""
  echo -e "${COLOR_LABEL}Opciones:${COLOR_RESET}"
  echo -e "  -h    Muestra esta ayuda y termina."
  echo ""
  exit 0
}

# Mostrar encabezado
show_header

# Verificar si se proporcionó la opción -h
if [ "$1" == "-h" ]; then
  show_help
fi

# Verificar si se proporcionó una dirección IP con CIDR
if [ "$#" -ne 1 ]; then
  echo -e "${COLOR_LABEL}Dirección IP con CIDR no proporcionada o incorrecta.${COLOR_RESET}"
  show_help
fi

ip_cidr=$1

# Validar la dirección IP con CIDR
if ! echo "$ip_cidr" | grep -Pq '^(\d{1,3}\.){3}\d{1,3}/[0-9]{1,2}$'; then
  echo -e "${COLOR_LABEL}Dirección IP con CIDR no válida.${COLOR_RESET}"
  show_help
fi

# Extraer la IP y la máscara de red
ip=$(echo "$ip_cidr" | cut -d'/' -f1)
mask=$(echo "$ip_cidr" | cut -d'/' -f2)

# Validar la IP
if ! echo "$ip" | grep -Pq '^(\d{1,3}\.){3}\d{1,3}$'; then
  echo -e "${COLOR_LABEL}Dirección IP no válida.${COLOR_RESET}"
  show_help
fi

# Validar la máscara de red
if [ "$mask" -lt 0 ] || [ "$mask" -gt 32 ]; then
  echo -e "${COLOR_LABEL}Máscara de red no válida.${COLOR_RESET}"
  show_help
fi

# Función para convertir un número decimal a binario
decimal_to_binary() {
  echo "obase=2; $1" | bc | tr -d '%'
}

# Función para convertir un número binario a decimal
binary_to_decimal() {
  echo "ibase=2; $1" | bc
}

# Función para crear la máscara de subred en binario
create_subnet_mask() {
  local bits=$1
  local mask=""
  for i in $(seq 1 $bits); do
    mask+="1"
  done
  for i in $(seq $((bits + 1)) 32); do
    mask+="0"
  done
  echo "$mask"
}

# Función para convertir la máscara de subred binaria a decimal
binary_mask_to_decimal() {
  local bin_mask=$1
  local decimal_mask=""
  for i in $(seq 0 3); do
    local start=$((i * 8 + 1))
    local end=$(((i + 1) * 8))
    local octet_bin=$(echo "$bin_mask" | cut -c$start-$end)
    local octet_dec=$(binary_to_decimal "$octet_bin")
    decimal_mask+="$octet_dec"
    if [ $i -lt 3 ]; then
      decimal_mask+="."
    fi
  done
  echo "$decimal_mask"
}

# Función para aplicar la máscara de subred a la IP
apply_subnet_mask() {
  local ip_bin=$1
  local mask_bin=$2
  local network_bin=""
  
  for i in $(seq 0 31); do
    if [ "${mask_bin:$i:1}" == "1" ]; then
      network_bin+="${ip_bin:$i:1}"
    else
      network_bin+="0"
    fi
  done
  
  echo "$network_bin"
}

# Función para calcular la dirección de broadcast
calculate_broadcast_address() {
  local ip_bin=$1
  local mask_bits=$2
  local broadcast_bin=""
  
  # Mantener los primeros bits igual y convertir los bits restantes en 1
  broadcast_bin=$(echo "$ip_bin" | cut -c1-$mask_bits)
  for i in $(seq $((mask_bits + 1)) 32); do
    broadcast_bin+="1"
  done
  
  echo "$broadcast_bin"
}

# Función para convertir una cadena binaria de 32 bits a una dirección IP decimal
binary_to_ip() {
  local bin=$1
  local ip=""
  for i in $(seq 0 3); do
    local start=$((i * 8))
    local octet_bin=${bin:start:8}
    local octet_dec=$(binary_to_decimal "$octet_bin")
    ip+="$octet_dec"
    if [ $i -lt 3 ]; then
      ip+="."
    fi
  done
  echo "$ip"
}

# Función para obtener la clase de la IP
get_ip_class() {
  local ip=$1
  local first_octet=$(echo "$ip" | cut -d'.' -f1)

  if [ "$first_octet" -lt 128 ]; then
    echo "A"
  elif [ "$first_octet" -lt 192 ]; then
    echo "B"
  elif [ "$first_octet" -lt 224 ]; then
    echo "C"
  else
    echo "D/E (Multicast o experimental)"
  fi
}

# Separar los octetos de la IP
IFS='.' read -r oct1 oct2 oct3 oct4 <<< "$ip"

# Convertir cada octeto a binario
bin1=$(decimal_to_binary "$oct1")
bin2=$(decimal_to_binary "$oct2")
bin3=$(decimal_to_binary "$oct3")
bin4=$(decimal_to_binary "$oct4")

# Asegurarse de que cada binario tenga 8 bits
bin1=$(printf "%08d" "$bin1")
bin2=$(printf "%08d" "$bin2")
bin3=$(printf "%08d" "$bin3")
bin4=$(printf "%08d" "$bin4")

# Concatenar los octetos en una sola cadena binaria
ip_bin="$bin1$bin2$bin3$bin4"

# Crear la máscara de subred en binario
subnet_mask_bin=$(create_subnet_mask "$mask")

# Convertir la máscara de subred binaria a decimal
subnet_mask_decimal=$(binary_mask_to_decimal "$subnet_mask_bin")

# Aplicar la máscara de subred a la IP en binario
network_bin=$(apply_subnet_mask "$ip_bin" "$subnet_mask_bin")

# Convertir la dirección de red en binario a decimal
network_ip=$(binary_to_ip "$network_bin")

# Calcular la dirección de broadcast
broadcast_bin=$(calculate_broadcast_address "$ip_bin" "$mask")

# Convertir la dirección de broadcast binaria a decimal
broadcast_ip=$(binary_to_ip "$broadcast_bin")

# Calcular la primera IP válida (dirección de red + 1)
network_ip_dec=$(echo "$network_ip" | awk -F. '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')
first_ip_dec=$((network_ip_dec + 1))
first_ip=$(printf "%d.%d.%d.%d" $((first_ip_dec >> 24 & 255)) $((first_ip_dec >> 16 & 255)) $((first_ip_dec >> 8 & 255)) $((first_ip_dec & 255)))

# Calcular la última IP válida (dirección de broadcast - 1)
broadcast_ip_dec=$(echo "$broadcast_ip" | awk -F. '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')
last_ip_dec=$((broadcast_ip_dec - 1))
last_ip=$(printf "%d.%d.%d.%d" $((last_ip_dec >> 24 & 255)) $((last_ip_dec >> 16 & 255)) $((last_ip_dec >> 8 & 255)) $((last_ip_dec & 255)))

# Calcular la cantidad de hosts
hosts_count=$((2**(32 - mask) - 2))

# Obtener la clase de la red
ip_class=$(get_ip_class "$ip")

# Mostrar los resultados con colores
echo -e "${COLOR_LABEL}IP:${COLOR_RESET} ${COLOR_VALUE}$ip${COLOR_RESET}"
echo -e "${COLOR_LABEL}CIDR:${COLOR_RESET} ${COLOR_VALUE}$mask${COLOR_RESET}"
echo -e "${COLOR_LABEL}Máscara de subred:${COLOR_RESET} ${COLOR_VALUE}$subnet_mask_decimal${COLOR_RESET}"
echo -e "${COLOR_LABEL}ID de red:${COLOR_RESET} ${COLOR_VALUE}$network_ip${COLOR_RESET}"
echo -e "${COLOR_LABEL}Broadcast address:${COLOR_RESET} ${COLOR_VALUE}$broadcast_ip${COLOR_RESET}"
echo -e "${COLOR_LABEL}Primera IP válida:${COLOR_RESET} ${COLOR_VALUE}$first_ip${COLOR_RESET}"
echo -e "${COLOR_LABEL}Última IP válida:${COLOR_RESET} ${COLOR_VALUE}$last_ip${COLOR_RESET}"
echo -e "${COLOR_LABEL}Cantidad de hosts:${COLOR_RESET} ${COLOR_VALUE}$hosts_count${COLOR_RESET}"
echo -e "${COLOR_LABEL}Cantidad de hosts válidos:${COLOR_RESET} ${COLOR_VALUE}$((hosts_count - 2))${COLOR_RESET}"
echo -e "${COLOR_LABEL}Clase de red:${COLOR_RESET} ${COLOR_VALUE}$ip_class${COLOR_RESET}"
