# Refactoring log:
# - Added module documentation describing the ledger formatter.
# - Extracted locale-specific headers into private format_header/1 clauses.
# - Extracted row formatting into format_rows/3, leaving format_entries/3 to
#   combine the header and rows.
# - Handled empty entries with a separate format_rows/3 clause.
# - Extracted sorting into sort_entries/1 and replaced the custom comparator with
#   Enum.sort_by/2 using day, description, and amount as the sort key.
# - Replaced Enum.map/2 and Enum.join/2 with a comprehension that builds a string
#   and appends a newline to each formatted entry.
# - Extracted date formatting into format_date/2 and replaced manual date assembly
#   with Calendar.strftime/2 and locale-specific date_pattern/1 clauses.
# - Extracted description formatting, truncation, and padding into helper functions.
# - Moved amount formatting into Ledger.AmountFormatter, separating it from row
#   assembly and removing duplicated numeric formatting for the two locales.
# - Prepared the amount parts, sign, currency symbol, and separators in init/3.
# - Replaced nested currency and locale conditionals with pattern-matched helpers,
#   including build_amount/2 clauses for locale and sign combinations.
# - Separated numeric text construction from currency/sign formatting and padding.
#
# Behavior correction (beyond refactoring):
# - Grouped the integer part recursively with String.split_at/2, inserting a
#   separator every three digits and preserving zeros within groups. The original
#   inserted only one separator and dropped leading zeros in the final group.

