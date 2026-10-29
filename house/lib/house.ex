defmodule House do
  @moduledoc """
  Recites the cumulative nursery rhyme 'This is the House that Jack Built'.
  """

  @data {
    {"house", "Jack built"},
    {"malt", "lay in"},
    {"rat", "ate"},
    {"cat", "killed"},
    {"dog", "worried"},
    {"cow with the crumpled horn", "tossed"},
    {"maiden all forlorn", "milked"},
    {"man all tattered and torn", "kissed"},
    {"priest all shaven and shorn", "married"},
    {"rooster that crowed in the morn", "woke"},
    {"farmer sowing his corn", "kept"},
    {"horse and the hound and the horn", "belonged to"}
  }

  @doc """
  Return verses of the nursery rhyme 'This is the House that Jack Built'.
  """
  @spec recite(start :: integer, stop :: integer) :: String.t()
  def recite(start, stop) do
    for n <- start..stop, into: "" do
      do_recite(n)
    end
  end

  @spec do_recite(integer) :: String.t()
  defp do_recite(n) do
    """
    This is#{verse(n)}
    """
  end

  @spec verse(integer) :: String.t()
  defp verse(0), do: "."

  defp verse(n) do
    {object, action} = elem(@data, n - 1)
    " the #{object} that #{action}#{verse(n - 1)}"
  end
end
