defmodule RnaTranscription do
  @moduledoc """
  Transcribes DNA nucleotides into their RNA complements.
  """
  @dna_to_rna %{
    ?G => ?C,
    ?C => ?G,
    ?T => ?A,
    ?A => ?U
  }

  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

    iex> RnaTranscription.to_rna(~c"ACTG")
    ~c"UGAC"
  """
  @spec to_rna([char]) :: [char]
  def to_rna(dna) do
    for dna_char <- dna do
      @dna_to_rna[dna_char]
    end
  end
end
