(
~boot = {
	Server.killAll;
	s.reboot;
	s.plotTree;
	s.meter;
})

~boot.value;

// Actually trying to make a sort of supercollider piece!!
// Its been a while and need to brush up on stuff

(
SynthDef(\pulse, {
	arg freq = 440, out = 0, amp = 0.4, pan = 0,
	atk = 0.02, dec = 0.2, sus = 0.25, rel=0.5, gate=1;
	var sig;

	//Create a pulse wave
	sig = Pulse.ar(freq, 0.8, 1.8, 3) * amp;

	// Give it a bit of reverb
	sig = FreeVerb.ar(sig, 0.7, 0.5, 0.5);

	// Use a bandpass filter to shape the sound
	sig = BPF.ar(
		in: sig,  // Send the signal as input
		freq: freq * 2,  // Center frequency
		rq: 0.5  // Resonance
	);

	// Create the envelop for the sound
	sig = sig * EnvGen.kr(Env.adsr(atk, dec, sus, rel),gate, doneAction: 2);	// 10ms attack, 200ms release freed when done.

	// Put a limiter on before this starts to get too out of hand
	sig = Limiter.ar(sig) * amp;

	// Pan and output the signal
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

i = inf;   // iterator 0.0

(
p = Pbind(
	\instrument, \pulse,
	\degree, Pwhite(0, 7, i),
	\dur, 0.25,
	\dec, 0.25,
	\amp, 0.5,
	\pan, -0.7
).play;

q = Pbind(
	\instrument, \pulse,
	\degree, Pwhite(0, 7, i),
	\dur, 0.25,
	\amp, 0.5,
	\pan, 0.7
).play;
)
s.meter;

// First Library of Sub-Patterns!!!!
(
~phrases = (
	p: Pbind(
	\instrument, \pulse,
	\degree, Pwhite(0, 7, i),
	\dur, 0.25,
	\dec, 0.25,
	\amp, 0.5,
	\pan, -0.7
),
	q: Pbind (
	\instrument, \pulse,
	\degree, Pwhite(0, 7, i),
	\dur, 0.25,
	\amp, 0.5,
	\pan, 0.7

	)
);
)

r = Pwhite(1,6, inf) * 2;

p.start;
p.(\dur, 1);

q.start;
q.stop

p.stop;

// Now we make a tight sine wave to see how that works
(
SynthDef(\sine, {
	arg freq = 440, out = 0, amp = 0.5, pan = 0, pha = 0,
	atk = 0.3, dec = 0.3, sus = 0.4, rel = 0.4, gate = 1;    // synth arguments for adsr envelope!
	var sig;

	// Create the sine wave
	sig = SinOsc.ar(freq, pha, 1, 0);

	// Apply reverb (optional)
	sig = FreeVerb.ar(sig, 0.6, 0.5, 0.5);

	// Apply Envelope
	sig = sig * EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction: 2);

	// Apply amp and pan
	sig = sig * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).store;
)


// YIPPPEEEEEEEEE
(
p = Pbind(
	\instrument, \spaceTri,
	\degree, Pwhite(0, 7, inf),
	\dur, 0.25,
	\amp, 0.2,
	\pan, -0.8,
	\legato, 1,
).play;

q = Pbind(
	\instrument, \sine,
	\degree, Pwhite(0, 7, inf),
	\dur, 0.25,
	\amp, 0.2,
	\pan, 0.8,
	\legato, 1,
).play;
)


p.start;
q.start;

(
r = Pbind(
	\instrument, \spaceTri,
	\dur, \2,
).play;
)


// Learned quite a bit just from the \sine synthdef and the two Pbinds!
//     -> ctrl-enter to execute block of code
//     -> adsr envelopes REQUIRE gate parameter to close and free
//     -> New Sequencing methods in Pwhite, Pxrand, and further knowledge of Pbind
//     -> updating an ongoing synth using a variable




// Using a Pseries to generate a list with steps
a = Pseries(start: 40, step: 3, length: 15).asStream;
b = Pseries(start: 45, step: 3, length: 15).asStream;
c = Pseries(start=48, step=3, length:15).asStream;

x = Pxrand([40, 43, 45, 47, 48], 3).asStream;

(
Pbind(
    \instrument, \pulse,
	\midinote, Pseq( x.next(5), 3),  // MIDI notes for E Major scale (E4 to D#5)
    \dur, 0.5,  // Duration of each note
    \amp, 0.8,  // Amplitude of the sound
    \pan, 0,    // Center pan
    \rq, 0.02,  // Resonance Q factor
    \shelffreq, 220,  // Shelf frequency
    \rs, 0.81,  // Shelf resonance
    \shelfamp, 2  // Shelf amplitude
).play;
)

x = Pxrand([30, 25, 32, 33].midicps, 4)

(
Pbind(
	\instrument, \pulse,
	\midinote, Pseq([x.next(4)].midicps, 4),
	\dur, 0.5,
	\amp, 0.3,
).play;
)

{\sine, \freq, 550}.play;

// Since that's not working we gotta move to the basics again
//      Starting over with the introduction to patterns page


// The First Routine! Using these patterns for calculations rather than sequencing??
a = Routine {
    var    i = 0;
    loop {
        i.yield;
        i = i + 1;
    };
};

a.nextN(10);


(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
	lsf=200, ldb=0,
	freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction:2);

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
}).add
)

Synth(\bpfsaw)

(
~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, Pwhite(4.5,7.0,inf),
	\midinote, Pxrand([
		[23,35,54,63,64],
		[45,52,54,59,63],
		[28,40,47,56,59,63],
		[42,52,57,61,63],
		],inf),
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, 100,
	\cfmax, 1500,
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0,2.5,inf),
	\rel, Pwhite(6.5,10.0,inf),
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
	).play;
)


