defmodule MohoMine.Repo.Migrations.CreateReportSchema do
  use Ecto.Migration

  def change do
    create table(:report_schemas) do
      add :name, :string, null: false
      add :system_name, :string, null: false
      add :data, :string, null: false, size: 1000

      timestamps
    end

    create unique_index(:report_schemas, [:system_name])
  end
end
