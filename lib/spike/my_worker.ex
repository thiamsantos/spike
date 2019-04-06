defmodule Spike.MyWorker do
  @behaviour Spike.Worker

  require Logger

  @impl true
  def perform(args) do
    Logger.info("#{__MODULE__} Called with #{inspect(args)}")
  end
end
