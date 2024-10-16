defmodule HikariHub.LightsManager do
  use GenServer

  @moduledoc """
  GenServer to control Lights by GPIO
  """

  require Logger
  alias Circuits.GPIO

  def start_link(state \\ []) do
    Logger.info("Starting LightsManager...")  # Log start
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do ### PROBLEM ZAPEWNE LEZY W STANIE COS PRZEKAZUJE LISTE
  # A MY MAMY MAPE
    Logger.info("Initializing LightsManager...")  # Log initialization
    gpio_pins = Application.get_env(:hikari_hub, :gpio_pins)
    Logger.info("GPIO Pins Configuration: #{inspect(gpio_pins)}")  # Log GPIO configuration

    gpio_map =
      gpio_pins
      |> Enum.map(fn {name, config} ->
        pin = Keyword.fetch!(config, :pin)
        direction = Keyword.fetch!(config, :direction)

        case GPIO.open(pin, direction) do
          {:ok, gpio} ->
            Logger.info("Opened GPIO pin #{pin} for #{name} as #{direction}.")
            {name, gpio}

          {:error, reason} ->
            Logger.error("Failed to open GPIO pin #{pin} for #{name}: #{reason}")
            {name, nil}  # You might want to handle this differently
        end
      end)
      |> Enum.into(%{})

    Logger.info("GPIO mapping completed: #{inspect(gpio_map)}")  # Log successful mapping

    {:ok, Map.merge(state, %{gpios: gpio_map})}
  end

  def handle_cast(:enable, %{gpios: gpios} = state) do
    Logger.info("inside handle cast, Enabling Lights...")
    Logger.info(" state: #{inspect(state)}")

    case GPIO.write(gpios[:lights], 1) do
      :ok ->
        Logger.info("Lights enabled.")
    end

    {:noreply, state}
  end

  def handle_cast(:disable, %{gpios: gpios} = state) do
    Logger.info("Disabling Lights...")

    case GPIO.write(gpios[:lights], 0) do
      :ok ->
        Logger.info("Lights disabled.")
    end

    {:noreply, state}
  end

  def enable() do
    Logger.info("inside enable function")
    GPIO.write(18, 1)
    GenServer.cast(__MODULE__, :enable)
  end

  def disable() do
    Logger.info("inside enable function")
    GenServer.cast(__MODULE__, :disable)
  end
end
