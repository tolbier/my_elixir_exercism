defmodule Markdown do
  @moduledoc """
  Converts Markdown text into HTML.
  """

  # El formato pendiente guarda {etiqueta, delimitador, acumulador anterior}.
  @typep frame :: String.t() | {String.t(), String.t(), String.t()}
  @typep stack :: [frame()]

  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

      iex> Markdown.parse("This is a paragraph")
      "<p>This is a paragraph</p>"

      iex> Markdown.parse("# Header!\\n* __Bold Item__\\n* _Italic Item_")
      "<h1>Header!</h1><ul><li><strong>Bold Item</strong></li><li><em>Italic Item</em></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(""), do: process("", ["p"], "<p>")

  def parse(text) when is_binary(text) do
    start_line(text, [], "")
  end

  @spec start_line(String.t(), stack(), String.t()) :: String.t()
  defp start_line("", [], acc), do: acc

  defp start_line("* " <> rest, ["ul"], acc) do
    process(rest, ["li", "ul"], acc <> "<li>")
  end

  defp start_line(text, ["ul"], acc) do
    start_line(text, [], acc <> "</ul>")
  end

  defp start_line("#" <> rest = text, [], acc) do
    start_header(rest, 1, text, acc)
  end

  defp start_line("* " <> _rest = text, [], acc) do
    start_line(text, ["ul"], acc <> "<ul>")
  end

  defp start_line(text, [], acc) do
    process(text, ["p"], acc <> "<p>")
  end

  @spec start_header(String.t(), pos_integer(), String.t(), String.t()) :: String.t()
  defp start_header("#" <> rest, level, original, acc) do
    start_header(rest, level + 1, original, acc)
  end

  defp start_header(" " <> rest, level, _original, acc) when level in 1..6 do
    tag = "h" <> Integer.to_string(level)
    process(rest, [tag], acc <> "<" <> tag <> ">")
  end

  defp start_header(_rest, _level, original, acc) do
    process(original, ["p"], acc <> "<p>")
  end

  @spec process(String.t(), stack(), String.t()) :: String.t()
  defp process("\n" <> rest, stack, acc), do: close_line(rest, stack, acc)
  defp process("", stack, acc), do: close_line("", stack, acc)

  defp process("__" <> rest, stack, acc) do
    inline(rest, "strong", "__", stack, acc)
  end

  defp process("_" <> rest, stack, acc) do
    inline(rest, "em", "_", stack, acc)
  end

  defp process(<<char::utf8, rest::binary>>, stack, acc) do
    process(rest, stack, acc <> <<char::utf8>>)
  end

  @spec inline(String.t(), String.t(), String.t(), stack(), String.t()) :: String.t()
  defp inline(rest, tag, _marker, [{tag, _saved_marker, previous_acc} | stack], acc) do
    process(rest, stack, previous_acc <> "<" <> tag <> ">" <> acc <> "</" <> tag <> ">")
  end

  defp inline(rest, tag, marker, stack, acc) do
    process(rest, [{tag, marker, acc} | stack], "")
  end

  @spec close_line(String.t(), stack(), String.t()) :: String.t()
  defp close_line(rest, [{_tag, marker, previous_acc} | stack], acc) do
    close_line(rest, stack, previous_acc <> marker <> acc)
  end

  defp close_line(rest, [tag | stack], acc) when is_binary(tag) do
    start_line(rest, stack, acc <> "</" <> tag <> ">")
  end
end
