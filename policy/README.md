# Policy as code

Two workloads, two safes. Each file gives one pipeline an identity and
access to one safe.

| File | Workload | Logs in from | Can read |
| --- | --- | --- | --- |
| `reporting-dev.yml` | `github-apps/reporting-dev` | this repo, `dev` branch | `dev-reporting-app` safe |
| `reporting-prod.yml` | `github-apps/reporting-prod` | this repo, `prod` branch | `prod-reporting-app` safe |

To onboard the next app, copy one file and change the names.

`reporting.yml` holds the same two workloads in one file. Use either the
combined file or the two single files, not both.

These files are examples. They are not applied to a tenant yet. Before you
apply them:

- The safes must exist in Privilege Cloud and sync to Secrets Manager.
  Policy cannot create a safe.
- The `github` JWT authenticator must allow hosts under `data/github-apps`
  to log in. That is a one-time admin step, not part of these files.
