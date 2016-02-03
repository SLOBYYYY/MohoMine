function createDefaultOptionsForBarChart (axisLabel) {
	return {
		series: {
			bars: {
				show: true,
			}
		},
		bars: {
			align: "center",
			barWidth: 0.7
		},
		xaxis: {
			ticks: [],
			axisLabel: axisLabel,
			axisLabelUseCanvas: true,
			axisLabelFontSizePixels: 12,
			axisLabelFontFamily: 'Verdana, Arial',
			axisLabelPadding: 10,
		},
		yaxis: {
			tickFormatter: function (v, axis) {
				return v.formatMoney() + " Ft";
			}
		},
		axisLabels: {
			show: true
		},
		grid: {
			hoverable: true
		},
		tooltip: true,
		tooltipOpts: {
			content: "%x - %y",
			shifts: {
				x: 20,
				y: 0
			},
			defaultTheme: true
		}
	}
}
function createDefaultBarChart (component, options, report_name) {
	let barChart = $.plot($(component), {
		data: []
	}, options);
	barChart.updateData = function (data) {
		Charts.updateBarChart (barChart, data);
	};
	return barChart;
}
function genericBarChartCreator(component, title, reportName) {
	let options = createDefaultOptionsForBarChart(title);
	let barChart = createDefaultBarChart(component, options);

	$.ajax({
		url: `/api/report_schemas/${reportName}`,
		type: "GET",
		dataType: "json",
		success: function (result) {
			Charts.updateBarChart(barChart, result);
		}
	});
	return barChart;
}

let Charts = {
	updateBarChart (barChart, result) {
		let ticks = [];
		let data = [];
		$.each(result.data, function (index, value) {
			ticks.push([index, value.name]);
			data.push([index, value.total]);
		});

		let newOptions = barChart.getOptions();
		newOptions.xaxes[0].ticks = ticks;
		barChart = $.plot(barChart.getPlaceholder(), [{data: data}], newOptions);
	},
	topAgentsBarChart (component) {
		return genericBarChartCreator(component, "Üzletkötők", "top_agents");
	},
	topProductsBarChart (component) {
		return genericBarChartCreator(component, "Termékek", "top_products");
	},

	randomBarChart (componentId) {
		let barOptions = {
			series: {
				bars: {
					show: true,
					barWidth: 43200000
				}
			},
			xaxis: {
				mode: "time",
				timeformat: "%m-%d",
				minTickSize: [1, "day"]
			},
			grid: {
				hoverable: true
			},
			legend: {
				show: false
			},
			tooltip: true,
			tooltipOpts: {
				content: "x: %x, y: %y"
			}
		};
		let barData = {
			label: "bar",
			data: [
				[1354521600000, 1000],
				[1355040000000, 2000],
				[1355223600000, 3000],
				[1355306400000, 4000],
				[1355487300000, 5000],
				[1355571900000, 6000]
			]
		};
		$.plot($("#" + componentId ), [barData], barOptions);
	}, 

	randomPieChart (componentId) {
		let data = [{
			label: "Series 0",
		data: 1
		}, {
			label: "Series 1",
		data: 3
		}, {
			label: "Series 2",
		data: 9
		}, {
			label: "Series 3",
		data: 20
		}];

		let pieOptions = {
			series: {
				pie: {
					show: true
				}
			},
			grid: {
				hoverable: true
			},
			tooltip: true,
			tooltipOpts: {
				content: "%p.0%, %s", // show percentages, rounding to 2 decimal places
				shifts: {
					x: 20,
					y: 0
				},
				defaultTheme: false
			}
		};
		$.plot($("#" + componentId), data, pieOptions);
	},

	randomLineChart (componentId) {
		let data = [];
		for (let i = 0; i < 15; i+=0.5) {
			data.push([i, Math.sin(i)]);
		}
		$.plot($("#" + componentId), [{
			data: data,
			lines: { show: true }
		}], {
			series: {
				lines: {
					show: true
				},
				points: {
					show:true
				}
			},
			grid: {
				hoverable: true
			},
			tooltip: true,
			tooltipOpts: {
				content: "%s -> FAG = %x || %n",
				shifts: {
					x: 20,
					y: 0
				},
				defaultTheme: true
			}
		});
	}
}

export default Charts
