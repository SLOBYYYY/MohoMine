defmodule MohoMine.ReportSchemaControllerTest do
  use MohoMine.ConnCase

  alias MohoMine.ReportSchema
  @valid_attrs %{name: "Top 10 stuff", system_name: "top_10_stuff", data: "random data"}
  @invalid_attrs %{random_param: "random data"}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  defp create_random_instance do
    %ReportSchema{
      name: "Top 10 stuff",
      system_name: "top_10_stuff",
      data: "random data"
    }
  end

  test "index returns zero entries if none is present", %{conn: conn} do
    conn = get conn, report_schema_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "index returns all added ReportSchemas", %{conn: conn} do
    Repo.insert! %ReportSchema{
      name: "New Schema",
      system_name: "new_schema",
      data: "Full of data"
    }
    Repo.insert! %ReportSchema{
      name: "Old Schema",
      system_name: "old_schema",
      data: "None of that data"
    }
    conn = get conn, report_schema_path(conn, :index)
    assert length(json_response(conn, 200)["data"]) == 2
    assert Enum.at(json_response(conn, 200)["data"],0)["name"] == "New Schema"
    assert Enum.at(json_response(conn, 200)["data"],1)["name"] == "Old Schema"
    assert Enum.at(json_response(conn, 200)["data"],0)["data"] == "Full of data"
    assert Enum.at(json_response(conn, 200)["data"],1)["data"] == "None of that data"
  end

  test "shows chosen resource", %{conn: conn} do
    report_schema = Repo.insert! create_random_instance
    conn = get conn, report_schema_path(conn, :show, report_schema), system_name: "top_10_stuff"
    assert json_response(conn, 200)["data"] == %{
      "id" => report_schema.id,
      "name" => report_schema.name,
      "system_name" => report_schema.system_name,
      "data" => report_schema.data
    }
  end

  test "does not show resource and instead throw error when system_name is nonexistent", %{conn: conn} do
    report_schema = Repo.insert! create_random_instance

    assert_raise Ecto.NoResultsError, fn ->
      get conn, report_schema_path(conn, :show, report_schema), system_name: "not existing report schema"
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, report_schema_path(conn, :create), report_schema: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ReportSchema, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    empty_data = %{}
    conn = post conn, report_schema_path(conn, :create), report_schema: empty_data
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    report_schema = Repo.insert! create_random_instance
    conn = put conn, report_schema_path(conn, :update, report_schema), report_schema: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(ReportSchema, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    report_schema = Repo.insert! create_random_instance
    conn = put conn, report_schema_path(conn, :update, report_schema), report_schema: %{name: nil}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    report_schema = Repo.insert! create_random_instance
    conn = delete conn, report_schema_path(conn, :delete, report_schema)
    assert response(conn, 204)
    refute Repo.get(ReportSchema, report_schema.id)
  end
end
