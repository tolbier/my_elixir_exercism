defmodule HighSchoolSweetheart do
  def first_letter(name) do
    name
    |> String.trim()
    |> String.first()
  end

  def initial(name) do
    "#{first_letter(name) |> String.upcase()}."
  end

  def initials(full_name) do
    full_name
    |> String.split()
    |> Enum.map(&initial/1)
    |> Enum.join(" ")
    |> String.trim()
  end

  def pair(full_name1, full_name2) do
    label = "#{initials(full_name1)}  +  #{initials(full_name2)}"
    line = String.duplicate("-", String.length(label))

    """
    ❤--#{line}--❤
    |  #{label}  |
    ❤--#{line}--❤
    """
  end
end
