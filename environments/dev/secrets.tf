# 動作確認用のダミー値。実際のパスワードや API キーは、コードに書かず Portal や CLI で登録する
resource "azurerm_key_vault_secret" "sample" {
  name         = "sample-secret"
  value        = "hello-from-key-vault"
  key_vault_id = module.keyvault.id

  # ロールが付与されてからシークレットを作る（付与前だと 403 になる）
  depends_on = [azurerm_role_assignment.me_kv_secrets_officer]
}
