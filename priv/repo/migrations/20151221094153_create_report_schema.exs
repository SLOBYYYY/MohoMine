defmodule MohoMine.Repo.Migrations.CreateReportSchema do
  use Ecto.Migration

  def change do
    create table(:report_schemas) do
      add :name, :string
      add :system_name, :string

      timestamps
    end

  end
end
