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
	var top_products_table = document.getElementById("top-products-table");
	var top_agents_table = document.getElementById("top-agents-table");
	Tables.topProductsTable(top_products_table);

	var top_products_bar_chart = document.getElementById("top-products-bar-chart");
	var top_agents_bar_chart = document.getElementById("top-agents-bar-chart");
	Charts.topProductsBarChart(top_products_bar_chart);
	Charts.topAgentsBarChart(top_agents_bar_chart);
});

