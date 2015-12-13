defmodule MohoMine.DashboardController do
  use MohoMine.Web, :controller
  
  def index(conn, _params) do
    render conn, "index.html"
  end
end
