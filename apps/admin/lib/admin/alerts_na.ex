defmodule Admin.AlertsNA do
  import Ecto.Query

  def update_na_schedule do
    fetch_na_schedule()
    |> Enum.each(&process_schedule_quest/1)
  end

  defp fetch_na_schedule do
    with {:ok, %HTTPoison.Response{status_code: 302, body: body}} <-
           HTTPoison.get("https://pso2.com/news/LoadScheduleCampaigns", []),
         schedule when is_list(schedule) <- Poison.decode!(body) do
      schedule
    else
      {:ok, %HTTPoison.Response{}} -> nil
    end
  end

  defp process_schedule_quest(quest) do
    quest
    |> Map.get("events")
    |> Enum.each(fn event -> insert_event(event, quest) end)
  end

  defp insert_event(event, quest) do
    %Admin.Alerts.PSO2NAEvent{}
    |> Admin.Alerts.PSO2NAEvent.changeset(%{
      title: quest["title"],
      url: quest["route"],
      start_date: event["startDate"] |> to_utc(),
      end_date: event["endDate"] |> to_utc(),
      category_title: quest["category"]["title"],
      category_description: quest["category"]["description"]
    })
    |> Admin.Repo.insert(
      on_conflict: {:replace_all_except, [:title]},
      conflict_target: [:title, :start_date]
    )
  end

  defp to_utc(date) do
    date
    |> Timex.parse!("%FT%T", :strftime)
    |> Timex.to_datetime("America/Phoenix")
    |> Timex.Timezone.convert("Etc/UTC")
  end

  def alert_channels do
    eqs = get_upcoming_eqs()

    if should_alert(eqs) do
      Admin.Alerts.create_alert(
        eqs,
        eqs |> List.first() |> Map.fetch!(:id),
        "pso2_eq_alert_na"
      )
    end
  end

  def should_alert(eqs) do
    with eq <- List.first(eqs),
         true <- is_not_already_alerted(eq),
         start_date <- Map.fetch!(eq, :start_date),
         difference <- Timex.diff(start_date, Timex.now(), :minutes),
         true <- is_in_one_hour(difference) do
      true
    else
      _ -> false
    end
  end

  def is_not_already_alerted(eq) do
    case :dets.lookup(:alerts_cache, "pso2_eq_alert_na") do
      [{"pso2_eq_alert_na", id}] -> id != eq.id
      [] -> true
      _ -> :noop
    end
  end

  def is_in_one_hour(minutes_difference) do
    minutes_difference <= 60
  end

  def get_upcoming_eqs do
    Admin.Alerts.PSO2NAEvent
    |> where([e], e.start_date > ^DateTime.now!("Etc/UTC"))
    |> order_by(asc: :start_date)
    |> limit(5)
    |> Admin.Repo.all()
  end
end
