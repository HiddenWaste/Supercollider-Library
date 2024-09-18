// Iniitialization Block
(
s.boot;        // Starts the audio server
s.plotTree;    // Visual of synth nodes and groups on the server
s.meter        // Level Meterd
)


(     // Band-Pass Filtered Sawtooth
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = Pan2.ar(sig, 0);

	sig = sig * env * amp;    // Signal Culmination

	Out.ar(out, sig);         // Output
}).add
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
		Post << "m - " << j << Char.nl;
        1.wait;
    }
};
)

a.play;
a.stop;