defmodule ProteinTranslation do
  @moduledoc """
  Translates RNA sequences into proteins.
  """

  @codons %{
    "UGU" => "Cysteine",
    "UGC" => "Cysteine",
    "UUA" => "Leucine",
    "UUG" => "Leucine",
    "AUG" => "Methionine",
    "UUU" => "Phenylalanine",
    "UUC" => "Phenylalanine",
    "UCU" => "Serine",
    "UCC" => "Serine",
    "UCA" => "Serine",
    "UCG" => "Serine",
    "UGG" => "Tryptophan",
    "UAU" => "Tyrosine",
    "UAC" => "Tyrosine",
    "UAA" => "STOP",
    "UAG" => "STOP",
    "UGA" => "STOP"
  }

  @doc """
  Given an RNA string, return a list of proteins specified by codons, in order.
  """
  @spec of_rna(String.t()) :: {:ok, list(String.t())} | {:error, String.t()}
  def of_rna(rna) do
    of_rna(to_codons(rna), [])
  end

  @spec to_codons(rna :: String.t()) :: list(String.t())
  defp to_codons(rna) do
    rna
    |> String.codepoints()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join/1)
  end

  @spec of_rna(codons :: list(String.t()), acc :: list(String.t())) ::
          {:ok, list(String.t())} | {:error, String.t()}
  defp of_rna([], acc), do: ok(acc)

  defp of_rna([codon | rest], acc) do
    case of_codon(codon) do
      {:ok, "STOP"} -> ok(acc)
      {:ok, amino_acid} -> of_rna(rest, [amino_acid | acc])
      _ -> error()
    end
  end

  @doc """
  Given a codon, return the corresponding protein
  """

  @spec of_codon(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def of_codon(codon) when is_map_key(@codons, codon), do: {:ok, @codons[codon]}
  def of_codon(_), do: {:error, "invalid codon"}

  @spec ok(acc :: list(String.t())) :: {:ok, list(String.t())}
  defp ok(acc), do: {:ok, acc |> Enum.reverse()}

  @spec error() :: {:error, String.t()}
  defp error(), do: {:error, "invalid RNA"}
end
