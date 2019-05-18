defmodule Spike.Worker do
  @callback perform(any) :: :ok | {:error, any()}
end
