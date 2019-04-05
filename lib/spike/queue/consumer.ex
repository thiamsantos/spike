defmodule Spike.Queue.Consumer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    exchange_name = Keyword.fetch!(opts, :exchange_name)

    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    :ok = AMQP.Exchange.declare(channel, exchange_name, :fanout)
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
    :ok = AMQP.Queue.bind(channel, queue_name, exchange_name)
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
  def handle_info(other, state) do
    IO.inspect(other, label: :other)
    {:noreply, state}
  end
end
