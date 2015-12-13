defmodule MohoMine.Repo.Migrations.CreateTenant do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string, null: false
      add :full_name, :string, null: false
      add :email, :string, null: false
      add :url, :string

      timestamps
    end

    create unique_index(:tenants, [:name])
  end
end
