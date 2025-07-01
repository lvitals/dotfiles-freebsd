#!/bin/sh

# Caminho absoluto do script (para funcionar de qualquer lugar)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Nome base do host (sem domínio)
HOST=$(hostname -s | tr '[:upper:]' '[:lower:]')
KERNEL_NAME=$(echo "$HOST" | tr '[:lower:]' '[:upper:]')_OPTIMIZED

# Caminho completo para o arquivo de configuração customizado
KERNEL_CONF_FILE="$SCRIPT_DIR/../kernel/$HOST/$KERNEL_NAME"

# Destino no diretório de fontes do kernel
KERNEL_CONF_DEST="/usr/src/sys/amd64/conf/$KERNEL_NAME"

# Verificações
if [ ! -f "$KERNEL_CONF_FILE" ]; then
  echo "❌ Arquivo de configuração do kernel não encontrado: $KERNEL_CONF_FILE"
  exit 1
fi

# Copia para o local correto
echo "📁 Copiando $KERNEL_CONF_FILE para $KERNEL_CONF_DEST..."
cp "$KERNEL_CONF_FILE" "$KERNEL_CONF_DEST"

# Compilação
echo "🔧 Compilando kernel com configuração $KERNEL_NAME..."
cd /usr/src || exit 1
make buildkernel KERNCONF="$KERNEL_NAME" || exit 1
make installkernel KERNCONF="$KERNEL_NAME" || exit 1

echo "✅ Kernel $KERNEL_NAME instalado com sucesso."
