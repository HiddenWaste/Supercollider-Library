(

s.waitForBoot(
	s.meter;
	s.plotTree;

	SynthDef(\reverb, {
		|mix=0.33, room=0.75, damp=0.8|
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = FreeVerb.ar(in, mix, room, damp);

		Out.ar(\out.ir(0), sig);
	}).add;

	~r_bus = Bus.audio(s, 2);

	~reverb_init = ( Synth(\reverb, [\in: ~b_fx, \out:0]));

)
)

