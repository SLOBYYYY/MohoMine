function createDefaultOptionsForDataTable () {
	let defaultOptions = {
		paging: false,
		searching: false,
		lengthChange: false,
		info: false,
	};
	return defaultOptions;
}

function setCustomObjects (dataTable, options, originalComponent) {
	dataTable.options = options;
	dataTable.originalComponent = originalComponent;
}

function genericDataTableCreator (component, options) {
	let defaultOptions = createDefaultOptionsForDataTable();
	let finalOptions = $.extend(defaultOptions, options);
	let dataTable = $(component).DataTable($.extend({}, finalOptions));

	setCustomObjects(dataTable, finalOptions, component);
	dataTable.updateData = function (data) {
		Tables.updateDataTable (this, data);
	}

	$.ajax({
		url: `/api/report_schemas/${finalOptions.reportName}`,
		type: "GET",
		dataType: "json",
		success: function (result) {
			let transformedData = $.map(result.data, function (value, key) {
				return [[value.name, value.total]];
			});
			let newData = { data: transformedData, destroy: true };
			let newOptions = $.extend(finalOptions, newData);
			dataTable = $(component).DataTable(newOptions);
		}
	});

	return dataTable;
}

function createTopProductsOptionsForTable () {
	return {
		reportName: "top_products",
		columns: [
			{
				title: "Termék",
			},
			{
				title: "Ft",
			}
		],
		order: [[ 1, "desc" ]],
		createdRow: function (row, data, index) {
			//$('td', row).last().text(data.total.formatMoney());
			$('td', row).last().text(data[1].formatMoney());
		}
	};
}

function createTopAgentsOptionsForTable () {
	return {
		reportName: "top_agents",
		columns: [
			{
				title: "Üzletkötő",
			},
			{
				title: "Ft",
			}
		],
		order: [[ 1, "desc" ]],
		createdRow: function (row, data, index) {
			//$('td', row).last().text(data.total.formatMoney());
			$('td', row).last().text(data[1].formatMoney());
		}
	};
}

let Tables = {
	topProductsTable (component) {
		let options = createTopProductsOptionsForTable();
		return genericDataTableCreator(component, options);
	},
	topAgentsTable (component) {
		let options = createTopAgentsOptionsForTable();
		return genericDataTableCreator(component, options);
	},
	updateDataTable(dataTable, data) {
		let transformedData = [];
		if (data.length !== 0) {
			transformedData = $.map(data, function (value, key) {
				return [[value.name, value.total]];
			});
		}
		let newData = { data: transformedData, destroy: true };
		let newOptions = $.extend(dataTable.options, newData);

		let newDataTable = $(dataTable.originalComponent).DataTable($.extend({}, newOptions));
		setCustomObjects(newDataTable, newOptions, dataTable.originalComponent);
		dataTable = newDataTable;
	}
}
export default Tables
