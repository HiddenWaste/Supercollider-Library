(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

(
SynthDef(\start, {
	|out=0, pan=0, amp=0.2, freq=3000, pha=0, atk=0.2, rel=0.5|
	var sig, env;

	sig = SinOsc.ar(XLine.kr(500, freq, rel), pha);

	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef(\beep_0, {
	|freq=440, out=0, pan=0, amp=0.2, atk=0.1, rel=1, dec=0.3, sus=0.15,
	gate=1|
	var sig, env;

	sig = Mix.ar([
		Pulse.ar(freq, 0.8, 0.7),
		Blip.ar(freq * 0.85, 150, 0.3),
		SinOsc.ar(freq, 0, 0.3);
	]);

	sig = Compander.ar(sig, 0, 0.8, 1, 1, 0.005, 0.15);

	env = EnvGen.ar(Env.perc(atk, rel), gate, doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\start)

(
Synth(\beep_0, [
	\rel, 0.5,
	\freq, Pxrand(Scale.major.degrees + 58, inf),
	\atk, Pwhite(0.03, 0.1, inf),
	\pan, Pwhite(-0.5, 0.5)
]
)
)

(
Pbindef(\a,
	\instrument, \beep_0,
	\rel, 0.5,
	\freq, Pxrand(Scale.major.degrees + 58, inf),
	\atk, Pwhite(0.05, 0.1, inf),
	\pan, Pwhite(-0.5, 0.5),
	\amp, Pbrown(0.4, 0.7, 0.125, inf)
).play;
)