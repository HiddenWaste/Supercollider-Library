(

s.waitForBoot( {
	s.meter;
	s.plotTree;

	// Synthdef section

	SynthDef(\random_sine, {
		arg amp=0.7, pan=1, out=0, freq=440, mod_freq=4,
		gate=0, atk=0.1, dec=0.3, sus=0.1, rel=0.5,  hpf=500;
		var sig, env;

		sig = SinOsc.ar(
			LFNoise0.kr(mod_freq, 500, 100),
			0,
		)!2;

		sig = HPF.ar(sig, hpf);

		env = EnvGen.ar(Env.adsr(atk, dec, sus, rel), gate=0, doneAction:2);

		sig = sig * amp;

		Out.ar(out, sig);
	}).add;

	SynthDef(\saw_0, {
		| out=0, pan=0, amp=0.3, lpf_cutoff=400 |
		var sig, env;

		sig = Saw.ar(
			LFNoise2.kr(0.5, 200, 80));

		sig = Pan2.ar(sig, pan);

			sig = LPF.ar(sig, lpf_cutoff);

		sig = sig * amp;

		Out.ar(out, sig)
	}).add;

	SynthDef(\reverb, {
		arg mix=0.55, room=0.7, damp=0.8;
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = FreeVerb.ar(in, mix, room, damp);

		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\comb_delay, {
		arg maxdel=0.2, del=0.2, dec=0.4;
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = CombC.ar(in, maxdel, del, dec);

		Out.ar(\out.ir(0), sig);
	}).add;

	// Busses (0.0)
	~b_fx = Bus.audio(s, 2);
	~b_comb = Bus.audio(s, 2);

	// Auto create fx synths
	~reverb_init = { Synth(\reverb, [\in: ~b_fx, \out:0]) };
	~comb_delay_init  = { Synth(\comb_delay, [\in, ~b_comb, \out:~b_fx])};
	ServerTree.add(~reverb_init);
	ServerTree.add(~comb_delay_init);
})
)

Synth(\random_sine, [
		\out: ~b_fx,
		\dur, Prand([0.5, 1, 1.5], inf),
	]);
	Synth(\random_sine,[
		\out: ~b_comb,
		\mod_freq, 8,
		\hpf, 1700,
		\amp, 1.2
	]);


	Synth(\saw_0, [
		\out: ~b_comb,
		\amp
	]);


(
Pbindef(\a,
	\instrument, \random_sine
	\dur,
).stop`;
)
	