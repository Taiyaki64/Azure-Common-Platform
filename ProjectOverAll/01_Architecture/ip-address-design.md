# アドレス設計

Phase3 で Hub and Spoke（VNet Peering）を行う際、**アドレス空間が重複すると接続できない**ため、将来分も含めて事前に決めています。
新しい VNet / Subnet を追加するときは、既存と重複しないことを確認し、この表を更新します。

## VNet

| VNet | アドレス空間 | 用途 | 作成する Phase |
| --- | --- | --- | --- |
| Hub-VNet | 10.0.0.0/16 | 共通サービス（Key Vault / DNS / 監視） | Phase3 |
| Dev-VNet | 10.1.0.0/16 | 開発環境 | **Phase1** |
| Test-VNet | 10.2.0.0/16 | テスト環境 | Phase3 |
| Prod-VNet | 10.3.0.0/16 | 本番環境（予約） | 未定 |

## Subnet（Dev-VNet 内）

| Subnet | アドレス | 用途 |
| --- | --- | --- |
| snet-acp-dev-app-001 | 10.1.1.0/24 | VM 配置用 |
| （予約） | 10.1.2.0/24 | Private Endpoint 用（Phase2 以降） |
