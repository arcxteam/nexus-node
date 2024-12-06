![com-webp-to-png-converter](https://github.com/user-attachments/assets/0fb7877d-8638-49a3-8a3f-670f9de617d9)

# A Complete Guide Nexus Testnet Node - Fix Issue Nexus Labs (Prover Network)

The Nexus Labs zkVM (zero-knowledge virtual machine) is a modular verifiable internet, as extensible, open-source, highly-parallelized, prover-optimized, contributor-friendly, zkVM written in Rust, focused on performance and security.
Read this step to runnig Nexus node as Prover Network.

## Here We Go...Gas!!!
`Is there incentivized?` ![Confirm](https://img.shields.io/badge/indicate-yes-brightgreen)

> [!IMPORTANT]
> What incentives do you offer for contributing to the network? At this time, contributors receive recognition through public leaderboards. Nexus may implement additional incentives in a future release. Read here https://nexus.xyz/network#network-faqs

**There mentioned in FAQs; As following categories of contributions and this incentive pools are indicated on faqs.**

![N-E-X-U-S-10-27-2024_12_46_AM](https://github.com/user-attachments/assets/8f195829-249f-4528-862d-e94bcb55d4df)

| Incentivized Activity             | Allocation Token |
|-----------------------------------|---------------|
| Running Nexus Prover Node         | xxxxx (TBA) |
| Testnetwork                       | xxxxx (TBA) |

## 1. Preparation Nexus Node
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

**3. Configuration Nexus prover node**

If you don't have these dependencies already, install them first.

```
sudo apt update && sudo apt upgrade -y 
sudo apt install build-essential pkg-config libssl-dev git-all
```
## 2. Start Install

**1. Auto installing**

```
curl sSL https://raw.githubusercontent.com/arcxteam/nexus-node/main/nexus.sh | bash
```

**2. Manual installing**

```
curl https://cli.nexus.xyz/ | sh
```

> If you do not already have Rust, you will be prompted to install it.

## 3. Getting an Error

logs: If have facing issue cargo/cycles etc `Proof sent! You proved at 0 Hz` try for the latest Api Network https://github.com/nexus-xyz/network-api/releases/

**1. Upgrade & restart service for network-api**

```
cd ~/.nexus/network-api && \
git fetch --all --tags && \
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
git checkout $LATEST_TAG && \
sudo systemctl daemon-reload && \
sudo systemctl restart nexus.service
```

![Desktop-screenshot-10-27-2024_02_16_PM](https://github.com/user-attachments/assets/d79d1b01-07d0-4589-8e2f-a36349ef986a)

## 4. Usefull Commands

**1. Based-on ran Nexus Labs node**

`Save the Prover-id`

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

**2. Important Note** 

- Delete all Nexus Node running service

```
sudo systemctl stop nexus.service && sudo systemctl disable nexus.service && sudo rm /etc/systemd/system/nexus.service && sudo systemctl daemon-reload && sudo systemctl reset-failed
```
