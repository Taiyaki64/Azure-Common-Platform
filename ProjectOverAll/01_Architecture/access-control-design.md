# 権限設計一覧（アカウント・サービスアカウント・権限・制御方法）

作成日：2026-11-15 ／ 対象：Azure Common Platform（Hub / Dev / Test）＋ GitHub Actions

> 📌 この一覧は、**コード（Terraform・ワークフロー）と手順書（Phase0〜5）の記載**から作成しています。Azure / GitHub の**実際の設定値を確認したものではありません**。`az` コマンドで作成した部分（Phase0 / Phase5）は Terraform 管理外のため、「確認方法」の列のコマンドで実態と突き合わせてください。

---

## 1. 全体像（誰が・どこから・何に触るか）

```text
[人間]  Taiyaki64 ──(az login / 自宅 PC)──────────────▶ Azure（Terraform 実行：dev の apply、hub/test の手動実行）
        Taiyaki64 ──(GitHub ログイン)────────────────▶ GitHub（PR 作成・マージ・apply の承認）

[CI]    GitHub Actions ──(OIDC)─▶ Entra ID ─▶ app-acp-github-plan-001  ─▶ Azure（読み取り中心）
                                         └──▶ app-acp-github-apply-001 ─▶ Azure（作成・変更）

[VM]    vm-acp-dev-001 ──(Managed Identity)─▶ id-acp-dev-jpe-001 ─▶ Key Vault / Storage（dev）
```

---

## 2. アカウント（ID）一覧

| # | 種別 | 名前 | 作成場所 | 管理方法 | 認証方式 | 用途 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 人間（Entra ID ユーザー） | 利用者本人（Taiyaki64） | Entra ID | Portal / 手動 | `az login`（ユーザーログイン） | Terraform の手元実行、Azure の確認、az による土台の作成 |
| 2 | サービスプリンシパル（アプリ登録） | `app-acp-github-plan-001` | Entra ID | **`az` で手動作成**（Terraform 管理外） | OIDC（シークレット無し） | PR の `terraform plan` |
| 3 | サービスプリンシパル（アプリ登録） | `app-acp-github-apply-001` | Entra ID | **`az` で手動作成**（Terraform 管理外） | OIDC（シークレット無し） | main マージ後の `terraform apply`（hub / test） |
| 4 | マネージド ID（ユーザー割り当て） | `id-acp-dev-jpe-001` | dev の RG | Terraform（`modules/managed_identity`） | Azure が自動管理（パスワード無し） | dev VM が Key Vault / Storage にアクセスする |
| 5 | 人間（GitHub アカウント） | Taiyaki64 | GitHub | GitHub | GitHub ログイン | リポジトリ管理者、Environment の承認者 |
| 6 | GitHub Actions のジョブ ID | `GITHUB_TOKEN`（ワークフロー実行ごと） | GitHub | ワークフローの `permissions:` | 自動発行（実行中のみ有効） | リポジトリの読み取り、OIDC トークンの要求 |
| 7 | VM の OS ユーザー | 管理ユーザー（SSH 鍵認証） | dev VM 内 | Terraform（`modules/vm`） | **SSH 鍵のみ**（パスワード認証は無効） | VM へのログイン |

---

## 3. Azure RBAC（ロール割り当て）一覧

### 3-1. 誰に・どのロールを・どの範囲に

