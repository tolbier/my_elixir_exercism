defmodule Grep do
  @moduledoc """
  Searches files for lines matching a pattern, similar to the Unix `grep` command.
  """

  @type context :: %{
          invert: boolean(),
          case_insensitive: boolean(),
          entire_line: boolean(),
          file_names_only: boolean(),
          line_numbers: boolean(),
          multiple_files: boolean()
        }

  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, raw_flags, files) do
    context = parse_context(raw_flags, files)

    files
    |> Enum.flat_map(fn file_name ->
      file_name
      |> read_lines()
      |> filter(pattern, context)
      |> format(file_name, context)
    end)
    |> Enum.map_join("", &(&1 <> "\n"))
  end

  @spec parse_context([String.t()], [String.t()]) :: context()
  defp parse_context(raw_flags, files) do
    %{
      invert: "-v" in raw_flags,
      case_insensitive: "-i" in raw_flags,
      entire_line: "-x" in raw_flags,
      file_names_only: "-l" in raw_flags,
      line_numbers: "-n" in raw_flags,
      multiple_files: length(files) > 1
    }
  end

  @spec read_lines(String.t()) :: [{String.t(), pos_integer()}]
  defp read_lines(file_name) do
    file_name
    |> File.read!()
    |> String.trim_trailing("\n")
    |> String.split("\n")
    |> Enum.with_index(1)
  end

  @spec filter([{String.t(), pos_integer()}], String.t(), context()) ::
          [{String.t(), pos_integer()}]
  defp filter(list, pattern, context) do
    Enum.filter(list, fn {line, _idx} ->
      {line, pattern} |> normalize(context) |> matches?(context) != context.invert
    end)
  end

  @spec matches?({String.t(), String.t()}, context()) :: boolean()
  defp matches?({line, pattern}, %{entire_line: true}), do: line == pattern
  defp matches?({line, pattern}, _), do: String.contains?(line, pattern)

  @spec normalize({String.t(), String.t()}, context()) :: {String.t(), String.t()}
  defp normalize(tuple, %{case_insensitive: true}),
    do: tuple |> Tuple.to_list() |> Enum.map(&String.downcase/1) |> List.to_tuple()

  defp normalize(tuple, _), do: tuple

  @spec format([{String.t(), pos_integer()}], String.t(), context()) :: [String.t()]
  defp format([], _, %{file_names_only: true}), do: []
  defp format(_, file_name, %{file_names_only: true}), do: [file_name]

  defp format(filtered_results, file_name, context),
    do: Enum.map(filtered_results, &format_line(&1, file_name, context))

  @spec format_line({String.t(), pos_integer()}, String.t(), context()) :: String.t()
  defp format_line({line, idx}, file_name, context) do
    file_prefix(file_name, context) <> line_prefix(idx, context) <> line
  end

  @spec file_prefix(String.t(), context()) :: String.t()
  defp file_prefix(file_name, %{multiple_files: true}), do: "#{file_name}:"
  defp file_prefix(_file_name, _), do: ""

  @spec line_prefix(pos_integer(), context()) :: String.t()
  defp line_prefix(idx, %{line_numbers: true}), do: "#{idx}:"
  defp line_prefix(_, _), do: ""
end
