# Getting Started - プロジェクト開始手順

Azure Common Platform を進めるための手順書の目次です。手順は Phase ごとのファイルに分かれています。作業は Step 順に進めてください。

| Phase | 手順書 | Step | 内容 |
| --- | --- | --- | --- |
| Phase0 | [GETTING_STARTED_Phase0.md](GETTING_STARTED_Phase0.md) | Step0 〜 Step9 | 準備編：方針決め・Azure / ツール / GitHub の準備・Terraform State・Resource Group の初回構築 |
| Phase1 | [GETTING_STARTED_Phase1.md](GETTING_STARTED_Phase1.md) | Step10 〜 Step16 | 基本インフラ構築編：VNet / Subnet / NSG / Linux VM の構築とモジュール化 |
| Phase2 | [GETTING_STARTED_Phase2.md](GETTING_STARTED_Phase2.md) | Step17 〜 Step23 | 共通サービス編：Storage Account / Key Vault / Managed Identity / RBAC |
| Phase3 | [GETTING_STARTED_Phase3.md](GETTING_STARTED_Phase3.md) | Step24 〜 Step30 | ネットワーク設計編：Hub and Spoke / VNet Peering / Private DNS / Private Endpoint |
| Phase4 | [GETTING_STARTED_Phase4.md](GETTING_STARTED_Phase4.md) | Step31 〜 Step36 | 監視編：Log Analytics / Azure Monitor Agent / KQL / アラート |
| Phase5 | [GETTING_STARTED_Phase5.md](GETTING_STARTED_Phase5.md) | Step37 〜 Step43 | CI/CD 編：GitHub Actions / OIDC 認証 / terraform plan・apply の自動化 |

```mermaid
flowchart LR
    P0["Phase0 準備編<br>Step0〜9"] --> P1["Phase1 基本インフラ<br>Step10〜16"] --> P2["Phase2 共通サービス<br>Step17〜23"] --> P3["Phase3 ネットワーク設計<br>Step24〜30"] --> P4["Phase4 監視<br>Step31〜36"] --> P5["Phase5 CI/CD<br>Step37〜43"]
```
