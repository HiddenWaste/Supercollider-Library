// Iniitialization Block
(
s.reboot;        // Starts the audio server
s.plotTree;    // Visual of synth nodes and groups on the server
s.meter        // Level Meterd
)

(
~intialize = Routine{
	s.reboot;
	15.wait;
	s.plotTree;
	s.meter;
	a = 'Begin!';
	a.postln;
};
)

~intialize.value;


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

// SYNTHDEF BLOCK
(     // Band-Pass Filtered Sawtooth
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3,                        // Attack, Sustain, and Release for Envelopw
	c1=1, c2=(-1),
	detune=0.2, cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
	lsf=200, ldb=0,
	freq=500, cf=1500, rq=0.2,
	amp=1, out=0, pan=0;                            // Baseline Amplitude, Out and Pan arguments
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction:2); // Envelop that crescendos and decrescendos, env arguments passed, and a curve based on c1 and c2

	sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio);

	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);

	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);

	sig = Balance2.ar(sig[0], sig[1], pan);

	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;

SynthDef(\woosh, {
	arg freq = 500, amp = 0.6, out = 0, pha = 0,
	c1=1, c2=(-1),
	hpHz=2000,
	atk = 0.1, rel = 2, fade=1;
	var sig, env;

	sig = Mix.new(
		[Array.fill(6,
			{SinOsc.ar(freq + freq.rand, pha, 0.1) },
	)
]);

	sig = FreeVerb.ar(sig, 0.8, 0.8, 0.3);

	sig = HPF.ar(sig, hpHz);

	env = EnvGen.kr(Env([0.2, 0.8, 0.2], [1,1], [c1, 0, c2]), doneAction:2);

	sig = sig * env;

	sig = Pan2.ar(sig, Line.kr(-0.7,0.7, rel), amp);
	//sig = Balance2.ar(sig[0], sig[1], Line.kr(-0.7, 1.0, rel), amp);
	Out.ar(out, sig);
}).add;
)

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

// SOUND CHECK???

Synth(\woosh)
Synth(\woosh, [\c2, 0.2, \rel, 6, \dur, 4, \amp,1 , \freq, Prand([4000, 4500, 5000], 1)])
Synth(\bpfsaw);

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

// ROUTINES FOR COMPOSITION
(

// Tha BIIIG woooosh
w = Routine {
	i = 1;

	12.do { // 12.do will do 12 times in a row
		Synth(\woosh,
			[\freq, i*100,  // Able to use an iterator within the loop!
				\atk, 0.05,
				\rel, 3.5,
				\amp, 0.3]);

		0.125.wait;         // Wait just long enough so they don't overlap
		i = i + 1;          // Increment Iterator
	};
};
)

(
~rsaw = Pbind(
	\instrument, \bpfsaw,
	\freq, Pwrand([4, 8, 12, 20], [0.4, 0.4, 0.1, 0.1], inf),
	\atk, 0.1,
	\dur, 2,
	\amp, Pexprand(0.8, 1.0, inf),
	\out, Pexprand(-0.7, 0.7, inf),
	).play;

~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, Pwhite(4.0,8.0,inf),
	\midinote, Pxrand([
		/*Scale.minor.degrees+60,
		Scale.minor.degrees+57,
		Scale.minor.degrees+53,
		Scale.minor.degrees+50,*/
		[23,35,54,63,64],
		[45,52,54,59,61,64],
		[28,40,47,56,59,63],
		[42,52,57,61,63],
		],inf),
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, Pwrand([100, 300, 500], [0.6, 0.3, 0.1], inf),
	\cfmax, Pwrand([1500, 2000, 1000], [0.7, 0.2, 0.1], inf),
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0,2.5,inf),
	\rel, Pwhite(6.5,10.0,inf),
	\ldb, 6,
	\amp, Pexprand(0.5, 0.8, inf),
	\out, 0,
	).play;
)

