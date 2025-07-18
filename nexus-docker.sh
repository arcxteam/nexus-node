#!/bin/bash

# Define working directories
WORK_DIR="/root/nexus"
NODE_ID_DIR="$WORK_DIR/prover"
DATA_DIR="$WORK_DIR/nexus-data"
mkdir -p "$WORK_DIR" "$NODE_ID_DIR" "$DATA_DIR"

# Function to generate a unique container name
get_container_name() {
    local base_name="nexus-docker"
    local instance_number=1
    while docker ps -a --format '{{.Names}}' | grep -q "^$base_name-$instance_number$"; do
        instance_number=$((instance_number + 1))
    done
    echo "$base_name-$instance_number"
}

# Check if node-id file is provided as an argument
NODE_ID_FILE="$1"
if [ -z "$NODE_ID_FILE" ]; then
    # Prompt for Node ID interactively, using /dev/tty for curl compatibility
    echo "Masukkan Node ID:"
    read -p "Node ID: " NODE_ID < /dev/tty
    if [ -z "$NODE_ID" ]; then
        echo "Error: Node ID tidak boleh kosong."
        exit 1
    fi
    # Generate a unique file name for the new node-id
    instance_number=1
    while [ -f "$NODE_ID_DIR/node-id-$instance_number.txt" ]; do
        instance_number=$((instance_number + 1))
    done
    NODE_ID_FILE="node-id-$instance_number.txt"
    echo "$NODE_ID" > "$NODE_ID_DIR/$NODE_ID_FILE"
else
    # If argument is provided, check if the file exists
    if [ ! -f "$NODE_ID_DIR/$NODE_ID_FILE" ]; then
        echo "Error: File $NODE_ID_FILE tidak ditemukan di $NODE_ID_DIR."
        exit 1
    fi
fi

# Validate Node ID
NODE_ID=$(cat "$NODE_ID_DIR/$NODE_ID_FILE" | tr -d '\n')
if [ -z "$NODE_ID" ]; then
    echo "Error: Node ID kosong di $NODE_ID_FILE."
    exit 1
fi

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Docker tidak ditemukan. Menginstal Docker..."
    apt update
    apt install -y docker.io curl ca-certificates
    systemctl start docker
    systemctl enable docker
    echo "Docker berhasil diinstal."
else
    if ! systemctl is-active --quiet docker; then
        echo "Docker terinstal tetapi tidak berjalan. Memulai Docker..."
        systemctl start docker
    fi
    echo "Docker sudah siap."
fi

# Create Dockerfile in the current directory
cat <<EOL > Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt update && apt install -y curl build-essential pkg-config libssl-dev git protobuf-compiler ca-certificates && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:\${PATH}"

# Install Nexus CLI
RUN curl https://cli.nexus.xyz/ | bash -s -- -y

# Set PATH for Nexus CLI
ENV PATH="/root/.nexus/bin:\${PATH}"

# Copy Node ID
COPY node-id.txt /root/nexus/node-id.txt

# Run nexus-network
CMD ["bash", "-c", "nexus-network start --node-id \$(cat /root/nexus/node-id.txt)"]
EOL

# Copy Node ID to build context
cp "$NODE_ID_DIR/$NODE_ID_FILE" node-id.txt

# Build Docker image
echo "Membangun image Docker..."
docker build -t nexus-docker .

# Generate unique container name
container_name=$(get_container_name)

# Create persistent data folder for this container
data_dir="$DATA_DIR/$container_name"
mkdir -p "$data_dir"

# Run the container interactively
echo "Memulai container $container_name secara interaktif..."
echo "Tekan Ctrl + D untuk detach setelah dashboard muncul."
docker run -it --detach-keys="ctrl-d" --network host --name "$container_name" -v "$data_dir:/root/nexus-data" nexus-docker

echo "Container $container_name sedang berjalan."
echo "Untuk reattach: docker attach --detach-keys='ctrl-d' $container_name"
echo "Untuk masuk ke container: docker exec -it $container_name /bin/bash"
echo "Untuk menghentikan container: docker stop $container_name"