let Tables = {
	createOptionsForDataTable (options) {
		var defaultOption = {
			ajax: `/api/report_schemas/${options.report_name}`,
			columns: [],
			dataSrc: "",
			order: [[ 1, "desc" ]],
			paging: false,
			searching: false,
			lengthChange: false,
			info: false,
		};
		$.extend(defaultOption, options);
		return defaultOption;
	},

	topProductsTable (component) {
		var options = {
			report_name: "top_products",
			columns: [
				{
					title: "Termék",
					data: "name"
				},
				{
					title: "Ft",
					data: "total"
				}
			],
			createdRow: function (row, data, index) {
				$('td', row).last().text(data.total.formatMoney());
			}
		};
		options = this.createOptionsForDataTable(options);
		$(component).DataTable(options);
	},
	topAgentsTable (component) {
		var options = {
			report_name: "top_agents",
			columns: [
				{
					title: "Üzletkötő",
					data: "name"
				},
				{
					title: "Ft",
					data: "total"
				}
			],
			createdRow: function (row, data, index) {
				$('td', row).last().text(data.total.formatMoney());
			}
		};
		options = this.createOptionsForDataTable(options);
		$(component).DataTable(options);
	},
	refreshDataTable(dataTable) {
		dataTable.ajax.reload();
	}
}
export default Tables
