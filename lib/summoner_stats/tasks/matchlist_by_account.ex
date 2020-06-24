defmodule SummonerStats.MatchlistByAccount do
  def query(account_id, host, query_param) do
    matchlist_uri = "#{host}/lol/match/v4/matchlists/by-account/#{account_id}?#{query_param}"

    {:ok, %Finch.Response{body: body}} = Finch.request(:summoner, :get, matchlist_uri)

    case Jason.decode!(body) do
      %{"matches" => matches} -> matches
      _ -> []
    end
    |> Enum.filter(fn match -> last_minute() <= match["timestamp"] and match["timestamp"] <= now() end)
    |> Enum.map(fn match -> "account #{account_id} played match #{match["gameId"]}" end)
  end

  defp now(), do: (DateTime.utc_now() |> DateTime.to_unix(:millisecond))
  defp last_minute(), do: now() - 60_000
end
