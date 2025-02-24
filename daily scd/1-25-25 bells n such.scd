Server.killAll;

(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)


(
SynthDef(\bells, {
	|out=0, pan=0, den_b=3, den_e=3, atk=0.01, rel=5, amp=0.7|
	var sig, env;

	sig = Ringz.ar(Dust.ar(XLine.kr(den_b, den_e, atk+rel, 0.3), 2000, 2));
	sig = FreeVerb.ar(sig, 0.5, 0.5, 0.5);
	sig = Limiter.ar(sig, amp);

	env = EnvGen.ar(Env([0, 1, 0], [atk, rel]), doneAction:2);

	sig = sig * env * amp;

	// sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;


SynthDef(\band_saw, {
	|out=0, pan=0, freq=440, atk=1, rel=2, bpf=500, rq=1.2, amp=0.6,
	detune=0.75|
	var sig, env;

	sig = Mix.new([
		Saw.ar(freq, 0.4),
		Saw.ar(freq * detune, 0.4),
		Saw.ar((freq * detune) * detune,  0.4),
		Saw.ar(freq * (1 + (1- detune)), 0.3),
	]);

	sig = FreeVerb.ar(sig, 0.3, 0.3, 0.3);

	sig = BPF.ar(sig, bpf, rq);

	env = EnvGen.ar(Env([0,1,0], [atk,rel]), doneAction:2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\bells)
Synth(\band_saw);


(
Pbindef(\a,
	\out, Pxrand([0,1], inf),
	\dur, 3,
).play;
)
(
b = Pbindef(\b,
	\instrument, \band_saw,
	\freq, Pxrand((Scale.minor.degrees)+64, inf),
);
)

b.play;


(
Pspawner({ | sp |
	Synth(\bells);
	10.wait;
	Synth(\bells);
}).play;
)