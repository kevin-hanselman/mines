defmodule Mines.TUI do
  use GenServer

  alias Mines.Game
  alias Mines.TUI.Formatter

  defstruct port: nil, cursor_row_col: [0, 0], game: nil

  #
  # GenServer API
  #
  def start_link(game = %Game{}) do
    GenServer.start_link(__MODULE__, game)
  end

  #
  # GenServer Callbacks
  #
  # called after start_link
  def init(game) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    new_game = Game.init(game)
    state = %__MODULE__{
              port: port,
              game: new_game,
            }
    print_board(state)
    {:ok, state}
  end

  # callback for the Erlang Port
  def handle_info({_pid, {:data, data}}, state) do
    key = translate(data)
    new_state = cond do
      key in [:up, :down, :left, :right] -> move_cursor(key, state)
      key == :space -> reveal_cell(state)
      key == :b -> toggle_bomb(state)
      true -> state
    end
    cond do
      Game.game_over?(new_state.game) -> print_game_over(new_state)
      Game.victory?(new_state.game) -> print_victory(new_state)
      new_state != state -> print_board(new_state)
      true -> nil
    end
    {:noreply, new_state}
  end

  #
  # Main actions
  #
  def move_cursor(key, state = %__MODULE__{cursor_row_col: [row, col]}) do
    %{ state | cursor_row_col:
      case key do
        :up    -> [row - 1, col]
        :down  -> [row + 1, col]
        :right -> [row, col + 1]
        :left  -> [row, col - 1]
      end
      |> Enum.map( &rem(&1, state.game.size) )
    }
  end

  def reveal_cell(state = %__MODULE__{}) do
    %{ state | game: Game.reveal(state.cursor_row_col, state.game) }
  end

  def toggle_bomb(state = %__MODULE__{}) do
    %{ state | game: Game.toggle_bomb(state.cursor_row_col, state.game) }
  end

  #
  # Other functions
  #
  defp clear_screen do
    IO.write [IO.ANSI.clear, IO.ANSI.home]
    IO.write [?\r, ?\n]
  end

  defp print_board(state) do
    clear_screen
    IO.write Formatter.format_board(state.game, state.cursor_row_col)
  end

  defp print_victory(state) do
    clear_screen
    IO.write Formatter.victory(state.game)
  end

  defp print_game_over(state) do
    clear_screen
    IO.write Formatter.game_over(state.game)
  end

  defp translate("\e[A"), do: :up
  defp translate("\e[B"), do: :down
  defp translate("\e[C"), do: :right
  defp translate("\e[D"), do: :left
  defp translate(" "), do: :space
  defp translate("b"), do: :b
  defp translate(_), do: nil

end
