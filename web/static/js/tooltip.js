let instance = null;

class Tooltip {
	constructor () {
		if (!instance) {
			instance = this;
		}

		$.fn.UseTooltip = function () {
			$(this).bind("plothover", function (event, pos, item) {
				if (item) {
					if ((previousLabel != item.series.label) || (previousPoint != item.dataIndex)) {
						previousPoint = item.dataIndex;
						previousLabel = item.series.label;
						$("#tooltip").remove();

						var x = item.datapoint[0];
						var y = item.datapoint[1];

						var color = item.series.color;
						var month = new Date(x).getMonth();

						if (item.seriesIndex == 0) {
							showTooltip(item.pageX,
								item.pageY,
								color,
								"<strong>" + item.series.label + "</strong><br>" + monthNames[month] + " : <strong>" + y + "</strong>(USD)");
						} else {
							showTooltip(item.pageX,
								item.pageY,
								color,
								"<strong>" + item.series.label + "</strong><br>" + monthNames[month] + " : <strong>" + y + "</strong>(%)");
						}
					}
				} else {
					$("#tooltip").remove();
					previousPoint = null;
				}
			});
		};

		return instance;
	}

	show (x, y, color, contents) {
		$('<div id="tooltip">' + contents + '</div>').css({
			position: 'absolute',
			display: 'none',
			top: y - 40,
			left: x - 120,
			border: '2px solid ' + color,
			padding: '3px',
			'font-size': '9px',
			'border-radius': '5px',
			'background-color': '#fff',
			'font-family': 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
			opacity: 0.9
		}).appendTo("body").fadeIn(200);
	}
}
