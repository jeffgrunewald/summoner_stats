defmodule SummonerStats.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: :summoner}
    ]

    opts = [strategy: :one_for_one, name: SummonerStats.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
