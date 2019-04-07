defmodule Spike.Producer do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    queue_name = Keyword.fetch!(opts, :queue_name)

    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, _} = AMQP.Queue.declare(channel, queue_name)

    {:ok, %{queue_name: queue_name, channel: channel}}
  end

  @impl true
  def handle_call(
        {:enqueue, module, args},
        _from,
        %{queue_name: queue_name, channel: channel} = state
      ) do
    payload = :erlang.term_to_binary({module, args})
    :ok = AMQP.Basic.publish(channel, "", queue_name, payload, persistent: true)

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(_other, state) do
    {:noreply, state}
  end
end
