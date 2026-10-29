defmodule ComplexNumbers do
  @moduledoc """
  Basic arithmetic and operations on complex numbers.
  """

  import Kernel, except: [div: 2]

  @typedoc """
  In this module, complex numbers are represented as a tuple-pair containing the real and
  imaginary parts.
  For example, the real number `1` is `{1, 0}`, the imaginary number `i` is `{0, 1}` and
  the complex number `4+3i` is `{4, 3}'.
  """
  @type complex :: {number, number}

  @doc """
  Return the real part of a complex number
  """
  @spec real(a :: complex) :: number
  def real({a, _}), do: a

  @doc """
  Return the imaginary part of a complex number
  """
  @spec imaginary(a :: complex) :: number
  def imaginary({_, b}), do: b

  @doc """
  Multiply two complex numbers, or a real and a complex number
  """
  @spec mul(a :: complex | number, b :: complex | number) :: complex
  def mul({a, b}, {c, d}), do: {a * c - b * d, b * c + a * d}
  def mul(r, {a, b}), do: mul({r, 0}, {a, b})
  def mul({a, b}, r), do: mul({r, 0}, {a, b})

  @doc """
  Add two complex numbers, or a real and a complex number
  """
  @spec add(a :: complex | number, b :: complex | number) :: complex
  def add({a, b}, {c, d}), do: {a + c, b + d}
  def add(r, {a, b}), do: add({r, 0}, {a, b})
  def add({a, b}, r), do: add({a, b}, {r, 0})

  @doc """
  Subtract two complex numbers, or a real and a complex number
  """
  @spec sub(a :: complex | number, b :: complex | number) :: complex
  def sub({a, b}, {c, d}), do: {a - c, b - d}
  def sub(r, {a, b}), do: sub({r, 0}, {a, b})
  def sub({a, b}, r), do: sub({a, b}, {r, 0})

  @doc """
  Divide two complex numbers, or a real and a complex number
  """
  @spec div(a :: complex | number, b :: complex | number) :: complex
  def div({a, b}, {c, d}),
    do: {(a * c + b * d) / (c ** 2 + d ** 2), (b * c - a * d) / (c ** 2 + d ** 2)}

  def div(r, {a, b}), do: div({r, 0}, {a, b})
  def div({a, b}, r), do: div({a, b}, {r, 0})

  @doc """
  Absolute value of a complex number
  """
  @spec abs(a :: complex) :: number
  def abs({a, b}), do: :math.sqrt(a ** 2 + b ** 2)

  @doc """
  Conjugate of a complex number
  """
  @spec conjugate(a :: complex) :: complex
  def conjugate({a, b}), do: {a, -b}

  @doc """
  Exponential of a complex number
  """
  @spec exp(a :: complex) :: complex
  def exp({a, b}), do: {:math.exp(a) * :math.cos(b), :math.exp(a) * :math.sin(b)}
end
