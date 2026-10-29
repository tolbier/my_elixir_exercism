defmodule BoutiqueSuggestions do
  def get_combinations(tops, bottoms, options \\ []) do
    for top <- tops,
        bottom <- bottoms,
        tuple = {top, bottom},
        not clash?(tuple),
        within_max_price?(tuple, options) do
      tuple
    end
  end

  defp clash?({top, bottom}), do: top.base_color == bottom.base_color

  defp within_max_price?({top, bottom}, options) do
    max_price = Keyword.get(options, :maximum_price, 100)
    top.price + bottom.price <= max_price
  end
end
