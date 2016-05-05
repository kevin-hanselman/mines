defmodule Mines.TUI.Formatter do

  alias Mines.Game
  alias IO.ANSI

  def format_board(game = %Game{}, [row_idx, col_idx]) do
    rows = Enum.chunk(game.board, game.size)
    row = Enum.at(rows, row_idx)
    cursor = ANSI.format([:inverse, Enum.at(row, col_idx)])

    rows
    |> List.replace_at(row_idx,
                       List.replace_at(row, col_idx, cursor)
                       )
    |> Enum.map( &[" ", format_board_row(&1), "\r\n"] )
  end

  def format_board(game = %Game{}) do
    Enum.chunk(game.board, game.size)
    |> Enum.map( &[" ", format_board_row(&1), "\r\n"] )
  end

  def victory(game = %Game{}) do
    board_with_message(game, "  VICTORY!")
  end

  def game_over(game = %Game{}) do
    board_with_message(game, "  GAME OVER")
  end

  defp board_with_message(game = %Game{}, string) do
    [format_board(game), "\r\n", string]
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
