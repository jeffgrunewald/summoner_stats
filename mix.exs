defmodule SummonerStats.MixProject do
  use Mix.Project

  def project do
    [
      app: :summoner_stats,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SummonerStats.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2.1"},
      {:finch, "~> 0.2.0"}
    ]
  end
end
