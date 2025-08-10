![com-webp-to-png-converter](https://github.com/user-attachments/assets/0fb7877d-8638-49a3-8a3f-670f9de617d9)

# A Complete Guide Nexus Testnet Node - Running on Docker (Non-Interactive)

The Nexus Labs zkVM (zero-knowledge virtual machine) is a modular verifiable internet, as extensible, open-source, highly-parallelized, prover-optimized, contributor-friendly, zkVM written in Rust, focused on performance and security. Read this step to runnig Nexus node as Prover Network.

[![Release Version](https://img.shields.io/github/v/release/nexus-xyz/nexus-cli.svg)](https://github.com/nexus-xyz/nexus-cli/releases)

> 2024, 10 Dec for CLI prover-id binding ![Confirm](https://img.shields.io/badge/Testnet_1-END_-red)

> 2025, 19 Feb CLI Run for ![Confirm](https://img.shields.io/badge/Testnet_2-END_-red)

> **Update**; 2025, 23 JUNE CLI Run for ![Confirm](https://img.shields.io/badge/Testnet_3-ONGOING_-brightgreen)

## Here We Go...Gas!!!
`Is there incentivized?` ![Confirm](https://img.shields.io/badge/Confirm-yes-brightgreen)

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
sudo apt install build-essential pkg-config libssl-dev git-all protobuf-compiler
```
## 2. Start Install using Docker

**1. Auto Installing by Docker**

```bash
git clone https://github.com/arcxteam/nexus-node.git
cd nexus-node
```

**2. Manual Installing by CLI**

```
curl https://cli.nexus.xyz/ | sh
```

> If you do not already have Rust, you will be prompted to install it.

## 3. Update First Setup 

**1. Update CLI for Binding a Wallet Address**

If you have runtime at **previous & run now**, please binding your **node-id** for manual without auto installer skrip `nexus.sh` above. so the step here

- Go to https://app.nexus.xyz/nodes
- Open and wait the dashboard showing all and go section `add node` > `add CLI node` > check `copy` and done
- Open your ssh-vps-terminal, add/input your **WALLET_ADDRESS** and use command to enter
```
echo "WALLET_ADDRESS=your-wallet" >> /root/nexus-node/.env
```
> For example 
```diff
- echo "WALLET_ADDRESS=0x123456789" >> /root/nexus-node/.env
```

**2. After running check logging**

```
docker compose logs -f nexus-docker
```
- or in the root
```
docker logs -f nexus-docker
```

**3. Running on Multiple NODE-ID**

- This will Run and create
- Replace **WALLET_ADDRESS**
- Rename for next wallet address -> **WALLET_ADDRESS_1** more multiple 3,4,5....

- ### If the container is running, you will see the status from the Dashboard nexus slow this processing

> Still wait, this having for syncing on website, check `Nexus Point` on section page.....

![image](https://github.com/user-attachments/assets/a2d5e515-df98-4701-93aa-5df3ceb26c57)

![Desktop-screenshot-02-21-2025_12_57_AM](https://github.com/user-attachments/assets/ea0abe49-3f66-4c98-8d30-20443ca0cef3)

**2. Upgrade version for network-api**

logs: If have facing issue cargo/cycles etc `Proof sent! You proved at 0 Hz` try `git tag -l` for the latest Api Network https://github.com/nexus-xyz/network-api/releases/

```
docker ps -a --filter "name=nexus-docker-" --format "{{.Names}}" | xargs -r docker rm -f && docker images --filter "reference=nexus-docker-*" --format "{{.ID}}" | xargs -r docker rmi -f && rm -rf /root/nexus-data/nexus-docker-* && cd /root/nexus && chmod +x nexus.sh && ./nexus.sh node-id-1.txt
```

## 4. Usefull Commands

**1. Based-on ran Nexus Labs node**


`Checking the status service and resources`

- docker images | grep nexus-docker
- docker ps -a
- docker stats

`Check Version or error`

```
source /root/.bashrc
source /root/.profile
nexus-network --version
```
**2. Important Note** 

- Delete all Nexus Node running service

```
docker rmi -f $(docker images --filter "reference=nexus-docker-*" --format "{{.ID}}")
```
