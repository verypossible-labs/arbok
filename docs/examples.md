# Examples

**mix.exs:**

List versions with `mix hex.info arbok`.

```elixir
deps = [
  {:arbok, "~> VERSION"},
]
```

**application.ex:**

Ensure certain Actions, Policies, and Scopes exist on start.

```elixir
action_list = :delete
actions = [action_list]
scope_devices_shadows = :"devices.shadows"
scopes = [scope_devices_shadows]
scope_rules = [{:permit, action_list, scope_devices_shadows}]
policies = [{"default person policy", scope_rules}]

arbok_opts = [
  {:actions, actions},
  {:policies, policies}
  {:scopes, scopes},
]

children = [
  {Arbok, arbok_opts}
]
```

**ets.ex**

```elixir
```

**business_logic.ex**

Rig device shadow deletion with authorization, only allowing a device shadow to be deleted if the
Authid is permitted the `:delete` Action on the `:"device.shadows"` Scope.

```elixir
def delete_device_shadow(device_shadow_id, authid) do
  action = :delete
  scope = :"devices.shadows"

  case Arbok.verify(authid, action, scope) do
    :ok -> Persistence.delete(device_shadow_id)
    {:error, _} -> {:error, :unauthorized}
  end
end
```
