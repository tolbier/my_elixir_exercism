defmodule Allergies do
  @moduledoc """
  Determines which allergies a person has from their allergy score.
  """

  @allergies ~w[cats pollen chocolate tomatoes strawberries shellfish peanuts eggs]
  @doc """
  List the allergies for which the corresponding flag bit is true.
  """
  @spec list(non_neg_integer) :: [String.t()]
  def list(number) do
    for {allergy, bit} <- Enum.zip(@allergies, bits(number)), bit == 1, do: allergy
  end

  @spec bits(non_neg_integer) :: [0 | 1]
  defp bits(byte) do
    for <<(b::size(1) <- <<byte::size(8)>>)>>, do: b
  end

  @doc """
  Returns whether the corresponding flag bit in 'flags' is set for the item.
  """
  @spec allergic_to?(non_neg_integer, String.t()) :: boolean
  def allergic_to?(flags, item), do: item in list(flags)
end
