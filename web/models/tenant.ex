defmodule MohoMine.Tenant do
  use MohoMine.Web, :model

  schema "tenants" do
    field :name, :string
    field :full_name, :string
    field :email, :string
    field :url, :string
    #has_many :users, MohoMine.User

    timestamps
  end

  @required_fields ~w(name full_name email)
  @optional_fields ~w(url)

  def changeset(model, params \\ :empty) do
    model 
    |> cast(params, @required_fields, @optional_fields)
  end
end
