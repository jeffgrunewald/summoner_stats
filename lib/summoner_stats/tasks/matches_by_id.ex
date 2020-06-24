defmodule SummonerStats.MatchesById do
  def query(match_id, host, query_param) do
    match_uri = "#{host}/lol/match/v4/matches/#{match_id}?#{query_param}"
    {:ok, %Finch.Response{body: body}} = Finch.request(:summoner, :get, match_uri)

    %{"participantIdentities" => participants} = Jason.decode!(body)

    account_matches =
      participants
      |> Enum.map(fn participant -> participant["player"]["accountId"] end)
      |> Enum.map(&Task.async(SummonerStats.MatchlistByAccount, :query, [&1, host, query_param]))

    Enum.map(account_matches, &Task.await/1)
  end
end
