defmodule Spike.Worker do
  @callback perform(any) :: any()
end
