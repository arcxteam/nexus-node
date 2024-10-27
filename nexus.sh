#!/bin/bash

# Gas bang 😂 jalankan pemenginstal dependensi dan layanan
install_nexus() {
    echo "Updating packages..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing necessary packages..."
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip cmake -y

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

    echo "Installing Nexus Prover..."
    sudo curl https://cli.nexus.xyz/install.sh | sh

    echo "Setting file ownership for Nexus..."
    sudo chown -R root:root /root/.nexus

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
ExecStart=/root/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
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
    sudo systemctl start nexus.service
}

# Fungsi untuk memperbarui Nexus Network API ke versi terbaru
update_nexus_api() {
    echo "Checking for updates in Nexus Network API..."
    cd ~/.nexus/network-api

    # Mengambil semua pembaruan terbaru dari repository
    git fetch --all --tags

    # Mendapatkan tag rilis terbaru dari repository
    LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))

    # Checkout ke versi terbaru
    git checkout $LATEST_TAG

    # Membersihkan dan membangun ulang proyek dengan versi terbaru
    cargo clean
    cargo build --release
    echo "Nexus Network API updated to the latest version ($LATEST_TAG)."
}

# Fungsi untuk menginstal dan mengatur Nexus ZKVM
setup_nexus_zkvm() {
    echo "Setting up Nexus ZKVM environment..."

    # Set up target dan install nexus-tools dari repository Nexus
    rustup target add riscv32i-unknown-none-elf
    cargo install --git https://github.com/nexus-xyz/nexus-zkvm nexus-tools --tag 'v1.0.0'

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

# Fungsi untuk menghapus layanan dan membersihkan
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

echo "Menginstal Nexus..."
install_nexus

echo "Memeriksa pembaruan Nexus Network API..."
update_nexus_api

echo "Mengatur Nexus ZKVM..."
setup_nexus_zkvm

echo "Memperbaiki peringatan impor yang tidak digunakan..."
fix_unused_import

# Test Nexus Prover dan cek kesalahan
if ! cargo run --release --bin prover -- beta.orchestrator.nexus.xyz; then
    echo "Kesalahan terdeteksi, membersihkan dan menginstal ulang..."
    cleanup
    install_nexus
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