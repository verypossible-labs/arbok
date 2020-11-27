# Concepts

Following is an outline of the entities and processes that compose Arbok's functionality.

## Action

Actions are implemented as maps. They represent an Authentication Identity's intent. You may
define your own Actions. While Actions can be defined via compile time configuration, it is
recommended to use run time configuration where possible. In either case see `Arbok` for more
information.

Action examples:

- `:create`
- `:delete`
- `:execute`
- `:list`
- `:read`
- `:write`

## Authentication Identity

Authentication Identities are implemented as maps. They have many Policies.

Integration example:

Your app has Persons and Personal Access Tokens. When a Person is created an associated
Authentication Identity is also created. When that Person authenticates successfully with your
application, it can use the associated Authentication Identity to perform Verifications.

## Policy

Policies are implemented as maps. They have many Scope Rules. Policies have a unique name
field. When Policies are merged, their Scope Rules are merged. Scope Rules are unique within a
Policy on the combination of their Scope and Action.

## Reduced Policy

A Reduced Policy is a single Policy resulting from merging other Policies. Typically all Policies
associated with a particular Authentication Identity.

## Rule

Rules are implemented as atoms. They represent a logical decision.

Rule atoms:

- `:permit`
- `:forbid`

You can not define your own Rules. An explicit forbid rule is one that is actually specified. An
implicit forbid rule is when no explicit forbid nor explicit permit rules exist.

## Scope

Scopes are implemented as maps. They represent a logical domain. Scopes have a unique name field.

Example Scopes:

- `:devices`
- `:"devices.shadows"`
- `:persons`
- `:"persons.billing"`

## Scope Rule

Scope Rules are implemented as maps. They represent a rule applied to the combination of an Action
and a Scope. When Scope Rules are merged, forbid rules always take precedence over permit rules.

## Verification

The process of checking an action or constraint. Verification fails due to explicit or implicit
forbid rules. `Arbok.verify/3` checks if an Authentication Identity's Reduced Policy permits them
to take the desired Action on the indicated Scope.
