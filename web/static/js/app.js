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
	let topProductsTable = Tables.topProductsTable($("#top-products-table"));
	let topAgentsTable = Tables.topAgentsTable($("#top-agents-table"));

	let topProductsChart = Charts.topProductsBarChart($("#top-products-bar-chart"));
	let topAgentsChart = Charts.topAgentsBarChart($("#top-agents-bar-chart"));

	//Initializer.initializeDashboard();
	let form = $("#agent_filter");
	form.submit(function (e) {
		$.ajax({
			type: "GET",
			url: "/api/dashboard/top_agents",
			data: form.serialize(),
			success: function (result) {
				topAgentsChart.updateData(result);
				topAgentsTable.updateData(result);
			}
		});
		e.preventDefault();
	});

	let form_product_filter = $("#product_filter");
	form_product_filter.submit(function (e) {
		$.ajax({
			type: "GET",
			url: "/api/dashboard/top_products",
			data: form_product_filter.serialize(),
			success: function (result) {
				topProductsChart.updateData(result);
				topProductsTable.updateData(result);
			}
		});
		e.preventDefault();
	});

	$.ajax({
		type: "GET",
		url: "/api/dashboard/providers",
		success: function (result) {
			let providerSelect = $('[name="filter[provider]"]');
			$.each(result.data, function (key, value) {
				providerSelect.append('<option value="' + value.id + '">' + value.name + '</option>');
			});
			providerSelect.select2({
				theme: "classic",
				allowClear: true,
				placeholder: "Válasszon egy szolgáltatót"
			});
			providerSelect.val(null).trigger("change");
		}
	});
});

