defmodule HikariHub.Scheduler do
  use Quantum, otp_app: :hikari_hub

  require Logger

  @timezone Application.compile_env(:hikari_hub, HikariHub.Scheduler, [])
  |> Keyword.get(:timezone, "Etc/UTC")

  def schedule_light_switching(lat, lng) do
    case HikariHub.SunriseSunset.fetch_times(lat, lng) do
      {:ok, %{"sunrise" => sunrise, "sunset" => sunset}} ->
        schedule_task(:sunrise, sunrise)
        schedule_task(:sunset, sunset)
      {:error, reason} ->
        Logger.error("Failed to fetch sunrise/sunset times: #{reason}")
    end
  end

  def manual_schedule(atom, time) do
    schedule_task(atom, time)
  end

  defp schedule_task(:sunrise, time) do
    new_job()
    |> Quantum.Job.set_name(:sunrise)
    |> Quantum.Job.set_schedule(Crontab.CronExpression.Parser.parse!(time_to_cron(time)))
    |> Quantum.Job.set_task(fn -> HikariHub.LightsManager.enable() end)
    |> Quantum.Job.set_timezone(@timezone)
    |> add_job()
  end

  defp schedule_task(:sunset, time) do
    new_job()
      |> Quantum.Job.set_name(:sunet)
      |> Quantum.Job.set_schedule(Crontab.CronExpression.Parser.parse!(time_to_cron(time)))
      |> Quantum.Job.set_task(fn -> HikariHub.LightsManager.disable() end)
      |> Quantum.Job.set_timezone(@timezone)
      |> add_job()
  end

  defp time_to_cron(time) do
    {:ok, datetime, _} = DateTime.from_iso8601(time)
    hour = datetime.hour
    minute = datetime.minute
    "#{minute} #{hour} * * *"
  end

end
