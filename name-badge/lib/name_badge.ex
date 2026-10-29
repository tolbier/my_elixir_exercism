defmodule NameBadge do
  def print(id, name, department) do
    print_id(id) <> print_name(name) <> print_department(department)
  end

  def print_id(id) do
    if id do
      "[#{id}] - "
    else
      ""
    end
  end

  def print_name(name) do
    "#{name} "
  end

  def print_department(department) do
    "- " <>
      if department do
        department |> String.upcase()
      else
        "OWNER"
      end
  end
end
