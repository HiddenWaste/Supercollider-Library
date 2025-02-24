(
s.waitForBoot(
	s.meter;
	s.plotTree;
)
)

(
SynthDef(\unknown, {
	|out=0, pan=0, freq=220, atk=1, rel=2, pha=0.3,
	amp=0.6|
	var sig, env;

	sig = Mix.new([
		SinOsc.ar(freq, pha, 0.5),
		SinOsc.ar(freq*2, pha, 0.3),
		LFSaw.ar(freq*0.5, 0.1)
	]);

	sig = Limiter.ar(sig, 0.6);

	env = EnvGen.ar(Env([0,0.8,0], [atk, rel]), doneAction:2);

	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)
(
SynthDef(\gendyPad, {
    arg out=0, freq=440, amp=0.3,
        ampdist=1, durdist=1,
        adparam=1.0, ddparam=1.0,
        minfreq=20, maxfreq=2000,
        ampscale=0.5, durscale=0.5,
        initCPs=12, knum=12,
        pan=0, gate=1, atk=2, rel=2;

    var env, sig;

    // ADSR envelope
    env = EnvGen.kr(
        Env.asr(atk, 1, rel),
        gate,
        doneAction: 2
    );

    // Gendy1 oscillator
    sig = Gendy1.ar(
        ampdist: ampdist,
        durdist: durdist,
        adparam: adparam,
        ddparam: ddparam,
        minfreq: minfreq,
        maxfreq: maxfreq,
        ampscale: ampscale,
        durscale: durscale,
        initCPs: initCPs,
        knum: knum,
        mul: amp
    );

    // Basic filtering
    sig = LPF.ar(sig, freq * 2);
    sig = HPF.ar(sig, 20);

    // Stereo spread
    sig = Pan2.ar(sig, pan);

    // Apply envelope and output
    Out.ar(out, sig * env);
}).add;

)

Synth(\gendyPad)

Synth(\unknown)