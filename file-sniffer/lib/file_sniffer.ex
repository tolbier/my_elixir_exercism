defmodule FileSniffer do
  @file_types %{
    "exe" => {"application/octet-stream", <<0x7F, 0x45, 0x4C, 0x46>>},
    "bmp" => {"image/bmp", <<0x42, 0x4D>>},
    "png" => {"image/png", <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>},
    "jpg" => {"image/jpg", <<0xFF, 0xD8, 0xFF>>},
    "gif" => {"image/gif", <<0x47, 0x49, 0x46>>}
  }

  def type_from_extension(extension) do
    case @file_types[extension] do
      {type, _magic_number} -> type
      nil -> nil
    end
  end

  def type_from_binary(file_binary) do
    Enum.find_value(@file_types, fn {_ext, {type, magic_number}} ->
      size = byte_size(magic_number)

      case file_binary do
        <<^magic_number::binary-size(^size), _body::binary>> -> type
        _ -> nil
      end
    end)
  end

  def verify(file_binary, extension) do
    extension_type = type_from_extension(extension)
    binary_type = type_from_binary(file_binary)

    if extension_type == binary_type and extension_type != nil do
      {:ok, extension_type}
    else
      {:error, "Warning, file format and file extension do not match."}
    end
  end
end
