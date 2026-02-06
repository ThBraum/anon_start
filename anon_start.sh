#!/bin/bash

# ==========================================
#  ANON LAUNCHER v3.0 - Hardened Profile
#  Browser: LibreWolf (Forced Tor Profile)
# ==========================================

BROWSER="librewolf"
URL="https://check.torproject.org"
# Define um local para um perfil isolado (não mistura com seu uso pessoal)
ANON_PROFILE="$HOME/.librewolf/anon_tor_profile"

# 1. Verifica Instalação
if ! command -v $BROWSER &> /dev/null; then
    echo "[X] Erro: LibreWolf não encontrado!"
    exit 1
fi

echo "[*] Verificando status do Tor..."

# 2. Gerenciamento do Serviço Tor
if systemctl is-active --quiet tor; then
    echo "[+] Tor já está rodando."
else
    echo "[!] Tor desligado. Iniciando..."
    sudo service tor start
    
    echo -n "[...] Aguardando Bootstrap do Tor"
    for i in {1..15}; do
        if ss -nlt | grep -q "127.0.0.1:9050"; then
            echo " [OK]"
            break
        fi
        echo -n "."
        sleep 2
    done
fi

# 3. CRIAÇÃO DO PERFIL SEGURO (A Mágica acontece aqui)
echo "[*] Criando perfil blindado em: $ANON_PROFILE"
mkdir -p "$ANON_PROFILE"

# Injeta as configurações de Proxy DIRETAMENTE no cérebro do navegador
# Isso sobrescreve qualquer erro humano de configuração manual.
cat <<EOF > "$ANON_PROFILE/user.js"
// Forçar Proxy Manual (Type 1)
user_pref("network.proxy.type", 1);
// Configurar SOCKS5 no Localhost:9050
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_version", 5);
// ESSENCIAL: Obrigar o DNS a passar pelo Proxy (Evita vazamento de IP)
user_pref("network.proxy.socks_remote_dns", true);
// Desativar proxy para HTTP/SSL direto (força tudo pelo SOCKS)
user_pref("network.proxy.http", "");
user_pref("network.proxy.ssl", "");
user_pref("network.proxy.no_proxies_on", "localhost, 127.0.0.1");
EOF

echo "[*] Limpando memória..."
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

echo "[*] Lançando $BROWSER em MODO ISOLADO..."

# 4. O Comando de Lançamento
# --profile: Usa nossa pasta configurada acima
# --no-remote: Permite abrir esse LibreWolf mesmo se você já tiver outro aberto
$BROWSER --profile "$ANON_PROFILE" --no-remote $URL &

echo "[✔] Lançado! Agora deve aparecer 'Congratulations'."
exit 0