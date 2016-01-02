let Formatter = {
	formatMoney () {
		var number = this,
			decimalPlaces = 0,
			thousandSign = " ",
			decimalSign = ",",
			sign = number < 0 ? "-" : "",
			i = parseInt(number = Math.abs(+number || 0).toFixed(decimalPlaces)) + "",
			j = (j = i.length) > 3 ? j % 3 : 0;
			return sign +
				(j ? i.substr(0, j) + thousandSign : "") +
				i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousandSign) +
				(decimalPlaces ? decimalSign + Math.abs(number - i).toFixed(decimalPlaces).slice(2) : "");
	}
}
Number.prototype.formatMoney = Formatter.formatMoney
export default Formatter
