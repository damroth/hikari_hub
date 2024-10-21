defmodule HikariHub.SchedulerWorker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    HikariHub.Scheduler.schedule_light_switching(51.1079, 17.0385)
    {:ok, %{}}
  end
end
