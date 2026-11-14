defmodule Wordy do
  @moduledoc """
  Parses and evaluates simple math word problems.
  """

  @typep error_reason :: :expected_number | :unknown_operation | :division_by_zero
  @typep operation :: :plus | :minus | :multiply | :divide
  @typep parse_result :: {:ok, integer, String.t()} | {:error, error_reason()}

  @doc """
  Calculate the math problem in the sentence.
  """
  @spec answer(String.t()) :: integer
  def answer(question) do
    question |> String.downcase() |> read_question()
  end

  @spec read_question(String.t()) :: integer
  defp read_question("what is " <> rest) do
    case read_expression(rest) do
      {:ok, result, "?"} -> result
      _ -> raise ArgumentError
    end
  end

  defp read_question(_), do: raise(ArgumentError)

  @spec read_expression(String.t()) :: parse_result()
  defp read_expression(str) do
    with {:ok, number, rest} <- read_number(str) do
      read_rest_expression(number, rest)
    end
  end

  @spec read_number(String.t()) :: parse_result()
  defp read_number(<<?-, d, rest::binary>>) when d in ?0..?9 do
    {:ok, number, rest} = read_digits(rest, d - ?0)
    {:ok, -number, rest}
  end

  defp read_number(<<d, rest::binary>>) when d in ?0..?9, do: read_digits(rest, d - ?0)
  defp read_number(_), do: {:error, :expected_number}

  @spec read_digits(String.t(), non_neg_integer) :: {:ok, non_neg_integer, String.t()}
  defp read_digits(<<d, rest::binary>>, acc) when d in ?0..?9,
    do: read_digits(rest, acc * 10 + (d - ?0))

  defp read_digits(rest, acc), do: {:ok, acc, rest}

  @spec read_rest_expression(integer, String.t()) :: parse_result()
  defp read_rest_expression(number, rest = "?"), do: {:ok, number, rest}

  defp read_rest_expression(operand_1, str) do
    with {:ok, operation, rest} <- read_operation(str),
         {:ok, operand_2, rest} <- read_number(rest),
         {:ok, result} <- apply_operation(operation, operand_1, operand_2) do
      read_rest_expression(result, rest)
    end
  end

  @spec read_operation(String.t()) :: {:ok, operation(), String.t()} | {:error, error_reason()}
  defp read_operation(" plus " <> rest), do: {:ok, :plus, rest}
  defp read_operation(" minus " <> rest), do: {:ok, :minus, rest}
  defp read_operation(" multiplied by " <> rest), do: {:ok, :multiply, rest}
  defp read_operation(" divided by " <> rest), do: {:ok, :divide, rest}
  defp read_operation(_), do: {:error, :unknown_operation}

  @spec apply_operation(operation(), integer, integer) ::
          {:ok, integer} | {:error, error_reason()}
  defp apply_operation(:plus, a, b), do: {:ok, a + b}
  defp apply_operation(:minus, a, b), do: {:ok, a - b}
  defp apply_operation(:multiply, a, b), do: {:ok, a * b}
  defp apply_operation(:divide, _a, 0), do: {:error, :division_by_zero}
  defp apply_operation(:divide, a, b), do: {:ok, div(a, b)}
end
