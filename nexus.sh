#!/bin/bash

# Fungsi untuk menginstal dependensi dan layanan
install_nexus() {
    echo "Updating packages..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing necessary packages..."
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
        source $HOME/.cargo/env
        export PATH="$HOME/.cargo/bin:$PATH"
        rustup update
    else
        echo "Rust is already installed. Updating..."
        rustup update
    fi

    echo "Rust version:"
    rustc --version

    echo "Installing Nexus Prover..."
    sudo curl https://cli.nexus.xyz/install.sh | sh

    echo "Menyesuaikan kepemilikan file..."
    sudo chown -R root:root /root/.nexus

    SERVICE_FILE="/etc/systemd/system/nexus.service"
    echo "Creating systemd service file for nexus..."
    sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Nexus Network
After=network-online.target

[Service]
User=root
WorkingDirectory=/root/.nexus/network-api/clients/cli
ExecStart=/root/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    echo "Reloading systemd daemon and starting nexus service..."
    sudo systemctl daemon-reload
    sudo systemctl enable nexus.service  # Baris ini diperbaiki
    sudo systemctl start nexus.service   # Baris ini diperbaiki
}

# Berfungsi memperbaiki peringatan impor yang tidak digunakan
fix_unused_import() {
    echo "Memperbaiki peringatan impor yang tidak digunakan..."
    sed -i 's/^use std::env;/\/\/ use std::env;/' /root/.nexus/network-api/clients/cli/src/prover.rs
}

# Berfungsi menghapus layanan dan membersihkan
cleanup() {
    echo "Menghentikan dan menonaktifkan layanan nexus..."
    sudo systemctl stop nexus.service   # Baris ini diperbaiki
    sudo systemctl disable nexus.service  # Baris ini diperbaiki
    echo "Menghapus file layanan..."
    sudo rm -f /etc/systemd/system/nexus.service
    echo "Memuat ulang daemon systemd..."
    sudo systemctl daemon-reload
}

# Berfungsi memastikan layanan berjalan
ensure_service_running() {
    if ! systemctl is-active --quiet nexus.service; then   # Baris ini diperbaiki
        echo "Nexus service tidak berjalan. Mencoba memulai..."
        sudo systemctl start nexus.service   # Baris ini diperbaiki
    fi
    
    if ! systemctl is-active --quiet nexus.service; then   # Baris ini diperbaiki
        echo "Gagal memulai layanan Nexus. Memeriksa log..."
        sudo journalctl -u nexus.service -n 50 --no-pager   # Baris ini diperbaiki
    else
        echo "Layanan Nexus berhasil dimulai."
    fi
}

# Eksekusi skrip ya
echo "Membersihkan instalasi lama..."
cleanup

echo "Menginstal Nexus..."
install_nexus

echo "Memperbaiki peringatan impor yang tidak digunakan..."
fix_unused_import

# Test gigi 7 run prover dan periksa apakah ada kesalahan
if ! cargo run --release --bin prover -- beta.orchestrator.nexus.xyz; then
    echo "Kesalahan terdeteksi, membersihkan dan menginstal ulang..."
    cleanup
    install_nexus
else
    echo "Prover berhasil dijalankan."
fi

echo "Memastikan layanan berjalan..."
ensure_service_running

echo "Instalasi selesai. Memeriksa status layanan..."
sudo systemctl status nexus.service   # Baris ini diperbaiki

echo "Mengikuti log untuk layanan nexus..."
sudo journalctl -fu nexus.service -o cat   # Baris ini diperbaiki