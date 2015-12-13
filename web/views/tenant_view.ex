defmodule MohoMine.TenantView do
  use MohoMine.Web, :view

  def render("index.json", %{tenants: tenants}) do
    tenants
  end
end
