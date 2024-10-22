defmodule NetworkGpio.Http do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/", do: send_resp(conn, 200, "System OK.")
  get "/health", do: send_resp(conn, 200, "healthy")

  get "/enable" do
    HikariHub.LightsManager.enable()
    send_resp(conn, 200, "Lights enabled")
  end

  get "/disable" do
    HikariHub.LightsManager.disable()
    send_resp(conn, 200, "Lights disabled")
  end

  match(_, do: send_resp(conn, 404, "Oops!"))
end
