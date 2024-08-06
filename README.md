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

## Requisitos

Para ejecutar este script, necesitas tener instaladas las siguientes herramientas en tu sistema:

- **Bash**: La shell de comandos de Unix.
- **bc**: Calculadora de precisión arbitraria. 

Para instalar `bc` en sistemas basados en Debian/Ubuntu, usa:

   ```bash
   sudo apt-get update
   sudo apt-get install bc


## USO

Para utilizar el script, sigue estos pasos:

1. Clona el repositorio a tu máquina local:

   ```bash
   git clone https://github.com/ixiosec/ipcalc
   
2. Desplazate a la carpeta

    ```bash
   cd ipcalc

4. Otorga permisos de ejecución al script

    ```bash
   chmod +x ipcalc.sh

6. prueba el script

    ```bash
   ./ipcalc.sh 192.168.15.10/15
    
