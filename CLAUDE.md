# CLAUDE.md

このファイルは、本リポジトリで作業する Claude 向けのプロジェクトルールです。
作業を始める前に必ず読み、以下のルールに従ってください。

---

## プロジェクト概要

- Azure 上に Hub and Spoke 構成の共通基盤を Terraform で構築する**個人の学習・ポートフォリオ用プロジェクト**
- 目的：Azure（AZ-104 / AZ-305）・Terraform・GitHub Actions・IaC・ネットワーク設計・運用設計のスキル向上
- 全体像は `README.md`、作業手順は `GETTING_STARTED.md` を参照する
- 作業は `GETTING_STARTED.md` の Step 順に進める。どの Step の作業かを意識し、手順書と実装がずれたら手順書も更新する

## 回答ルール

- **日本語で回答する**
- 利用者は Azure / Terraform / Git の学習中。専門用語は簡単な説明を添え、「何をしているか」だけでなく「なぜ必要か」も説明する
- コードを書いたら、要点（何のリソースか・重要な設定値の意味）を短く説明する
- 推測で進めず、分からない点・決めるべき点は確認する

---

## 安全ルール（最重要）

### 実行前に必ず利用者の確認を取るコマンド

| コマンド | 理由 |
| --- | --- |
| `terraform apply` | Azure にリソースが作成・変更され、課金が発生する |
| `terraform destroy` | リソースが削除される |
| `git push` | GitHub に公開される |
| `az` コマンドでのリソース作成・変更・削除 | Azure に直接影響する |

- `terraform apply` の前には、必ず `terraform plan` を実行し、**追加・変更・削除の件数と内容を説明してから**確認を取る
- `plan` に `destroy` / `must be replaced` が含まれる場合は、特に強調して説明する
- `terraform fmt` / `terraform validate` / `terraform plan` / `git status` / `git diff` などの確認系コマンドは実行してよい

### 機密情報を扱わない・コミットしない

- 以下のファイルは**コミットしない**。内容をチャットに表示しない
  - `terraform.tfvars` / `*.tfvars.json`（サブスクリプション ID・自宅 IP など）
  - `*.tfstate` / `*.tfstate.backup`
  - `.terraform/`
  - SSH 秘密鍵（`~/.ssh/acp_dev_rsa` など）
- コミット前は `git status` で上記が含まれていないことを確認する
- サブスクリプション ID・IP アドレス・パスワードなどをコードに直接書かない。変数にして `terraform.tfvars` で渡す
- `terraform.tfvars` を変更したら、値を伏せた `terraform.tfvars.example` も更新する

---

## コストルール

- 月額コスト：**目標 5,000円以内 / 上限 10,000円以内**
- 安価な SKU を優先する（VM：`Standard_B1s`、ディスク：`Standard_LRS`）
- 高額になりやすいリソース（VPN Gateway / Azure Firewall / Bastion / AKS / Application Gateway など）を提案・作成する場合は、**月額の目安を必ず伝えてから**確認を取る
- VM には自動シャットダウン（23:00 / Tokyo Standard Time）を設定する
- 停止は `az vm deallocate`（OS 内のシャットダウンでは課金が続く）

---

## 命名規則

形式：`<種類>-<PJ名>-<環境>-<リージョン>-<連番>`（PJ名：`acp` / リージョン：`jpe` = Japan East）

| リソース | 略称 | 例 |
| --- | --- | --- |
| Resource Group | rg | `rg-acp-dev-jpe-001` |
| Virtual Network | vnet | `vnet-acp-dev-jpe-001` |
| Subnet | snet | `snet-acp-dev-app-001` |
| NSG | nsg | `nsg-acp-dev-app-001` |
| Virtual Machine | vm | `vm-acp-dev-001` |
| Network Interface | nic | `nic-acp-dev-001` |
| Public IP | pip | `pip-acp-dev-001` |
| OS Disk | osdisk | `osdisk-acp-dev-001` |
| Key Vault | kv | `kv-acp-dev-jpe-001` |
| Log Analytics | log | `log-acp-hub-jpe-001` |
| Private DNS Zone | — | Azure の規定名（例：`privatelink.blob.core.windows.net`） |
| Storage Account | st | `stacpdevjpe001`（小文字英数字のみ・3〜24文字・全世界で一意） |

上記にないリソースは、Microsoft Cloud Adoption Framework の略称に従う。

## タグ規則

全リソースに以下のタグを付ける（`locals.tf` の `local.common_tags` を使う）。

