![com-webp-to-png-converter](https://github.com/user-attachments/assets/0fb7877d-8638-49a3-8a3f-670f9de617d9)

# A Complete Guide Nexus Testnet Node - Fix Issue Nexus Labs (Prover Network)

The Nexus Labs zkVM (zero-knowledge virtual machine) is a modular verifiable internet, as extensible, open-source, highly-parallelized, prover-optimized, contributor-friendly, zkVM written in Rust, focused on performance and security. Read this step to runnig Nexus node as Prover Network.

> [!NOTE]
> **Update**: 2024, 10 Dec for CLI prover-id binding ![Confirm](https://img.shields.io/badge/Testnet_1-END_-red)
> **Update**; 2025, 19 Feb CLI Run for ![Confirm](https://img.shields.io/badge/Testnet_2-ONGOING_-brightgreen)

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

**1. Update CLI for Binding Prover-id**

If you have runtime at previous & now, please binding your prover-id

- Go to https://beta.nexus.xyz/
- Open w/ `CTRL`+`SHIFT`+`i` and go section `application` > `local storage` > check `flutter.proverid` and save
- Open your ssh-vps-terminal, replace **YOUR_PROVER_ID** and use command to enter
```
echo "YOUR_PROVER_ID" > ~/.nexus/prover-id
```
> For example
```diff
- echo "12345aBCdE6789" > ~/.nexus/prover-id
```
- And now restart the systemctl nexus-service use command to enter

```
sudo systemctl restart nexus.service
journalctl -u nexus.service -f -n 100
```
> Still wait, this having for syncing on website, check `Nexus Point` on section page.....

![beta-nexus-xyz-12-10-2024_03_18_PM](https://github.com/user-attachments/assets/ed331dd9-3863-43d0-9e3a-aa5be82146c8)

**2. Upgrade & restart service for network-api**

logs: If have facing issue cargo/cycles etc `Proof sent! You proved at 0 Hz` try `git tag -l` for the latest Api Network https://github.com/nexus-xyz/network-api/releases/

```
cd ~/.nexus/network-api && \
git fetch --all --tags && \
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1)) && \
git checkout $LATEST_TAG && \
cd ~/.nexus/network-api/clients/cli && \
cargo clean && \
cargo build --release && \
sudo systemctl daemon-reload && \
sudo systemctl restart nexus.service && \
sudo journalctl -u nexus.service -f -n 100
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
