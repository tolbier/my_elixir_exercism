defmodule BasketballWebsite do
  def extract_from_path(data, path) do
    data
    |> do_extract_from_path(path |> split_on_dots)
  end

  def get_in_path(data, path) do
    data
    |> do_get_in_path(path |> split_on_dots)
  end

  defp split_on_dots(string), do: string |> String.split(".")

  defp do_extract_from_path(nil, _), do: nil
  defp do_extract_from_path(data, []), do: data

  defp do_extract_from_path(data, _path = [h | t]) when is_map(data) do
    data[h]
    |> do_extract_from_path(t)
  end

  defp do_extract_from_path(_data, _path), do: nil

  defp do_get_in_path(data, path) do
    data |> get_in(path)
  end
end
