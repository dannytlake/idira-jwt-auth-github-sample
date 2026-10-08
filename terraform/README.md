# Safes as code

Developers cannot create safes with Secrets Manager policy. Safes live in
Privilege Cloud. This Terraform lets a team create its own safes through a
pull request, with the security team as reviewer.

| Step | Tool | Result |
| --- | --- | --- |
| 1 | Terraform (`terraform/`) | The safes `dev-reporting-app` and `prod-reporting-app` exist in Privilege Cloud. |
| 2 | Conjur Sync | Each safe syncs to Secrets Manager as `data/vault/<safe-name>`. |
| 3 | Policy as code (`policy/`) | Each pipeline gets access to its own safe. |

Each safe gets three members:

- `Conjur Sync`, so the safe syncs to Secrets Manager.
- The PAM admins group, so the PAM team manages the safe as it does today.
- The app team group. It can add accounts, but it cannot read them back.
  Only the pipelines read the secrets, through the policy grant.

Each safe also gets one database account, `reporting_app`:

1. The app team gives the current password once, as `initial_passwords`.
   This is the password that was hard-coded before.
2. Privilege Cloud rotates it right away (`rotate_now`). The old value in the
   code and the copy in Terraform state stop working.
3. Nobody knows the new password. The pipelines get it from Secrets Manager
   on demand.

This is an example. It is not applied to a tenant. The provider, resource and
attribute names follow the `cyberark/idsec` provider, but they are not checked
against its docs. The same applies to the permission names and the rotate-now
API call.
