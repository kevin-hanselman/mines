defmodule Mines.TUI do
  use GenServer

  alias Mines.Game
  alias Mines.TUI.Formatter

  defstruct port: nil, cursor_row_col: [0, 0], game: nil

  #
  # GenServer API
  #
  def start_link([game = %Game{}, num_mines]) do
    GenServer.start_link(__MODULE__, [game, num_mines])
  end

  #
  # GenServer Callbacks
  #
  # called after start_link
  def init([empty_game = %Game{}, num_mines]) do
    state = %__MODULE__{
              port: Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof]),
              game: Game.init(empty_game, num_mines),
            }
    print_board(state)
    {:ok, state}
  end

  # callback for the Erlang Port
  def handle_info({_pid, {:data, data}}, state) do
    new_state = data |> raw_input_to_key |> act_on_key(state)

    if new_state != state, do: print_game(new_state)

    {:noreply, new_state}
  end

  #
  # Main actions
  #
  defp act_on_key(key, state) do
    cond do
      key in [:up, :down, :left, :right] -> move_cursor(key, state)
      key == :space -> reveal_cell(state)
      key == "b" -> toggle_bomb(state)
      true -> state
    end
  end

  def move_cursor(key, state = %__MODULE__{cursor_row_col: [row, col]}) do
    %{state | cursor_row_col:
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
    %{state | game: Game.reveal(state.game, state.cursor_row_col)}
  end

  def toggle_bomb(state = %__MODULE__{}) do
    %{state | game: Game.toggle_bomb(state.game, state.cursor_row_col)}
  end

  #
  # Other functions
  #
  defp clear_screen do
    IO.write [IO.ANSI.clear, IO.ANSI.home]
    IO.write [?\r, ?\n]
  end

  defp print_game(state) do
    cond do
      Game.game_over?(state.game) -> game_over(state)
      Game.victory?(state.game) -> victory(state)
      true -> print_board(state)
    end
  end

  defp print_board(state) do
    clear_screen()
    IO.write Formatter.format_game(state.game, state.cursor_row_col)
  end

  defp victory(state) do
    clear_screen()
    IO.write Formatter.victory(state.game)
  end

  defp game_over(state) do
    clear_screen()
    IO.write Formatter.game_over(state.game)
  end

  defp raw_input_to_key("\e[A"), do: :up
  defp raw_input_to_key("\e[B"), do: :down
  defp raw_input_to_key("\e[C"), do: :right
  defp raw_input_to_key("\e[D"), do: :left
  defp raw_input_to_key(" "),    do: :space
  defp raw_input_to_key(raw_key), do: raw_key

end
