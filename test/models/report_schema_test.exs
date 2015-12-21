defmodule MohoMine.ReportSchemaTest do
  use MohoMine.ModelCase

  alias MohoMine.ReportSchema

  @valid_attrs %{name: "some content", system_name: "some content", data: "some data"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ReportSchema.changeset(%ReportSchema{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ReportSchema.changeset(%ReportSchema{}, @invalid_attrs)
    refute changeset.valid?
  end
end
