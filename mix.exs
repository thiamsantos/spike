defmodule Spike.MixProject do
  use Mix.Project

  def project do
    [
      app: :spike,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Spike",
      package: package(),
      docs: docs(),
      name: "Spike",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:lager, :logger]
    ]
  end

  defp package do
    [
      maintainers: ["Thiago Santos"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/thiamsantos/spike"}
    ]
  end

  defp docs do
    [
      main: "Spike",
      source_url: "https://github.com/thiamsantos/spike",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:amqp, "~> 1.1"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
    ]
  end
end
