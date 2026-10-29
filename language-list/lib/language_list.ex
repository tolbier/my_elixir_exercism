defmodule LanguageList do
  @functional_language "Elixir"
  def new(), do: []

  def add(list, language), do: [language | list]

  def remove([_head | tail]), do: tail

  def first([head | _tail]), do: head

  def count(list), do: length(list)

  def functional_list?(list), do: @functional_language in list
end
