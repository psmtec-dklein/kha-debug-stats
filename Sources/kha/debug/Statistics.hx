package kha.debug;

import kha.graphics2.Graphics;
import kha.math.FastMatrix3;

@:structInit
class Tag {
	public var id : String;
	public var color : Color;
}

@:structInit
class Settings {
	public var bufferSize : Int;
	public var displayHeight : Int;
	public var tags : Array<Tag>;
}

class Display {
	var buffers : Array<haxe.ds.Vector<Float>>;
	var bufferColors : Array<Color>;
	var bufferSize : Int;

	var frameIndex = 0;
	var width : Float;
	var height : Float;

	var font : Font;

	public function new( settings : Settings, font : Font ) {
		if (settings.tags == null || settings.tags.length == 0) {
			throw 'provide at least 1 tag';
		}

		buffers = [for (tag in settings.tags) new haxe.ds.Vector(settings.bufferSize)];
		bufferColors = [for (tag in settings.tags) tag.color];
		bufferSize = settings.bufferSize;
		this.width = settings.bufferSize;
		this.height = settings.displayHeight;

		this.font = font;
	}

	public function nextFrame() {
		if (++frameIndex >= bufferSize) {
			frameIndex = 0;
		}

		for (b in buffers) {
			b[frameIndex] = 0;
		}
	}

	public function updateBuffer( index : Int, duration : Float ) {
		buffers[index][frameIndex] += duration * 1000;
	}

	function round( n : Float ) : Float return Math.round(n * Math.pow(10, 3)) / Math.pow(10, 3);

	public function render( g2 : Graphics, x : Float, y : Float ) {
		var colorGuard = g2.color;
		var fontGuard = g2.font;

		g2.begin(false);
			g2.pushTransformation(FastMatrix3.translation(x, y));
				g2.color = Color.fromBytes(0, 128, 128);
				g2.font = font;
				g2.fontSize = 12;
				g2.fillRect(0, 0, width, height);

				var bufferCount = buffers.length;

				for (frameIndex in 0...bufferSize) {
					var y = height;

					for (bufferIndex in 0...bufferCount) {
						var b = buffers[bufferIndex];

						g2.color = bufferColors[bufferIndex];
						var t = height * (b[frameIndex] / (1 / 60 * 1000));
						g2.drawLine(frameIndex, y, frameIndex, y - t);
						y -= t;
					}
				}

				g2.color = Color.Black;
				g2.drawLine(frameIndex, height, frameIndex, 0);

				g2.drawLine(0, height * 0.0, width, height * 0.0);
				g2.drawString('${round(1 / 60 * 1000)}ms', 4, height * 0.0);
				g2.drawLine(0, height * 0.25, width, height * 0.25);
				g2.drawString('${round(1 / 60 * 1000 * 0.75)}ms', 4, height * 0.25);
				g2.drawLine(0, height * 0.5, width, height * 0.5);
				g2.drawString('${round(1 / 60 * 1000 * 0.5)}ms', 4, height * 0.5);
				g2.drawLine(0, height * 0.75, width, height * 0.75);
				g2.drawString('${round(1 / 60 * 1000 * 0.25)}ms', 4, height * 0.75);

			g2.popTransformation();

			g2.color = colorGuard;
			g2.font = fontGuard;
		g2.end();
	}
}
