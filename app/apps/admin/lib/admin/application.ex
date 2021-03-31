defmodule Admin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Admin.Repo,
      # Start the Telemetry supervisor
      AdminWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Admin.PubSub},
      # Start the Endpoint (http/https)
      AdminWeb.Endpoint,
      # Start a worker by calling: Admin.Worker.start_link(arg)
      # {Admin.Worker, arg}
      Admin.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
    :ets.new(:alerts_cache, [:named_table, :public, read_concurrency: true])

    opts = [strategy: :one_for_one, name: Admin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end