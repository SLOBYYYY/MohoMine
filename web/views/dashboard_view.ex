defmodule MohoMine.DashboardView do
  use MohoMine.Web, :view

  def render("providers.json", %{providers: providers}) do
    providers
    |> Enum.into([], fn { id, name } ->
      %{
        "id": id,
        "name": name
      } end)
  end
end
