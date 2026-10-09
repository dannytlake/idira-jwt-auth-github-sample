# DEMO

Securing CI/CD Pipelines with Idira

GitHub Actions pipelines that get their secrets from Secrets Manager (Conjur)
at run time. The pipeline logs in with its GitHub OIDC token (JWT), so no
secrets are stored in GitHub Secrets. Each run gets the current value, and
Privilege Cloud can rotate the password on the target without any change here.

| Path | What it is | Tested |
| --- | --- | --- |
| `.github/workflows/demo-workflow.yml` | Demo pipeline on `main`. Fetches a username and password from `data/vault/demo-github/github-app01`, then runs two simulated build and deploy steps. | Yes |
| `.github/workflows/dev-workflow.yml` | Same pattern on the `dev` branch, reading the `dev-reporting-app` safe. | No |
| `policy/` | Policy as code. Gives the dev and prod pipelines an identity and access to one safe each. See [`policy/README.md`](policy/README.md). | No |
| `terraform/` | Creates the `dev-reporting-app` and `prod-reporting-app` safes in Privilege Cloud. See [`terraform/README.md`](terraform/README.md). | No |

Only `demo-workflow.yml` has been tested. Everything else
is an example. Review it and adapt it before you use it.

The workflows read these repository variables:

- `CONJUR_URL`
- `CONJUR_ACCOUNT`
- `CONJUR_AUTHN_ID`
