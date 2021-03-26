# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Admin.Repo.insert!(%Admin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Admin.Repo.insert!(
  %Admin.Guilds.AvailableSetting{
    key: "alert_channel_id",
    label: "Alert Channel ID",
    type: "string"
  },
  on_conflict: :nothing
)