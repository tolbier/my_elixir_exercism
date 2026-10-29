defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank account, making it available for further operations.
  """
  @spec open() :: account
  def open() do
    {:ok, pid} = Agent.start_link(fn -> 0 end)
    pid
  end

  @doc """
  Close the bank account, making it unavailable for further operations.
  """
  @spec close(account) :: :ok
  def close(account) do
    Agent.stop(account)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer | {:error, :account_closed}
  def balance(account) do
    with :ok <- check_process_alive(account), do: Agent.get(account, & &1)
  end

  @doc """
  Add the given amount to the account's balance.
  """
  @spec deposit(account, integer) :: :ok | {:error, :account_closed | :amount_must_be_positive}
  def deposit(account, amount) do
    with :ok <- check_process_alive(account),
         :ok <- check_amount_positive(amount) do
      Agent.get_and_update(account, &{:ok, &1 + amount})
    end
  end

  @doc """
  Subtract the given amount from the account's balance.
  """
  @spec withdraw(account, integer) ::
          :ok | {:error, :account_closed | :amount_must_be_positive | :not_enough_balance}
  def withdraw(account, amount) do
    with :ok <- check_process_alive(account),
         :ok <- check_amount_positive(amount) do
      Agent.get_and_update(account, &withdraw_update(&1, amount))
    end
  end

  @spec check_process_alive(account) :: :ok | {:error, :account_closed}
  defp check_process_alive(account) do
    if Process.alive?(account) do
      :ok
    else
      {:error, :account_closed}
    end
  end

  @spec check_amount_positive(integer) :: :ok | {:error, :amount_must_be_positive}
  defp check_amount_positive(amount) when amount < 0, do: {:error, :amount_must_be_positive}
  defp check_amount_positive(_), do: :ok

  @spec check_enough_balance(integer) :: :ok | {:error, :not_enough_balance}
  defp check_enough_balance(new_balance) when new_balance < 0,
    do: {:error, :not_enough_balance}

  defp check_enough_balance(_), do: :ok

  @spec withdraw_update(integer, integer) :: {:ok | {:error, :not_enough_balance}, integer}
  defp withdraw_update(balance, amount) do
    new_balance = balance - amount

    case check_enough_balance(new_balance) do
      :ok -> {:ok, new_balance}
      error -> {error, balance}
    end
  end
end
