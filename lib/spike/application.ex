defmodule Spike.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Spike.Worker.start_link(arg)
      # {Spike.Worker, arg}
      {Spike.Queue, exchange_name: "spike_test"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spike.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
