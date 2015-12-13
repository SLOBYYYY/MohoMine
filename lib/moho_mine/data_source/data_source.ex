defmodule MohoMine.DataSource do
  use Behaviour

  @doc """
  Fetches the data from the given data source
  """
  defcallback def fetch() :: Map.t

  @doc """
  Fetches data from the given data source according to criteria
  """
  defcallback def fetch(filter :: Map.t) :: Map.t
end
