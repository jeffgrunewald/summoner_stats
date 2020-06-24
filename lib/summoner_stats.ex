defmodule SummonerStats do
  defdelegate find_recently_played_with_matches(region, summoner), to: SummonerStats.Monitor, as: :start
end
