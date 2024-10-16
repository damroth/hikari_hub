defmodule HikariHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Children for all targets
        # Starts a worker by calling: HikariHub.Worker.start_link(arg)
        # {HikariHub.Worker, arg},
        #{HikariHub.LightsManager, name: HikariHub.LightsManager},
        {Plug.Cowboy, scheme: :http, plug: NetworkGpio.Http, options: [port: 80]},
      ] ++ children(Nerves.Runtime.mix_target())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HikariHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  defp children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: HikariHub.Worker.start_link(arg)
      # {HikariHub.Worker, arg},
    ]
  end

  defp children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: HikariHub.Worker.start_link(arg)
      # {HikariHub.Worker, arg},
      #{HikariHub.LightsManager, name: HikariHub.LightsManager},
      #{Plug.Cowboy, scheme: :http, plug: NetworkGpio.Http, options: [port: 80]},
    ]
  end
end