// This is lovely!
(
(1..6).choose.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees+60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200,500),
			\rq, exprand(0.01, 0.5),
			\detune, 0,
		]
	);
};
)

Synth(\spaceTri, [\dur, 2]).play;

(
b = Routine{
	var j =0;
	loop {
		[58, 65, 68, 73].midicps.do{
	arg f;
	Synth(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f * exprand(1,12),
			\rq, exprand(0.01, 0.5),
		]
	);
		};

		(note:Rest(), dur:3).play;

		j = j + 1;
	};
};
)

(
a = Routine {
    var j = 0;
    loop {
        // Define the frequencies and the duration
        var freqs = [58, 65, 68, 73].midicps;
        var dur = 0.5; // Adjust duration to control timing

        // Iterate over frequencies
        freqs.do { |f|
            Synth(\bpfsaw, [
                \freq, f,
                \amp, 0.25,
                \cf, f * exprand(1, 12),
                \rq, exprand(0.01, 0.5)
            ]);

            // Delay to avoid creating too many synths at once
            dur.wait;
        };

        // Rest period between note sequences
        (note: Rest(), dur: 3).play;

        // Increment the loop counter
      /*  j = j + 1;
		Post << "m - " << j << Char.nl;

		// Every 4th start or stop a pbind
		if ( j == 4, {
			Post << "sine began...." << Char.nl;
			p.start;
		});

		if (j == 8, {
			Post << "sine terminated..." << Char.nl;
			p.stop;
		});

		if ( j == 12, {
			Post << "Stereo Sine began...." << Char.nl;
			p.start;
			q.start;
		});

		if (j == 16, {
			Post << "Stereo Sine terminated..." << Char.nl;
			p.stop;
			q.stop;
		});*/

		//print the number loop

        // Short pause to prevent server overload
        1.wait;
    }
};
)

a.play;
a.reset;

// Space Triangle Ambient THing!
(
SynthDef(\spaceTri,{
	arg atk=0.4, del=0, rel=0.5, dec=0.2, sus=0.7,
	freq = 500, out=0, amp=0.4, pha=0.4, gate=1, cf = 400, rq=3;   // Args on Args!!
	var sig, env;

	sig = LFTri.ar(freq, pha);   // Triangle LFO in which we can control frequency and phase
	env = EnvGen.kr(Env.perc(atk, rel), gate, doneAction:2);

	sig = BPF.ar(sig, cf, rq);  // Band Pass Filter

	sig = Delay1.ar(sig);

	sig = FreeVerb.ar(sig, 0.6);  // Reverb

	sig = sig * env * amp;      // Signal Culmination

	// Outputing....

	sig = Pan2.ar(sig, out);
	Out.ar(out, sig)
}).add;
)

(
x = Synth(\spaceTri, [
    \freq, 500,   // Frequency in Hz
	\rel, 2,
]);
)

Synth(\spaceTri)


// Playing with mixes!!!
(
SynthDef(\abyss, {
	arg freq = 500, amp = 0.6, out = 0, pha = 0, atk = 0.4, rel = 2;
	var sig, env;

	sig = Mix.new(
		Array.fill(6,
			{SinOsc.ar(freq + freq.rand, pha, 0.1) },
	),
		Saw.ar(freq/2, 1),
	);

	sig = FreeVerb.ar(sig, 0.8, 0.8, 0.3);

	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, out);
	Out.ar(out, sig);
}).add;
)

Synth(\abyss)

(
b = Routine {
	i = 1;

	12.do {
		Synth(\abyss,
			[\freq, i*100,
				\atk, 0.05,
				\rel, 3.5,
				\amp, 0.3]);
		0.125.wait;
		i = i + 1;
	};
})

(
~playB = {
	b.reset;
	b.play;
})

~playB.value;

s.reboot;

(
SynthDef(\star, {
	arg freq = 500, amp=0.7, out=0,                // Baseline Arguments
	atk=0.3, rel=0.7, dec=1.2, sus=0.5, gate=1,
	pha = 0.05, del=0.6;   // Envelope Arguments
	var sig, env;                                  // Variables for signal and envelope

	// Using Mix.new to make the signal a culmination of multiple different waves
	sig = Mix.new([
		Pulse.ar(freq, 0.8, 0.5),
		FreeVerb.ar(Pulse.ar(freq/2), 0.7, 0.8, 0.5, 0.7),
		LFTri.ar(freq, pha, 0.5),
	]);

	env = EnvGen.ar(Env.perc(atk, rel), gate, doneAction:2);

	//High Pass Filter?
	sig = LPF.ar(sig, freq + 100);
	sig = HPF.ar(sig, freq - 150);

	sig = sig + AllpassL.ar(sig, 0.2, del, dec);
	sig = sig * env * amp;
	sig = Limiter.ar(sig, 0.7);

	Pan2.ar(sig, out);
	Out.ar(out, sig);
}).add;
)

Synth(\star)

p = Pbind( \instrument, \star, \dur, 1, \freq, 500).play;

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


Pbind

Pbindef

(
~myKick = Pbind(
	\instrument, \kick,
	\dur, Pseq([1, 1, 0.25, 0.25, 0.5, 1], inf),
	\freqA, Prand([100, 500, 800, 1000], inf),
	\atk, 0.01,
	\rel, 1,
	\amp, Pwhite(0.3, 0.7, inf),
	\out, 0,
).play;
)

~myKick.stop;
~myKick.play;>