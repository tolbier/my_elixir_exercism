defmodule Username do
  def sanitize(username) do
    username
    |> Enum.flat_map(fn char ->
      case char do
        c when c in ?a..?z or c == ?_ -> [c]
        c when c == ?ä -> ~c"ae"
        c when c == ?ö -> ~c"oe"
        c when c == ?ü -> ~c"ue"
        c when c == ?ß -> ~c"ss"
        _ -> []
      end
    end)
  end
end
