defmodule MohoMine.ReportSchemaController do
  use MohoMine.Web, :controller

  alias MohoMine.ReportSchema

  plug :scrub_params, "report_schema" when action in [:create, :update]

  def index(conn, _params) do
    report_schemas = Repo.all(ReportSchema)
    render(conn, "index.json", report_schemas: report_schemas)
  end

  def create(conn, %{"report_schema" => report_schema_params}) do
    changeset = ReportSchema.changeset(%ReportSchema{}, report_schema_params)

    case Repo.insert(changeset) do
      {:ok, report_schema} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", report_schema_path(conn, :show, report_schema))
        |> render("show.json", report_schema: report_schema)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MohoMine.ChangesetView, "error.json", changeset: changeset)
    end
  end

  """
  It has to be extracted into separate process to avoid interfering sql queries with eachother
  """
  defp query_top10 do
    result = []
    :odbc.start()
    case :odbc.connect('Driver=Firebird;Uid=SYSDBA;Pwd=PcL233yW;Server=localhost;Port=3050;Database=/databases/dbs_bosz_2015.fdb', []) do
    {:ok, ref} ->
      query_res = :odbc.sql_query(ref, 'select first 10 t.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
                            from szamlatetel szt join
                            termek t on t.id_termek = szt.id_termek join
                            forgalmazo f on f.id_forgalmazo = t.id_forgalmazo
                            group by t.nev
                            order by \"EladarSum\" desc')
      result = extract_query_results(query_res)
      :odbc.disconnect(ref)
    {:error, _} ->
      raise "Cannot connect to database!"
    end
    :odbc.stop()
    {:ok, result} = Poison.encode result
    %{data: result}
  end

  defp extract_query_results(query_result) do
    # Only the 3rd part is interesting
    {_type, _columns, result} = query_result
    result 
    |> Enum.into([], fn {name, total} -> %{"name": :erlang.iolist_to_binary(name), "total": total} end)
  end

  def show(conn, %{"system_name" => system_name}) do
    report_schema = []
    case system_name do
      "top_10_product" ->
        report_schema = query_top10
      _ -> 
        report_schema = Repo.get_by!(ReportSchema, %{system_name: system_name})
    end
    IO.inspect report_schema

    render(conn, "show.json", report_schema: report_schema)
  end

  def update(conn, %{"id" => id, "report_schema" => report_schema_params}) do
    report_schema = Repo.get!(ReportSchema, id)
    changeset = ReportSchema.changeset(report_schema, report_schema_params)

    case Repo.update(changeset) do
      {:ok, report_schema} ->
        render(conn, "show.json", report_schema: report_schema)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MohoMine.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    report_schema = Repo.get!(ReportSchema, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(report_schema)

    send_resp(conn, :no_content, "")
  end
end
