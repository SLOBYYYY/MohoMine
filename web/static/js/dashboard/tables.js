let Tables = {
	dataTable: null,

	top10Table (component) {
		var setupData = {
			ajax: "/api/report_schemas/top_10_product",
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
