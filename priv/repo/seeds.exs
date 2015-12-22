# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MohoMine.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MohoMine.Repo
alias MohoMine.ReportSchema

Repo.get_by(ReportSchema, system_name: "top_10_product") || 
  Repo.insert(%ReportSchema{
    system_name: "top_10_product", 
    name: "Top 10 product",
    data: "[\"Omex szuper 5\", 12412444], [\"Gladiator SL 10\", 634345634]"
  })
