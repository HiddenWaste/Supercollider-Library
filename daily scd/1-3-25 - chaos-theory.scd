(
s.boot;
s.meter;
s.plotTree;
)

FBSineL.ar(freq: 22050, im: 1, fb: 0.1, a: 1.1, c: 0.5, xi: 0.1, yi: 0.1, mul: 1, add: 0);


{ FBSineL.ar(LFNoise2.kr(1, 1e4, 1e4), LFNoise2.kr(1,16,17), 1, 1.005, 0.7)!2 * 0.05}.play(s);

SynthDef(\feedback0, {
	arg amp = 0.05;
	var sig, env;

	sig = FBSineL.ar(LFNoise2.kr(1, 1e4, 1e4),
		LFNoise2.kr(1,16,17),
		1, 1.005, 0.7)!2;

	sig = GVerb.ar(sig, 20, 2,
		0.5, 0.5, 20);

	sig = sig * amp;

	Out.ar(0, sig);
}).add;

Synth(\feedback0, [\amp, 0.02])