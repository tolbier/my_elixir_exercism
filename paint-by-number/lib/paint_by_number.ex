defmodule PaintByNumber do
  def palette_bit_size(color_count) do
    log2(color_count)
  end

  def log2(n), do: log2(n, 0)

  defp log2(n, exp) do
    if 2 ** exp >= n do
      exp
    else
      log2(n, exp + 1)
    end
  end

  def empty_picture(), do: <<>>

  def test_picture(), do: <<0::2, 1::2, 2::2, 3::2>>

  def prepend_pixel(picture, color_count, pixel_color_index) do
    bit_size = color_count |> palette_bit_size
    <<pixel_color_index::size(bit_size), picture::bitstring>>
  end

  def get_first_pixel(<<>>, _), do: nil

  def get_first_pixel(picture, color_count) do
    bit_size = color_count |> palette_bit_size
    <<result::size(^bit_size), _rest::bitstring>> = picture
    result
  end

  def drop_first_pixel(<<>>, _), do: <<>>

  def drop_first_pixel(picture, color_count) do
    bit_size = color_count |> palette_bit_size
    <<_::size(^bit_size), rest::bitstring>> = picture
    rest
  end

  def concat_pictures(picture1, picture2), do: <<picture1::bitstring, picture2::bitstring>>
end
