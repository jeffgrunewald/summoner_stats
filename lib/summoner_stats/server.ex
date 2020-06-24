defmodule SummonerStats.Monitor do
  use GenServer, restart: :transient
  require Logger

  @api_query_param "api_key=<API_KEY_GOES_HERE>"
  @domain "api.riotgames.com"

  def start(region, summoner) do
    GenServer.start(__MODULE__, %{region: region, summoner: summoner})
  end

  def init(opts) do
    {:ok, Map.put(opts, :checks, 0), {:continue, :initial_check}}
  end

  def handle_continue(:initial_check, %{region: region, summoner: summoner, checks: checks} = state) do
    recent_matches = find_recent_matches(region, summoner)

    Logger.info(fn -> "Activity : #{inspect(recent_matches)}" end)

    {:noreply, %{state | checks: checks + 1}, 60_000}
  end

  def handle_info(:timeout, %{region: region, summoner: summoner, checks: checks} = state) do
    recent_matches = find_recent_matches(region, summoner)

    Logger.info(fn -> "Activity : #{inspect(recent_matches)}" end)

    case checks < 5 do
      true -> {:noreply, %{state | checks: checks + 1}, 60_000}
      false -> {:stop, :normal, state}
    end
  end

  defp find_recent_matches(region, summoner) do
    host = "https://#{region}.#{@domain}"
    summoner_uri = "#{host}/lol/summoner/v4/summoners/by-name/#{summoner}?#{@api_query_param}"

    {:ok, %Finch.Response{body: summoner_body}} = Finch.request(:summoner, :get, summoner_uri)
    %{"accountId" => account} = Jason.decode!(summoner_body)

    matches_uri = "#{host}/lol/match/v4/matchlists/by-account/#{account}?#{@api_query_param}"
    {:ok, %Finch.Response{body: match_body}} = Finch.request(:summoner, :get, matches_uri)

    %{"matches" => match_list} = Jason.decode!(match_body)

    matches =
      match_list
      |> Enum.sort_by(fn map -> map["timestamp"] end, &>=/2)
      |> Enum.take(5)
      |> Enum.map(fn match -> match["gameId"] end)
      |> Enum.map(&Task.async(SummonerStats.MatchesById, :query, [&1, host, @api_query_param]))

    Enum.map(matches, &Task.await/1)
    |> List.flatten()
  end
end
