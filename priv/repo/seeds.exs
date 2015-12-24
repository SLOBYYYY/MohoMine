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

{_, object} = Poison.encode [
  %{name: "Omex általános lombtrágya", total: 14929242},
  %{name: "Agrocean 20", total: 11167052},
  %{name: "Omex Boron 20", total: 9118990},
  %{name: "Calmax 20", total: 2193440},
  %{name: "Omex Kingfol Zn 20", total: 1764072},
  %{name: "Omex Ferti I. (16-09-26) 25", total: 1509072},
  %{name: "Omex Starter (15-30-15) 25", total: 1223540},
  %{name: "Omex Boron 5", total: 1159860},
  %{name: "Agrocean 5", total: 656172},
  %{name: "Calmax 5", total: 635908}
]

Repo.get_by(ReportSchema, system_name: "top_10_product") || 
  Repo.insert(%ReportSchema{
    system_name: "top_10_product", 
    name: "Top 10 product",
    data: object
  })
