defmodule Spike.Queue.Producer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    exchange_name = Keyword.fetch!(opts, :exchange_name)

    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)

    :ok = AMQP.Exchange.declare(channel, exchange_name)

    {:ok, %{exchange_name: exchange_name, channel: channel}}
  end

  @impl true
  def handle_call({:enqueue, module, args}, _from, %{exchange_name: exchange_name, channel: channel} = state) do
    payload = :erlang.term_to_binary({module, args})
    :ok = AMQP.Basic.publish(channel, exchange_name, "", payload, persistent: true)

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(other, state) do
    IO.inspect(other, label: :other)
    {:noreply, state}
  end
end
