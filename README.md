# Subnetting
# Calculadora completa de IP

## Descripción

Este script de Bash permite calcular información relacionada con redes IP. Dado una dirección IP con un prefijo CIDR (Classless Inter-Domain Routing)
# ejemplo: 192.168.15.25/18

El script calcula lo siguiente:

- La dirección IP.
- CIDR.
- La máscara de subred.
- La dirección de red.
- La dirección de broadcast.
- La primera IP válida en la red.
- La última IP válida en la red.
- La cantidad total de hosts en la red.
- La cantidad de hosts válidos (excluyendo la dirección de red y la dirección de broadcast).
- La clase de red (A, B, C, D/E).

## Uso

Para utilizar el script, sigue estos pasos:

1. Clona el repositorio a tu máquina local:

   ```bash
   git clone https://github.com/ixiosec/ipcalc
   
2. Desplazate a la carpeta

    cd ipcalc

3. Otorga permisos de ejecución al script

    chmod +x ipcalc.sh

4. prueba el script

   ./ipcalc.sh 192.168.15.10/15
    
