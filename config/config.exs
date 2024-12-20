# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :logger, level: :debug

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1728495408"

# https://github.com/lau/tzdata
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tzdata, :data_dir, "/tmp/tzdata"

config :hikari_hub, :gpio_pins,
  lights: [pin: 18, direction: :output]

config :hikari_hub, HikariHub.Scheduler,
  timezone: "Etc/UTC",
  jobs: []

config :hikari_hub, :scheduler,
  # Only UTC timezone is supported for now
  static_sunrise_time: "2030-01-01T02:00:00+00:00"

config :nerves_time, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
]

if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
