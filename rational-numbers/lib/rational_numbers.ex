defmodule RationalNumbers do
  @moduledoc """
  Arithmetic and exponentiation of rational numbers.
  """

  @type rational :: {integer, integer}

  @doc """
  Add two rational numbers
  """
  @spec add(r1 :: rational, r2 :: rational) :: rational
  def add({a1, b1}, {a2, b2}), do: reduce({a1 * b2 + a2 * b1, b1 * b2})

  @doc """
  Subtract two rational numbers
  """
  @spec subtract(r1 :: rational, r2 :: rational) :: rational
  def subtract({a1, b1}, {a2, b2}), do: reduce({a1 * b2 - a2 * b1, b1 * b2})

  @doc """
  Multiply two rational numbers
  """
  @spec multiply(r1 :: rational, r2 :: rational) :: rational
  def multiply({a1, b1}, {a2, b2}), do: reduce({a1 * a2, b1 * b2})

  @doc """
  Divide two rational numbers
  """
  @spec divide_by(num :: rational, den :: rational) :: rational
  def divide_by({a1, b1}, {a2, b2}), do: reduce({a1 * b2, a2 * b1})

  @doc """
  Absolute value of a rational number
  """
  @spec abs(r :: rational) :: rational
  def abs({a, b}), do: reduce({Kernel.abs(a), Kernel.abs(b)})

  @doc """
  Exponentiation of a rational number by an integer
  """
  @spec pow_rational(r :: rational, n :: integer) :: rational

  def pow_rational({a, b}, n) when n < 0 do
    m = Kernel.abs(n)
    reduce({b ** m, a ** m})
  end

  def pow_rational({a, b}, n), do: reduce({a ** n, b ** n})

  @doc """
  Exponentiation of a real number by a rational number
  """
  @spec pow_real(n :: integer, r :: rational) :: float
  def pow_real(n, {a, b}), do: :math.pow(n ** a, 1 / b)

  @doc """
  Reduce a rational number to its lowest terms
  """
  @spec reduce(r1 :: rational) :: rational
  def reduce({a1, b1}) when b1 < 0, do: reduce({a1 * -1, b1 * -1})

  def reduce({a1, b1}) do
    gcd = Integer.gcd(a1, b1)
    {div(a1, gcd), div(b1, gcd)}
  end
end
