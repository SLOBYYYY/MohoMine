defmodule MohoMine.DataSource.Firebird do
  def fetch(query) do
    result = start_odbc_query(query)
    apply_transformation(result)
  end

  def start_odbc_query(''), do: []
  def start_odbc_query(query) do
    firebird_env = Application.get_env(:moho_mine, :firebird)
    result = []
    case :odbc.connect('Driver=#{firebird_env[:driver]};Uid=#{firebird_env[:uid]};Pwd=#{firebird_env[:pwd]};Server=#{firebird_env[:server]};Port=#{firebird_env[:port]};Database=#{firebird_env[:database]}', [{:scrollable_cursors, :off}]) do
    {:ok, ref} ->
      query_res = :odbc.sql_query(ref, query)
      result = extract_query_results(query_res)
      :odbc.disconnect(ref)
    {:error, _} ->
      raise "Cannot connect to database!"
    end
    result
  end
  
  defp extract_query_results(query_result) do
    # Only the 3rd part is interesting
    {_type, _columns, result} = query_result
    result
  end

  def apply_transformation(result) do
    result 
    |> transform_characters_to_binary
  end

  @doc """
  Since this DB stores strings in a weird way, we have to transform every string to latin1
  """
  defp transform_characters_to_binary(result) do
    result 
    |> Enum.map(fn entry -> 
      Enum.reduce(Enum.reverse(Tuple.to_list(entry)), {}, fn(value, acc) ->
        final_value = if is_list(value), do: convert_to_latin1(value), else: value
        Tuple.insert_at(acc, 0, final_value) 
      end)
    end)
  end

  defp convert_to_latin1(string) do
    :unicode.characters_to_binary(string, :latin1)
  end
end
