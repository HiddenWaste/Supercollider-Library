

//////////////////////////////////////////
// This is the file in which I'm going to be testing the
// 'natural soundscapes' idea I've been having in regards to
// SuperCollider. It may be the least efficient way for
// an accurate soundscape, but will be wholly interesting
//  to try and accomplish at least some parts.

// ..... There may be a lot more wind than I imagine....

// Current sounds I think I might be able to manage:
//  -> Wind (already have a sembleance of one)
// -> Birds
    // Various chirps and high pitch flutters
     // Maybe something similar to wind sound for wings?


// Ones I am completely unsure on:
    // -> water
    // -> Other wildlife
         /// - Crickets, Frogs, Bugs

//////////////////////////////////////////

// Startup!
(
s.boot;
s.meter;
s.plotTree;
)

s.reboot;


// Synthdefs! This whole idea could be easily constructed
//    using samples and buffers, but I think generating the
//    sound within SuperCollider will be much more interesting

// Let's start with the wind!
(
SynthDef(\woosh, { | freq = 500, amp = 0.6, out = 0, pha = 0, c1=1, c2=(-1), hpHz=2000, atk = 0.1, rel = 2, fade=1|
	var sig, env;

	sig = Mix.new(
		[Array.fill(6,
			{SinOsc.ar(freq + freq.rand, pha, 0.1) },
	)
]);

	sig = FreeVerb.ar(sig, 0.8, 0.8, 0.3)!2;

	sig = HPF.ar(sig, hpHz);

	env = EnvGen.kr(Env([0, 0.8, 0.2], [1,1], [c1, 0, c2]), doneAction:2);

	sig = sig * env;

	sig = Balance2.ar(sig[0], sig[1], Line.kr(-0.7, 1.0, rel), amp);
	Out.ar(out, sig);
}).add;
)

// Maybe try some realistic wind?

(
w = Routine {
	var wind_level = Pxrand([12,18,15,8],20).asStream.next;
	var i = 1;



	wind_level.do {
		Synth(\woosh,
			[\freq, i*100,
				\atk, 0.05,
				\rel, 3.7,
				\amp, 0.3]);
		0.125.wait;
		i = i + 1;
	};
}.play;

~gust = {
	w.reset;
	w.play;
}
)

~gust.value;

s.boot;
s.plotTree;

// Playing with the sounds....
Synth(\woosh, [\c2, 0.2, \rel, 6, \amp, 0.4, \freq, 4500])


// Attempting the Bird Sounds

s.meter;


// First try will be getting a single decent sounding chirp
(
SynthDef(\chirp, { | amp = 0.3, out=0, pan=0, atk=0.05, rel=0.08, freq=2500, dec=0.3, sus=0.1, gate=1|
	var sig, env;

	sig = Mix.new([
		Pulse.ar(freq, 0.3, 0.5),
		LFTri.ar(freq, 0.2, 0.4),
	]);

	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);

	// Verry Slight Reverb for more balanced feel?
	sig = FreeVerb.ar(sig, 0.5, 0.5);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, Dust.kr(XLine.kr(200, 50), 1));

	Out.ar(out, sig);
}).add;
)


(
                                        // sd is the starting density of Dust.ar, and ed is the ending
SynthDef(\waves, { | out=0, pan=0, amp=0.8, dur=3, sd=300, ed=25, lpf_start=4000, lpf_end=6200 |  // lpf_freq is for the low pass filter
	var sig, env, den, lpf_curve, lpf_t, lpf_dif; // create density as a variable

	den = XLine.kr(sd, ed, dur); // Dust Density, decreas

	// Trying to slowly raise the
	lpf_t = (dur/4).asInteger; // Going to modulate in 1/4 increments? Last with be most drastic
	lpf_dif = lpf_end - lpf_start; // Used in modulation calculation
	lpf_curve = EnvGen.ar(
	     Env([lpf_start,
			lpf_start+(lpf_dif/6).asInteger,
			lpf_start+(lpf_dif/4).asInteger,
			lpf_end],
		[lpf_t, lpf_t, lpf_t, lpf_t]), 1, doneAction:2);

	sig = Dust.ar(den, 1.5);

	//sig = LPF.ar(sig, lpf_curve);

	sig = BLowShelf.ar(sig, 500, 1, 12, 1.5);

 	sig = FreeVerb.ar(sig, 1, 0.9, 0.8); // Creates a wash of sound, only reverb

	sig = Pan2.ar(sig, pan);

	sig = sig * amp;

	Out.ar(out, sig);
}).add;
)

(
Pbindef(\rough_waves,
	\instrument, \waves,
	\dur, Pwhite(3, 6),
	\sd, Pwrand([300, 200, 500, 250], [0.5, 0.4, 0.1], inf),
	\ed, Prand([20, 25, 30], inf),
).play;
)

Synth(\chirp, [\freq, 4000, \dur, 0.5, \rel, 0.5])





(
SynthDef(\birb, { | amp = 0.3, out=0, pan=0, atk=0.05, rel=0.08, freq=2500, dec=0.3, sus=0.1, gate=1|
	var sig, env;

	sig = Mix.new([
		Pulse.ar(freq, 0.3, 0.2),
		Saw.ar((freq/10).asInteger, 0.8),
		LFTri.ar((freq/5).asInteger, 0.2, 0.2),
		Dust.ar(XLine.kr(200, 150, rel, 0.8), 0.5),
	]);

	env = EnvGen.ar(Env([0.1, 0.8, 0.1], [0.5, 0.5]), gate, doneAction:2);

	// Verry Slight Reverb for more balanced feel?
	sig = FreeVerb.ar(sig, 0.8, 0.2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, Dust.kr(XLine.kr(200, 50), 1));

	Out.ar(out, sig);
}).add;
)

(
Pbindef(\b,
	\instrument, \birb,
	\freq, Pxrand([2000, 2500, 3000, 3500, 4000], inf),
	\dur, Pexprand(0.125, 0.5, inf),
	\rel, Pxrand([0.5, 1, 1.5], inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\atk, Pexprand(0.03, 0.08, inf),
).play;
)


// Attempting to find a way to produce a 'flock' of birds
//     Initial idea is to use the random Impulses from Dust.ar
//     to affect the chirp synthdef?
(
SynthDef(\flock, { | amp=0.8, out=0, pan=0, atk=0.05, rel=0.08, freq=4000|
	var sig, env, chirp, flock;

	chirp = Mix.new([
		Pulse.ar(freq, 0.3, 0.5),
		Saw.ar((freq).asInteger, 0.2)]);

	flock = Dust2.ar(XLine.kr(200, 50, 5), 0.8);

	sig = flock * chirp * amp;

	sig = FreeVerb.ar(sig, 0.4, 0.8, 0.4);

	sig = Pan2.ar(sig, pan);


	Out.ar(out, sig);
}).add;
)


Synth(\flock)
Synth(\chirp)

Synth(\chirp, [\pan, 0, \freq, Pxrand([2500, 3000], 1)]);

(
Pbind(
	\instrument, \chirp,
	\out, Dust.ar(200, 0.5),
	\dur, 0.5,
).play;
)

// Sandstorm no darude?
(
SynthDef("help-Dust", { arg out=0;
    Out.ar(out,
        Dust.ar(XLine.kr(20000, 2, 10), 0.5)
    )
}).play;
)