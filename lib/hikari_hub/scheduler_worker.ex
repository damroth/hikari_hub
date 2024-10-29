defmodule HikariHub.SchedulerWorker do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    wait_for_time_sync(1)
    HikariHub.Scheduler.schedule_light_switching(51.1079, 17.0385)
    HikariHub.Scheduler.schedule_daily_update()
    {:ok, %{}}
  end

  # WARNING: This function may block forever if the time is not synchronized
  defp wait_for_time_sync(attempt) do
    if NervesTime.synchronized?() do
      Logger.info("Time is synchronized")
    else
      backoff = :math.pow(2, attempt) * 1000 |> round()
      Logger.warning("Time is not synchronized, retrying in #{backoff} ms")
      :timer.sleep(backoff)
      wait_for_time_sync(attempt + 1)
    end
  end

end