| # | 対象の ID | ロール | 種類 | スコープ（範囲） | 付与方法 | 付けた理由 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ① 利用者本人 | Owner（所有者）※ | 管理プレーン | サブスクリプション | サブスクリプション作成時（個人契約の既定） | 全リソースの作成・変更。※手順書に明記はなく、「所有者」と記載されているため推定 |
| 2 | ① 利用者本人 | **Storage Blob Data Contributor** | データプレーン | State 用ストレージ（`stacptfstate55814`） | `az role assignment create`（Phase0 の手順） | State（Blob）の読み書き。所有者でもデータ用ロールは別に必要 |
| 3 | ① 利用者本人（Terraform 実行者） | **Key Vault Secrets Officer** | データプレーン | `kv-acp-dev-jpe-001` | **Terraform**（`environments/dev/roles.tf`） | RBAC 方式の Key Vault では、所有者でもシークレットを作れないため |
| 4 | ④ `id-acp-dev-jpe-001`（VM） | **Key Vault Secrets User** | データプレーン | `kv-acp-dev-jpe-001` | **Terraform**（`roles.tf`） | VM がシークレットを**読み取る**ため（読み取り専用） |
| 5 | ④ `id-acp-dev-jpe-001`（VM） | **Storage Blob Data Contributor** | データプレーン | `stacpdevjpe001` | **Terraform**（`roles.tf`） | VM が Blob を読み書きするため |
| 6 | ② `app-acp-github-plan-001` | **Reader** | 管理プレーン | サブスクリプション | `az role assignment create`（Phase5 Step39） | plan のリフレッシュ（リソースの読み取り） |
| 7 | ② `app-acp-github-plan-001` | **role-acp-terraform-plan**（カスタム） | 管理プレーン | サブスクリプション | `az role assignment create` | Reader に無い「Storage / Log Analytics のキー取得」のみ追加 |
| 8 | ② `app-acp-github-plan-001` | **Storage Blob Data Contributor** | データプレーン | **State 用ストレージのみ** | `az role assignment create` | State の読み取りとロック（Blob のリース取得）のため |
| 9 | ③ `app-acp-github-apply-001` | **Contributor** | 管理プレーン | サブスクリプション | `az role assignment create`（Phase5 Step39） | RG・VNet・Peering などの作成・変更 |
| 10 | ③ `app-acp-github-apply-001` | **Storage Blob Data Contributor** | データプレーン | **State 用ストレージのみ** | `az role assignment create` | State の読み書き・ロック |

### 3-2. カスタムロール定義

| ロール名 | 許可する操作（Actions） | 作成方法 |
| --- | --- | --- |
| `role-acp-terraform-plan` | `Microsoft.Storage/storageAccounts/listKeys/action`<br>`Microsoft.OperationalInsights/workspaces/sharedKeys/action` | `az role definition create`（スコープ：サブスクリプション） |

### 3-3. 「付けていない」権限（意図的）

| ID | 付けていないロール | 理由 |
| --- | --- | --- |
| ③ apply 用 | User Access Administrator / Owner | hub / test の Terraform は `azurerm_role_assignment` を作らないため。**dev の apply（ロール割り当てを含む）は自宅 PC のまま**にしている |
| ② plan 用 | Contributor 系 | PR のジョブは、ワークフローを書き換えて出せるため、書き込み権限を持たせない |
| ④ VM | Contributor / Owner | VM が侵害されても、Azure リソースの管理操作はできないようにする（Secrets User は読み取りのみ） |
| 全 ID | Key Vault Administrator | 必要最小限の原則 |

---

## 4. 信頼関係（OIDC フェデレーション資格情報）

「どの GitHub の条件で来たトークンなら、どの Azure ID として扱うか」の対応表です。**subject は完全一致**で判定されます。

| Azure 側の ID | 資格情報名 | issuer | subject（信頼する条件） | 発行されるタイミング |
| --- | --- | --- | --- | --- |
| `app-acp-github-plan-001` | `github-pull-request` | `https://token.actions.githubusercontent.com` | `repo:Taiyaki64/Azure-Common-Platform:pull_request` | 自リポジトリの PR のジョブ（フォーク元の PR は不可） |
| `app-acp-github-apply-001` | `github-environment-hub` | 同上 | `repo:Taiyaki64/Azure-Common-Platform:environment:hub` | `hub` Environment の**承認後**のジョブのみ |
| `app-acp-github-apply-001` | `github-environment-test` | 同上 | `repo:Taiyaki64/Azure-Common-Platform:environment:test` | `test` Environment の**承認後**のジョブのみ |

