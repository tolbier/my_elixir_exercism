defmodule RPG.CharacterSheet do
  def welcome() do
    IO.puts("Welcome! Let's fill out your character sheet together.")
  end

  defp ask(prompt) do
    IO.gets(prompt)
    |> String.trim()
  end

  def ask_name(), do: ask("What is your character's name?\n")

  def ask_class(), do: ask("What is your character's class?\n")

  def ask_level() do
    IO.gets("What is your character's level?\n")
    |> Integer.parse()
    |> elem(0)
  end

  def run() do
    welcome()
    name = ask_name()
    class = ask_class()
    level = ask_level()
    character = %{class: class, level: level, name: name}
    IO.inspect(character, label: "Your character")
  end
end
