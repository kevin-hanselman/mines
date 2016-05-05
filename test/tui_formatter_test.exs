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
    board = Formatter.format_board(game, [0, 0])
            |> to_string
    assert board == to_string(
      [" \e[7m-\e[0m - - - -", "\r\n",
       " - - - - -", "\r\n",
       " - - - - -", "\r\n",
       " - - - - -", "\r\n",
       " - - - - -", "\r\n"])
  end

  test "formats zeros through threes" do
    board = %Game{
      size: 5,
      board: List.flatten([ '-----', '--0--', '--1--', '--2--', '--3--' ]),
    }
    |> Formatter.format_board([0, 0])
    |> to_string
    assert board == to_string(
      [" \e[7m-\e[0m - - - -", "\r\n",
       " - - \e[1m\e[30m0\e[0m - -", "\r\n",
       " - - \e[1m\e[34m1\e[0m - -", "\r\n",
       " - - \e[1m\e[32m2\e[0m - -", "\r\n",
       " - - \e[1m\e[31m3\e[0m - -", "\r\n"])
  end
end
