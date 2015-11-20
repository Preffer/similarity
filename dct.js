"use strict";

var dctCosCache = {};

function calcDctCos(N) {
	if (dctCosCache[N]) {
		return dctCosCache[N];
	} else {
		var cache = new Float64Array(N * N);
		var PI_N = Math.PI / N;
		for (var k = 0; k < N; k++) {
			var PI_N_K = PI_N * k;
			for (var n = 0; n < N; n++) {
				cache[k * N + n] = Math.cos(PI_N_K * (n + 0.5));
			}
		}
		dctCosCache[N] = cache;
		return cache;
	}
}

function dct(signal) {
	var N = signal.length;
	var cos = calcDctCos(N);
	var coeff = new Float64Array(N);

	for (var k = 0; k < N; k++) {
		var sum = 0;
		for (var n = 0; n < N; n++) {
			sum += signal[n] * cos[k * N + n];
		}
		coeff[k] = sum;
	}

	return coeff;
}

/*
 @params signal 4 channel greyscale image, but only the first channel will be processed
 @return dct signal of the greyscale image, single channel
 */
function dct2(signal, width, height) {
	var coeff = new Float64Array(width * height);

	for (var row = 0; row < height; row++) {
		var rowArray = new Float64Array(width);
		for (var col = 0; col < width; col++) {
			rowArray[col] = signal[(row * width + col) * 4];
		}
		var freq = dct(rowArray);
		for (col = 0; col < width; col++) {
			coeff[(row * width + col)] = freq[col];
		}
	}

	for (col = 0; col < width; col++) {
		var colArray = new Float64Array(height);
		for (row = 0; row < height; row++) {
			colArray[row] = coeff[(row * width + col)];
		}
		freq = dct(colArray);
		for (row = 0; row < height; row++) {
			coeff[(row * width + col)] = freq[row];
		}
	}

	return coeff;
}

module.exports.dct = dct;
module.exports.dct2 = dct2;
