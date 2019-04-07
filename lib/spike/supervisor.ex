defmodule Spike.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(mod, opts) do
    Supervisor.start_link(__MODULE__, {mod, opts}, name: Module.concat(mod, "Supervisor"))
  end

  @impl true
  def init({mod, opts}) do
    queue_name = Keyword.fetch!(opts, :queue_name)
    consumers_size = Keyword.get(opts, :consumers_size, System.schedulers_online())

    consumers =
      1..consumers_size
      |> Enum.map(fn number ->
        Supervisor.child_spec({Spike.Consumer, queue_name: queue_name},
          id: {Module.concat(mod, "Consumer"), number}
        )
      end)

    producer_spec =
      Supervisor.child_spec(
        {Spike.Producer, name: Module.concat(mod, "Producer"), queue_name: queue_name},
        id: Module.concat(mod, "Producer")
      )

    children = [producer_spec | consumers]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
