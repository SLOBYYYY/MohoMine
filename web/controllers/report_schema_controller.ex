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

  def show(conn, %{"system_name" => system_name}) do
    report_schema = case system_name do
      "top_products" ->
        #{{current_year,_,_}, _} = :calendar.universal_time
        current_year = 2015
        MohoMine.DataSource.Firebird.fetch(:top_products, %{year: current_year})
      "top_agents" ->
        #{{current_year,_,_}, _} = :calendar.universal_time
        current_year = 2015
        MohoMine.DataSource.Firebird.fetch(:top_agents, %{year: current_year})
      _ -> 
        Repo.get_by!(ReportSchema, %{system_name: system_name})
    end

    render(conn, "show.json", report_schema: report_schema)
  end

  def filter(conn, %{"system_name" => system_name, "filter" => filter}) do
    filter = convert_filter_strings_to_atom(filter)
    result = case system_name do
      "top_agents" ->
        MohoMine.DataSource.Firebird.fetch(:top_agents, filter)
      _ ->
        %{}
    end
    render(conn, "show.json", report_schema: result)
  end

  defp convert_filter_strings_to_atom(filter) do
    filter 
    |> Enum.reduce(%{}, fn ({key, value}, acc) -> Map.put(acc, String.to_atom(key), value) end)
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
