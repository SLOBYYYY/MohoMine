let Charts = {
	top10ProductBarChart (component) {
		var options = {
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
				axisLabel: "Termékek",
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
				content: "%x - %y",
				shifts: {
					x: 20,
					y: 0
				},
				defaultTheme: true
			}
		}

		var barChart = $.plot($(component), {
			data: []
		}, options);

		var updateBarPlot = function (result) {
			var ticks = [];
			var data = [];
			$.each(result.data, function (index, value) {
				ticks.push([index, value.name]);
				data.push([index, value.total]);
			});

			options.xaxis.ticks = ticks;
			$.plot($(component), [{data: data}], options);
		};

		$.ajax({
			url: "/api/report_schemas/top_10_product",
			type: "GET",
			dataType: "json",
			success: updateBarPlot
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