> 💡 apply 用は `pull_request` を信頼していません。PR のジョブがワークフローを書き換えても、apply 用の ID は発行されません。

---

## 5. 何で制御しているか（制御レイヤー別）

| レイヤー | 仕組み | 設定内容 | 守っているもの | 設定方法 |
| --- | --- | --- | --- | --- |
| **ID の認証** | OIDC（フェデレーション資格情報） | クライアントシークレット無し。GitHub の一時トークンのみ | シークレットの漏えい・期限切れ | `az ad app federated-credential create` |
| | マネージド ID | VM にユーザー割り当て ID を付与 | VM 内にパスワード・キーを置かない | Terraform（`modules/vm` の `identity`） |
| | SSH 鍵認証 | `disable_password_authentication = true` | VM への総当たりログイン | Terraform（`modules/vm`） |
| **Azure の認可** | Azure RBAC | 上記 3 章のロール割り当て | リソースの操作・データへのアクセス | Terraform / `az` |
| | Key Vault の RBAC モード | `rbac_authorization_enabled = true`（アクセスポリシーは不使用） | シークレットへのアクセスを RBAC に一本化 | Terraform（`modules/keyvault`） |
| **ネットワーク** | NSG | SSH(22) は自宅 IP（`/32`）からのみ許可（`Allow-SSH-From-MyIP`） | VM への不正な接続 | Terraform（`environments/dev/main.tf`） |
| | Key Vault ファイアウォール | `default_action = "Deny"`、自宅 IP と dev の app Subnet のみ許可、`bypass = AzureServices` | シークレットへのネットワーク経由の到達 | Terraform（`modules/keyvault`） |
| | Storage ファイアウォール | `default_action = "Deny"`、自宅 IP と dev の app Subnet のみ許可、匿名アクセス禁止、TLS1.2 以上 | Blob へのネットワーク経由の到達 | Terraform（`modules/storage`） |
| | Private Endpoint ＋ Private DNS | `pep-acp-dev-blob-001` / `pep-acp-dev-kv-001`（Hub の Private DNS Zone に登録） | PaaS への通信を VNet 内（プライベート IP）に閉じる | Terraform（`modules/private_endpoint` ほか） |
| **CI/CD の関所** | GitHub Environments | `hub` / `test` に Required reviewers（自分）。承認まで apply ジョブも OIDC トークンも始まらない | 意図しない apply | `gh api`（Phase5 Step40） |
| | 削除検知 | plan に delete / 作り直しが含まれると apply を中止（`allow_destroy` で手動許可） | 誤った削除 | `terraform-apply-env.yml` |
| | 同時実行制御 | `concurrency: terraform-apply`（同時に 2 つ走らせない） | State の競合 | `terraform-apply.yml` |
| | ワークフロー権限 | `permissions: id-token: write / contents: read` のみ | `GITHUB_TOKEN` の過剰権限 | 各ワークフロー |
| | トリガーの選択 | `pull_request`（`pull_request_target` は不使用）。フォーク PR は Secrets / OIDC が使えない | 外部からの PR による悪用 | 各ワークフロー |
| | ブランチ保護（Ruleset `protect-main`） | PR 必須、`fmt` / `plan` の成功が必須、force push・削除禁止、Bypass は空 | 未検証コードの main 混入 | GitHub の Settings（手動） ※要確認 |
| **機密情報** | GitHub Secrets | 下の 6 章 | ログ・コードへの機密値の混入 | `gh secret set` |
| | `.gitignore` | `terraform.tfvars` / `*.tfstate` / `.terraform/` を除外 | Git への機密情報の混入 | `.gitignore` |
| **State** | Azure Storage backend | `use_azuread_auth = true`（アクセスキーを使わない）、Terraform 管理外 | State の改ざん・漏えい | `environments/*/main.tf` |
| **運用** | VM の自動シャットダウン | 23:00（Tokyo Standard Time） | 課金の抑制 | Terraform |

