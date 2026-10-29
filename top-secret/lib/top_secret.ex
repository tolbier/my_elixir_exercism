defmodule TopSecret do
  def to_ast(string) do
    Code.string_to_quoted!(string)
  end

  def decode_secret_message_part({operation, _meta, args} = ast, acc)
      when operation in [:def, :defp] do
    {function_name, params} = get_name_and_params(args)
    arity = length(params)
    name_slice = function_name |> to_string() |> String.slice(0, arity)

    {ast, [name_slice | acc]}
  end

  def decode_secret_message_part(ast, acc), do: {ast, acc}

  defp get_name_and_params([{:when, _meta, args} | _rest]), do: get_name_and_params(args)

  defp get_name_and_params([{name, _meta, params} | _rest]) when is_list(params),
    do: {name, params}

  defp get_name_and_params([{name, _meta, params} | _rest]) when is_atom(params), do: {name, []}

  def decode_secret_message(string) do
    {_ast, parts} =
      string
      |> to_ast()
      |> Macro.prewalk([], &decode_secret_message_part/2)

    parts
    |> Enum.reverse()
    |> Enum.join()
  end
end
