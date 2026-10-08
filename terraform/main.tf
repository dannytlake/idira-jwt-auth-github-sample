# Safes for the reporting app, one for dev and one for prod, and the database
# account in each.
#
# A team creates its own safes and accounts through a pull request. The security team owns
# this pattern and reviews the change. After the apply, each safe syncs to
# Secrets Manager as data/vault/<safe-name>, and policy/reporting.yml grants
# the pipelines access to it.
#
# Example only, not applied. The provider, resource and attribute names follow
# the cyberark/idsec provider but are not checked against its docs.

terraform {
  required_providers {
    idsec = {
      source = "cyberark/idsec"
    }
  }
}

# The Terraform pipeline logs in as a service user. Its secret comes from the
# pipeline at run time, never from this repo.
provider "idsec" {
  username = var.idsec_username
  secret   = var.idsec_secret
}

locals {
  environments = toset(["dev", "prod"])
}

# 1. The safes: dev-reporting-app and prod-reporting-app.
resource "idsec_pcloud_safe" "reporting" {
  for_each = local.environments

  safe_name                = "${each.key}-reporting-app"
  description              = "Reporting app secrets, ${each.key}"
  managing_cpm             = "PasswordManager" # Privilege Cloud rotates the accounts
  number_of_days_retention = 7
}

# 2. Conjur Sync: syncs each safe to Secrets Manager. Without this member,
#    the safe never appears under data/vault, and policy cannot grant it.
resource "idsec_pcloud_safe_member" "conjur_sync" {
  for_each = idsec_pcloud_safe.reporting

  safe_id     = each.value.safe_id
  member_name = "Conjur Sync"
  member_type = "user"

  permissions = {
    list_accounts               = true
    retrieve_accounts           = true
    view_safe_members           = true
    access_without_confirmation = true
  }
}

# 3. The PAM team manages the safes, as it does today.
resource "idsec_pcloud_safe_member" "pam_admins" {
  for_each = idsec_pcloud_safe.reporting

  safe_id        = each.value.safe_id
  member_name    = var.pam_admins_group
  member_type    = "group"
  permission_set = "full"
}

# 4. The app team may add accounts, but not read them back. Only the
#    pipelines read the secrets, through the policy grant.
resource "idsec_pcloud_safe_member" "app_team" {
  for_each = idsec_pcloud_safe.reporting

  safe_id     = each.value.safe_id
  member_name = var.app_team_group
  member_type = "group"

  permissions = {
    list_accounts     = true
    add_accounts      = true
    retrieve_accounts = false
    use_accounts      = false
  }
}

# 5. The database account in each safe. The app team hands over the current
#    password once. Privilege Cloud manages it from then on.
resource "idsec_pcloud_account" "reporting_db" {
  for_each = local.environments

  safe_name   = idsec_pcloud_safe.reporting[each.key].safe_name
  platform_id = "PostgreSQL"
  address     = var.db_addresses[each.key]
  username    = "reporting_app"
  secret      = var.initial_passwords[each.key]

  secret_management = {
    automatic_management_enabled = true
  }

  depends_on = [idsec_pcloud_safe_member.app_team]
}

# 6. Rotate each password right after onboarding. The value that was
#    hard-coded in the code, and the copy in Terraform state, stop working.
#    Nobody knows the new password. The pipelines get it on demand.
resource "terraform_data" "rotate_now" {
  for_each = idsec_pcloud_account.reporting_db

  triggers_replace = [each.value.id]

  provisioner "local-exec" {
    command = <<-CMD
      curl -sf -X POST \
        -H "Authorization: Bearer $PCLOUD_TOKEN" \
        "${var.pcloud_url}/PasswordVault/API/Accounts/${each.value.id}/Change" \
        -H "Content-Type: application/json" -d '{}'
    CMD
    environment = {
      PCLOUD_TOKEN = var.pcloud_token
    }
  }
}
