#!/bin/bash

# Gas bang 😂 jalankan pemasangan dependensi dan layanan

# Fungsi untuk memeriksa apakah terminal interaktif

check_interactive() {
if [ ! -t 0 ] && [ ! -f “$0” ]; then
echo “ERROR: Skrip ini harus dijalankan secara interaktif!”
echo “Gunakan:”
echo “  curl -sSL https://raw.githubusercontent.com/arcxteam/nexus-node/main/nexus.sh -o nexus.sh”
echo “  chmod +x nexus.sh”
echo “  ./nexus.sh”
exit 1
fi
}

# Fungsi untuk menginstal dependensi

install_dependencies() {
echo “Updating packages…”
sudo apt update && sudo apt upgrade -y
echo “Installing necessary packages…”
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip cmake -y
}

# Fungsi untuk menginstal Rust

install_rust() {
if ! command -v rustc &> /dev/null; then
echo “Installing Rust…”
curl –proto ‘=https’ –tlsv1.2 -sSf https://sh.rustup.rs | sh -s – -y
source “$HOME/.cargo/env”
export PATH=”$HOME/.cargo/bin:$PATH”
else
echo “Rust is already installed. Updating…”
rustup update
fi
echo “Rust version:”
rustc –version
}

# Fungsi untuk menginstal Nexus Prover

install_nexus_prover() {
echo “Installing Nexus Prover…”
sudo curl -sSL https://cli.nexus.xyz/ | NONINTERACTIVE=1 sh
echo “Setting file ownership for Nexus…”
sudo chown -R root:root /root/.nexus
}

# Fungsi untuk membuat file node-id.txt dengan input interaktif

create_node_id_file() {
NODE_ID_FILE=”/root/.nexus/node-id.txt”

```
# Pastikan direktori .nexus ada
mkdir -p "/root/.nexus"

if [ ! -f "$NODE_ID_FILE" ]; then
    echo ""
    echo "================================================================"
    echo "SETUP NODE ID DIPERLUKAN"
    echo "================================================================"
    echo "Node ID tidak ditemukan di $NODE_ID_FILE"
    echo "Anda perlu mendapatkan Node ID dari website Nexus:"
    echo ""
    echo "1. Kunjungi https://app.nexus.xyz/nodes"
    echo "2. Login dengan wallet Anda"
    echo "3. Buat node baru atau pilih node yang sudah ada"
    echo "4. Salin Node ID yang ditampilkan"
    echo ""
    echo "================================================================"
    echo ""
    
    # Loop sampai input valid
    while true; do
        echo -n "Masukkan Node ID Anda: "
        read NODE_ID
        
        # Validasi input
        if [ -z "$NODE_ID" ]; then
            echo "Node ID tidak boleh kosong. Silakan coba lagi."
            echo ""
            continue
        fi
        
        # Hilangkan spasi di awal dan akhir
        NODE_ID=$(echo "$NODE_ID" | tr -d '[:space:]')
        
        # Validasi format dasar (minimal 10 karakter)
        if [ ${#NODE_ID} -lt 10 ]; then
            echo "Node ID terlalu pendek. Pastikan Anda menyalin seluruh ID."
            echo ""
            continue
        fi
        
        # Konfirmasi
        echo ""
        echo "Node ID yang Anda masukkan: $NODE_ID"
        echo -n "Apakah ini benar? (y/n): "
        read confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            break
        fi
        echo ""
    done
    
    echo ""
    echo "Menyimpan Node ID ke $NODE_ID_FILE..."
    echo "$NODE_ID" > "$NODE_ID_FILE"
    
    # Verifikasi file tersimpan
    if [ -f "$NODE_ID_FILE" ]; then
        echo "Node ID berhasil disimpan!"
        echo "Lokasi file: $NODE_ID_FILE"
    else
        echo "Gagal menyimpan Node ID!"
        exit 1
    fi
else
    echo "File Node ID sudah ada. Melanjutkan..."
    NODE_ID_CONTENT=$(cat "$NODE_ID_FILE" | tr -d '[:space:]')
    echo "Node ID Anda: $NODE_ID_CONTENT"
fi
echo ""
```

}

# Fungsi untuk membuat wrapper.sh

create_wrapper_script() {
WRAPPER_SCRIPT=”/root/.nexus/network-api/clients/cli/wrapper.sh”
WRAPPER_DIR=$(dirname “$WRAPPER_SCRIPT”)
NODE_ID_FILE=”/root/.nexus/node-id.txt”

```
echo "Creating wrapper script directory if not exists..."
mkdir -p "$WRAPPER_DIR"

echo "Creating wrapper script for Nexus..."
cat > "$WRAPPER_SCRIPT" << 'EOF'
```

#!/bin/bash

# Skrip ini memberikan input otomatis ke program nexus-network

# Navigate to the correct directory

cd /root/.nexus/network-api/clients/cli

# Check if binary exists

if [ ! -f “./target/release/nexus-network” ]; then
echo “Error: nexus-network binary not found!”
exit 1
fi

# Check if node-id.txt exists

NODE_ID_FILE=”/root/.nexus/node-id.txt”
if [ ! -f “$NODE_ID_FILE” ]; then
echo “Error: node-id.txt not found at $NODE_ID_FILE!”
exit 1
fi

# Read node-id from file

NODE_ID=$(cat “$NODE_ID_FILE” | tr -d ‘[:space:]’)

# Validate node-id

if [ -z “$NODE_ID” ]; then
echo “Error: Node ID is empty in $NODE_ID_FILE!”
exit 1
fi

echo “Using Node ID: $NODE_ID”

# Run with automated input using the node-id from file

echo -e “y\n2\n$NODE_ID” | ./target/release/nexus-network start –node-id
EOF

```
chmod +x "$WRAPPER_SCRIPT"
echo "Wrapper script created at $WRAPPER_SCRIPT"
```

}

