defmodule Mines.App do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, game) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Mines.Worker, [arg1, arg2, arg3]),
      worker(Mines.TUI, [game]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mines.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Mines.Escript do
  alias Mines.Game

  def main(args) do
    {game, num_mines} = parse_args(args)
    Mines.App.start(:normal, [game, num_mines])
    :erlang.hibernate(Kernel, :exit, [:killed])
  end

  def parse_args(args) do
    case OptionParser.parse(args, strict: [size: :integer, mines: :integer]) do
      {[], [], []} -> {%Game{size: 9}, 10}
      {[size: size, mines: mines], [], []} -> {%Game{size: size}, mines}
    end
  end
end
