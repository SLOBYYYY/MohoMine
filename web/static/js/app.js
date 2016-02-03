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
	
	let topProductsTable = Tables.topProductsTable($("#top-products-table"));
	let topAgentsTable = Tables.topAgentsTable($("#top-agents-table"));

	let topProductsChart = Charts.topProductsBarChart($("#top-products-bar-chart"));
	let topAgentsChart = Charts.topAgentsBarChart($("#top-agents-bar-chart"));

	//Initializer.initializeDashboard();
	let form = $("#agent_filter");
	form.submit(function (e) {
		$.ajax({
			type: "POST",
			url: "/api/report_schemas/top_agents",
			data: form.serialize(),
			success: function (data) {
				topAgentsChart.updateData(data);
				topAgentsTable.updateData(data);
			}
		});
		e.preventDefault();
	});
});

