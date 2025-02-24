Server.killAll;
Server.freeAll;
s.reboot;

(
s.waitForBoot(
	s.meter;
	s.plotTree;
);
)

(
SynthDef(\new_wave, {
	|out=0, pan=0, freq=440, amp=0.6, rmix=0.88, room=0.8, damp=0.5,
	atk=0.4, rel=1, numharm=150, lpf=400, hpf=2000, pha=0.3|
	var sig, env;

	sig = Mix.new([
		Blip.ar(freq, numharm, 0.3),
		Saw.ar(freq, 0.5),
		Saw.ar(freq*4, 0.3),
		SinOsc.ar(freq*2, pha),
		LFTri.ar(freq, pha, 0.3),
		SinOsc.ar(freq*0.25, pha)
	]);

	sig = FreeVerb.ar(sig, rmix, room, damp);
	sig = Ringz.ar(sig, freq, 0.5);
	sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);
	sig = FreeVerb.ar(sig, rmix, room, damp);
	sig = Normalizer.ar(sig,amp);

	env = EnvGen.ar(Env([0,1,0.3,0],[atk,rel*0.33,rel*0.66]), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

(
SynthDef(\sea_waves, {
	|out=0, pan=0.5, amp=0.4, lpf=2000, atk=0.5, rel=3|
	var sig, env;

	sig = BrownNoise.ar(amp);
	sig = FreeVerb.ar(sig, 0.5, 0.6, 0.3);
	sig = LPF.ar(sig, lpf);

	env = EnvGen.ar(Env([0,0.8,1,0.25, 0], [atk,atk, rel*0.33, rel*0.66]), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, Line.kr((-1)*pan, pan, rel));
	Out.ar(out, sig);
}).add;
)

(
SynthDef(\snake, {
	|out=0, pan=0, den=25, amp=0.6, hpf=1500,
	atk=0.5, rel=3|
	var sig, env;

	sig = Dust.ar(Line.kr(den, den*0.25, atk+rel));

	sig = FreeVerb.ar(sig, 0.6, Line.kr(1, 0, atk+rel), 0.4);
	sig = HPF.ar(sig, hpf);
	sig = Ringz.ar(sig, hpf*0.25, 1);
	sig = Normalizer.ar(sig, amp);

	env = EnvGen.ar(Env([0,1,0], [atk,rel]), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

(
SynthDef(\ring, {
	|out=0, pan=0, freq=440, amp=0.6, pha=0.3, atk=0.5, rel=1.5,
	lpf=400|
	var sig, env;

	sig = Mix.new([
		SinOsc.ar(freq, pha, 0.6),
		SinOsc.ar(freq*2, pha, 0.5),
		LFTri.ar(freq * 0.5, 0.6),
	]);

	sig = Ringz.ar(sig, freq, 1.3);
	sig = LPF.ar(sig, lpf);
	sig = FreeVerb.ar(sig, 0.3, 0.3, 0.3);

	env = EnvGen.ar(Env([0,1,0], [atk, rel]), doneAction:2);

	sig = Limiter.ar(sig, amp);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)


(
SynthDef(\fast_wind, {
	|atk=0.8, rel=0.8, rmix=0.6, room=0.8, damp=0,
	out=0, pan=1, amp=0.8, lpf=4000, hpf=150|

	var sig, env;

	sig = FreeVerb.ar(BrownNoise.ar(amp), rmix, room, damp);
	sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);

	env = EnvGen.ar(Env([0,1,0.2, 0], [atk, rel*0.75, rel*0.25]), doneAction:2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, XLine.kr((-1)*pan, pan, atk*rel));
	Out.ar(out, sig);
}).add;
)

Synth(\fast_wind);
Synth(\new_wave);
Synth(\sea_waves);
Synth(\snake);
Synth(\ring);

~sub_snake.value;

(
~sub_snake = {
	Synth(\snake, [
		\amp, 0.3,
		\hpf, 2000,
		\pan, Pwhite(-0.7, 0.7, 0.1, 1),
	])
}
)

(
w = Pbindef(\waves,
	\instrument, \sea_waves,
	\rel, Pxrand([3, 6, 8], inf),
	\dur, Pwrand([3, 6], [0.6, 0.4], inf),
	\amp, Pwhite(0.4, 0.6, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\lpf, Pxrand([2000, 3000, 4000], inf)
);
w.play;
)

(
x = Pbindef(\slow_waves,
	\instrument, \sea_waves,
	\rel, Pxrand([6, 8, 10], inf),
	\dur, Pwrand([6, 8], [0.6, 0.4], inf),
	\amp, Pwhite(0.4, 0.5, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\lpf, Pxrand([2000, 3000, 4000, 1500], inf)
);
x.play;
)

s.record(duration:30)
s.reboot;
(
o = Pbindef(\organish,
	\instrument, \new_wave,
	\freq, Prand((Scale.major.degrees+51).midicps,inf),
	\amp, Pwhite(0.2, 0.4, inf),
	\numharm, 50,
	\rmix, 0.5,
	\dur, Pwrand([0.25, 0.5, 1, 1.5], [0.5, 0.3, 0.2, 0.1], inf),
	\pan, Pwhite(-1, 1, inf),
);
o.play;
)

o.set(\dur, 0.25)
o.set(\amp, 1);

{ Resonz.ar(WhiteNoise.ar(0.5), 2000, XLine.kr(0.001, 1, 8)) }.scope(1);


(
Pspawner({ | sp |
	w.play;

	36.wait;

	12.loop(
		~sub_snake.value;
		4.wait;
	);

	w.stop;
}).play;

)
