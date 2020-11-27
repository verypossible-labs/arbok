defmodule Arbok.MixProject do
  use Mix.Project

  def application, do: [extra_applications: [:logger]]

  def project do
    [
      app: :arbok,
      version: "0.1.0",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end
end
