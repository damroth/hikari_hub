defmodule HikariHub.SunriseSunset do
  @api_url "https://api.sunrise-sunset.org"
  @max_retries 5

  require Logger

  @timezone Application.compile_env(:hikari_hub, HikariHub.Scheduler, [])
  |> Keyword.get(:timezone, "Etc/UTC")

  def fetch_times(lat, lng) do
    url = "#{@api_url}/json?lat=#{lat}&lng=#{lng}&formatted=0&tzid=#{@timezone}"

    Logger.info("Fetching sunrise/sunset times from URL: #{url}")

    retry_request(url, @max_retries)
  end

  defp retry_request(url, retries) when retries > 0 do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{reason}. Retrying in #{:math.pow(2, @max_retries - retries)} seconds...")
        :timer.sleep(round(:math.pow(2, @max_retries - retries) * 1000))
        retry_request(url, retries - 1)
    end
  end

  defp retry_request(_url, 0) do
    {:error, :max_retries_exceeded}
  end

  defp parse_response(body) do
    body
    |> Jason.decode!
    |> Map.get("results")
  end
end
