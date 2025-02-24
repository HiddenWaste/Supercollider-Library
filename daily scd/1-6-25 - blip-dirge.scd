Server.killAll;


(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

(
	SynthDef(\blip, {
		|freq=200, out=0, pan=0, amp=0.6, numharm=100, atk=0.1, rel=0.5|
		var sig, env;

		sig = Blip.ar(freq, numharm);

		sig = Pan2.ar(sig, pan);

		env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);

		sig = sig * env * amp;

		Out.ar(out, sig);
	}).add;

	SynthDef(\blip_phase, {
		| freq=440, out=0, pan=0, amp=0.6, mod_freq=6 |
		var sig, env;

		sig = Blip.ar(
			LFNoise2.kr(mod_freq, 200, 20),
			Line.kr(1, 100, 20),
			0.4);

		sig = Pan2.ar(sig, pan);

		Out.ar(out, sig);
	}).add;





	SynthDef(\blip_2, {
		|out=0, pan=0, freq=440, numharm=50, amp=08, rel=0.8, atk=0.5,
	lpf=1000|
		var sig, env;

		/*sig = Mix.new([
		Blip.ar(freq, numharm),
		SinOsc.ar(freq, 0.2),
	]);*/

	sig = Saw.ar(freq);

	// sig = Ringz.ar(sig, freq*2, 2);
	sig = MoogFF.ar(sig, freq * 0.25, amp, 0);
	sig = FreeVerb.ar(sig, 0.5, 0.3, 0.5);

	sig = LPF.ar(sig, lpf);
	sig = Normalizer.ar(sig, amp);
	sig = Limiter.ar(sig, amp);

	sig = BPF.ar(sig, 2000, 1.5);

		env = EnvGen.ar(Env([0,1,0], [atk, rel]), doneAction:2);

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


)

(
Synth(\blip_2, [
	\dur, \3,
	\atk, Pxrand([0.5, 1, 1.5], inf),
	\rel, Pxrand([2, 3, 0.5], inf),
	\freq, Pxrand((Scale.minor.degrees+52).midicps,1),
	// \amp, 0.8,
]
);
)
~b_fx = Bus.audio(s, 2);

(

	~reverb_init = ( Synth(\reverb, [\in: ~b_fx, \out:0]));
	ServerTree.add(~reverb_init);

Pbindef(\a,
	\instrument, \blip,
	\amp, 0.15,
	\out, ~b_fx,
	\rel, 0.25,
	\dur, 0.25,
	\numharm, Prand([50, 100, 150, 200], inf),
	\freq, Pxrand([200, 240, 320, 300], inf),
	\pan, Pwhite(-1.0, 1.0, inf)
).play;

Pbindef(\b,
	\instrument, \blip,
	\amp, 0.1,
	\out, ~b_fx,
	\freq, Pxrand([100, 120, 160, 150], inf),
	\dur, 2,
	\rel, 1.5,
	\pan, Pwhite(-0.5, 0.5, inf)
).play;

Pbindef(\c,
	\instrument, \blip,
	\amp, 0.1,
	\numharm, 500,
	\freq, Pxrand([50, 60, 80, 75], inf),
	\dur, 4,
	\sus, 2,
	\rel, 1.5,
	\pan, Pwhite(-0.3, 0.3, inf)
).play;


)

// Recorder instantiation learning!
r  = Recorder.new(s);

// record into a flac file
r.recHeaderFormat = "flac";

// default 'float' is incompatible with flac. set to 24bit:
r.recSampleFormat = "int24";

// set very obvious prefix for files
r.filePrefix = "blip_dirge_1-16_";

// start recording:
r.record(duration:30);


Synth(\blip_phase);
s.record(duration:20
Server.killAll;