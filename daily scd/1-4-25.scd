(
s.boot;
s.meter;
s.plotTree;
)


// woob woob woob woob...
{ LFPar.ar(LFPar.kr(3, 0.3, 200, 400), 0.4) * 0.1 }.play;

(
SynthDef(\chaos_start, {
	arg pan = 0, out = 0, amp=0.5;
	var sig, env;

	sig = 	FBSineL.ar(
    LFNoise2.kr(1, 1e4, 1e4),
    LFNoise2.kr(1, 32, 33),
    LFNoise2.kr(1, 0.5),
    LFNoise2.kr(1, 0.05, 1.05),
    LFNoise2.kr(1, 0.3, 0.3)
	)!2;

	sig = Pan2.ar(sig, pan);

	Out.ar(out, sig * amp);
}).add;
)

(
Synth(\chaos_start, [
	\amp, 0.2,
]
);
)