(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

(
SynthDef(\fat_sine, {
	|freq=440, out=0, pan=0, detune=0.8, r_mix=0.4,
	room=0.65, damp=0.5, pha=0.1, lpf=2500, atk=1, rel=2,
	amp=0.6|
	var sig, env;

	sig = Mix.new([
		SinOsc.ar(freq, pha, 0.6),
		SinOsc.ar(freq*detune, pha, 0.4),
		SinOsc.ar(freq*(1+(1-detune)), pha, 0.4)
	]);

	sig = FreeVerb.ar(sig, r_mix, room, damp);

	sig = LPF.ar(sig, lpf);

	env = EnvGen.ar(Env([0,1, 0.2, 0], [atk, rel, rel*0.2]), doneAction:2);

	sig = sig * env * amp;
	// sig = Pan2.ar(sig, Line.kr(pan, (-1)*pan, atk+rel+(rel*0.2)));
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\fat_sine)

(
Pbindef(\a,
	\instrument, \fat_sine,
	\dur, 3,
).play;
)