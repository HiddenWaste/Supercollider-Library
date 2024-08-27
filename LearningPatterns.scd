s.boot;
Server.killAll;

//Synth Def to use in pbind event handler
(
SynthDef.new(\sine, {
	arg freq=440, atk=0.05, rel=0.3, amp=2, pan=0;
	var sig, env;                                            //variables to hold signal and envelope to affect signal
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
SynthDef.new(\saw, {
	arg freq=220, atk=0.05, rel=0.3, amp=2, pan=1;
	var sig, env;
	sig = Saw.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(1, sig);
}).add;
)

(
SynthDef.new(\triangle, {
	arg freq=220, atk=0.05, rel=0.3, amp=2, pan=1;
	var sig, env;
	sig = LFTri.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(1, sig);
}).add;
)


(
SynthDef.new(\sineS, {
	arg freq=440, atk=0.05, rel=0.3, amp=2, pan=0;
	var sig, env;                                            //variables to hold signal and envelope to affect signal
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

//Pbind arguments
(
p = Pbind(
	\type, \note,
	\instrument, \sine,
	\dur, Pseq([0.25, 0.25, 0.25, 0.25, 0.55], inf).trace,
	\freq, Pexprand(400, 600, inf).round(10).trace,
).play;


q = Pbind(
	\type, \note,
	\instrument, \saw,
	\dur, Pseq([0.5, 0.5, 0.25, 0.3], inf).trace,
	\freq, Pexprand(200, 400, inf).round(10).trace,
).play;

r = Pbind(
	\type, \note,
	\instrument, \triangle,
	\dur, 2,
	\rel, Pseq([1, 0.5, 2], 3).trace,
	\freq, Pexprand(330, 660, inf).round(30).trace,
).play;
)

//More Ambient shit
(
p = Pbind(
	\type, \note,
	\instrument, \sine,
	\dur, Pseq([0.25, 0.25, 0.25, 0.25, 0.55], inf).trace,
	\freq, Pexprand(1000, 1200, inf).round(10).trace,
).play;



)

s.plotTree

p.stop;

s.boot;
Server.killAll;

(
r = Routine({
	a = Scale.major;
	a = a.degrees;
	b = Scale.minor;
	b = b.degrees;
	c = Scale.ionian;
	c = c.degrees;
});
)