---

## 6. GitHub Secrets（Azure / 機密情報の受け渡し）

| Secret 名 | 内容 | 使う ID・ワークフロー | 機密度 |
| --- | --- | --- | --- |
| `AZURE_TENANT_ID` | Entra ID のテナント ID | plan / apply 共通 | 中 |
| `AZURE_SUBSCRIPTION_ID` | サブスクリプション ID | plan / apply 共通（`TF_VAR_subscription_id`） | 中 |
| `AZURE_PLAN_CLIENT_ID` | plan 用アプリの ID | `terraform-plan.yml` | 低（ID のみ。単体では認証できない） |
| `AZURE_APPLY_CLIENT_ID` | apply 用アプリの ID | `terraform-apply-env.yml` | 低（同上） |
| `ALLOWED_SSH_SOURCE_IP` | 自宅 IP（/32） | `terraform-plan.yml`（dev の plan 用） | 中 |
| `ALERT_EMAIL` | アラート通知先メール | `terraform-plan.yml` | 中 |
| `SSH_PUBLIC_KEY` | SSH **公開鍵** | `terraform-plan.yml` | 低（公開鍵のため。**秘密鍵は登録しない**） |

> 💡 クライアントシークレット（パスワード）は存在しません。漏えいしても、そのまま Azure にログインできる値はありません。

---

## 7. 操作別：誰ができるか（早見表）

| 操作 | 利用者本人 | plan 用 ID | apply 用 ID | VM（マネージド ID） |
| --- | --- | --- | --- | --- |
| Azure リソースの閲覧 | ✅ | ✅（Reader） | ✅ | ❌ |
| Azure リソースの作成・変更・削除 | ✅ | ❌ | ✅（Contributor） | ❌ |
| ロール割り当ての作成 | ✅（Owner） | ❌ | ❌ | ❌ |
| State の読み書き | ✅ | ✅ | ✅ | ❌ |
| Storage / Log Analytics のキー取得 | ✅ | ✅（カスタムロール） | ✅（Contributor に含まれる） | ❌ |
| Key Vault シークレットの読み取り | ✅（Officer） | ❌ | ❌ | ✅（Secrets User） |
| Key Vault シークレットの作成・更新 | ✅（Officer） | ❌ | ❌ | ❌ |
| dev Storage の Blob 読み書き | ✅（※自宅 IP 経由のみ） | ❌ | ❌ | ✅（Contributor） |
| VM に SSH ログイン | ✅（自宅 IP ＋ 秘密鍵） | ❌ | ❌ | — |
| `terraform apply`（hub / test） | ✅（手元でも可） | ❌ | ✅（CI：承認後） | ❌ |
| `terraform apply`（dev） | ✅（**自宅 PC のみ**） | ❌ | ❌（未自動化） | ❌ |

---

## 8. 気づいた点・改善候補（リスクと対応案）

