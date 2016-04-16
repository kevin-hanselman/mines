defmodule Mines.Game.Test do
  use ExUnit.Case
  doctest Mines.Game

  alias Mines.Game

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
       mine_locs: [0, 6, 11, 19]
       #'X2100'
       #'3X200'
       #'2X221'
       #'1111X'
       #'00011'
     }
    }
  end

  test "can initialize game" do
    game = Game.init(%Game{size: 5, num_mines: 6})
    assert length(game.board) == 25
    assert length(game.mine_locs) == 6
    assert Enum.all?(game.board, fn(char) -> char == ?- end)
  end

  test "given an idx, can get a row and col" do
    size = 5
    assert Game.index_to_row_col(0, size) == {0, 0}
    assert Game.index_to_row_col(1, size) == {0, 1}
    assert Game.index_to_row_col(5, size) == {1, 0}
    assert Game.index_to_row_col(22, size) == {4, 2}
    assert Game.index_to_row_col(24, size) == {4, 4}
  end

  test "given a row and col, can get an index" do
    size = 5
    assert Game.row_col_to_index([0, 0], size) == 0
    assert Game.row_col_to_index([0, 1], size) == 1
    assert Game.row_col_to_index([1, 0], size) == 5
    assert Game.row_col_to_index([4, 2], size) == 22
    assert Game.row_col_to_index([4, 4], size) == 24
  end

  test "given index, can find neighboring indices" do
    size = 5
    assert Game.get_neighbor_indices(0, size) == [1, 5, 6]
    assert Game.get_neighbor_indices(6, size) == [0, 1, 2, 5, 7, 10, 11, 12]
    assert Game.get_neighbor_indices(5, size) == [0, 1, 6, 10, 11]
    assert Game.get_neighbor_indices(22, size) == [16, 17, 18, 21, 23]
  end

  test "given index and board, can find number of neighboring mines", %{game: game} do
    assert Game.get_number_of_neighboring_mines(4, game) == 0
    assert Game.get_number_of_neighboring_mines(24, game) == 1
    assert Game.get_number_of_neighboring_mines(12, game) == 2
    assert Game.get_number_of_neighboring_mines(5, game) == 3
  end

  test "can call to_string on a game" do
    game = %Game{ size: 5, board: List.flatten(['X----', '----X', '-----', '-XX--', '-----']) }
    assert to_string(game) ==
~S(X - - - -
- - - - X
- - - - -
- X X - -
- - - - -)
  end

  test "revealing a cell with a mine shows that cell", %{game: game} do
    assert Game.reveal(0, game).board ==
      List.flatten([ 'X----', '-----', '-----', '-----', '-----' ])
  end

  test "revealing a cell with a non-zero number shows that cell", %{game: game} do
    assert Game.reveal(5, game).board ==
      List.flatten([ '-----', '3----', '-----', '-----', '-----' ])
  end

  test "revealing a zero-valued cell reveals surrounding cells", %{game: game} do
    assert Game.reveal(4, game).board ==
      List.flatten([ '--100',
                     '--200',
                     '--211',
                     '-----',
                     '-----' ])
    assert Game.reveal(21, game).board ==
      List.flatten([ '-----',
                     '-----',
                     '-----',
                     '1111-',
                     '0001-' ])
  end

  test "game over when the board has at least one X", %{game: game} do
    assert Game.game_over?(
      %{game | board: List.flatten([ 'X----', '-----', '-----', '-----', '-----' ]) }
      )
  end

  test "a game over cannot also be a victory" do
    game_over = %Game{ board: List.flatten([ 'X----', '-----', '-----', '-----', '-----' ]) }
    assert (not Game.victory?(game_over)) and Game.game_over?(game_over)
  end

  test "victory when the board has all non-bomb cells revealed and all bombs marked", %{game: game} do
    assert Game.victory?(
      %{game | board: List.flatten([ '!1011', '1101!', '12221', '1!!10', '12210' ]) }
      )
  end

  test "a victory cannot also be a game over" do
    victory_game = %Game{ board: List.flatten([ '!1011', '1101!', '12221', '1!!10', '12210' ]) }
    assert (not Game.game_over?(victory_game)) and Game.victory?(victory_game)
  end

end
