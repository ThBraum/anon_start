#!/bin/bash

# ==========================================
#  ANON LAUNCHER v2.0 - Powered by Braum
#  Browser: LibreWolf + ProxyChains + Tor
# ==========================================

BROWSER="librewolf"
URL="https://check.torproject.org"

# 1. Verifica se o LibreWolf está instalado
if ! command -v $BROWSER &> /dev/null
then
    echo "[X] Erro: LibreWolf não encontrado!"
    echo "    Instale com: sudo apt install librewolf"
    exit 1
fi

echo "[*] Verificando status do Tor..."

# 2. Verifica e Inicia o Tor se necessário
if systemctl is-active --quiet tor; then
    echo "[+] Tor já está rodando. Motor quente!"
else
    echo "[!] Tor está desligado. Iniciando..."
    sudo service tor start
    echo "[...] Aguardando o circuito fechar (5s)..."
    sleep 5
fi

# 3. Limpa rastros de memória/cache do sistema (opcional, boa prática)
echo "[*] Preparando ambiente..."
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

echo "[*] Lançando $BROWSER em modo Furtivo..."

# 4. O Comando Mágico
# --private-window: Garante que nada grava no disco local
# proxychains: Força o tráfego pelo túnel do Tor
proxychains $BROWSER --private-window $URL &

echo "[✔] Sucesso! Você está invisível."
exit 0