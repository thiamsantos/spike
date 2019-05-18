defmodule Spike do
  @moduledoc """
  Spike
  """
  @callback enqueue(module(), any()) :: :ok

  defmacro __using__(_opts) do
    quote do
      @behaviour Spike

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts) do
        Spike.Supervisor.start_link(__MODULE__, opts)
      end

      @impl true
      def enqueue(module, args) do
        GenServer.call(Module.concat(__MODULE__, "Producer"), {:enqueue, module, args})
      end
    end
  end
end
