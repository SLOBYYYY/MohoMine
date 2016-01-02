defmodule MohoMine.ReportSchemaView do
  use MohoMine.Web, :view

  def render("index.json", %{report_schemas: report_schemas}) do
    %{data: render_many(report_schemas, MohoMine.ReportSchemaView, "report_schema.json")}
  end

  def render("show.json", %{report_schema: report_schema}) do
    %{data: render_one(report_schema, MohoMine.ReportSchemaView, "report_schema.json")}
  end

  def render("report_schema.json", %{report_schema: report_schema}) do
    report_schema.data
  end
end
