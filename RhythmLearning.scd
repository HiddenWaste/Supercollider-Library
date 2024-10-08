(
~reboot = {
	s.reboot;
	s.meter;
	s.plotTree;
})

~reboot.value;

(
SynthDef.new(\kick, {
	arg freqA=1000, freqB=50, freqC=1, freqDur1=0.01, freqDur2=0.2, freqC1=1, freqC2=(-1),
	atk=0.01, rel=1, c1=1, c2=(-12), amp=0.8, pan=0, out=0;

	var sig, env, freqSweep;

	freqSweep = Env([freqA, freqB, freqC], [freqDur1, freqDur2], [freqC1, freqC2]).ar;

	env = Env([0,1,0],[atk,rel],[c1,c2]).kr(2);

	sig = SinOsc.ar(freqSweep, pi/2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig)
}).add;
)


~myKick = Synth.new(\kick, [\freqA, 550, \atk, 0.01, \rel, 1, \amp, 1]);

// Establish the Tempo

(
t = TempoClock(88/60).permanent_(true);
t.schedAbs(t.nextBar,{t.beats.postln;1}); //resched every 1 beat
)

// Pbindef
(
Pbindef(\myKick,
	\instrument, \kick,
	\dur, 1,
	\amp, 1,
	\freqA, 500,
	\atk, 0.01,
	\rel, 0.2,
	\out, 0,
).play(t);
)

