// testing new argument features?

(
~etude_melody = [
	[1, 2, 1, 3, 1, 4, 1, 5],
	[2, 1, 2, 3, 2, 4, 2, 5],
	[3, 1, 3, 2, 3, 4, 3, 5],
	[4, 1, 4, 2, 4, 3, 4, 5],
	[5, 1, 5, 2, 5, 3, 5, 4],
];
)


Pen = 11111
Airplane = 1111
Plum = 111
comet = 111
Crayon = 111



(
b = Pbindef(\b,
	\instrument, \blip_testing,
	\filter, 1,
	\dur, 0.5,
	\freq, Pseq((~etude_melody+60).midicps, inf)
);
)

b.play;


(
s.waitForBoot(
	s.meter;
	s.plotTree
)
)

Scale.phrygian.degrees+64

s.reboot;

{LFNoise2.ar(3, 0.6).scope}.play

(
SynthDef(\evo, {
	|pan=0, out=0, amp=0.6, freq=440, wave=0, pha=0.0,
	atk=0.3, rel = 0.3, filter=0, r_mix=0.3, room=0.4,
	damp=0.5, max_del=0.2, del=0.2, dec=0.2,
	mf=3, mod_norm=0.6|

	var sig, env, mod_freq;

	// Use Select to choose between different waveforms
	sig = Select.ar(wave, [
		SinOsc.ar(freq, pha),  // wave == 0
		LFTri.ar(freq, pha),    // wave == 1....
		Saw.ar(freq, 0.7),
		Blip.ar(freq, 100)
	]);


	// Also choose different filters!
	sig = Select.ar(filter, [
		HPF.ar(sig, freq*2),
		LPF.ar(sig, freq * 0.5),
		BPF.ar(BPF.ar(sig, freq*0.5, 1), freq*2, 1)
	]);

	// Oddball FX Testing
	mod_freq = LFNoise2.kr(mf, mod_norm);

	sig = AllpassN.ar(sig, max_del, del, dec);
	sig = FreeVerb.ar(sig, r_mix, Line.kr(0, room, atk+rel), damp);


	// Usual Closing Section
	sig = Normalizer.ar(sig, 0.8);
	env = EnvGen.ar(Env([0,1,0], [atk, rel]), doneAction:2);
	sig = sig * amp * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\evo, [\wave, 0, \filter, 2])


(
SynthDef(\blip_testing, {
	|out=0, pan=0, freq=440, amp=0.6,
	hpf=2000, lpf=2000, numharm=200,
	rmix=0.3, room=0.5, damp=0.6, atk=0.25,
	rel=0.5, filter=0|
	var sig, env;

	sig = Blip.ar(freq, numharm);

	sig = Select.ar(filter, [
		LPF.ar(sig, lpf),
		HPF.ar(sig, hpf)
	]);

	sig = FreeVerb.ar(sig, rmix, room, damp);


	env = EnvGen.ar(Env([0,1,0], [atk, rel]), doneAction:2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

(


SynthDef(\mod_space, {
	|mf=10, m_norm=0.6, rmix=0.3, room=0.5, damp=0.7,
	out=0, pan=0, amp=0.6, freq=440|
	var sig, env, modula;

	modula = LFNoise2.kr(mf, m_norm);

	sig = SinOsc.ar(freq*  modula);
	sig = FreeVerb.ar(sig, rmix, room*modula, damp);

	sig = sig * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Synth(\mod_space);

(
Synth(\evo, [
	\dur, 3,
	\atk, 1, \rel, 2,
	\wave, Prand([0, 1, 2, 3], inf),
	\filter, Prand([0,1,2], inf),
	// \gate, 0
])
)

(
Pbindef(\a,
	\instrument, \evo,
	\atk, 1,
	\rel, 0.5,
	\freq, Pxrand((Scale.major.degrees+60).midicps, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\wave, Prand([0, 1, 2, 3], inf),
	\filter, Prand([0,1,2], inf),
	\amp, 0.6
).play;
)