args = commandArgs(trailingOnly=T)
IsDate <- function(mydate, date.format = "%Y-%m-%d") {
	  tryCatch(!is.na(as.Date(mydate, date.format)),  
	  		              error = function(err) {FALSE})  
}
if (length(args) != 6) {
	stop("A JDBC driver location, 3 output(sales by category, sales by sites, full data dump) file a \"from\" and a \"to\" date parameter has to be passed")
}
if (!IsDate(args[5])) {
	stop("Argument \"from\" has to be in a format yyyy-mm-dd")
}
if (!IsDate(args[6])) {
	stop("Argument \"to\" has to be in a format yyyy-mm-dd")
}
args.jdbc.path = args[1]
args.agent.sales.by.category.file = args[2]
args.agent.sales.by.site.file = args[3]
args.full.data.file = args[4]
args.from = args[5]
args.to = args[6]

AgentSales = function (connection) {
    thisEnv = environment()
    if (class(connection) == "JDBCConnection") {
        localConnection = connection
        result = NULL
        loadSpecialProducts = function () {
            command = paste("select id_termek",
                            "from termek",
                            "where lower(termek.nev) in (",
							"'adengo  1', ",
							"'adengo  5', ",
							"'afalon disp.  5', ",
							"'alcedo 100 ec  1', ",
							"'alcedo 100 ec  5', ",
							"'antracol wg   6', ",
							"'biathlon 4d', ",
							"'biscaya  3', ",
							"'bumper 25 ec  5', ", 
							"'calypso 480 sc  1', ",
							"'cambio          5', ",
							"'capreno csomag', ",
							"'colombus  1', ",
							"'colombus  5', ",
							"'coragen 20 sc  1', ",
							"'coragen 20 sc  5', ",
							"'curzate super  5', ",
							"'cuproxat        5', ",
							"'cuproxat        20', ",
							"'cyflamid 5 ew   1', ",
							"'folpan 80 wdg   5', ",
							"'fontelis 20 sc  1',",
							"'galera sl   5', ",
							"'galigan 240 ec  5', ",
							"'inazuma  1', ",
							"'kaiso eg  1', ",
							"'karathane star  1', ",
							"'karathane star  5',",
							"'kentaur 5 g  25',",
							"'kideka  5',",
							"'laudis  5', ",
							"'lingo  5', ",
							"'mavrik 24 ew  5', ",
							"'melody compact 49 wg 6', ",
							"'mildicut  10',",
							"'monsoon active  5', ",
							"'montaflow sc  10', ",
							"'mustang forte  1', ",
							"'mustang forte  5', ",
							"'mystic pro  5', ",
							"'nimrod 25 ec    1',",
							"'nuflon  5', ",
							"'nurelle-d 500 ec 1', ",
							"'nurelle-d 500 ec 5', ",
							"'opera new  5', ",
							"'osiris  5', ",
							"'pendigan 330 ec   5', ",
							"'perenal  5',",
							"'pictor  5', ",
							"'prolectus  0,25', ",
							"'propulse se 250  5', ",
							"'prosaro               5', ",
							"'pulsar          5', ",
							"'pulsar plus  5', ",
							"'pyrinex 48 ec   5',",
							"'pyrinex supreme  5', ",
							"'racer 25 ec     5', ",
							"'sekator od  1', ",
							"'stabilan sl     10', ",
							"'systhane 20 ew  1', ",
							"'taltos+polyglycol  1,5+22,5', ",
							"'taltos+polyglycol  25*(0,033+0,5)', ",
							"'tango star      5', ",
							"'teppeki 50 wg  2', ",
							"'teppeki 50 wg  0,5', ",
							"'trek p  5', ",
							"'warrant 200 sl  1', ",
							"'wing p  10', ",
							"'zantara ec 216  5', ",
							"'zoom 11 sc  1', ",
							"'zoom 11 sc  0,25'",
							") or ",
							"lower(termek.nev) like 'bayer sz_l_ cs.'")
            temp = dbGetQuery(localConnection, command)
            colnames(temp) = c("id")
            return(temp)
        }
        loadAgentNames = function (customer.ids) {
            customer.ids.string = paste("'", as.character(customer.ids), "'", collapse=", ", sep="")
            command = paste("select v.id_vevo, u.nev",
                            " from vevo v left join",
                            " uzletkoto u on u.id_uzletkoto = v.id_uzletkoto",
                            " where v.id_vevo in (", customer.ids.string, ")", sep="")
            temp = dbGetQuery(localConnection, command)
            colnames(temp) = c("customer_id", "agent_name")
            return(temp)
        }
        removePhoneBills = function (data) {
            return(data[-which(grepl(" HAVI (MOBIL|VEZET.KES) ?TEL", data$product_name)),])
        }
        imputeAgentName = function (data) {
            data.without.agents = is.na(data$agent_name)
            customer.ids.with.no.agents = unique(data[data.without.agents, 'customer_id'])
            if (length(customer.ids.with.no.agents) > 0) {
                agents.of.customers = loadAgentNames(customer.ids.with.no.agents)
                temp = merge(data[data.without.agents,], agents.of.customers, by="customer_id", all.x=T)
                
                data[which(data.without.agents),'agent_name'] = temp$agent_name.y
            }
            return (data)
        }
        aggregateForAgents = function (data, agents) {
            if (nrow(data) == 0) {
                return (rep(0, length(agents$agent_name)))
            }
            aggregated.sales = aggregate(data$totalprice, 
                                         list(data$agent_name),
                                         function (x) { round(sum(x),0)})
            colnames(aggregated.sales) = c("agent_name", "sum")
			full.total = sum(aggregated.sales$sum)
			tempresult = merge(agents, aggregated.sales, by="agent_name", all.x=T)
			# I had issues here. merge() works in weird ways with the row for "Összesen":
			# If "Összesen" was already added to the aggregated.sales with a value, merge will sort it too, forcing it after letter "O" alphabetically
			# tempresult will contain "Összesen" now but it will be at the end of the dataframe since it's value is N/A!
			tempresult[which(tempresult$agent_name=="Összesen"),"sum"] = full.total
			merged = tempresult[,2]
			merged[is.na(merged)] = 0
			return(merged)
        }
        aggregateForSitesByAgent = function (data, sites, agent_name, criteria = NULL) {
            localData = data
            if (!is.null(criteria)) {
                localData = localData[which(criteria),]
            }
            localData = localData[which(localData$agent_name == agent_name),]
            if (nrow(localData) == 0) {
                return (rep(0, length(sites$site)))
            }
            aggregated.sales = aggregate(localData$totalprice, 
                                         list(localData$original_site),
                                         function (x) { round(sum(x),0)})
            colnames(aggregated.sales) = c("site", "sum")
			full.total = sum(aggregated.sales$sum)
			tempresult = merge(sites, aggregated.sales, by="site", all.x=T)
			tempresult[which(tempresult$site=="Összesen"),"sum"] = full.total
			merged = tempresult[,2]
			merged[is.na(merged)] = 0
			return(merged)
        }
        aggregateByCriteria = function (data, agents, criteria) {
            ss = data[which(criteria),]
            return(aggregateForAgents(ss, agents))
        }
        aggregateForProvider = function (data, agents, provider) {
            ss = subset(data, grepl(provider, data$provider_name))
            return(aggregateForAgents(ss, agents))
        }
        aggregateByCriteriaForVetomagForProvider = function (data, agents, provider) {
            ss = subset(data, grepl("^VET.MAG$", data$group_name))
            ss = subset(ss, grepl(provider, ss$provider_name))
            return(aggregateForAgents(ss, agents))
        }
        me = list (
            thisEnv = thisEnv,
            getEnv = function () {
                return(get("thisEnv", thisEnv))
            },
            getResult = function () {
            	data = get("result", thisEnv)
            	data$customer_differs = rep(0, nrow(data))
            	data[which(data$customer_szallito != data$customer_szamla),"customer_differs"] = 1
            	data$agent_differs = rep(0, nrow(data))
            	data[which(data$agent_szallito != data$agent_szamla),"agent_differs"] = 1
                colnames(data) = c("Dátum", "Szállító/Számla száma", "Termék neve", "Egységár (kerekített)", "Mennyiség", "Total (kerekített)", "Szolgáltató", "Termékcsoport", "Vevő", "Üzletkötő", "Kiállító telephely", "termek_id", "vevo_id", "Üzletkötő típusa", "Szállítólevél vevője", "Szállítólevél üzletkötője", "Számla vevője", "Számla üzletkötője", "Vevő különbözik", "Üzletkötő különbözik")
                return(data)
            },
            load = function (from, to) {
                command = paste(
                    #Azok a számlák amihez tartozik szállítólevél.
                    #Itt az üzletkötőket a szállítóhoz tartozó vevő alapján számítom
                    "select szamla.datum, szamla.sorszam, termek.nev, round(szamlatetel.eladar) as \"eladar\", szamlatetel.mennyiseg, ",
                    "round(szamlatetel.eladar * szamlatetel.mennyiseg) as \"EladarSum\", ",
                    "forgalmazo.nev, csoport.nev, vevo.nev, uzletkoto.nev, telephelysync.nev, termek.id_termek, ",
                    "vevo.id_vevo, 'UZLETKOTO-SZLEVEL', vevo.nev, uzletkoto.nev, vszamla.nev, uszamla.nev ",
                    "from szamlatetel join  ",
                    "szamla on szamla.id_szamla = szamlatetel.id_szamla join ",
                    "kihivatkozas kh on kh.id_szamla = szamla.id_szamla join ",
                    "szlevel on szlevel.id_szlevel = kh.id_szlevel join	",
                    "telephelysync on telephelysync.id_telephelysync = szlevel.id_orig_telephely join ",
                    "vevo on vevo.id_vevo = szlevel.id_vevo join ",
                    "termek on termek.id_termek = szamlatetel.id_termek join ",
                    "forgalmazo on forgalmazo.id_forgalmazo = termek.id_forgalmazo join ",
                    "csoport on csoport.id_csoport = termek.id_csoport left join ",
                    "uzletkoto on uzletkoto.id_uzletkoto = vevo.id_uzletkoto left join ",
                    "vevo vszamla on vszamla.id_vevo = szamla.id_vevo left join ",
                    "uzletkoto uszamla on uszamla.id_uzletkoto = vszamla.id_uzletkoto ",
                    "where szamla.datum >='", from, "' and szamla.datum <='", to, "' ",
                    "union all ",
                    #Ugyanaz mint az előző csak itt minden olyan számlát húzok be amihez nem tartozik szállítólevél. ",
                    #Itt az üzletkötőket a számlához tartozó vevő alapján számítom ",
                    "select szamla.datum, szamla.sorszam, termek.nev, round(szamlatetel.eladar) as \"eladar\", szamlatetel.mennyiseg, ",
                    "round(szamlatetel.eladar * szamlatetel.mennyiseg) as \"EladarSum\", ",
                    "forgalmazo.nev, csoport.nev, vevo.nev, uzletkoto.nev, telephelysync.nev, termek.id_termek, ",
                    "vevo.id_vevo, 'UZLETKOTO-SZAMLA', null, null, vevo.nev, uzletkoto.nev ",
                    "from szamlatetel join  ",
                    "szamla on szamla.id_szamla = szamlatetel.id_szamla join ",
                    "telephelysync on telephelysync.id_telephelysync = szamla.id_orig_telephely join ",
                    "vevo on vevo.id_vevo = szamla.id_vevo join ",
                    "termek on termek.id_termek = szamlatetel.id_termek join ",
                    "forgalmazo on forgalmazo.id_forgalmazo = termek.id_forgalmazo join ",
                    "csoport on csoport.id_csoport = termek.id_csoport left join ",
                    "uzletkoto on uzletkoto.id_uzletkoto = vevo.id_uzletkoto ",
                    "where szamla.datum >='", from, "' and szamla.datum <='", to, "' and ",
                    "szamla.id_szamla not in ( ",
                        "select distinct id_szamla ",
                        "from kihivatkozas ",
                    ") or ",
                    #Lehetséges, hogy a kihivatkozas táblában szerepel, de szlevel már nincs hozzá rendelve valamiért
                    "szamla.id_szamla in ( ",
                        "select distinct id_szamla ",
                        "from kihivatkozas left join ",
                        "szlevel on szlevel.id_szlevel = kihivatkozas.id_szlevel ",
                        "where szlevel.sorszam is null",
                    ") ",
                    sep="")
                
                temp = dbGetQuery(localConnection, command)
                colnames(temp) = c("date", "bill_num", "product_name", "price", "amount", "totalprice", "provider_name", "group_name", "customer_name", "agent_name", "original_site", "product_id", "customer_id", "agent_type", "customer_szallito", "agent_szallito", "customer_szamla", "agent_szamla")
                assign("result", temp, thisEnv)
                #print("Data is loaded into memory")
            },
            report = function () {
                if (is.null(result)) {
                    stop("Use \"load\" to load data first")
                } else {
                    special.products = loadSpecialProducts()
                    agents = data.frame("agent_name"=sort(unique(result$agent_name)))
                    agents = rbind(agents, data.frame("agent_name"="Összesen"))
                    agent.sales = data.frame("agent_name"=agents$agent_name)
                    result = removePhoneBills(result)
                    result = imputeAgentName(result)
                    agent.sales$Farmmix = aggregateByCriteria(result, agents, grepl("^FARMMIX KFT$", result$provider_name))
                    agent.sales$"Farmmix Alternatív" = aggregateByCriteria(result, agents, grepl("^FARMMIX KFT ALT", result$provider_name))
                    agent.sales$Agrosol = aggregateByCriteria(result, agents, grepl("AGROSOL", result$provider_name))
                    agent.sales$Vetco = aggregateByCriteria(result, agents, grepl("VETCO", result$provider_name))
                    agent.sales$"F + FA + A + V" = agent.sales$Farmmix +
                        agent.sales$"Farmmix Alternatív" +
                        agent.sales$Agrosol +
                        agent.sales$Vetco
                    agent.sales$Kiemelt = aggregateByCriteria(result, agents, criteria = (result$product_id %in% special.products$id))
                    # Axe out the special products for further calculations
                    result.without.special = result[-which(result$product_id %in% special.products$id),]
                    
                    # We filter all products that are:
                    #   - "Egyéb" is set as a provider
                    #   - Is not "Műtrágya" or not "Vetőmag"
                    #   - Is "Műtrágya" but doesn't start with MT, Yara, Timac or Cropcare
                    agent.sales$"Egyéb, nagy gyártóhoz nem köthető" = 
                        aggregateByCriteria(result.without.special,
                                                           agents,
                                                           criteria = grepl("^EGY.B$", result.without.special$provider_name) &
                                                                           (
                                                                               !grepl("^M.TR.GYA$|^VET.MAG$", result.without.special$group_name) |
                                                                               (
                                                                                   grepl("^M.TR.GYA$", result.without.special$group_name) &
                                                                                    !grepl("^MT|^YARA|^TIMAC|^CROPCARE", result.without.special$product_name)
                                                                               )
                                                                           )
                                            )
                    agent.sales$"F + FA + A + V + K + E" = agent.sales$"F + FA + A + V" + 
                        agent.sales$Kiemelt +
                        agent.sales$"Egyéb, nagy gyártóhoz nem köthető"
                    
					# We have to exclude VETŐMAG from the query
					rws.without.vetomag = subset(result.without.special, !grepl("^VET.MAG$", result.without.special$group_name))
                    agent.sales$Adama = aggregateForProvider(rws.without.vetomag, agents, "^ADAMA")
                    agent.sales$Arysta = aggregateForProvider(rws.without.vetomag, agents, "^ARYSTA")
                    agent.sales$BASF = aggregateForProvider(rws.without.vetomag, agents, "^BASF")
                    agent.sales$Bayer = aggregateForProvider(rws.without.vetomag, agents, "^BAYER CROPSCIENCE")
                    agent.sales$Belchim = aggregateForProvider(rws.without.vetomag, agents, "^BELCHIM")
                    agent.sales$"FMC Agro" = aggregateForProvider(rws.without.vetomag, agents, "^FMC-AGRO")
                    agent.sales$Chemtura = aggregateForProvider(rws.without.vetomag, agents, "^CHEMTURA$")
                    agent.sales$Dow = aggregateForProvider(rws.without.vetomag, agents, "^DOW")
                    agent.sales$Dupont = aggregateForProvider(rws.without.vetomag, agents, "^DUPONT")
                    agent.sales$Kwizda = aggregateForProvider(rws.without.vetomag, agents, "^KWIZDA")
                    agent.sales$Nufarm = aggregateForProvider(rws.without.vetomag, agents, "^NUFARM")
                    agent.sales$"Sumi-Agro növényvédőszer" = aggregateForProvider(rws.without.vetomag, agents, "^SUMI AGRO")
                    agent.sales$"Syngenta növényvédőszer" = aggregateForProvider(rws.without.vetomag, agents, "^SYNGENTA KFT$")
                    agent.sales$"Egyéb növényvédőszer" = agent.sales$Adama +
                        agent.sales$Arysta +
                        agent.sales$BASF +
                        agent.sales$Bayer +
                        agent.sales$Belchim +
                        agent.sales$"FMC Agro" +
                        agent.sales$Chemtura +
                        agent.sales$Dow +
                        agent.sales$Dupont +
                        agent.sales$Kwizda +
                        agent.sales$Nufarm +
                        agent.sales$"Sumi-Agro növényvédőszer" +
                        agent.sales$"Syngenta növényvédőszer"
                    agent.sales$"Növényvédőszer összes" = agent.sales$"F + FA + A + V + K + E" + agent.sales$"Egyéb növényvédőszer"
                    
                    agent.sales$"Gabonakutató" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^GABONAKUTAT.")
                    agent.sales$"Egyéb vetőmag" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^EGY.B$")
                    agent.sales$BayerSeeds = aggregateByCriteria(result.without.special, agents, (grepl("^VET.MAG$", result.without.special$group_name) &
                    																			  (
                    																			   grepl("^BAYER SEEDS$", result.without.special$provider_name) |
                    																			   grepl("^BAYER CROPSCIENCE$", result.without.special$provider_name)
                    																			   )
                    																			  )
                    )
                    agent.sales$KWS = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^KWS")
                    agent.sales$Limagrain = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^LIMAGRAIN")
                    agent.sales$Monsanto = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^MONSANT")
                    agent.sales$Martonvasar = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^MARTONV.S.R")
                    agent.sales$Pioneer = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^PIONEER")
                    agent.sales$Ragt = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^RAGT")
                    agent.sales$Saaten = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^SAATEN") 
                    agent.sales$"Sumi-Agro vetőmag" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^SUMI AGRO")
                    agent.sales$"Syngenta vetőmag" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^SYNGENTA VET.MAG$")
                    agent.sales$"Dow vetőmag" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^DOW")
                    agent.sales$"Kwizda vetőmag" = aggregateByCriteriaForVetomagForProvider(result.without.special, agents, "^KWIZDA")

                    agent.sales$"Vetőmag összes" = agent.sales$"Gabonakutató" +
                        agent.sales$"Egyéb vetőmag" +
                        agent.sales$BayerSeeds +
                        agent.sales$KWS +
                        agent.sales$Limagrain +
                        agent.sales$Monsanto +
                        agent.sales$Martonvasar +
                        agent.sales$Pioneer +
                        agent.sales$Ragt +
                        agent.sales$Saaten +
                        agent.sales$"Sumi-Agro vetőmag" +
                        agent.sales$"Syngenta vetőmag" +
                        agent.sales$"Dow vetőmag" +
                        agent.sales$"Kwizda vetőmag"
                    
                    agent.sales$"Egyéb műtrágya alap" = aggregateByCriteria(result.without.special, agents, (grepl("^EGY.B$", result.without.special$provider_name) &
																											 grepl("^M.TR.GYA ALAP$", result.without.special$group_name)))
                    agent.sales$"Egyéb műtrágya" = aggregateByCriteria(result.without.special, agents, (grepl("^EGY.B$", result.without.special$provider_name) &
																										grepl("^M.TR.GYA$", result.without.special$group_name)))
                    agent.sales$"Műtrágya összes" = agent.sales$"Egyéb műtrágya alap" + agent.sales$"Egyéb műtrágya"
                    agent.sales$"Összes" = agent.sales$"Növényvédőszer összes" +
                        agent.sales$"Vetőmag összes" +
                        agent.sales$"Műtrágya összes"
                    return(agent.sales)
                }
            },
            exportAgentDataBySite = function (filename) {
                if (is.null(result)) {
                    stop("Use \"load\" to load data first")
                } else {
                    special.products = loadSpecialProducts()
                    result.without.special = result[-which(result$product_id %in% special.products$id),]
                    agents = data.frame("agent_name"=sort(unique(result$agent_name)))
                    agents = rbind(agents, data.frame("agent_name"="Összesen"))
                    sites = data.frame("site"=sort(unique(result$original_site)))
                    sites = rbind(sites, data.frame("site"="Összesen"))
                    for (i in c(1:(dim(agents)[1])-1)) {
                        agent.name = agents[i,1]
                        agent.result = data.frame("site"=sites$site)
                        agent.result$"Nettó összforgalom" = aggregateForSitesByAgent(result, sites, agent.name)
                        
                        farmmix = aggregateForSitesByAgent(result, sites, agent.name, criteria=(grepl("^FARMMIX KFT$", result$provider_name)))
                        farmmix.alternativ = aggregateForSitesByAgent(result, sites, agent.name, criteria=(grepl("^FARMMIX KFT ALT", result$provider_name)))
                        kiemelt = aggregateForSitesByAgent(result, sites, agent.name, criteria=(result$product_id %in% special.products$id))
                        agrosol = aggregateForSitesByAgent(result, sites, grepl("AGROSOL", result$provider_name))
                        vetco = aggregateForSitesByAgent(result, sites, grepl("VETCO", result$provider_name))
                        ffaav = farmmix + 
                            farmmix.alternativ +
                            agrosol +
                            vetco
                        result.without.special = result[-which(result$product_id %in% special.products$id),]
                        misc = 
                            aggregateForSitesByAgent(result.without.special,
                                                                sites,
                                                                agent.name,
                                                                criteria = grepl("^EGY.B$", result.without.special$provider_name) &
                                                                               (
                                                                                   !grepl("^M.TR.GYA$|^VET.MAG$", result.without.special$group_name) |
                                                                                   (
                                                                                       grepl("^M.TR.GYA$", result.without.special$group_name) &
                                                                                        !grepl("^MT|^YARA|^TIMAC|^CROPCARE", result.without.special$product_name)
                                                                                   )
                                                                               )
                                                )
                        ffaavke = ffaav + 
                            kiemelt +
                            misc

						# We have to exclude VETŐMAG from the query
                        rws.without.vetomag = subset(result.without.special, !grepl("^VET.MAG$", result.without.special$group_name))
                        adama = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^ADAMA", rws.without.vetomag$provider_name))
                        arysta = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^ARYSTA", rws.without.vetomag$provider_name))
                        BASF = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^BASF", rws.without.vetomag$provider_name))
                        bayer = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^BAYER CROPSCIENCE", rws.without.vetomag$provider_name))
                        belchim = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^BELCHIM", rws.without.vetomag$provider_name))
                        fmc_agro = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^FMC-AGRO", rws.without.vetomag$provider_name))
                        chemtura = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^CHEMTURA$", rws.without.vetomag$provider_name))
                        dow = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^DOW", rws.without.vetomag$provider_name))
                        dupont = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^DUPONT", rws.without.vetomag$provider_name))
                        kwizda = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^KWIZDA", rws.without.vetomag$provider_name))
                        nufarm = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^NUFARM", rws.without.vetomag$provider_name))
                        sumi = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^SUMI AGRO", rws.without.vetomag$provider_name))
                        syngenta = aggregateForSitesByAgent(rws.without.vetomag, sites, agent.name, grepl("^SYNGENTA KFT$", rws.without.vetomag$provider_name))
                        misc_pesticide = adama +
                            arysta +
                            BASF +
                            bayer +
                            belchim +
                            fmc_agro +
                            chemtura +
                            dow +
                            dupont +
                            kwizda +
                            nufarm +
                            sumi +
                            syngenta
                        
                        
                        #Set the columns
                        agent.result$"Növszer összforgalom" = ffaavke + misc_pesticide
                        agent.result$"Farmmix kiemelt" = kiemelt
                        agent.result$"Farmmix Alternatív" = farmmix.alternativ
                        agent.result$Farmmix = farmmix
                        
                        
                        rws.vetomag = subset(result.without.special, grepl("^VET.MAG$", result.without.special$group_name))
                        aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^DUPONT", rws.vetomag$provider_name))
                        gabonakutato = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^GABONAKUTAT.", rws.vetomag$provider_name))
                        egyeb.vetomag = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^EGY.B$", rws.vetomag$provider_name))
                        KWS = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^KWS", rws.vetomag$provider_name))
						bayerSeeds = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, 
															  (
															   grepl("^BAYER SEEDS$", result.without.special$provider_name) |
															   grepl("^BAYER CROPSCIENCE$", result.without.special$provider_name)
															   )
															  )
                        limagrain = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^LIMAGRAIN", rws.vetomag$provider_name))
                        monsanto = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^MONSANT", rws.vetomag$provider_name))
                        martonvasar = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^MARTONV.S.R", rws.vetomag$provider_name))
                        pioneer = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^PIONEER", rws.vetomag$provider_name))
                        ragt = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^RAGT", rws.vetomag$provider_name))
                        saaten = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^SAATEN", rws.vetomag$provider_name)) 
                        sumi.vegomag = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^SUMI AGRO", rws.vetomag$provider_name))
                        syngenta.vetomag = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^SYNGENTA VET.MAG$", rws.vetomag$provider_name))
                        dow.vetomag = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^DOW", rws.vetomag$provider_name))
                        kwizda.vetomag = aggregateForSitesByAgent(rws.vetomag, sites, agent.name, grepl("^KWIZDA", rws.vetomag$provider_name))
                        vetomag.osszes = gabonakutato +
                            egyeb.vetomag +
                            KWS +
                            bayerSeeds + 
                            limagrain +
                            monsanto +
                            martonvasar +
                            pioneer +
                            ragt +
                            saaten +
                            sumi.vegomag +
                            syngenta.vetomag +
                            dow.vetomag +
                            kwizda.vetomag
                        
                        agent.result$"Vetőmag" = vetomag.osszes


                        agent.result$"Egyéb műtrágya alap" = aggregateForSitesByAgent(result.without.special, sites, agent.name, (grepl("^EGY.B$", result.without.special$provider_name) &
																																  grepl("^M.TR.GYA ALAP$", result.without.special$group_name)))
                        agent.result$"Egyéb műtrágya" = aggregateForSitesByAgent(result.without.special, sites, agent.name, (grepl("^EGY.B$", result.without.special$provider_name) &
																															      grepl("^M.TR.GYA$", result.without.special$group_name)))
                        if (i==1) {
                            write.table(agent.name, filename, row.names=F, col.names=F)
                        } else {
                            write.table(agent.name, filename, row.names=F, col.names=F, append=T)
                        }
                        write.table(agent.result, filename, row.names=F, col.names=T, append=T, sep=",")
                        write.table(" ", filename, row.names=F, col.names=F, append=T)
                    }
                }
            }
        )
        assign('this', me, envir = thisEnv)
        class(me) = append(class(me), "AgentSales")
        return(me)
    }
}

suppressMessages(library('RJDBC'))
suppressMessages(library('xlsx'))

dbPassword = "masterkey"
drv = JDBC("org.firebirdsql.jdbc.FBDriver",
		   args.jdbc.path,
           identifier.quote="`")
c = dbConnect(drv, 
			   paste("jdbc:firebirdsql://127.0.0.1:3050//databases/", "dbs_2017.fdb?encoding=ISO8859_1", sep=""),
			   "SYSDBA", dbPassword)


as = AgentSales(c)

as$load(args.from, args.to)
agent.sales.by.category = as$report()
agent.result = as$getResult()

write.csv(t(agent.sales.by.category), args.agent.sales.by.category.file, col.names=F)
as$exportAgentDataBySite(args.agent.sales.by.site.file)
write.csv(agent.result, args.full.data.file)
success = dbDisconnect(conn = c)
cat("OK")
