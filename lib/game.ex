defmodule Mines.Game do

  defstruct board: [], size: nil, mine_locs: [], start_time: nil

  #
  # Public API
  #
  def init(game = %__MODULE__{}, num_mines) do
    %{game |> init_board |> init_mines(num_mines) | start_time: System.monotonic_time}
  end

  def reveal(game = %__MODULE__{}, [row, col]) do
    game |> reveal(row_col_to_index([row, col], game.size))
  end

  def reveal(game = %__MODULE__{}, idx) do
    cond do
      cell_revealed?(game, idx) -> game
      idx in game.mine_locs -> %{game | board: game.board |> List.replace_at(idx, ?X)}
      true -> reveal_number(game, idx)
    end
  end

  def toggle_bomb(game = %__MODULE__{}, [row, col]) do
    idx = row_col_to_index([row, col], game.size)
    cond do
      cell_marked?(game, idx) -> %{game | board: game.board |> List.replace_at(idx, ?-)}
      cell_revealed?(game, idx) -> game
      true -> %{game | board: game.board |> List.replace_at(idx, ?!)}
    end
  end

  def game_over?(game = %__MODULE__{}) do
    ?X in game.board
  end

  def victory?(game = %__MODULE__{}) do
    (not Enum.any?(game.board, fn(char) -> char == ?- or char == ?X end)) and
    Enum.count(game.board, fn(char) -> char == ?! end) == total_number_of_mines(game)
  end

  def count_remaining_bombs(game = %__MODULE__{}) do
    total_number_of_mines(game) - Enum.count(game.board, fn(char) -> char == ?! end)
  end

  #
  # Private API
  #
  defp reveal_number(game = %__MODULE__{}, idx) do
    num_mines = get_number_of_neighboring_mines(game, idx)
    revealed_game = %{game | board: game.board |> List.replace_at(idx, ?0 + num_mines)}
    if num_mines == 0 do
      idx
      |> get_neighbor_indices(game.size)
      |> Enum.reduce(revealed_game, fn(i, acc_game) -> reveal(acc_game, i) end)
    else
      revealed_game
    end
  end

  defp cell_revealed?(game = %__MODULE__{}, idx) do
    Enum.at(game.board, idx) != ?-
  end

  defp cell_marked?(game = %__MODULE__{}, idx) do
    Enum.at(game.board, idx) == ?!
  end

  defp init_board(game = %__MODULE__{}) do
    %{game | board: List.duplicate(?-, game.size * game.size)}
  end

  defp init_mines(game = %__MODULE__{}, num_mines) do
    %{game |
      mine_locs: game |> flat_board_indices |> Enum.take_random(num_mines)
    }
  end

  defp total_number_of_mines(game = %__MODULE__{}), do: length(game.mine_locs)

  defp flat_board_indices(game = %__MODULE__{}) do
    Range.new(0, game.size * game.size - 1)
  end

  #
  # The below functions are intended to be private, but defp functions cannot be tested
  #
  def index_to_row_col(idx, size) do
    {div(idx, size), rem(idx, size)}
  end

  def row_col_to_index([row, col], size) do
    # translate negative indices into their positive (actual) values
    [row, col] = Enum.map([row, col], &(if &1 < 0, do: &1 + size, else: &1))
    size * row + col
  end

  def get_neighbor_indices(idx, size) do
    {r, c} = index_to_row_col(idx, size)
    (for ro <- -1..1, co <- -1..1, [ro, co] != [0, 0], do: [r + ro, c + co])
    |> Enum.filter(
      fn([r, c]) ->
        r >= 0 and r < size and c >= 0 and c < size
      end
    )
    |> Enum.map(&row_col_to_index(&1, size))
  end

  def get_number_of_neighboring_mines(game = %__MODULE__{}, idx) do
    idx
    |> get_neighbor_indices(game.size)
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
