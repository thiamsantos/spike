defmodule Spike.Worker do
  require Logger
  def perform(args) do
    Logger.info("#{__MODULE__} Called with #{inspect args}")
  end
end
