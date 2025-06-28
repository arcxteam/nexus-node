![com-webp-to-png-converter](https://github.com/user-attachments/assets/0fb7877d-8638-49a3-8a3f-670f9de617d9)

# A Complete Guide Nexus Testnet Node - Fix Issue Nexus Labs (Prover Network)

The Nexus Labs zkVM (zero-knowledge virtual machine) is a modular verifiable internet, as extensible, open-source, highly-parallelized, prover-optimized, contributor-friendly, zkVM written in Rust, focused on performance and security. Read this step to runnig Nexus node as Prover Network.

> **Update**: 2024, 10 Dec for CLI prover-id binding ![Confirm](https://img.shields.io/badge/Testnet_1-END_-red)

> **Update**; 2025, 19 Feb CLI Run for ![Confirm](https://img.shields.io/badge/Testnet_2-CLOSED_-brightgreen)

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
## 2. Start Install

**1. Auto installing**

```bash
curl sSL https://raw.githubusercontent.com/arcxteam/nexus-node/main/nexus.sh | bash
```

**2. Manual installing**

```
curl https://cli.nexus.xyz/ | sh
```

> If you do not already have Rust, you will be prompted to install it.

## 3. Update and Getting an Error

**1. Update CLI for Binding a node-id**

If you have runtime at **previous & run now**, please binding your **node-id** for manual without auto installer skrip `nexus.sh` above. so the step here

- Go to https://app.nexus.xyz/nodes
- Open and wait the dashboard showing all and go section `add node` > `add CLI node` > check `copy` and done
- Open your ssh-vps-terminal, add/input your **YOUR_NODE_ID** and use command to enter
```
echo "YOUR_NODE_ID" > /root/.nexus/node-id
```
> For example 
```diff
- echo "6317901" > ~/.nexus/node-id
```
- And now restart the systemctl nexus-service use command to enter

```
sudo systemctl daemon-reload
sudo systemctl restart nexus.service
sudo journalctl -u nexus.service -f -n 100
```
> Still wait, this having for syncing on website, check `Nexus Point` on section page.....

![image](https://github.com/user-attachments/assets/a2d5e515-df98-4701-93aa-5df3ceb26c57)

![Desktop-screenshot-02-21-2025_12_57_AM](https://github.com/user-attachments/assets/ea0abe49-3f66-4c98-8d30-20443ca0cef3)

**2. Upgrade & restart service for network-api**

logs: If have facing issue cargo/cycles etc `Proof sent! You proved at 0 Hz` try `git tag -l` for the latest Api Network https://github.com/nexus-xyz/network-api/releases/

```
cd ~/.nexus/network-api && \
git fetch --all --tags && \
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
git stash && \
git checkout $LATEST_TAG && \
cd ~/.nexus/network-api/clients/cli && \
cargo clean && \
cargo build --release && \
sudo systemctl daemon-reload && \
sudo systemctl restart nexus.service && \
sudo journalctl -u nexus.service -f -n 100
```

## 4. Usefull Commands

**1. Based-on ran Nexus Labs node**

`Check & Save the Prover-id & Node-id`

- cat $HOME/.nexus/prover-id; echo ""
- cat $HOME/.nexus/node-id; echo ""

`Start and enable the service`

- sudo systemctl stop nexus.service
- sudo systemctl daemon-reload
- sudo systemctl enable nexus.service
- sudo systemctl start nexus.service
- sudo systemctl restart nexus.service

`Checking the status service`

- sudo systemctl status nexus.service
- ps aux | grep nexus

`Monitor the status logs`

- sudo journalctl -u nexus.service -f -n 100

**2. Important Note** 

- Delete all Nexus Node running service

```
sudo systemctl stop nexus.service && sudo systemctl disable nexus.service && sudo rm /etc/systemd/system/nexus.service && sudo systemctl daemon-reload && sudo systemctl reset-failed
```
