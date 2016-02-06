defmodule MohoMine.DataSource.Firebird do
  @behaviour MohoMine.DataSource

  defmodule TopXOptions do
    defstruct top_n: 10, year: nil, provider: nil
  end

  def fetch(query_name) do
    fetch(query_name, %{})
  end

  def fetch(query_name, options) when is_map(options) do
    query = case query_name do
      :top_products ->
        options = Map.merge(%TopXOptions{}, options)
        query_top_products(options)
      :top_agents ->
        options = Map.merge(%TopXOptions{}, options)
        query_top_agents(options)
      :providers ->
        query_providers()
      _ ->
        ''
    end
    result = start_odbc_query(query)
    apply_transformation(result)
  end

  defp query_providers do
    'select id_forgalmazo, nev from forgalmazo order by nev'
  end

  defp query_top_products(options) do 
    #FIXME: Somehow if we join the table 'szamla' to the query, getting the 
    # result for it jumpst up from ~500ms to 2000ms. Probably related to
    # ODBC driver.
    query = 'select first #{options.top_n} t.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
             from szamlatetel szt join
             szamla sz on sz.id_szamla = szt.id_szamla join
             termek t on t.id_termek = szt.id_termek join
             forgalmazo f on f.id_forgalmazo = t.id_forgalmazo
             where 1=1'
    if options.year do
      query = query ++ ' and extract(year from sz.datum) = #{options.year}'
    end
    if options.provider do
      query = query ++ ' and f.id_forgalmazo = #{options.provider}'
    end
    query ++ ' group by t.nev order by \"EladarSum\" desc'
  end

  defp query_top_agents(options) do
    query = 'select first #{options.top_n} u.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
             from szamlatetel szt join
             szamla sz on sz.id_szamla = szt.id_szamla join
             uzletkoto u on u.id_uzletkoto = sz.id_uzletkoto join
             termek t on t.id_termek = szt.id_termek join
             forgalmazo f on f.id_forgalmazo = t.id_forgalmazo
             where 1=1'
    if options.year do
      query = query ++ ' and extract(year from sz.datum) = #{options.year}'
    end
    if options.provider do
      query = query ++ ' and f.id_forgalmazo = #{options.provider}'
    end
    query ++ ' group by u.nev order by \"EladarSum\" desc'
  end

  defp start_odbc_query(''), do: []
  defp start_odbc_query(query) do
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

  defp apply_transformation(result) do
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
