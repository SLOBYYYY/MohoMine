// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import Formatter from "./formatter"
import Tables from "./dashboard/tables"
import Charts from "./dashboard/charts"

$(document).ready(function () {
	// Cannot use jquery call syntax here to get elements. It's funny because 
	// $(document) ready is working..
	
	//let top_products_table = $("#top-products-table");
	//let top_agents_table = $("#top-agents-table");
	//Tables.topProductsTable(top_products_table);
	//Tables.topAgentsTable(top_agents_table);

	let top_products_bar_chart = $("#top-products-bar-chart");
	let top_agents_bar_chart = $("#top-agents-bar-chart");
	let topProducts = Charts.topProductsBarChart(top_products_bar_chart);
	let topAgents = Charts.topAgentsBarChart(top_agents_bar_chart);

	//Initializer.initializeDashboard();
	let form = $("#agent_filter");
	form.submit(function (e) {
		$.ajax({
			type: "POST",
			url: "/api/report_schemas/top_agents",
			data: form.serialize(),
			success: function (data) {
				topAgents.updateData(data.data);
				//var tables = require("web/static/js/dashboard/tables");
				//tables.refreshDataTable($("#top-agents-table"));
			}
		});
		e.preventDefault();
	});
});

