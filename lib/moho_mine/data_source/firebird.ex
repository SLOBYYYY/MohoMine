defmodule MohoMine.DataSource.Firebird do
  @behaviour MohoMine.DataSource

  defmodule TopXOptions do
    defstruct top_n: 10, year: nil
  end

  def fetch(query_name) do
    fetch(query_name, %{})
  end

  def fetch(query_name, options) when is_map(options) do
    result = case query_name do
      :top_products ->
        options = Map.merge(%TopXOptions{}, options)
        query = query_top_products(options)
        start_odbc_query(query)
      :top_agents ->
        options = Map.merge(%TopXOptions{}, options)
        query = query_top_agents(options)
        start_odbc_query(query)
      _ ->
        []
    end
    %{data: result}
  end

  defp query_top_products(options) do 
    #FIXME: Somehow if we join the table 'szamla' to the query, getting the 
    # result for it jumpst up from ~500ms to 2000ms. Probably related to
    # ODBC driver.
    query = 'select first #{options.top_n} t.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
             from szamlatetel szt join
             szamla sz on sz.id_szamla = szt.id_szamla join
             termek t on t.id_termek = szt.id_termek join
             forgalmazo f on f.id_forgalmazo = t.id_forgalmazo'
    if options.year do
      query = query ++ ' where extract(year from sz.datum) = #{options.year}'
    end
    query ++ ' group by t.nev order by \"EladarSum\" desc'
  end

  defp query_top_agents(options) do
    query = 'select first #{options.top_n} u.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
             from szamlatetel szt join
             szamla sz on sz.id_szamla = szt.id_szamla join
             uzletkoto u on u.id_uzletkoto = sz.id_uzletkoto'
    if options.year do
      query = query ++ ' where extract(year from sz.datum) = #{options.year}'
    end
    query ++ ' group by u.nev order by \"EladarSum\" desc'
  end

  defp start_odbc_query(query) do
    firebird_env = Application.get_env(:moho_mine, :firebird)
    case :odbc.connect('Driver=#{firebird_env[:driver]};Uid=#{firebird_env[:uid]};Pwd=#{firebird_env[:pwd]};Server=#{firebird_env[:server]};Port=#{firebird_env[:port]};Database=#{firebird_env[:database]}', [{:scrollable_cursors, :off}]) do
    {:ok, ref} ->
      query_res = :odbc.sql_query(ref, query)
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
