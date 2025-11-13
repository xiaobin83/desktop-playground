class_name Blink;

enum Style {
	Off,
	Lit,
	Flicker,
	Candle01,
	Candle02,
	SlowStrobe,
	FluorescentFlicker,
	EyeBlink,
}

static var _light_styles = {
	Style.Off: "a",
	Style.Lit: "z",
	Style.Flicker: "nmonqnmomnmomomno",
	Style.Candle01: "mmmaaabcdefgmmmmaaaammmmaamm",
	Style.Candle02: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaa",
	Style.SlowStrobe: "aaaaaaaazzzzzzzz",
	Style.FluorescentFlicker: "mmamammmmmammamamaaamammma",
	Style.EyeBlink: "mmmmmmmmmmamammmmmmmmmmmmmmmmmammmmmmmmmmmm",
};

class BlinkInstance:
	var style: Style
	var pattern: String;
	var intensity: float = 1.0;
	var speed: float = 1.0;
	var _time: float = 0.0;

	func process(delta: float) -> float:
		_time += delta * speed;
		var index = int(_time) % pattern.length();
		var ch = ord(pattern[index]) - ord('a');
		intensity = ch / 26.0;
		return intensity;

static func create(style: Style, speed: float) -> BlinkInstance:
	var instance = BlinkInstance.new();
	instance.style = style;
	instance.pattern = _light_styles[style];
	instance.speed = speed;
	instance.process(0);
	return instance;
