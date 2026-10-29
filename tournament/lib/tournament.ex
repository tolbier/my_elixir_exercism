defmodule Tournament.Results do
  @moduledoc """
  Tracks a team's wins, draws and losses, deriving points and matches played.
  """

  defstruct wins: 0, draws: 0, losses: 0

  @type t :: %__MODULE__{wins: non_neg_integer, draws: non_neg_integer, losses: non_neg_integer}

  @spec win(t) :: t
  def win(results), do: %{results | wins: results.wins + 1}

  @spec draw(t) :: t
  def draw(results), do: %{results | draws: results.draws + 1}

  @spec loss(t) :: t
  def loss(results), do: %{results | losses: results.losses + 1}

  @spec matches_played(t) :: non_neg_integer
  def matches_played(results), do: results.wins + results.draws + results.losses

  @spec points(t) :: non_neg_integer
  def points(results), do: results.wins * 3 + results.draws
end

defmodule Tournament do
  @moduledoc """
  Tallies match results into a formatted tournament standings table.
  """

  alias Tournament.Results

  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @header "Team                           | MP |  W |  D |  L |  P"

  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    input
    |> build_results()
    |> format_results()
  end

  @spec format_results(%{String.t() => Results.t()}) :: String.t()
  defp format_results(results) do
    results
    |> Enum.sort_by(fn {team, _results} -> team end)
    |> Enum.sort_by(fn {_team, results} -> Results.points(results) end, :desc)
    |> Enum.map(&format_row/1)
    |> then(&Enum.join([@header | &1], "\n"))
  end

  @spec format_row({String.t(), Results.t()}) :: String.t()
  defp format_row({team, results}) do
    [
      pad_team(team),
      pad_number(Results.matches_played(results)),
      pad_number(results.wins),
      pad_number(results.draws),
      pad_number(results.losses),
      pad_last_number(Results.points(results))
    ]
    |> Enum.join("|")
  end

  @spec pad_team(String.t()) :: String.t()
  defp pad_team(team), do: String.pad_trailing(team, 31)

  @spec pad_number(non_neg_integer) :: String.t()
  defp pad_number(n), do: " " <> String.pad_leading(Integer.to_string(n), 2) <> " "

  @spec pad_last_number(non_neg_integer) :: String.t()
  defp pad_last_number(n), do: " " <> String.pad_leading(Integer.to_string(n), 2)

  @spec build_results(list(String.t())) :: %{String.t() => Results.t()}
  defp build_results(input) do
    Enum.reduce(input, %{}, &process_line/2)
  end

  @spec process_line(String.t(), %{String.t() => Results.t()}) :: %{
          String.t() => Results.t()
        }
  defp process_line(line, results) do
    case String.split(line, ";") do
      [home, away, "win"] ->
        results
        |> update_team(home, &Results.win/1)
        |> update_team(away, &Results.loss/1)

      [home, away, "loss"] ->
        results
        |> update_team(home, &Results.loss/1)
        |> update_team(away, &Results.win/1)

      [home, away, "draw"] ->
        results
        |> update_team(home, &Results.draw/1)
        |> update_team(away, &Results.draw/1)

      _ ->
        results
    end
  end

  @spec update_team(
          %{String.t() => Results.t()},
          String.t(),
          (Results.t() -> Results.t())
        ) :: %{String.t() => Results.t()}
  defp update_team(results, team, fun) do
    Map.update(results, team, fun.(%Results{}), fun)
  end
end
