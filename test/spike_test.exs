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
      :ok = AMQP.Channel.close(channel)
      :ok = AMQP.Connection.close(connection)
    end)
  end

  describe "spike" do
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
  end
end
