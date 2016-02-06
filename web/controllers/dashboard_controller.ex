defmodule MohoMine.DashboardController do
  use MohoMine.Web, :controller
  
  def index(conn, _params) do
    render conn, "index.html"
  end
  
  def providers(conn, _params) do
    providers = MohoMine.DataAccess.get_providers
    render conn, "providers.json", providers: providers
  end
end