defmodule Ledger do
  @moduledoc """
  Formats ledger entries for a given currency and locale.
  """

  @doc """
  Format the given entries given a currency and locale
  """
  @type currency :: :usd | :eur
  @type locale :: :en_US | :nl_NL
  @type entry :: %{amount_in_cents: integer(), date: Date.t(), description: String.t()}

  @spec format_entries(currency(), locale(), list(entry())) :: String.t()
  def format_entries(currency, locale, entries) do
    format_header(locale) <> format_rows(currency, locale, entries)
  end

  @spec format_rows(currency(), locale(), [entry()]) :: String.t()
  defp format_rows(_currency, _locale, _entries = []), do: ""

  defp format_rows(currency, locale, entries) do
    for entry <- sort_entries(entries),
        into: "" do
      format_entry(currency, locale, entry) <> "\n"
    end
  end

  @spec sort_entries([entry()]) :: [entry()]
  defp sort_entries(entries) do
    Enum.sort_by(entries, fn entry ->
      {entry.date.day, entry.description, entry.amount_in_cents}
    end)
  end

  @spec format_header(locale()) :: String.t()
  defp format_header(:en_US) do
    "Date       | Description               | Change       \n"
  end

  defp format_header(_locale) do
    "Datum      | Omschrijving              | Verandering  \n"
  end

  @spec format_entry(currency(), locale(), entry()) :: String.t()
  defp format_entry(currency, locale, entry) do
    format_date(locale, entry) <>
      "|" <> format_description(entry) <> " |" <> format_amount(currency, locale, entry)
  end

  @spec format_date(locale(), entry()) :: String.t()
  defp format_date(locale, entry) do
    Calendar.strftime(entry.date, date_pattern(locale))
  end

  @spec date_pattern(locale()) :: String.t()
  defp date_pattern(_locale = :en_US), do: "%m/%d/%Y "
  defp date_pattern(_locale), do: "%d-%m-%Y "

  @spec format_description(entry()) :: String.t()
  defp format_description(entry) do
    format_long_text(entry.description)
  end

  @spec format_long_text(String.t()) :: String.t()
  defp format_long_text(description) do
    " " <>
      if String.length(description) > 26 do
        truncate_long_text(description)
      else
        pad_trailing_long_text(description)
      end
  end

  @spec truncate_long_text(String.t()) :: String.t()
  defp truncate_long_text(text), do: String.slice(text, 0, 22) <> "..."

  @spec pad_trailing_long_text(String.t()) :: String.t()
  defp pad_trailing_long_text(text), do: String.pad_trailing(text, 25, " ")

  @spec format_amount(currency(), locale(), entry()) :: String.t()
  defp format_amount(currency, locale, entry) do
    Ledger.AmountFormatter.format(entry.amount_in_cents, currency, locale)
  end

  defmodule AmountFormatter do
    @moduledoc """
    Formats monetary amounts for the ledger's currencies and locales.
    """

    @typep state :: %{
             locale: Ledger.locale(),
             currency_symbol: String.t(),
             whole: String.t(),
             cents: String.t(),
             positive: boolean(),
             decimal_separator: String.t(),
             thousands_separator: String.t()
           }

    @spec format(integer(), Ledger.currency(), Ledger.locale()) :: String.t()
    def format(amount_in_cents, currency, locale) do
      init(amount_in_cents, currency, locale)
      |> build()
    end

    @spec init(integer(), Ledger.currency(), Ledger.locale()) :: state()
    defp init(amount_in_cents, currency, locale) do
      amount = abs(amount_in_cents)

      %{
        locale: locale,
        currency_symbol: currency_symbol(currency),
        whole: amount |> div(100) |> to_string(),
        cents: amount |> rem(100) |> to_string() |> String.pad_leading(2, "0"),
        positive: amount_in_cents >= 0,
        decimal_separator: decimal_separator(locale),
        thousands_separator: thousands_separator(locale)
      }
    end

    @spec decimal_separator(Ledger.locale()) :: String.t()
    defp decimal_separator(:en_US),
      do: "."

    defp decimal_separator(_locale),
      do: ","

    @spec thousands_separator(Ledger.locale()) :: String.t()
    defp thousands_separator(:en_US),
      do: ","

    defp thousands_separator(_locale),
      do: "."

    @spec currency_symbol(Ledger.currency()) :: String.t()
    defp currency_symbol(:eur),
      do: "€"

    defp currency_symbol(_currency),
      do: "$"

    @spec build(state()) :: String.t()
    defp build(state) do
      build_number(state)
      |> build_amount(state)
      |> String.pad_leading(14, " ")
    end

    @spec build_amount(String.t(), state()) :: String.t()
    defp build_amount(
           number,
           _state = %{locale: :en_US, positive: true, currency_symbol: currency_symbol}
         ),
         do: "  #{currency_symbol}#{number} "

    defp build_amount(
           number,
           _state = %{locale: _, positive: true, currency_symbol: currency_symbol}
         ),
         do: " #{currency_symbol} #{number} "

    defp build_amount(
           number,
           _state = %{locale: :en_US, positive: false, currency_symbol: currency_symbol}
         ),
         do: " (#{currency_symbol}#{number})"

    defp build_amount(
           number,
           _state = %{locale: _, positive: false, currency_symbol: currency_symbol}
         ),
         do: " #{currency_symbol} -#{number} "

    @spec build_number(state()) :: String.t()
    defp build_number(state = %{decimal_separator: decimal_separator, cents: cents}) do
      build_integer_part(state) <> decimal_separator <> cents
    end

    @spec build_integer_part(state()) :: String.t()
    defp build_integer_part(_state = %{whole: whole, thousands_separator: thousands_separator}) do
      do_build_integer_part(thousands_separator, whole, "", "")
    end

    @spec do_build_integer_part(String.t(), String.t(), String.t(), String.t()) :: String.t()
    defp do_build_integer_part(_thousands_separator, "", _next_thousands_separator, acc),
      do: acc

    defp do_build_integer_part(
           thousands_separator,
           part,
           next_thousands_separator,
           acc
         ) do
      {rest, group} = String.split_at(part, -3)

      do_build_integer_part(
        thousands_separator,
        rest,
        thousands_separator,
        group <> next_thousands_separator <> acc
      )
    end
  end
end
