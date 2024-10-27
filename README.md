![ezgif com-webp-to-png-converter (1)](https://github.com/user-attachments/assets/2eed75ac-39c4-4abc-92d4-a8236ecb725a)

# Nexus Labs Testnet Node - Full Guides Fix Issue

The Nexus zkVM (zero-knowledge virtual machine) is a modular, extensible, open-source, highly-parallelized, prover-optimized, contributor-friendly, zkVM written in Rust, focused on performance and security.


## Here We Go...Gas!!!
*There mentioned in FAQs, Do is incentivized??* 
> **What incentives do you offer for contributing to the network? At this time, contributors receive recognition through public leaderboards. Nexus may implement additional incentives in a future release. Read here https://nexus.xyz/network#network-faqs**

*As following categories of contributions and this incentive pools are indicated on faqs.*

![N-E-X-U-S-10-27-2024_12_46_AM](https://github.com/user-attachments/assets/a784a339-aa03-4bfc-ad3f-3f4f39553af3)

| Incentivized Activity             | Allocation Token |
|-----------------------------------|---------------|
| Running Prover Node               | 0% xxx Nexus (TBA) |
| xxxxxxxxxxx                       | xxxxx (TBA) |

## 1. Preparation for Nexus Prover Node
**1. Hardware requirements** 

`In order to ran Nexus prover node as CLI, need a Linux server (VPS) with the minimum recommended hardware`
| Requirement                      | Details                                          |
|-----------------------------------|------------------------------------------------|
| RAM                               | 4 GB                                            |
| CPU/vCPU                          | 2-4 Cores                                        |
| Storage Space                     | 50-100 GB                                      |
| Supported OS                      | Ubuntu 20.04, 22.04, 24.04 LTS                 |

**2. Hardware requirements**

`In order to ran Nexus prover node as BROWSER, need a device`
| Requirement                      | Details                                         |
|-----------------------------------|------------------------------------------------|
| Internet                          | Stable Connection                            |
| Portable Devices                  | Hand/mobile phones, PC/Laptop/Netbooks, Tablet | 
| Web Browser                       | Chrome, Firefox, Safari, Opera, Brave, Edge, UC/Kiwi etc.. |

**3. Configuration nexus prover node**

If you don't have these dependencies already, install them first.

```
sudo apt update && sudo apt upgrade -y 
sudo apt install build-essential pkg-config libssl-dev git-all
```
## 2. Quick start install

**1. Auto installer**

```
curl sSL https://raw.githubusercontent.com/arcxteam/nexus-node/main/nexus.sh | bash
```

**2. Manual installer**

```
curl https://cli.nexus.xyz/ | sh
```

If you do not already have Rust, you will be prompted to install it.

## 3. Getting an error

If have facing issue on logs `Proof sent! You proved at 0 Hz` to be here https://github.com/nexus-xyz/network-api/releases/

**1. Upgrade & Restart service to latest version**

```
cd/root/network-api
git fetch --all
git checkout tags/0.3.1-beta
```

## 4. Super usefull commands

**1. Based-on Java running Nexus node**

`Save your Prover-id`

- cat $HOME/.nexus/prover-id; echo ""

`Start and enable the service`

- sudo systemctl stop nexus.service
- sudo systemctl daemon-reload
- sudo systemctl enable nexus.service
- sudo systemctl start nexus.service
- sudo systemctl restart nexus.service

`Checking the status`

- sudo systemctl status nexus.service
- ps aux | grep nexus

`Monitor the logs`

- journalctl -u nexus.service -f -n 100

**2. Important note** 

- Delete all Nexus Node - running service

```
sudo systemctl stop nexus.service && sudo systemctl disable nexus.service && sudo rm /etc/systemd/system/nexus.service && sudo systemctl daemon-reload && sudo systemctl reset-failed
```