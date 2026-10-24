# Azure Common Platform

![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)

## 概要

本リポジトリは、Azure上に共通基盤環境を構築することを目的とした個人プロジェクトです。

Azureの学習だけでなく、実務を意識した **設計・構築・運用** を行い、以下のスキル向上を目的としています。

- Azure（AZ-104 / AZ-305）
- Terraform
- GitHub Actions
- Infrastructure as Code（IaC）
- Azureガバナンス
- ネットワーク設計
- 運用設計

---

## プロジェクトの目標

Hub and Spoke 構成の共通基盤を構築します。

```text
Hub-VNet
│
├─ Log Analytics
├─ Key Vault
├─ Private DNS Zone
│
├─ Dev-VNet
│   └─ Linux VM
│
└─ Test-VNet
    └─ Linux VM
```

---

## 学習対象

| カテゴリ | 対象リソース / 技術 |
| --- | --- |
| 基盤 | Resource Group |
| ネットワーク | Virtual Network / NSG / VNet Peering / Private DNS |
| コンピュート | Virtual Machine |
| ID・セキュリティ | Managed Identity / Key Vault |
| ストレージ | Storage Account / Azure Files |
| 監視 | Azure Monitor / Log Analytics |
| IaC・CI/CD | Terraform / GitHub Actions |

---

## システム構成

構成図は以下を参照してください。

```text
ProjectOverAll/
└─ 01_Architecture/
```

---

## ディレクトリ構成

```text
Azure-Common-Platform
│
├─ README.md
│
├─ ProjectOverAll
│   ├─ 01_Architecture      # 構成図・設計書
│   ├─ 02_Lecture           # 学習ログ・メモ
│   ├─ 03_RunBook           # 運用手順書
│   └─ 04_CostManagement    # コスト管理
│
├─ environments
│   ├─ dev
│   ├─ test
│   └─ prod
│
├─ modules
│   ├─ rg
│   ├─ vnet
│   ├─ subnet
│   ├─ nsg
│   ├─ vm
│   ├─ storage
│   ├─ keyvault
│   ├─ private_dns
│   └─ log_analytics
│
└─ .github
    └─ workflows
```

---

## 構築フェーズ

| Phase | テーマ | 内容 | 状況 |
| --- | --- | --- | --- |
| Phase1 | 基本インフラ | Resource Group / VNet / Subnet / NSG / Linux VM | ⬜ 未着手 |
| Phase2 | 共通サービス | Storage Account / Key Vault / Managed Identity | ⬜ 未着手 |
| Phase3 | ネットワーク設計 | Hub and Spoke / VNet Peering / Private DNS | ⬜ 未着手 |
| Phase4 | 監視 | Log Analytics / Azure Monitor | ⬜ 未着手 |
| Phase5 | CI/CD | GitHub Actions / Terraform Plan / Terraform Apply | ⬜ 未着手 |

> 状況欄は ⬜ 未着手 / 🔄 対応中 / ✅ 完了 で更新します。

---

## 使用技術

| 項目 | 技術 |
| --- | --- |
| Cloud | Microsoft Azure |
| IaC | Terraform |
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

- 不要時は仮想マシンを停止し、コストを削減します。
- コストの実績・分析は `ProjectOverAll/04_CostManagement/` に記録します。

---

## 今後の拡張候補

- Azure Files
- Recovery Services Vault
- VPN Gateway
- Container Apps
- AKS
- Azure Functions
- Azure Front Door

---

## 学習ログ

実施内容や学習メモは以下に整理します。

```text
ProjectOverAll/
└─ 02_Lecture/
```

---

## 更新履歴

| 日付 | 内容 |
| --- | --- |
| 2026-10-24 | リポジトリ作成 |
