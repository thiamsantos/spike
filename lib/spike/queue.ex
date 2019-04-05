defmodule Spike.Queue do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    exchange_name = Keyword.fetch!(opts, :exchange_name)

    consumers = 1..System.schedulers_online()
    |> Enum.map(fn number ->
      Supervisor.child_spec({Spike.Queue.Consumer, exchange_name: exchange_name}, id: {Spike.Queue.Consumer, number})
    end)
    |> IO.inspect()

    children = [{Spike.Queue.Producer, exchange_name: exchange_name} | consumers]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def enqueue(module, args) do
    GenServer.call(Spike.Queue.Producer, {:enqueue, module, args})
  end
end
# Spike.Queue.enqueue(Spike.Worker, %{something: "else"})
