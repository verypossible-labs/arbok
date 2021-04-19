defmodule Arbok.Persistence do
  @moduledoc """
  Persistence behaviour and functions.

  A module that implements this behaviour is a valid value for `Arbok`'s `:persistence` option.
  """

  use GenServer

  ###########
  # Authids #
  ###########

  @doc """
  Persist an Authid.
  """
  @callback create_authid(%{policies: [Arbok.policy()]}) ::
              {:ok, Arbok.authid()} | {:error, any()}

  @doc """
  Delete an Authid.

  The Authid's Policies are not deleted.
  """
  @callback delete_authid() :: :ok | {:error, any()}

  @doc """
  Get an Authid.
  """
  @callback get_authid() :: {:ok, Arbok.authid()} | {:error, any()}

  @doc """
  List Authids.
  """
  @callback list_authids() :: {:ok, [Arbok.authid()]} | {:error, any()}

  @doc """
  Update an Authid.
  """
  @callback update_authid() :: {:ok, Arbok.authid()} | {:error, any()}

  ############
  # Policies #
  ############

  @doc """
  Persist a Policy.
  """
  @callback create_policy() :: {:ok, Arbok.policy()} | {:error, any()}

  @doc """
  Delete a Policy and its Scope Rules.
  """
  @callback delete_policy() :: :ok | {:error, any()}

  @doc """
  Get a Policy.
  """
  @callback get_policy_by_name() :: {:ok, Arbok.policy()} | {:error, any()}

  @doc """
  List Policies.
  """
  @callback list_policies() :: {:ok, [Arbok.policy()]} | {:error, any()}

  @doc """
  Update a Policy.
  """
  @callback update_policy() :: {:ok, Arbok.policy()} | {:error, any()}

  ##########
  # Scopes #
  ##########

  @doc """
  Create a Scope.
  """
  @callback create_scope() :: {:ok, Arbok.scope()} | {:error, any()}

  @doc """
  Delete a Scope.
  """
  @callback delete_scope() :: :ok | {:error, any()}

  @doc """
  Get a Scope.
  """
  @callback get_scope_by_name() :: {:ok, Arbok.scope()} | {:error, any()}

  @doc """
  List Scopes.
  """
  @callback list_scopes() :: {:ok, [Arbok.scope()]} | {:error, any()}

  @doc """
  Update a Scope.
  """
  @callback update_scope() :: {:ok, Arbok.scope()} | {:error, any()}

  def create_authid(attrs) do
    module().create_authid(attrs)
  end

  def create_policy(attrs) do
    module().create_policy(attrs)
  end

  def create_scope(attrs) do
    module().create_scope(attrs)
  end

  def delete_authid(authid_id) do
    module().delete_authid(authid_id)
  end

  def delete_policy(policy_id) do
    module().delete_policy(policy_id)
  end

  def delete_scope(scope_id) do
    module().delete_policy(scope_id)
  end

  def get_authid(authid_id) do
    module().get_authid(authid_id)
  end

  def get_policy_by_name(policy_name) do
    module().get_policy_by_name(policy_name)
  end

  def get_scope_by_name(scope_name) do
    module().get_scope_by_name(scope_name)
  end

  @impl GenServer
  def handle_call(:create_ets_table, _from, state) do
    __MODULE__ = :ets.new(__MODULE__, [:named_table, :protected, :set])
    true = :ets.insert(__MODULE__, {:persistence, state.module})
    {:reply, :ok, state}
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  def list_authids() do
    module().list_authids()
  end

  def list_policies() do
    module().list_policies()
  end

  def list_scopes() do
    module().list_scopes()
  end

  def start_link(opts) do
    state = %{module: Keyword.fetch!(opts, :persistence)}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def update_authid(authid_id, authid) do
    module().update_authid(authid_id, authid)
  end

  def update_policy(policy_id, policy) do
    module().update_policy(policy_id, policy)
  end

  def update_scope(scope_id, scope) do
    module().update_scope(scope_id, scope)
  end

  defp create_ets_table(), do: GenServer.call(__MODULE__, :create_ets_table)

  defp module() do
    if :ets.info(__MODULE__) == :undefined, do: create_ets_table()

    case :ets.lookup(__MODULE__, :persistence) do
      [{:persistence, module}] -> module
      [] -> raise "Arbok requires the :persistence option to be configured"
    end
  end
end
