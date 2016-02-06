defmodule MohoMine.DataAccess do
  alias MohoMine.DataProvider.Firebird

  defmodule TopXOptions do
    defstruct top_n: 10, year: nil, provider: nil
  end

  def get_providers do
    query = 'select id_forgalmazo, nev from forgalmazo order by nev'
    Firebird.fetch(query)
  end

  def get_top_products(options) do 
    options = Map.merge(%TopXOptions{}, options)
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
    query = query ++ ' group by t.nev order by \"EladarSum\" desc'

    Firebird.fetch(query)
  end

  def get_top_agents(options) do
    options = Map.merge(%TopXOptions{}, options)
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
    query = query ++ ' group by u.nev order by \"EladarSum\" desc'

    Firebird.fetch(query)
  end
end
