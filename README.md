# Azure Common Platform

![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)

## 概要

本リポジトリは、Azure 上に Hub and Spoke 構成の共通基盤を Terraform で構築しながら学ぶ、**個人の学習用プロジェクト**です。

手順書に沿って Phase ごとに作業を進め、設計・構築・運用の流れを実際に手を動かして身につけることを目的としています。学習の過程で試行錯誤した内容（つまずいた点や設計の判断）も記録として残しています。

身につけたいスキルは次のとおりです。

- Azure（AZ-104 / AZ-305）
- Terraform
- GitHub Actions
- Infrastructure as Code（IaC）
- Azure ガバナンス
- ネットワーク設計
- 運用設計

> ⚠️ 学習用のため、本番利用は想定していません。サブスクリプション ID・自宅 IP・SSH 鍵などの機密情報は Git に含めない方針です（`terraform.tfvars` は `.gitignore` で除外し、値を伏せた `terraform.tfvars.example` のみ管理しています）。

---

## 構築する構成

Hub and Spoke 構成の共通基盤です。共通サービスを Hub に置き、環境ごとの VNet（Spoke）を VNet Peering でつなぎます。

```text
Hub-VNet (10.0.0.0/16)
│   ├─ Log Analytics
│   └─ Private DNS Zone
│
├─ Dev-VNet (10.1.0.0/16)      # 開発環境（主に検証を行う環境）
│   ├─ Linux VM
│   ├─ Storage Account / Key Vault
│   ├─ Managed Identity
│   └─ Private Endpoint
│
├─ Test-VNet (10.2.0.0/16)     # テスト環境
│
└─ Prod-VNet (10.3.0.0/16)     # 本番環境（アドレスのみ予約）
```

アドレス設計の詳細は [ip-address-design.md](ProjectOverAll/01_Architecture/ip-address-design.md) を参照してください。

---

## 学習対象

| カテゴリ | 対象リソース / 技術 |
| --- | --- |
| 基盤 | Resource Group |
| ネットワーク | Virtual Network / NSG / VNet Peering / Private DNS / Private Endpoint |
| コンピュート | Virtual Machine |
| ID・セキュリティ | Managed Identity / Key Vault / RBAC |
| ストレージ | Storage Account |
| 監視 | Azure Monitor / Log Analytics / メトリックアラート |
| IaC・CI/CD | Terraform / GitHub Actions（OIDC 認証・承認付き apply） |

---

## システム構成図

構成図（draw.io）は Phase ごとに、次のフォルダに保存しています。

```text
ProjectOverAll/01_Architecture/
├─ architecture-phase1.drawio   # 基本インフラ
├─ architecture-phase2.drawio   # 共通サービス
├─ architecture-phase3.drawio   # Hub and Spoke
├─ architecture-phase4.drawio   # 監視
├─ architecture-phase5.drawio   # CI/CD
└─ ip-address-design.md         # アドレス設計
```

---

## ディレクトリ構成

```text
Azure-Common-Platform
│
├─ README.md
├─ CLAUDE.md                     # AI アシスタント向けのプロジェクトルール
│
├─ .github
│   └─ workflows
│       ├─ terraform-plan.yml        # PR で fmt / validate / plan を実行
│       ├─ terraform-apply.yml       # main への merge で hub → test を承認制で apply
│       └─ terraform-apply-env.yml   # 1 環境を apply する共通部品
│
├─ ProjectOverAll
│   ├─ 01_Architecture           # 構成図・設計書
│   ├─ 02_Lecture                # 学習ログ・手順書（GETTING_STARTED*.md）
│   ├─ 03_RunBook                # 運用手順書
│   └─ 04_CostManagement         # コスト管理
│
├─ environments                  # 環境ごとのルートモジュール（State も環境ごとに分離）
│   ├─ hub                       # 共通サービス（VNet / Private DNS / Log Analytics）
│   ├─ dev                       # 開発環境
│   ├─ test                      # テスト環境
│   └─ prod                      # 本番環境（予約・未作成）
│
└─ modules                       # 再利用するモジュール
    ├─ rg
    ├─ vnet
    ├─ subnet
    ├─ nsg
    ├─ vnet_peering
    ├─ vm
    ├─ vm_monitoring
    ├─ storage
    ├─ keyvault
    ├─ managed_identity
    ├─ private_dns
    ├─ private_endpoint
    └─ log_analytics
```

各環境のフォルダは、次のファイルで構成しています。

| ファイル | 役割 |
| --- | --- |
| `main.tf` | Terraform / backend / provider の設定と、モジュールの呼び出し |
| `variables.tf` | 外から渡す値の定義 |
| `locals.tf` | 共通タグなど、内部で使う値 |
| `outputs.tf` | `apply` 後に表示する値 |
| `terraform.tfvars` | 実際の値（**Git に含めない**） |
| `terraform.tfvars.example` | 値を伏せた見本 |

---

## 構築フェーズ

作業は、手順書（`ProjectOverAll/02_Lecture/GETTING_STARTED_Phase<N>.md`）の Step 順に進めています。全体の目次は [GETTING_STARTED.md](ProjectOverAll/02_Lecture/GETTING_STARTED.md) です。

状況の凡例：⬜ 未着手 / 🔄 対応中 / ✅ 完了

| Phase | テーマ | 内容 | 状況 |
| --- | --- | --- | --- |
| Phase1 | 基本インフラ | Resource Group / VNet / Subnet / NSG / Linux VM | ✅ |
| Phase2 | 共通サービス | Storage Account / Key Vault / Managed Identity | ✅ |
| Phase3 | ネットワーク設計 | Hub and Spoke / VNet Peering / Private DNS / Private Endpoint | ✅ |
| Phase4 | 監視 | Log Analytics / Azure Monitor / アラート | ✅ |
| Phase5 | CI/CD | GitHub Actions / OIDC 認証 / Terraform Plan / 承認付き Apply | 🔄 |

---

## CI/CD の運用方針（Phase5）

- **Pull Request**：`fmt` と `plan`（hub / test / dev）を自動実行し、結果を PR 上で確認します。
- **`main` への merge**：hub → test の順に `apply` します。Environment の承認（Required reviewers）を通るまで、ジョブは始まりません。
- **dev**：`plan` のみ CI で実行し（リフレッシュなし）、`apply` は手元の PC で行います。
- **認証**：パスワードやキーを保存しない OIDC（フェデレーション資格情報）を使います。`plan` 用と `apply` 用で ID を分け、`plan` 用は読み取り中心の権限にしています。

---

## 使用技術

| 項目 | 技術 |
| --- | --- |
| Cloud | Microsoft Azure |
| IaC | Terraform（`>= 1.9.0`）/ azurerm Provider（`~> 4.0`） |
| CI/CD | GitHub Actions |
| Version Control | GitHub |
| OS | Ubuntu Linux |
| Documentation | Markdown |
| Diagram | draw.io |

---

## コスト目標

| 項目 | 金額（月額） |
| --- | --- |
| 目標 | 5,000円以内 |
| 上限 | 10,000円以内 |

- VM は `Standard_B1s` など安価なサイズを使い、毎日 23:00（日本時間）に自動シャットダウンします。
- 使わないときは `az vm deallocate` で割り当てを解除し、課金を止めます（OS 内のシャットダウンでは課金が続きます）。
- VPN Gateway / Azure Firewall / Bastion / AKS など、高額になりやすいリソースは、月額の目安を確認してから作成します。

---

## 今後の拡張候補

- Azure Files
- Recovery Services Vault
- VPN Gateway
- Container Apps
- AKS
- Azure Functions
- Azure Front Door
