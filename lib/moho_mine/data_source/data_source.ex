defmodule MohoMine.DataSource do
  use Behaviour

  @doc """
  Fetches data from the given data source based on the 
  name of the resource
  """
  @callback fetch(String.t) :: Map.t
  @doc """
  Fetches data from the given data source based on the name of the resource. 
  Also passes options for the query to filter the results.
  """
  @callback fetch(String.t, Map.t) :: Map.t
end
