(

s.waitForBoot (
	s.meter;
	s.plotTree;
)

)

(
SynthDef(\multi_tri, {
	| out=0, pan=0, amp=0.5, freq=440, pha=0, lpf=500, atk=0.05, rel=1|
	var sig, env;

	sig = Mix.ar([
		LFSaw.ar(freq/2, pha * 2, 0.1),
		SinOsc.ar(freq, pha * 1.3, 0.5),
		LFTri.ar(freq,pha),
	]);

	sig = LPF.ar(sig, lpf);

	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);

	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
		|mix=0.33, room=0.75, damp=0.8|
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = FreeVerb.ar(in, mix, room, damp);

		Out.ar(\out.ir(0), sig);
}).add;

SynthDef(\waves_0, {
	|out=0, pan=0, amp=0.5, hpf_c=1000, lpf_c=3000, rel=1,
	pan_amount=0.5, pan_sign=1|
	var sig, env;

	sig = WhiteNoise.ar(0.02);

	sig = HPF.ar(sig, hpf_c);
	sig = LPF.ar(sig, lpf_c);

	env = EnvGen.ar(Env([0, 1, 0], [rel/2, rel/2]), doneAction:2);

	sig = Pan2.ar(sig, Line.kr(pan+(pan_amount*pan_sign), pan, rel));
	Out.ar(out, sig);
}).add;

)

(
~b_fx = Bus.audio(s, 2);

// Create a function that will create the reverb synth
~reverb_init = {
    Synth(\reverb, [
		\in, ~b_fx,
		\out, 0,
		\mix, 0.5
	]);
};

// Add the function to ServerTree
ServerTree.add(~reverb_init);
)


(
Synth(\multi_tri,
	[
		\pha, 0.4,
		\amp, 0.3,
		\lpf, 200,
		\dur, 3,
		\rel, 3,
		\out: ~b_fx
	]
)
)

(
Synth(\waves_0,
	[
		\rel, 0.25,
		\out: ~b_fx,
		\lpf_c, 3500,
		\pan_amount, 0.7
])
)

Scale.minor.degrees + 60;

(
Pbindef(\a,
	\instrument, \multi_tri,
	\dur, 0.5,
	\freq, Pxrand(Scale.minor.degrees + 60, inf).midicps,
	\out, ~b_fx,
	\pan, Pwhite(-0.3, 0.3, inf)
).play;

Pbindef(\b,
	\instrument, \multi_tri,
	\dur, 0.5,
	\freq, Pxrand(Scale.minor.degrees + 48, inf).midicps,
	\out, ~b_fx,
	\pan, Pwhite(-0.5, 0.5, inf),
	\lpf, 200,
	\dur, 3,
	\rel, 3,
).play;

Pbindef(\c,
	\instrument, \waves_0,
	\rel, Pxrand([0.25, 0.5, 1.5], inf),
	\lpf_c, Prand([3500, 4000, 5000, 1500], inf),
	\pan_amount, Pwhite(0.4, 0.7, inf),
	\pan_sign, Pxrand([1, -1], inf),
	\out, ~b_fx,
).play;
)

s.record(duration:30)

s.reboot;