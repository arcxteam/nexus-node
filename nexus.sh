#!/bin/bash
# Gas bang 😂 jalankan pemasangan dependensi dan layanan

# Fungsi untuk menginstal dependensi
install_dependencies() {
    echo "Updating packages..."
    sudo apt update && sudo apt upgrade -y
    echo "Installing necessary packages..."
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip cmake -y
}

# Fungsi untuk menginstal Rust
install_rust() {
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        echo "Rust is already installed. Updating..."
        rustup update
    fi
    echo "Rust version:"
    rustc --version
}

# Fungsi untuk menginstal Nexus Prover
install_nexus_prover() {
    echo "Installing Nexus Prover..."
    sudo curl https://cli.nexus.xyz/install.sh | sh
    echo "Setting file ownership for Nexus..."
    sudo chown -R root:root /root/.nexus
}

# Fungsi untuk membuat file systemd
create_systemd_service() {
    SERVICE_FILE="/etc/systemd/system/nexus.service"
    
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "Creating systemd service file for Nexus..."
        sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Nexus Network
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/.nexus/network-api/clients/cli
ExecStart=/root/.nexus/network-api/clients/cli/wrapper.sh
Restart=always
RestartSec=11
LimitNOFILE=65000

[Install]
WantedBy=multi-user.target
EOF
    else
        echo "Service file already exists. Skipping creation."
    fi
    echo "Reloading systemd daemon and enabling Nexus service..."
    sudo systemctl daemon-reload
    sudo systemctl enable nexus.service
}

# Fungsi untuk membuat wrapper.sh
create_wrapper_script() {
    WRAPPER_SCRIPT="/root/.nexus/network-api/clients/cli/wrapper.sh"
    
    if [ ! -f "$WRAPPER_SCRIPT" ]; then
        echo "Creating wrapper script for Nexus..."
        sudo tee $WRAPPER_SCRIPT > /dev/null <<EOF
#!/bin/bash
# Skrip ini memberikan input otomatis ke program nexus-network
echo -e "y\n2" | /root/.nexus/network-api/clients/cli/target/release/nexus-network start --env beta
EOF
        sudo chmod +x $WRAPPER_SCRIPT
    else
        echo "Wrapper script already exists. Skipping creation."
    fi
}

# Fungsi untuk memperbarui Nexus Network API ke versi terbaru
update_nexus_api() {
    echo "Checking for updates in Nexus Network API..."
    
    # Pindah ke direktori utama repository network-api
    cd ~/.nexus/network-api
    # Mengambil semua pembaruan terbaru dari repository
    git fetch --all --tags
    # Mendapatkan tag rilis terbaru dari repository
    LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
    # Checkout ke versi terbaru
    git checkout $LATEST_TAG
    # Pindah ke direktori yang berisi Cargo.toml
    cd ~/.nexus/network-api/clients/cli
    # Membersihkan dan membangun ulang proyek dengan versi terbaru
    cargo clean
    cargo build --release
    echo "Nexus Network API updated to the latest version ($LATEST_TAG)."
}

# Fungsi untuk membuat file node-id
create_node_id_file() {
    NODE_ID_FILE="/root/.nexus/node-id"
    
    if [ ! -f "$NODE_ID_FILE" ]; then
        echo "Node ID file not found. Please enter your Node ID (from the website):"
        read -p "Enter Node ID: " NODE_ID
        
        if [ -z "$NODE_ID" ]; then
            echo "Node ID cannot be empty. Exiting..."
            exit 1
        fi
        
        echo "Saving Node ID to $NODE_ID_FILE..."
        echo "$NODE_ID" | sudo tee $NODE_ID_FILE > /dev/null
    else
        echo "Node ID file already exists. Skipping creation."
    fi
}

# Fungsi untuk mengatur Nexus ZKVM
setup_nexus_zkvm() {
    echo "Setting up Nexus ZKVM environment..."
    # Set up target dan install nexus-tools dari repository Nexus
    rustup target add riscv32i-unknown-none-elf
    cargo install --git https://github.com/nexus-xyz/nexus-zkvm nexus-tools --tag 'v0.2.4'
    # Membuat project Nexus ZKVM
    cargo nexus new nexus-project
    cd nexus-project/src
    rm -rf main.rs
    # Menulis program contoh ke main.rs
    cat <<EOT >> main.rs
#![no_std]
#![no_main]
fn fib(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fib(n - 1) + fib(n - 2),
    }
}
#[nexus_rt::main]
fn main() {
    let n = 7;
    let result = fib(n);
    assert_eq!(result, 13);
}
EOT
    cd ..
}

# Fungsi untuk menjalankan, membuktikan, dan memverifikasi program ZKVM
run_nexus_program() {
    echo "Running Nexus program..."
    cargo nexus run
    echo "Proving your program..."
    cargo nexus prove
    echo "Verifying your proof..."
    cargo nexus verify
}

# Fungsi untuk memperbaiki peringatan impor yang tidak digunakan
fix_unused_import() {
    echo "Memperbaiki peringatan impor yang tidak digunakan..."
    sed -i 's/^use std::env;/\/\/ use std::env;/' /root/.nexus/network-api/clients/cli/src/prover.rs
}

# Fungsi untuk membersihkan layanan dan file
cleanup() {
    echo "Menghentikan dan menonaktifkan layanan Nexus..."
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
    echo "Menghapus file layanan..."
    sudo rm -f /etc/systemd/system/nexus.service
    echo "Memuat ulang daemon systemd..."
    sudo systemctl daemon-reload
}

# Fungsi untuk memastikan layanan berjalan
ensure_service_running() {
    if ! systemctl is-active --quiet nexus.service; then
        echo "Nexus service tidak berjalan. Mencoba memulai..."
        sudo systemctl start nexus.service
    fi
    
    if ! systemctl is-active --quiet nexus.service; then
        echo "Gagal memulai layanan Nexus. Memeriksa log..."
        sudo journalctl -u nexus.service -n 50 --no-pager
    else
        echo "Layanan Nexus berhasil dimulai."
    fi
}

# Eksekusi skrip dulu 😎
echo "Membersihkan instalasi lama..."
cleanup

echo "Menginstal dependensi..."
install_dependencies

echo "Menginstal Rust..."
install_rust

echo "Menginstal Nexus Prover..."
install_nexus_prover

echo "Membuat file node-id..."
create_node_id_file

echo "Membuat wrapper.sh..."
create_wrapper_script

echo "Membuat file systemd..."
create_systemd_service

echo "Memeriksa pembaruan Nexus Network API..."
update_nexus_api

echo "Mengatur Nexus ZKVM..."
setup_nexus_zkvm

echo "Memperbaiki peringatan impor yang tidak digunakan..."
fix_unused_import

# Test Nexus Prover dan cek kesalahan
if ! cargo run --release --bin nexus-network -- start --env beta; then
    echo "Kesalahan terdeteksi, membersihkan dan menginstal ulang..."
    cleanup
    install_nexus_prover
else
    echo "Prover berhasil dijalankan."
fi

echo "Memastikan layanan berjalan..."
ensure_service_running

# Menjalankan program Nexus dan memverifikasi bukti
echo "Menjalankan dan membuktikan Nexus program..."
run_nexus_program

echo "Instalasi selesai. Memeriksa status layanan..."
sudo systemctl status nexus.service

echo "Mengikuti log untuk layanan nexus..."
sudo journalctl -fu nexus.service -o cat