| # | 内容 | リスク | 対応案 | 優先度 |
| --- | --- | --- | --- | --- |
| 1 | apply 用 ID が**サブスクリプション全体の Contributor** | 万一トークンを悪用されると、サブスクリプション内の全リソースを変更・削除できる | 現状は「承認済み Environment のジョブ限定」で緩和済み。発展課題として RG 単位に絞る（State 用 RG は対象外にする） | 中 |
| 2 | plan 用 ID のカスタムロールで**キーを取得できる**（完全な読み取り専用ではない） | PR のジョブから Storage のアクセスキーを取得できる | 自リポジトリの PR のみ信頼。リポジトリを Public にする場合は、PR の作成権限（コラボレーター）に注意 | 中 |
| 3 | **plan 用 ID に State の書き込み権限**がある | PR のジョブから State を書き換えられる | State のロックに必要なため現状は許容。将来、State を環境別の Container に分け、スコープを絞ることも可能 | 低 |
| 4 | 利用者本人の Owner が常時有効 | 手元の `az login` が漏れると影響が大きい | PIM は個人サブスクリプションでは使えないため、普段は Contributor で作業する運用も検討 | 低 |
| 5 | Key Vault の**Purge Protection が無効** | 削除後、7 日以内でも完全消去できてしまう | 学習用のため許容（コード内コメントのとおり） | 低 |
| 6 | Ruleset（ブランチ保護）が**実際に設定済みかが、この資料では未確認** | main への直接 push が可能な可能性 | `gh api repos/Taiyaki64/Azure-Common-Platform/rulesets` で確認 | 中 |
| 7 | dev は CI で apply できない（ファイアウォール） | dev の変更は自宅 PC に依存。自宅 IP が変わると 403 | Self-hosted Runner（発展課題）。当面は CLAUDE.md の手順どおり | 低 |
| 8 | OS ユーザーに紐づく sudo 権限・SSH 鍵の管理は未整理 | 秘密鍵（`acp_dev_rsa`）の紛失・漏えい | 秘密鍵は Git・Secrets に置かない。バックアップ場所を RunBook に記載 | 低 |

---

## 9. 実態の確認コマンド（読み取りのみ）

```powershell
# 変数の準備（値はチャットに貼らないこと）
$SUB_ID = az account show --query id -o tsv

# 1. 自分の権限（サブスクリプションと State 用ストレージ）
az role assignment list --assignee (az ad signed-in-user show --query id -o tsv) --all --query "[].{role:roleDefinitionName, scope:scope}" -o table

# 2. CI 用 ID の権限
$PLAN_SP_ID  = az ad sp list --display-name "app-acp-github-plan-001"  --query "[0].id" -o tsv
$APPLY_SP_ID = az ad sp list --display-name "app-acp-github-apply-001" --query "[0].id" -o tsv
az role assignment list --assignee $PLAN_SP_ID  --all --query "[].{role:roleDefinitionName, scope:scope}" -o table
az role assignment list --assignee $APPLY_SP_ID --all --query "[].{role:roleDefinitionName, scope:scope}" -o table

# 3. 信頼関係（subject）
az ad app federated-credential list --id (az ad app list --display-name "app-acp-github-plan-001"  --query "[0].appId" -o tsv) --query "[].{name:name, subject:subject}" -o table
az ad app federated-credential list --id (az ad app list --display-name "app-acp-github-apply-001" --query "[0].appId" -o tsv) --query "[].{name:name, subject:subject}" -o table

# 4. カスタムロールの定義
az role definition list --custom-role-only true --query "[].{name:roleName, actions:permissions[0].actions}" -o json

# 5. dev のロール割り当て（Key Vault / Storage / マネージド ID）
az role assignment list --all --query "[?contains(scope,'rg-acp-dev')].{who:principalName, role:roleDefinitionName, scope:scope}" -o table

# 6. GitHub 側（Secrets 名・Environments・Ruleset）
gh secret list
gh api repos/Taiyaki64/Azure-Common-Platform/environments --jq ".environments[].name"
gh api repos/Taiyaki64/Azure-Common-Platform/rulesets --jq ".[].name"
```

---

## 10. 更新ルール

- ロール割り当て・アプリ登録・Environment・Secrets を追加／変更したら、この資料も更新する
- 新しい環境（Prod など）を追加する場合は、**3 章・4 章・6 章**に行を追加し、apply 用 ID のフェデレーション資格情報（`environment:prod`）も追加する
- 参考：`GETTING_STARTED_Phase2.md`（Managed Identity・RBAC）／ `GETTING_STARTED_Phase5.md`（OIDC・CI 用 ID）／ `environments/dev/roles.tf`
