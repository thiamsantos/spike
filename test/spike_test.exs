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

  @consumer_size 8
  @queue_name "queue_name"

  describe "spike" do
    setup :start_queue

    test "run worker" do
      :ok = MyQueue.enqueue(MyWorker, self())

      assert_receive :perform
    end

    test "README install version check" do
      app = :spike

      app_version = "#{Application.spec(app, :vsn)}"
      readme = File.read!("README.md")
      [_, readme_versions] = Regex.run(~r/{:#{app}, "(.+)"}/, readme)

      assert Version.match?(
               app_version,
               readme_versions
             ),
             """
             Install version constraint in README.md does not match to current app version.
             Current App Version: #{app_version}
             Readme Install Versions: #{readme_versions}
             """
    end

    test "start the amount of passed consumers + one producer" do
      total = @consumer_size + 1
      children = Supervisor.which_children(MyQueue)

      assert length(children) == total

      expected =
        children
        |> Enum.map(fn {id, _child, _type, [mod]} -> {id, mod} end)
        |> Enum.sort()

      actual = [
        {SpikeTest.MyQueue.Producer, Spike.Producer},
        {{SpikeTest.MyQueue.Consumer, 1}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 2}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 3}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 4}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 5}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 6}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 7}, Spike.Consumer},
        {{SpikeTest.MyQueue.Consumer, 8}, Spike.Consumer}
      ]

      assert actual == expected
    end
  end

  describe "child_spec/1" do
    test "returns child spec" do
      opts = [queue_name: "queue_name", consumers_size: 8]
      actual = MyQueue.child_spec(opts)

      expected = %{
        id: MyQueue,
        start: {MyQueue, :start_link, [opts]},
        type: :supervisor
      }

      assert actual == expected
    end
  end

  describe "enqueue/2" do
    setup :start_queue

    test "sends message to producer" do
      pid = Process.whereis(MyQueue.Producer)
      :erlang.trace(pid, true, [:receive])

      :ok = MyQueue.enqueue(MyWorker, self())

      assert_receive {:trace, ^pid, :receive, {_, _, {:enqueue, MyWorker, _from}}}
    end
  end

  defp start_queue(_context) do
    start_supervised!({MyQueue, queue_name: @queue_name, consumers_size: @consumer_size})

    on_exit(fn ->
      {:ok, connection} = AMQP.Connection.open()
      {:ok, channel} = AMQP.Channel.open(connection)

      {:ok, _} = AMQP.Queue.delete(channel, @queue_name)
      :ok = AMQP.Channel.close(channel)
      :ok = AMQP.Connection.close(connection)
    end)
  end
end
