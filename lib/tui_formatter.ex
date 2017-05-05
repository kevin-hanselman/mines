defmodule Mines.TUI.Formatter do

  alias Mines.Game
  alias IO.ANSI

  #
  # Public API
  #
  def format_game(game = %Game{}, [cursor_row, cursor_col]) do
    [header(game),
     "\r\n",
     format_board(game, [cursor_row, cursor_col])]
  end

  def format_board(game = %Game{}, [row_idx, col_idx]) do
    rows = Enum.chunk(game.board, game.size)
    cursor_row = Enum.at(rows, row_idx)
    cursor = ANSI.format([:inverse, Enum.at(cursor_row, col_idx)])

    rows
    |> List.replace_at(row_idx, List.replace_at(cursor_row, col_idx, cursor))
    |> format_rows
  end

  def format_board(game = %Game{}) do
    Enum.chunk(game.board, game.size)
    |> format_rows
  end

  def victory(game = %Game{}) do
    format_game_with_message(game, "  VICTORY!")
  end

  def game_over(game = %Game{}) do
    format_game_with_message(game, "  GAME OVER")
  end

  #
  # Private API
  #
  defp format_rows(board_rows) do
    board_rows
    |> Enum.map(&[" ", format_board_row(&1), "\r\n"])
  end

  defp header(game = %Game{}) do
    seconds_since_start = div(System.monotonic_time - game.start_time, 1_000_000_000)
    ["  ", :bright, :red,
     Game.count_remaining_bombs(game) |> to_string |> String.ljust(game.size),
     seconds_since_start |> to_string |> String.rjust(game.size - 1),
     "\r\n"]
    |> ANSI.format
  end

  defp format_game_with_message(game = %Game{}, string) do
    [header(game),
     "\r\n",
     format_board(game),
     "\r\n",
     string]
  end

  defp format_board_row(row) do
    Enum.map(row, &format_board_cell/1)
  end

  defp format_board_cell(cell) do
    case cell do
      ?0 -> ANSI.format([" ", :bright, :black, ?/])
      ?1 -> ANSI.format([" ", :bright, :blue, cell])
      ?2 -> ANSI.format([" ", :bright, :green, cell])
      ?3 -> ANSI.format([" ", :bright, :red, cell])
      ?4 -> ANSI.format([" ", :blue, cell])
      ?5 -> ANSI.format([" ", :red, cell])
      ?6 -> ANSI.format([" ", :bright, :cyan, cell])
      ?7 -> ANSI.format([" ", :bright, :yellow, cell])
      ?8 -> ANSI.format([" ", :bright, :white, cell])
      ?X -> ANSI.format([" ", :blink_slow, :inverse, :red, cell])
      ?! -> ANSI.format([" ", :inverse, :red, cell])
      _ -> [" ", cell]
    end
  end
end
