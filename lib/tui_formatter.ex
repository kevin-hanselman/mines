defmodule Mines.TUI.Formatter do

  alias Mines.Game

  def format_board(game = %Game{}, [row_idx, col_idx]) do
    rows = Enum.chunk(game.board, game.size)
    row = Enum.at(rows, row_idx)
    cursor = IO.ANSI.format([:inverse, Enum.at(row, col_idx)])

    rows
    |> List.replace_at(row_idx,
                       List.replace_at(row, col_idx, cursor)
                       )
    |> Enum.map(fn(row) -> Enum.intersperse(row, ?\s) |> to_string end)
    |> Enum.intersperse([?\r, ?\n])
    # TODO: these last two functions should be replaced with the two functions below
  end

  defp format_board_row(row) do
    Enum.map(row, &format_board_row/1)
  end

  defp format_board_cell(cell) do
    [" ", cell]
  end
end
