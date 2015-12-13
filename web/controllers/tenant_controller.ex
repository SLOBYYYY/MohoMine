defmodule MohoMine.TenantController do
  use MohoMine.Web, :controller
  alias MohoMine.Tenant

  def index(conn, _params) do
    tenants = Repo.all(Tenant)
    render conn, tenants: tenants
  end
end
