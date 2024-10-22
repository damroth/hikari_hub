defmodule HikariHub.LightsManager do
  use GenServer

  @moduledoc """
  GenServer to control Lights by GPIO
  """

  require Logger
  alias Circuits.GPIO

  def start_link(opts) do
    Logger.info("Starting LightsManager...")  # Log start
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # Server Callbacks
  @impl true
  def init(:ok) do
    Logger.info("Initializing LightsManager...")
    gpio_pins = Application.get_env(:hikari_hub, :gpio_pins)
    Logger.info("GPIO Pins Configuration: #{inspect(gpio_pins)}")

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
            {name, nil}
        end
      end)
      |> Enum.into(%{})

    Logger.info("GPIO mapping completed: #{inspect(gpio_map)}")

    {:ok, %{gpio_map: gpio_map}}
  end

  @impl true
  def handle_cast({:initialize_gpio, gpio_map}, state) do
    # Update the state with the new gpio_map
    new_state = Map.put(state, :gpio_map, gpio_map)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:enable, state) do
    Logger.info("Enabling Lights...")
    case GPIO.write(state.gpio_map[:lights], 1) do
      :ok ->
        Logger.info("Lights enabled.")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:disable, state) do
    Logger.info("Disabling Lights...")
    case GPIO.write(state.gpio_map[:lights], 0) do
      :ok ->
        Logger.info("Lights disabled.")
    end

    {:noreply, state}
  end

  def enable() do
    GenServer.cast(__MODULE__, :enable)
  end

  def disable() do
    GenServer.cast(__MODULE__, :disable)
  end
end
