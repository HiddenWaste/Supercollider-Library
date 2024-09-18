// Iniitialization Block
(
s.reboot;        // Starts the audio server
s.plotTree;    // Visual of synth nodes and groups on the server
s.meter        // Level Meterd
)


// SynthDef Section!!!

(     // Band-Pass Filtered Sawtooth
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),      // in order: attack, sustain, release
	freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = Pan2.ar(sig, 0);

	sig = sig * env * amp;    // Signal Culmination

	Out.ar(out, sig);         // Output
}).add;

SynthDef(\woosh, {
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

        // Increment the loop counter, print, wait
        j = j + 1;
		//Post << "m - " << j << Char.nl;
        1.wait;
    }
};

b = Routine {
	i = 1;

	12.do {
		Synth(\woosh,
			[\freq, i*100,
				\atk, 0.05,
				\rel, 3.5,
				\amp, 0.3]);
		0.125.wait;
		i = i + 1;
	};
};

)

// Mic Test-Testing 1, 2
Synth(\woosh)
Synth(\bpfsaw)

a.play;
b.play;

// Learning Functions as well!!!
(
~playB = {
	b.reset;
	b.play;
};
~playA = {
	a.reset;
	a.play;
};
)

a.reset;
// To .do loop and call functions, must use a routine
(
c = Routine {
	//  s.record(duration: 30);    // We can actually record our tracks!!!!
	~playA.value;
	8.wait;
	4.do {
		~playB.value;
		6.wait;
	};
	8.wait;
	~playB.value;
	a.stop;
})

(
~playC = {
	c.reset;
	c.play;
})

~playC.value;  // So far this is the composition!!!