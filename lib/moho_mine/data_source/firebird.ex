defmodule MohoMine.DataSource.Firebird do
  @behaviour MohoMine.DataSource

  defmodule TopXOptions do
    defstruct top_n: 10
  end

  def fetch(query_name) do
    fetch(query_name, %{})
  end

  def fetch(query_name, options) when is_map(options) do
    result = case query_name do
      :top_x_product ->
        start_odbc_query(options)
      _ ->
        []
    end
    %{data: result}
  end

  defp start_odbc_query(options) do
    options = Map.merge(options, %TopXOptions{})
    firebird_env = Application.get_env(:moho_mine, :firebird)
    case :odbc.connect('Driver=#{firebird_env[:driver]};Uid=#{firebird_env[:uid]};Pwd=#{firebird_env[:pwd]};Server=#{firebird_env[:server]};Port=#{firebird_env[:port]};Database=#{firebird_env[:database]}', []) do
    {:ok, ref} ->
      query_res = :odbc.sql_query(ref, 'select first #{options.top_n} t.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
                            from szamlatetel szt join
                            termek t on t.id_termek = szt.id_termek join
                            forgalmazo f on f.id_forgalmazo = t.id_forgalmazo
                            group by t.nev
                            order by \"EladarSum\" desc')
      result = extract_query_results(query_res)
      :odbc.disconnect(ref)
    {:error, _} ->
      raise "Cannot connect to database!"
    end
    {:ok, result} = Poison.encode result
    result
  end
  
  defp extract_query_results(query_result) do
    # Only the 3rd part is interesting
    {_type, _columns, result} = query_result
    result 
    |> Enum.into([], fn {name, total} -> %{"name": :erlang.iolist_to_binary(name), "total": total} end)
  end
end
