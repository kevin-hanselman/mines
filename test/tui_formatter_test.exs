defmodule Mines.TUI.Formatter.Test do
  use ExUnit.Case
  doctest Mines.TUI.Formatter

  alias Mines.Game
  alias Mines.TUI.Formatter

  setup do
    {:ok,
     game: %Game{
       board: List.flatten([ '-----', '-----', '-----', '-----', '-----' ]),
       size: 5,
       num_mines: 4,
       mine_locs: [0, 9, 16, 17]
       #'X----'
       #'----X'
       #'-----'
       #'-XX--'
       #'-----'
     }
    }
  end

  test "can format a blank board with cursor in top left cell", %{game: game} do
    assert Formatter.format_board(game, [0, 0]) ==
      ["\e[7m-\e[0m - - - -", '\r\n',
       "- - - - -", '\r\n',
       "- - - - -", '\r\n',
       "- - - - -", '\r\n',
       "- - - - -"]
  end
end