# Fungsi untuk membuat file systemd

create_systemd_service() {
SERVICE_FILE=”/etc/systemd/system/nexus.service”

```
echo "Creating systemd service file for Nexus..."
cat > "$SERVICE_FILE" << 'EOF'
```

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

```
echo "Reloading systemd daemon and enabling Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
```

}

# Fungsi untuk memperbarui Nexus Network API ke versi terbaru

update_nexus_api() {
echo “Checking for updates in Nexus Network API…”

```
# Pindah ke direktori utama repository network-api
cd ~/.nexus/network-api || { echo "Failed to change directory to ~/.nexus/network-api"; exit 1; }

# Mengambil semua pembaruan terbaru dari repository
git fetch --all --tags --force

# Mendapatkan tag rilis terbaru dari repository
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not find latest tag!"
    exit 1
fi

echo "Latest tag found: $LATEST_TAG"

# Stash any local changes
git stash

# Checkout ke versi terbaru
git checkout "$LATEST_TAG"

# Pindah ke direktori yang berisi Cargo.toml
cd ~/.nexus/network-api/clients/cli || { echo "Failed to change directory to cli"; exit 1; }

# Membersihkan dan membangun ulang proyek dengan versi terbaru
cargo clean
cargo build --release

echo "Nexus Network API updated to the latest version ($LATEST_TAG)."
```

}

# Fungsi untuk mengatur Nexus ZKVM

setup_nexus_zkvm() {
echo “Setting up Nexus ZKVM environment…”
# Set up target dan install nexus-tools dari repository Nexus
rustup target add riscv32i-unknown-none-elf
cargo install –git https://github.com/nexus-xyz/nexus-zkvm nexus-tools –tag ‘v0.3.4’
# Membuat project Nexus ZKVM
cargo nexus new nexus-project
cd nexus-project/src || { echo “Failed to enter nexus-project/src”; exit 1; }
rm -f main.rs
# Menulis program contoh ke main.rs
cat > main.rs << ‘EOF’
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
EOF
cd ../..
}

# Fungsi untuk menjalankan, membuktikan, dan memverifikasi program ZKVM

run_nexus_program() {
echo “Running Nexus program…”
cargo nexus run
echo “Proving your program…”
cargo nexus prove
echo “Verifying your proof…”
cargo nexus verify
}

# Fungsi untuk memperbaiki peringatan impor yang tidak digunakan

fix_unused_import() {
echo “Memperbaiki peringatan impor yang tidak digunakan…”
sed -i ‘s/^use std::env;/// use std::env;/’ /root/.nexus/network-api/clients/cli/src/prover.rs 2>/dev/null || echo “Warning: Could not modify prover.rs”
}

# Fungsi untuk membersihkan layanan dan file

cleanup() {
echo “Menghentikan dan menonaktifkan layanan Nexus…”
sudo systemctl stop nexus.service 2>/dev/null || true
sudo systemctl disable nexus.service 2>/dev/null || true
echo “Menghapus file layanan…”
sudo rm -f /etc/systemd/system/nexus.service
echo “Memuat ulang daemon systemd…”
sudo systemctl daemon-reload
}

# Fungsi untuk memastikan layanan berjalan

ensure_service_running() {
if ! systemctl is-active –quiet nexus.service; then
echo “Nexus service tidak berjalan. Mencoba memulai…”
sudo systemctl start nexus.service

```
    # Tunggu sebentar untuk memastikan service sudah mulai
    sleep 5
    
    if ! systemctl is-active --quiet nexus.service; then
        echo "Gagal memulai layanan Nexus. Memeriksa log..."
        sudo journalctl -u nexus.service -n 50 --no-pager
        return 1
    fi
fi
echo "Layanan Nexus berjalan."
return 0
```

}

# Fungsi untuk memeriksa dan memulai ulang layanan

restart_service_if_needed() {
if ! ensure_service_running; then
echo “Mencoba membangun ulang dan memulai layanan…”
cd ~/.nexus/network-api/clients/cli || return 1
cargo build –release
sudo systemctl restart nexus.service
ensure_service_running
fi
}

# Eksekusi utama

main() {
check_interactive

```
echo "================================================================"
echo "NEXUS NODE INSTALLATION SCRIPT"
echo "================================================================"
echo ""

echo "Membersihkan instalasi lama..."
cleanup

echo "Menginstal dependensi..."
install_dependencies

echo "Menginstal Rust..."
install_rust

echo "Menginstal Nexus Prover..."
install_nexus_prover

echo "Setup Node ID..."
create_node_id_file

echo "Memeriksa pembaruan Nexus Network API..."
update_nexus_api

echo "Membuat wrapper script..."
create_wrapper_script

echo "Membuat file systemd service..."
create_systemd_service

echo "Memperbaiki peringatan impor yang tidak digunakan..."
fix_unused_import

echo "Mengatur Nexus ZKVM..."
setup_nexus_zkvm

echo "Memastikan layanan berjalan..."
restart_service_if_needed

echo "Menjalankan dan membuktikan Nexus program..."
run_nexus_program

echo ""
echo "================================================================"
echo "INSTALASI SELESAI!"
echo "================================================================"
echo ""
echo "Memeriksa status layanan..."
sudo systemctl status nexus.service --no-pager

echo ""
echo "Mengikuti log untuk layanan nexus..."
echo "Press Ctrl+C to exit log view"
echo ""
sudo journalctl -fu nexus.service -o cat
```

}

# Jalankan fungsi utama

main “$@”