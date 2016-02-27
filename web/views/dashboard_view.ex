defmodule MohoMine.DashboardView do
  use MohoMine.Web, :view

  def render("providers.json", %{providers: providers}) do
    providers_converted = 
      Enum.into(providers, [], fn { id, name } ->
        %{
          "id": id,
          "name": name
        } end
      )
    %{result: :ok, data: providers_converted}
  end

  def render("top_products.json", %{products: products}) do
    products_converted = convert_to_table(products)
    %{result: :ok, data: products_converted}
  end

  def render("top_agents.json", %{agents: agents}) do
    agents_converted = convert_to_table(agents)
    %{result: :ok, data: agents_converted}
  end

  def render("aggregated_agent_sales.json", %{result: result, files: files}) do
    data = case result do
      :ok ->
        files
      _ ->
        nil
    end
    %{result: result, data: data}
  end

  defp convert_to_table(data) do
    data
    |> Enum.into([], fn { name, total } ->
      %{
        "name": name,
        "total": total
      } end)
  end
end
