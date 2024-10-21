defmodule HikariHub.SunriseSunset do
  @api_url "https://api.sunrise-sunset.org"

  @timezone Application.compile_env(:hikari_hub, HikariHub.Scheduler, [])
  |> Keyword.get(:timezone, "Etc/UTC")

  def fetch_times(lat, lng) do
    url = "#{@api_url}/json?lat=#{lat}&lng=#{lng}&formatted=0&tzid=#{@timezone}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse_response(body) do
    body
    |> Jason.decode!
    |> Map.get("results")
  end
end
