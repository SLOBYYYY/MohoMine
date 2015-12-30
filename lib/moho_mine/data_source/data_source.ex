defmodule MohoMine.DataSource do
  use Behaviour

  @doc """
  Fetches data from the given data source according to criteria
  """
  defcallback def fetch(filter) :: Map.t
end
