let Tables = {
	dataTable: null,

	topProductsTable (component) {
		var setupData = {
			ajax: "/api/report_schemas/top_products",
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
			dataSrc: "",
			order: [[ 1, "desc" ]],
			paging: false,
			searching: false,
			lengthChange: false,
			info: false
		};
		this.dataTable = $(component).DataTable(setupData);
	},

	refreshDataTable() {
		this.dataTable.ajax.reload();
	}
}
export default Tables
