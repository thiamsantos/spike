defmodule Spike.Worker do
  @moduledoc """
  Spike worker
  """
  @callback perform(any) :: :ok | {:error, any()}
end
