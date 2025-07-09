#!/bin/bash

# Define working directory
WORK_DIR="/root/nexus"
DATA_DIR="/root/nexus-data"
mkdir -p "$WORK_DIR" "$DATA_DIR"
cd "$WORK_DIR"

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Docker tidak ditemukan. Menginstal Docker..."
    sudo apt update
    sudo apt install -y docker.io curl ca-certificates
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker berhasil diinstal."
else
    if ! systemctl is-active --quiet docker; then
        echo "Docker terinstal tetapi tidak berjalan. Memulai Docker..."
        sudo systemctl start docker
    fi
    echo "Docker sudah terinstal dan berjalan."
fi

# Check if node-id.txt file exists
if [ ! -f "$WORK_DIR/node-id.txt" ]; then
    echo "Error: File node-id.txt tidak ditemukan di $WORK_DIR. Buat file node-id.txt dengan Node ID."
    echo "Contoh: echo 'your-node-id-here' > $WORK_DIR/node-id.txt"
    exit 1
fi

# Validate Node ID
NODE_ID=$(cat "$WORK_DIR/node-id.txt" | tr -d '\n')
if [ -z "$NODE_ID" ]; then
    echo "Error: Node ID kosong atau tidak diset di node-id.txt."
    exit 1
fi

# Create working dir for Docker
mkdir -p nexus-docker && cd nexus-docker

# Create start.sh
cat <<EOL > start.sh
#!/bin/bash

# Source Rust environment
source /root/.cargo/env

# Add riscv target
rustup target add riscv32i-unknown-none-elf

# Install Nexus CLI with error handling
echo "Menginstal Nexus CLI pada \$(date)" >> /root/nexus-data/nexus.log
curl https://cli.nexus.xyz/ | bash -s -- -y || { echo "Gagal menginstal Nexus CLI pada \$(date)" >> /root/nexus-data/nexus.log; exit 1; }

# Source bashrc to update PATH
source /root/.bashrc

# Verify nexus-network command
if ! command -v nexus-network &> /dev/null; then
    echo "Error: Perintah nexus-network tidak ditemukan setelah instalasi CLI pada \$(date)" >> /root/nexus-data/nexus.log
    # Attempt to manually add PATH
    export PATH="/root/.nexus/bin:\$PATH"
    if ! command -v nexus-network &> /dev/null; then
        echo "Error: Gagal menemukan nexus-network bahkan setelah menambahkan PATH pada \$(date)" >> /root/nexus-data/nexus.log
        exit 1
    fi
fi

# Check if node-id.txt file exists
if [ ! -f /root/nexus/node-id.txt ]; then
    echo "Error: File node-id.txt tidak ditemukan di /root/nexus pada \$(date)" >> /root/nexus-data/nexus.log
    exit 1
fi

# Read Node ID from node-id.txt
NODE_ID=\$(cat /root/nexus/node-id.txt | tr -d '\n')

# Validate Node ID
if [ -z "\$NODE_ID" ]; then
    echo "Error: Node ID kosong atau tidak diset di node-id.txt pada \$(date)" >> /root/nexus-data/nexus.log
    exit 1
fi

# Start Nexus network with logging
echo "Memulai nexus-network dengan Node ID: \$NODE_ID pada \$(date)" >> /root/nexus-data/nexus.log
nexus-network start --node-id \$NODE_ID 2>> /root/nexus-data/nexus.log || { echo "nexus-network start gagal pada \$(date)" >> /root/nexus-data/nexus.log; exit 1; }

# Keep container running for debugging
echo "nexus-network start selesai, menjaga container tetap berjalan untuk debugging pada \$(date)" >> /root/nexus-data/nexus.log
tail -f /dev/null
EOL
chmod +x start.sh

# Create Dockerfile
cat <<EOL > Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt update && apt install -y \\
    curl build-essential pkg-config libssl-dev \\
    git protobuf-compiler ca-certificates bash && \\
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:\${PATH}"

# Add riscv target
RUN rustup target add riscv32i-unknown-none-elf

# Create directories
RUN mkdir -p /root/nexus /root/nexus-data

# Copy startup script and node-id.txt
COPY start.sh /start.sh
COPY node-id.txt /root/nexus/node-id.txt
RUN chmod +x /start.sh

# Set entrypoint to run the script
ENTRYPOINT ["/start.sh"]
EOL

# Copy node-id.txt to build context
if ! cp "$WORK_DIR/node-id.txt" node-id.txt; then
    echo "Error: Gagal menyalin node-id.txt ke build context."
    exit 1
fi

# Determine instance number
existing_instances=$(docker ps -a --filter "name=nexus-docker-" --format "{{.Names}}" | grep -Eo '[0-9]+' | sort -n | tail -1)
instance_number=$((existing_instances + 1))
container_name="nexus-docker-$instance_number"

# Create persistent data folder
data_dir="$DATA_DIR/$container_name"
mkdir -p "$data_dir"

# Build the image
echo "Membangun image Docker: $container_name"
docker build -t "$container_name" . || { echo "Gagal membangun image Docker"; exit 1; }

# Run the container interactively with custom detach keys
echo -e "\e[32mSetup selesai. Memulai container Nexus secara interaktif...\e[0m"
echo -e "\e[33mUntuk detach dari container tanpa menghentikan, tekan Ctrl + D\e[0m"
docker run -it --detach-keys="ctrl-d" --name "$container_name" -v "$data_dir:/root/nexus-data" "$container_name"

echo -e "\e[32mContainer $container_name sedang berjalan secara interaktif.\e[0m"
echo -e "Untuk reattach ke container: \e[36mdocker attach $container_name\e[0m"
echo -e "Untuk masuk ke container untuk debugging: \e[36mdocker exec -it $container_name /bin/bash\e[0m"
echo -e "Untuk menghentikan container: \e[36mdocker stop $container_name\e[0m"
echo -e "Untuk memeriksa log: \e[36mcat $data_dir/nexus.log\e[0m"