## Authentik

Authentik is provisioned with `opentofu`.

## Forward authentication

Proxy providers are only served when explicitly attached to the outpost, ref: [authentik_outpost](./tofu/applications.tofu?plain=1#L64): the outpost API filters by the service account's object permissions, so an outpost with no attached providers fetches an empty provider list.

## Robot access
- 'zot-ci' may use the zot app (identity for zot API keys),
- 'forgejo-bots' may use the forgejo app with the 'gituser' entitlement only,
- Forgejo 'user' role via the forgejo scope property mapping — not admin.

## Entitlement bindings
- The 'admin' group receives the admin-tier entitlements.
- Forgejo 'gitadmin' => forgejo admin role; 'gituser' => 'forgejo-bots' robots.
- 'gitrestricted' is left unbound for future assignment (e.g. to 'family').
