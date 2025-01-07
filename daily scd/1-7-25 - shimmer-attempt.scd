(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

s.reboot;
Server.killAll;

// Shimmer attempt with Dust?
(
SynthDef(\dust_s, {
	| freq=880, amp=0.7, out=0, pan=0, hpf_freq=2000, room=0.9,
	atk=0.05, dec=0.4, sus=0.3, rel=1.4, gate=1|
	var sig, env;

	sig = CombN.ar(
		Decay.ar(
			Dust.ar(1, 1), 0.2, WhiteNoise.ar),
		0.08, 0.08, 3);
	sig.poll(label: "1-dust");

	// Reverb To Heaven
	sig = FreeVerb.ar(sig, 0.6, room, 0.8);

	sig.poll(label: "2-reverb");

	//Make only higher frequencies
	sig = HPF.ar(sig, hpf_freq);
	sig.poll(label: "3-hpf");

	// second level of decay?
	sig = CombN.ar(Decay.ar(sig, 0.2), 0.08, 0.08, 1);
	sig.poll(label: "4-comb * dec 2");

	env = EnvGen.ar(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);

	sig = sig * amp;
	sig.poll(label: "5-final");

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

(
Pbindef(\a,
	\instrument, \dust_s,
	\dur, 1,
).play;
)

(
SynthDef(\sine_s, {
	|pan=0, amp=0.2|
	var sig;
	sig = SinOsc.ar(Dust.kr(0.5, 500, 500), 0);
	sig = Pan2.ar(sig, pan);
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)

Synth(\sine_s);