| タグ名 | 値 |
| --- | --- |
| `Project` | `AzureCommonPlatform` |
| `Environment` | `dev` / `test` / `prod` |
| `Owner` | `Taiyaki64` |
| `ManagedBy` | `Terraform` |

## アドレス設計

| VNet | アドレス空間 | 用途 |
| --- | --- | --- |
| Hub-VNet | 10.0.0.0/16 | 共通サービス（Key Vault / DNS / 監視） |
| Dev-VNet | 10.1.0.0/16 | 開発環境 |
| Test-VNet | 10.2.0.0/16 | テスト環境 |
| Prod-VNet | 10.3.0.0/16 | 本番環境（予約） |

- Subnet は各 VNet 内で `/24` 単位で切り出す（例：Dev の VM 用は `10.1.1.0/24`、`10.1.2.0/24` は Private Endpoint 用に予約）
- 新しい VNet / Subnet を追加する際は、既存と重複しないことを確認し、`ProjectOverAll/01_Architecture/` のアドレス設計も更新する

## ネットワーク・セキュリティ方針

- インターネットからの受信は、SSH（22番）を利用者の自宅 IP（`/32`）からのみ許可する。`*` / `Any` で開放しない
- VM はパスワード認証を無効にし、SSH 鍵認証のみとする
- PaaS（Storage / Key Vault など）は、可能な範囲で Private Endpoint / ネットワーク制限を使う

---

## Terraform のルール

- バージョン：Terraform `>= 1.9.0` / azurerm Provider `~> 4.0`
- State：Azure Storage の backend（`rg-acp-tfstate-jpe-001`）に保存する。State 用リソースは Terraform で管理しない
- 作業後は `terraform fmt -recursive` と `terraform validate` を実行する
- `.terraform.lock.hcl` はコミットする
- 既存リソースのコードの場所を変える（モジュール化・リネーム）ときは、`moved` ブロックを使い、作り直しが発生しないようにする
- Portal での手動作成・変更はしない（確認のみ）。手動変更が必要な場合は理由を説明する

### ディレクトリ構成

```text
environments/<env>/   # 環境ごとのルートモジュール（dev / test / prod）
  main.tf             # terraform / backend / provider / module 呼び出し
  locals.tf           # 共通タグなど
  variables.tf        # 変数定義
  outputs.tf          # 出力値
  terraform.tfvars    # 変数の値（コミットしない）
  terraform.tfvars.example
modules/<name>/       # 再利用するモジュール
  main.tf / variables.tf / outputs.tf
```

### コーディング規約

- リソースのローカル名：モジュール内は `this`、ルートでは役割名（`main` / `app` など）
- 変数には `description` と `type` を書く
- 値のハードコードは避け、環境ごとに変わる値は変数にする
- コメントは日本語で、「なぜそうしているか」が分かりにくい箇所に書く

---

## Git のルール

- `main` は動作確認済みのコードのみ。作業は `feature/<phase>-<内容>` ブランチで行う（例：`feature/phase2-keyvault`）
- Pull Request を作成して `main` にマージする
- コミットメッセージ：`<種類>: <内容>`（日本語）
  - `feat`：機能・リソース追加 / `fix`：修正 / `docs`：ドキュメント / `chore`：設定・構成 / `refactor`：リファクタリング
  - 例：`feat: dev 環境に NSG を追加`

---

## ドキュメントのルール

| 保存先 | 内容 |
| --- | --- |
| `ProjectOverAll/01_Architecture/` | 構成図・設計書（アドレス設計・命名規則など） |
| `ProjectOverAll/02_Lecture/` | 学習ログ（ファイル名：`YYYY-MM-DD_Phase<N>_<内容>.md`） |
| `ProjectOverAll/03_RunBook/` | 運用手順書（起動・停止・接続・トラブル対応） |
| `ProjectOverAll/04_CostManagement/` | コストの実績・分析 |

- 作業の区切りでは、学習ログの作成を提案する（テンプレート：やったこと / 学んだこと / ハマったこと・解決方法 / 次にやること）
- Phase が完了したら、`README.md` の「構築フェーズ」の状況欄（⬜ 未着手 / 🔄 対応中 / ✅ 完了）を更新する

---

## 現在の進捗

> 作業が進んだらこの欄を更新する。

- 現在のフェーズ：Phase1（準備中）
- 次にやること：`GETTING_STARTED.md` の Step0 から開始
