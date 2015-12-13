defmodule MohoMine.DataApiControllerTest do
  use ExUnit.Case, async: false
  use Plug.Test # Access to 'conn' function

  alias MohoMine.Tenant
  alias MohoMine.Repo
  alias Ecto.Adapters.SQL

  setup do
    SQL.begin_test_transaction(Repo)

    on_exit fn ->
      SQL.rollback_test_transaction(Repo)
    end
  end

  test "/index returns a list of tenants" do
    tenant_as_json = 
      %Tenant{name: "test", full_name: "Test Tenant", email: "test@test.com"}
      |> Repo.insert
      |> List.wrap
      |> Postgres.encode!

    response = conn(:get, "/api/tenants") |> send_request

    assert response.status == 200
    assert response.resp_body == query_scheme_as_json
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> MohoMine.Endpoint.call([])
  end

  @app_layers """
  farmmix:
    -SQL queries:
      -top 10 vevo
      -top 10 uzletkoto
      -top 10 forgalmazo
    -excel queries:
      -marketing merfoldkovek

  Types:
    -Tenant
    -RepoType/DataAdapter
    -QueryScheme
  """

end
