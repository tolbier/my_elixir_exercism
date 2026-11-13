defmodule SgfParsing do
  @moduledoc """
  Parses Smart Game Format (SGF) strings into trees.
  """

  defmodule Sgf do
    @moduledoc """
    A node of an SGF tree: its properties and its child nodes.
    """

    defstruct properties: %{}, children: []
  end

  @type sgf :: %Sgf{properties: properties(), children: [sgf]}
  @type properties :: %{String.t() => [String.t()]}
  @type error :: {:error, String.t()}

  @type parsed(value) :: {:ok, value, String.t()} | error()

  @non_newline_whitespace [?\t, ?\r, ?\v, ?\f]

  defguardp is_letter(c) when c in ?A..?Z or c in ?a..?z

  @doc """
  Parse a string into a Smart Game Format tree
  """
  @spec parse(encoded :: String.t()) :: {:ok, sgf} | error()
  def parse("(" <> _ = encoded) do
    case parse_tree(encoded) do
      {:ok, tree, ""} -> {:ok, tree}
      {:ok, _tree, _rest} -> {:error, "unexpected input after tree"}
      error -> error
    end
  end

  def parse(""), do: {:error, "tree missing"}
  def parse(";" <> _), do: {:error, "tree missing"}
  def parse(_encoded), do: {:error, "unexpected input after tree"}

  @spec parse_tree(String.t()) :: parsed(sgf)
  defp parse_tree("(" <> rest) do
    with {:ok, node, rest} <- parse_node(rest),
         {:ok, rest} <- close_tree(rest) do
      {:ok, node, rest}
    end
  end

  @spec close_tree(String.t()) :: {:ok, String.t()} | error()
  defp close_tree(")" <> rest), do: {:ok, rest}
  defp close_tree(_rest), do: {:error, "tree missing closing parenthesis"}

  @spec parse_node(String.t()) :: parsed(sgf)
  defp parse_node(";" <> rest) do
    with {:ok, properties, rest} <- parse_properties(rest, %{}),
         {:ok, children, rest} <- parse_children(rest) do
      {:ok, %Sgf{properties: properties, children: children}, rest}
    end
  end

  defp parse_node(_rest), do: {:error, "tree with no nodes"}

  @spec parse_children(String.t()) :: parsed([sgf])
  defp parse_children(";" <> _ = encoded) do
    with {:ok, child, rest} <- parse_node(encoded) do
      {:ok, [child], rest}
    end
  end

  defp parse_children(encoded), do: parse_variations(encoded, [])

  @spec parse_variations(String.t(), [sgf]) :: parsed([sgf])
  defp parse_variations("(" <> _ = encoded, acc) do
    with {:ok, tree, rest} <- parse_tree(encoded) do
      parse_variations(rest, [tree | acc])
    end
  end

  defp parse_variations(rest, acc), do: {:ok, Enum.reverse(acc), rest}

  @spec parse_properties(String.t(), properties()) :: parsed(properties())
  defp parse_properties(<<c, _::binary>> = encoded, acc) when is_letter(c) do
    with {:ok, {key, values}, rest} <- parse_property(encoded) do
      parse_properties(rest, Map.put(acc, key, values))
    end
  end

  defp parse_properties(rest, acc), do: {:ok, acc, rest}

  @spec parse_property(String.t()) :: parsed({String.t(), [String.t()]})
  defp parse_property(encoded) do
    {key, rest} = take_key(encoded, "")

    with :ok <- check_uppercase(key),
         {:ok, values, rest} <- parse_values(rest, []) do
      {:ok, {key, values}, rest}
    end
  end

  @spec take_key(String.t(), String.t()) :: {String.t(), String.t()}
  defp take_key(<<c, rest::binary>>, acc) when is_letter(c), do: take_key(rest, acc <> <<c>>)
  defp take_key(rest, acc), do: {acc, rest}

  @spec check_uppercase(String.t()) :: :ok | error()
  defp check_uppercase(key) do
    if key == String.upcase(key), do: :ok, else: {:error, "property must be in uppercase"}
  end

  @spec parse_values(String.t(), [String.t()]) :: parsed([String.t()])
  defp parse_values("[" <> rest, acc) do
    with {:ok, value, rest} <- parse_value(rest, "") do
      parse_values(rest, [value | acc])
    end
  end

  defp parse_values(_rest, []), do: {:error, "properties without delimiter"}
  defp parse_values(rest, acc), do: {:ok, Enum.reverse(acc), rest}

  @spec parse_value(String.t(), String.t()) :: parsed(String.t())
  defp parse_value("]" <> rest, acc), do: {:ok, acc, rest}
  defp parse_value("\\\n" <> rest, acc), do: parse_value(rest, acc)

  defp parse_value(<<"\\", c::utf8, rest::binary>>, acc),
    do: parse_value(rest, acc <> normalize_whitespace(c))

  defp parse_value(<<c::utf8, rest::binary>>, acc),
    do: parse_value(rest, acc <> normalize_whitespace(c))

  defp parse_value("", _acc), do: {:error, "property value not closed"}

  # Whitespace other than newline becomes a space, escaped or not.
  @spec normalize_whitespace(char()) :: String.t()
  defp normalize_whitespace(c) when c in @non_newline_whitespace, do: " "
  defp normalize_whitespace(c), do: <<c::utf8>>
end
