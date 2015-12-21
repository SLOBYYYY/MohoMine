let Charts = {
	top10ProductBarChart (component) {
		var data = [[1, 14929242], [2, 11167052], [3, 9118990], [4, 2193440], [5, 1764072], [6, 1509072], [7, 1223540], [8, 1159860], [9, 656172], [10, 635908]];
		$.plot($(component), [{
			data: data,
			label: "Top 10 termék"
		}], {
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
				ticks: [[1,"Omex általános lombtrágya"], [2, "Agrocean 20"], [3, "Omex Boron 20"], [4, "Calmax 20"], [5, "Omex Kingfol Zn 20"], [6, "Omex Ferti I. (16-09-26) 25"], [7, "Omex Starter (15-30-15) 25"], [8, "Omex Boron 5"], [9, "Agrocean 5"], [10, "Calmax 5"]],
				axisLabel: "World Cities",
				axisLabelUseCanvas: true,
				axisLabelFontSizePixels: 12,
				axisLabelFontFamily: 'Verdana, Arial',
				axisLabelPadding: 10,
			},
			yaxis: {
				tickFormatter: function (v, axis) {
					return v + " Ft";
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
				content: "%s - %y | %lx & %ly",
				shifts: {
					x: 20,
					y: 0
				},
				defaultTheme: true
			}
		});
	},

	randomBarChart (componentId) {
		var barOptions = {
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
		var barData = {
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
		var data = [{
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

		var pieOptions = {
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
		var data = [];
		for (var i = 0; i < 15; i+=0.5) {
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
