defmodule PhoneNumber do
  @moduledoc """
  Cleans and validates North American Numbering Plan phone numbers.
  """

  @doc """
  Remove formatting from a phone number if the given number is valid. Return an error otherwise.
  """
  @spec clean(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def clean(raw) do
    with {:ok, valid_str} <- validate_str(raw),
         digits = valid_str |> String.to_charlist() |> sanitize(),
         {:ok, valid_digits} <- validate_digits(digits) do
      {:ok, List.to_string(valid_digits)}
    else
      error -> error
    end
  end

  @spec validate_digits(charlist) :: {:ok, charlist} | {:error, String.t()}
  defp validate_digits(digits) do
    case {digits, length(digits)} do
      {_, l} when l > 11 ->
        {:error, "must not be greater than 11 digits"}

      {_, l} when l < 10 ->
        {:error, "must not be fewer than 10 digits"}

      {[?1 | rest], 11} ->
        validate_digits(rest)

      {_, 11} ->
        {:error, "11 digits must start with 1"}

      {[c | _rest], 10} when c in ?0..?1 ->
        {:error, "area code cannot start with #{number(c)}"}

      {[_, _, _, c | _rest], 10} when c in ?0..?1 ->
        {:error, "exchange code cannot start with #{number(c)}"}

      _ ->
        {:ok, digits}
    end
  end

  @numbers {"zero", "one"}

  @spec number(?0..?1) :: String.t()
  defp number(c), do: elem(@numbers, c - ?0)

  @spec validate_str(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_str(str) do
    if String.match?(str, ~r/[^0-9\s().\-\+]/) do
      {:error, "must contain digits only"}
    else
      {:ok, str}
    end
  end

  @spec sanitize(charlist) :: charlist
  defp sanitize(charlist) do
    charlist |> Enum.filter(&(&1 in ?0..?9))
  end
end
