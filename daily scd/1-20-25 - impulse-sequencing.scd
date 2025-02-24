Server.killAll;

(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

(
SynthDef(\impulse, {
	|freq=440, amp=0.8, pha=0.3, atk=0.2, rel=1,
	out=0, pan=0|
	var sig, env;

	sig = Impulse.ar(freq, pha);

	sig = LPF.ar(sig, freq*2);

	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
		|mix=0.45, room=0.75, damp=0.8|
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = FreeVerb.ar(in, mix, room, damp);

		Out.ar(\out.ir(0), sig)
	}).add;

SynthDef(\dreamweave, {
	|out=0, pan=0, amp=0.3, mix=0.8, room=0.9, damp=0.5,
	freq=440, atk=0.5, rel=3, pha=0.7|
	var sig, env;

	sig = Mix.new([
		SinOsc.ar(freq, pha),
		LFTri.ar(freq*2, pha, 0.5),
		SinOsc.ar(freq*0.75)]);

	sig = Limiter.ar(sig, amp);
	sig = FreeVerb.ar(sig, mix, room, damp);
	sig = LPF.ar(sig, freq*4);

	env = EnvGen.ar(Env([0, 1, 0], [atk, rel]), doneAction:2);

	sig = sig * env;
	sig = Pan2.ar(sig, Line.kr((-1)*pan, pan, rel));
	Out.ar(out, sig);
}).add;

SynthDef(\saw, {
	|freq=220, out=0, pan=0, amp=0.6, atk=0.6, rel=1.5,
	numharm=100, mix=0.8, room=0.9, damp=0.5, detune=0.75, sus=0.3, dec=0.3|
	var sig, env;

	sig = Mix.new([
		Saw.ar(freq),
		Blip.ar(freq*0.5, numharm),
	]);

	sig = FreeVerb.ar(sig, mix, room, damp);
	// sig = Limiter.ar(sig, amp);
	sig = LPF.ar(sig, freq*detune);

	sig = Normalizer.ar(sig, amp);

	sig = FreeVerb.ar(sig, mix*2, room, damp);

	env = EnvGen.ar(Env([0, 1, 1, 0.1, 0], [atk, sus, rel, dec]), doneAction:2);

	sig = Pan2.ar(sig*env*amp, pan);
	Out.ar(out, sig)
}).add;


)

Synth(\dreamweave);
Synth(\saw, [\dur, 4])


(
Routine(
		4.do(
			Synth(\saw, [
				\dur, 4,
				\freq, (Scale.minor.degrees+40).midicps.choose,
			]);

			4.wait;
		);
	).play;
)

(
c = Pbindef(\c,
	\instrument, \saw,
	\amp, Pwhite(0.4, 0.6, inf),
	\pan, Pwhite(-0.3, 0.3, inf),
	\freq, Pxrand((Scale.minor.degrees+60).midicps, inf),
	\rel, 4,
	\dur, 4,
	\atk, 0.7,
	\pha, 0.8,
);
)

(
c = Pbindef(\c,
    \instrument, \dreamweave,/*
    \amp, Pwhite(0.4, 0.6, inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \freq, Pxrand((Scale.minor.degrees+60).midicps, inf),
    \atk, 0.7,
    \sus, 0.3,
    \rel, 1.5,
    \dec, 0.3,
    \dur, 4*/
).play;
)
c.set(\instrument, \saw)
c.set(\freq, 440)


c.play;
(Scale.minor.degrees+60).midicps

~b_fx = Bus.audio(s, 2);
Synth(\reverb, [\in: ~b_fx, \out:0])

(
a = Pbindef(\imp,
	\instrument, \impulse,
	\amp, Pwhite(0.55, 0.81, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
	\freq, Pxrand((Scale.minor.degrees+60).midicps, inf)
);

b = Pbindef(\saw,
	\instrument, \dreamweave,
	\amp, Pwhite(0.4, 0.6, inf),
	\pan, Pwhite(-0.3, 0.3, inf),
	\freq, Pxrand((Scale.minor.degrees+60).midicps, inf),
	\rel, 4,
	// \dur, 4,
	\atk, 0.7,
	\pha, 0.8,
);

d = Pbindef(\e,
	\instrument, \saw,
	\freq, 440,
);
)

d.play;

b.play;

(
var j;
j = 0;

Pspawner({ | sp |

	Synth(\reverb, [\in: ~b_fx, \out:0]);
	a.set(\out, ~b_fx);

	//start and stop pbindef
	a.play;

	12.do{
		j.postln;

		if(j % 4 == 0){
			a.set(\dur, [1, 0.5, 0.25].choose;);
		};

		1.wait;
		j = j + 1;
	};

	a.set(\dur, 0.25);

	b.play;

	12.do{
		if(j % 4 == 0){
			b.set(\room, [0.3, 0.6, 0.9].choose);
		};

		if(j % 6 == 0){
			a.play;
		};

		1.wait;
		 j = j + 1;
	};

	a.stop;
	i.stop;
}).play;

)