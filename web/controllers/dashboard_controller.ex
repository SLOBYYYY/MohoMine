defmodule MohoMine.DashboardController do
  use MohoMine.Web, :controller
  
  def index(conn, _params) do
    render conn, "index.html"
  end
  
  def providers(conn, _params) do
    providers = MohoMine.DataAccess.get_providers
    render conn, "providers.json", providers: providers
  end

  def top_products(conn, params) do
    filter = sanitize_params(params)
    #{{current_year,_,_}, _} = :calendar.universal_time
    products = MohoMine.DataAccess.get_top_products(filter)

    render conn, "top_products.json", products: products
  end

  def top_agents(conn, params) do
    filter = sanitize_params(params)
    #{{current_year,_,_}, _} = :calendar.universal_time
    agents = MohoMine.DataAccess.get_top_agents(filter)

    render conn, "top_agents.json", agents: agents
  end

  defp sanitize_params(params) do
    case Map.has_key?(params, "filter") do
      false ->
        %{}
      true ->
        params 
        |> Map.get("filter")
        # Remove empty values
        |> Enum.filter(fn {_key, value} -> value != "" end)
        # Convert string keys to atoms
        |> Enum.reduce(%{}, fn ({key, value}, acc) -> Map.put(acc, String.to_atom(key), value) end)
    end
  end
end
