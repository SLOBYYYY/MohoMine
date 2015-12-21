defmodule MohoMine.ReportSchemaControllerTest do
  use MohoMine.ConnCase

  alias MohoMine.ReportSchema
  @valid_attrs %{name: "some content", system_name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, MohoMine.Router.Helpers.report_schema_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    report_schema = Repo.insert! %ReportSchema{}
    conn = get conn, MohoMine.Router.Helpers.report_schema_path(conn, :show, report_schema)
    assert json_response(conn, 200)["data"] == %{"id" => report_schema.id,
      "name" => report_schema.name,
      "system_name" => report_schema.system_name}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, MohoMine.Router.Helpers.report_schema_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, MohoMine.Router.Helpers.report_schema_path(conn, :create), report_schema: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ReportSchema, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, MohoMine.Router.Helpers.report_schema_path(conn, :create), report_schema: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    report_schema = Repo.insert! %ReportSchema{}
    conn = put conn, MohoMine.Router.Helpers.report_schema_path(conn, :update, report_schema), report_schema: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(ReportSchema, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    report_schema = Repo.insert! %ReportSchema{}
    conn = put conn, MohoMine.Router.Helpers.report_schema_path(conn, :update, report_schema), report_schema: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    report_schema = Repo.insert! %ReportSchema{}
    conn = delete conn, MohoMine.Router.Helpers.report_schema_path(conn, :delete, report_schema)
    assert response(conn, 204)
    refute Repo.get(ReportSchema, report_schema.id)
  end
end
