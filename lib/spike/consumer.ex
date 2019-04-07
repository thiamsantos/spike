defmodule Spike.Consumer do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    queue_name = Keyword.fetch!(opts, :queue_name)

    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, _} = AMQP.Queue.declare(channel, queue_name)
    {:ok, _} = AMQP.Basic.consume(channel, queue_name)

    {:ok, %{queue_name: queue_name, channel: channel}}
  end

  @impl true
  def handle_info({:basic_deliver, payload, meta}, %{channel: channel} = state) do
    {module, args} = :erlang.binary_to_term(payload)
    apply(module, :perform, [args])
    :ok = AMQP.Basic.ack(channel, meta.delivery_tag)

    {:noreply, state}
  end

  @impl true
  def handle_info(_other, state) do
    {:noreply, state}
  end
end
