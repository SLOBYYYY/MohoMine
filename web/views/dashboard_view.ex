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
    %{"data": providers_converted}
  end

  def render("top_products.json", %{products: products}) do
    products_converted = convert_to_table(products)
    %{"data": products_converted}
  end

  def render("top_agents.json", %{agents: agents}) do
    agents_converted = convert_to_table(agents)
    %{"data": agents_converted}
  end

  def render("aggregated_agent_sales.json", %{result: result, file_name: file_name}) do
    data = case result do
      :ok ->
        %{result_file: file_name}
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
