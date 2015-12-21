let Tables = {
	top10Table (component) {
		var dataSet = [
			[ "Omex általános lombtrágya", 14929242 ],
			[ "Agrocean 20", 11167052 ],
			[ "Omex Boron 20", 9118990 ],
			[ "Calmax 20", 2193440 ],
			[ "Omex Kingfol Zn 20", 1764072 ],
			[ "Omex Ferti I. (16-09-26) 25", 1509072 ],
			[ "Omex Starter (15-30-15) 25", 1223540 ],
			[ "Omex Boron 5", 1159860 ],
			[ "Agrocean 5", 656172 ],
			[ "Calmax 5", 635908 ]
		];
		var setupData = {
			data: dataSet,
			columns: [
				{ title: "Termék" },
				{ title: "Ft" }
			],
			order: [[ 1, "desc" ]],
			paging: false,
			searching: false,
			lengthChange: false,
			info: false
		};
		$(component).dataTable(setupData);
	}
}
export default Tables
