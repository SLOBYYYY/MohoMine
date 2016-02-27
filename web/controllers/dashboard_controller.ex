defmodule MohoMine.DashboardController do
  use MohoMine.Web, :controller
  alias MohoMine.Reporter
  
  def index(conn, _params) do
    {{current_year,_,_}, _} = :calendar.universal_time
    render conn, "index.html", current_year: current_year
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

  def agent_report(conn, params) do
    filter = 
      params
      |> sanitize_params
      |> Map.update!(:from, &convert_date_to_string(&1))
      |> Map.update!(:to, &convert_date_to_string(&1))

    {result, file_names} = Reporter.aggregated_agent_sales(filter.from, filter.to)
    files = case file_names do
      nil ->
        nil
      _ ->
        file_names
        |> Enum.map(fn x -> %{file_name: x, link: MohoMine.Router.Helpers.file_path(conn, :download_report, x)} end)
    end
    render conn, "aggregated_agent_sales.json", %{result: result, files: files}
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
        |> convert_string_keys_to_atoms
    end
  end

  @doc """
  Converts each key in a list from string to atom and checks the values 
  """
  defp convert_string_keys_to_atoms(params) do
    params 
    |> Enum.into(%{}, fn({key, value}) ->
      converted_key = if(is_binary(key), do: String.to_atom(key), else: key)
      if(is_map(value) || is_list(value)) do
        {converted_key, convert_string_keys_to_atoms(value)}
      else
        {converted_key, value}
      end
    end)
  end

  defp convert_date_to_string(date) do
    "#{date.year}-#{String.rjust(date.month, 2, ?0)}-#{String.rjust(date.day, 2, ?0)}"
  end
end
