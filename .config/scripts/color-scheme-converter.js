#!/usr/bin/node
const fs = require("fs");
const path = require("path");

/**
 * Pad a hex string.
 * @param {string} hex 
 * @param {number} length 
 */
function pad(hex, length) {
	let result = hex;
	while (result.length < length) {
		result = "0" + result;
	}
	return result;
}

/**
 * Convert an rgb array to a hex string.
 * @param {string[]} rgb 
 */
function rgbArrToHex(rgb) {
	let hex = "#";
	for (let j = 0; j < 3; j++) {
		hex += pad(Number(rgb[j]).toString(16), 2);
	}
	return hex;
}

const args = process.argv.slice(2);
if (args[0] == undefined) {
	console.log("Missing arguments!");
	process.exit();
}

let target = path.resolve(args[0]);

if (!fs.existsSync(target)) {
	console.log("Target does not exist: " + target);
	process.exit();
}

let data = fs.readFileSync(target, { encoding: "utf8" });
let result = "";
let reTemplate = "(?<=\\[Color%s\\]\\nColor=).*$"

let opacity = data.match(/(?<=Opacity=).*$/gm);
if (opacity != null) {
	let value = Number(opacity[0])
	result += `background_opacity ${value}`;
}
let bg = data.match(/(?<=\[Background\]\nColor=).*$/gm);
if (bg != null) {
	let hex = rgbArrToHex(bg[0].split(","));
	result += `\nbackground ${hex}`;
}
let fg = data.match(/(?<=\[Foreground\]\nColor=).*$/gm);
if (fg != null) {
	let hex = rgbArrToHex(fg[0].split(","));
	result += `\nforeground ${hex}`;
}

let n = 0;
for (let i = 0; i <= 15; i++) {
	/** @type RegExp */
	let regex;
	if (i >= 8) regex = RegExp(reTemplate.replace("%s", n + "Intense"), "gm");
	else regex = RegExp(reTemplate.replace("%s", n), "gm");
	let rgb = data.match(regex);
	let hex = "";
	if (rgb != null) {
		hex = rgbArrToHex(rgb[0].split(","));
	}

	result += `\ncolor${i} ${hex}`;

	n++;
	if (i == 7) n = 0;
}

console.log(result);
