defmodule SpikeTest do
  use ExUnit.Case

  defmodule MyWorker do
    @behaviour Spike.Worker

    def perform(pid) do
      send(pid, :perform)
    end
  end

  defmodule MyQueue do
    use Spike
  end

  setup do
    queue_name = "something"
    start_supervised({MyQueue, queue_name: queue_name, consumers_size: 8})

    on_exit(fn ->
      {:ok, connection} = AMQP.Connection.open()
      {:ok, channel} = AMQP.Channel.open(connection)

      {:ok, _} = AMQP.Queue.delete(channel, queue_name)
    end)
  end

  describe "spike" do
    test "run worker" do
      :ok = MyQueue.enqueue(MyWorker, self())

      assert_receive :perform
    end
  end
end
