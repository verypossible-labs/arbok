defmodule Arbok do
  @moduledoc """
  `Arbok` can be used in a Supervisor's list of children. It's child spec points at
  `Arbok.Persistence` and the resulting `GenServer` will be named as such.

  # Configuration

  Options can be specified at compile time and run time, but the latter takes precedence and is
  the recommended pattern. In either case, because Arbok is a library application, the options are
  only ever leveraged if you start an instance of `Arbok` in your applicaiton.

  - `:actions` - `[Arbok.action()]`. `[]`. A list of Actions that Arbok will ensure exists.
  - `:persistence` - `module()` The `Arbok.Persistence` behaviour implementation to be used.
    implementation.
  - `:policies` - `[Arbok.policy()]`. `[]`. A list of Policies that Arbok will ensure exists.
  - `:scopes` - `[Arbok.scope()]`. `[]`. A list of Scopes that Arbok will ensure exists.

  ## Run Time

  Run time configuration is the recommended method of configuration.

  ```elixir
  action_list = :list
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
  children = [{Arbok, arbok_opts}]
  ```

  ## Compile Time

  ```elixir
  action_list = :list
  actions = [action_list]
  scope_devices_shadows = :"devices.shadows"
  scopes = [scope_devices_shadows]
  scope_rules = [{:permit, action_list, scope_devices_shadows}]
  policies = [{"default person policy", scope_rules}]

  config :arbok,
    actions: actions,
    policies: policies,
    scopes: scopes
  ```
  """

  @typedoc "Must have the `:name` field. Can have more implementation specific fields."
  @type action() :: %{name: atom()}

  @typedoc "Must have the `:policies` field. Can have more implementation specific fields."
  @type authid() :: %{policies: [policy()]}

  @typedoc """
  Must have the `:name` and `:scope_rules` fields. Can have more implementation specific fields.
  """
  @type policy() :: %{name: policy_name(), scope_rules: [scope_rule()]}

  @type policy_name() :: atom()

  @type rule() :: :permit | :forbid

  @typedoc "Must have the `:name` field. Can have more implementation specific fields."
  @type scope() :: %{name: scope_name()}

  @type scope_name() :: atom()

  @typedoc """
  Must have the `:action`, `:scope`, and `:rule` fields. Can have more implementation specific
  fields.
  """
  @type scope_rule() :: %{action: action(), scope: scope(), rule: rule()}

  def child_spec(arg) do
    %{id: __MODULE__, start: {Persistence, :start_link, [arg]}}
  end

  @doc """
  Ensures `action` on `scope` is permitted for `authid`.
  """
  @spec verify(authid(), action(), scope()) ::
          :ok | {:error, {__MODULE__, {:verify, :implicit_forbid | :explicit_forbid}}}
  def verify(authid, action, scope) do
    with {:ok, policy} <- reduce_policies(authid.policies),
         :ok <- check_policy(policy, action, scope) do
      :ok
    else
      {:error, error} -> {:error, {__MODULE__, {:verify, error}}}
    end
  end

  defp check_policy(policy, action, scope) do
    case Map.fetch(policy, {scope, action}) do
      {:ok, :permit} -> :ok
      {:ok, :forbid} -> {:error, :explicit_forbid}
      :error -> {:error, :implicit_forbid}
    end
  end

  defp reduce_policies(policies) do
    policy =
      Enum.reduce(policies, %{}, fn policy, acc ->
        Enum.reduce(policy.scope_rules, acc, fn scope_rule, acc ->
          key = {scope_rule.scope.name, scope_rule.action}

          cond do
            :restrict in [scope_rule.action_type, acc[key]] -> Map.put(acc, key, :restrict)
            true -> Map.put(acc, key, scope_rule.action_type)
          end
        end)
      end)

    {:ok, policy}
  end
end
