defmodule Mines.Game do

  # TODO: remove num_mines member, make it a param to init
  defstruct board: [], size: nil, num_mines: nil, mine_locs: []

  #
  # Public API
  #
  def init(game = %__MODULE__{}) do
    game
    |> init_board
    |> init_mines
  end

  def reveal([row, col], game = %__MODULE__{}) do
    row_col_to_index([row, col], game.size)
    |> reveal(game)
  end

  def reveal(idx, game = %__MODULE__{}) do
    cond do
      cell_revealed?(idx, game) -> game
      idx in game.mine_locs -> %{ game | board: game.board |> List.replace_at(idx, ?X) }
      true -> reveal_number(idx, game)
    end
  end

  def toggle_bomb([row, col], game = %__MODULE__{}) do
    idx = row_col_to_index([row, col], game.size)
    cond do
      Enum.at(game.board, idx) == ?! -> %{ game | board: game.board |> List.replace_at(idx, ?-) }
      cell_revealed?(idx, game) -> game
      true -> %{ game | board: game.board |> List.replace_at(idx, ?!) }
    end
  end

  def game_over?(game = %__MODULE__{}) do
    ?X in game.board
  end

  def victory?(game = %__MODULE__{}) do
    (not Enum.any?(game.board, fn(char) -> char == ?- or char == ?X end)) and
    Enum.count(game.board, fn(char) -> char == ?! end) == game.num_mines
  end

  #
  # Private API
  #
  defp reveal_number(idx, game = %__MODULE__{}) do
    num_mines = get_number_of_neighboring_mines(idx, game)
    revealed_game = %{ game | board: game.board |> List.replace_at(idx, ?0 + num_mines) }
    if num_mines == 0 do
        get_neighbor_indices(idx, game.size)
        |> Enum.reduce(revealed_game, fn(i, acc_game) -> reveal(i, acc_game) end)
    else
      revealed_game
    end
  end

  defp cell_revealed?(idx, game = %__MODULE__{}) do
    Enum.at(game.board, idx) != ?-
  end

  defp init_board(game = %__MODULE__{}) do
    %{ game |
      board: List.duplicate(?-, game.size*game.size)
    }
  end

  defp init_mines(game = %__MODULE__{}) do
    %{ game |
      mine_locs: flat_board_indices(game) |> Enum.take_random(game.num_mines)
    }
  end

  defp flat_board_indices(game = %__MODULE__{}) do
    Range.new(0, game.size * game.size - 1)
  end

  #
  # The below functions are intended to be private, but defp functions cannot be tested
  #
  def index_to_row_col(idx, size) do
    { div(idx, size), rem(idx, size) }
  end

  def row_col_to_index([row, col], size) do
    size * row + col
  end

  def get_neighbor_indices(idx, size) do
    { r, c } = index_to_row_col(idx, size)
    neighbor_idx = [
      [ r-1, c-1 ],
      [ r-1, c ],
      [ r-1, c+1 ],
      [ r, c-1 ],
      [ r, c+1 ],
      [ r+1, c-1 ],
      [ r+1, c ],
      [ r+1, c+1 ]
    ]
    Enum.filter(neighbor_idx, fn([r,c]) -> r >= 0 and r < size and c >= 0 and c < size end)
    |> Enum.map( &row_col_to_index(&1, size) )
  end

  def get_number_of_neighboring_mines(idx, game = %__MODULE__{}) do
    get_neighbor_indices(idx, game.size)
    |> Enum.count(fn(idx) -> idx in game.mine_locs end)
  end
end

# A basic print-out of the board. Meant for debugging purposes, not the final game display.
defimpl String.Chars, for: Mines.Game do
  def to_string(game) do
    game.board
    |> Enum.chunk(game.size)
    |> Enum.intersperse([?\n])
    |> Enum.map(fn(row) -> Enum.intersperse(row, ?\s) |> Kernel.to_string end)
    |> List.to_string
  end
end

