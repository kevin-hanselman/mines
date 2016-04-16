defmodule Mines.TUI.Test do
  use ExUnit.Case
  doctest Mines.TUI

  alias Mines.Game
  alias Mines.TUI

  setup do
    {:ok,
     game: %Game{
       board: List.flatten([ '-----',
                             '-----',
                             '-----',
                             '-----',
                             '-----' ]),
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

end
