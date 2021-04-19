defmodule Arbok.Ets do
  use GenServer
  alias Arbok.Persistence

  @behaviour Persistence

  @impl Persistence
  def create_authid(%{policies: policies} = attrs) do
    Enum.reduce(policies, [], fn %{scope_rules: scope_rules}, errors ->
      Enum.reduce(scope_rules, errors, fn
        %{action: action, scope: scope, rule: rule}, errors when rule in [:permit, :forbid] ->
          with {:action, {:ok, _}} <- {:action, get({:action, action})},
               {:scope, {:ok, _}} <- {:scope, get({:scope, scope})} do
            []
          else
            {:action, :error} -> [{:action, action} | errors]
            {:scope, :error} -> [{:scope, scope} | errors]
          end
      end)
    end)

    authid = Map.put(attrs, :id, :ets.update_counter(__MODULE__, :authid_id, 1, 0))
    :ok = put({:authid, authid.id}, authid)
    {:ok, authid}
  end

  def create_authid(attrs) do
    {:error, {:bad_attrs, attrs}}
  end

  @imple GenServer
  def handle_call(:create_ets_table, _from, state) do
    __MODULE__ = :ets.new(__MODULE__, [:named_table, :protected, :set])
    true = :ets.insert(__MODULE__, {:persistence, state.module})
    {:reply, :ok, state}
  end

  def init(state) do
    {:ok, state}
  end

  def start_link(_opts) do
    state = %{next_id: 1, authids: %{}}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  defp create_ets_table(), do: GenServer.call(__MODULE__, :create_ets_table)

  defp put(key, value) do
    if :ets.info(__MODULE__) == :undefined, do: create_ets_table()
    :ok = :ets.insert(__MODULE__, {key, value})
    :ok
  end

  defp get(key) do
    if :ets.info(__MODULE__) == :undefined, do: create_ets_table()

    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end
end
