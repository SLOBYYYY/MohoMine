defmodule MohoMine.DataSource.Firebird do
  @behaviour MohoMine.DataSource

  def fetch(filter) do
    result = []
    case filter do
      :top_10_product ->
        result = start_odbc_query
      _ ->
        result = []
    end
    %{data: result}
  end

  defp start_odbc_query do
    case :odbc.connect('Driver=Firebird;Uid=SYSDBA;Pwd=PcL233yW;Server=localhost;Port=3050;Database=/databases/dbs_bosz_2015.fdb', []) do
    {:ok, ref} ->
      query_res = :odbc.sql_query(ref, 'select first 10 t.nev, round(sum(szt.eladar * szt.mennyiseg),0) as \"EladarSum\"
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
