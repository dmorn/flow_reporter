defmodule Flow.Reporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :flow_reporter,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:statistex, "~> 1.0"},
      {:vega_lite, "~> 0.1.4"},
      {:flow_telemetry, git: "https://github.com/dmorn/flow_telemetry.git"}
      # :dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
