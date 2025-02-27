Server.killAll

(
s.waitForBoot (
	s.meter;
	s.plotTree;
)
)

(
SynthDef(\guitar, {
	arg
	// Standard values
	out = 0, pan = 0, freq = 440, amp = 0.3, rel = 5,
	// String controls (pickPos goes from 0 to 1)
	decayCoef = 0.125, dampCoef = 0.0002, pickPos = 0.414, openFreq = 82.5, muteSus = 5.5,
	// Pickup Controls (pickupPos goes from 0 to 1)
	pickupPos = 0.17, pickupWidth = 0.75, resFreq = 4000, rq = 0.5, toneFreq = 3250;

	var exciter, freqArray, ampArray, decArray, constant, mute, snd;

	// Make a Constant from pickupWidth for ampArray
	constant = pickupWidth/25.5; // The scale length is set to 25.5 inches
	constant = constant * pi/2;
	constant = constant/openFreq;

	// Stiff String Model for Frequencies
	freqArray = Array.fill(50, {
		arg i;
		(i + 1) * sqrt(1 + ((i + 1).pow(2) * 0.00001))
	});
	freqArray = freqArray/freqArray[0];

	// Decay Times
	decArray = Array.fill(50, {
		arg i;
		exp(
			(-1 * i)/
			(
				(1/decayCoef) +
				((dampCoef/10) * freq.pow(2)) +
				(dampCoef * freqArray[i].pow(2))
		    )
		)
	});
	decArray = decArray/decArray[0];

	// Rescale freqArray for ampArray and Klank
	freqArray = freqArray * freq;

	// Effects of Pick Position and Pickup Placement
	ampArray = Array.fill(50, {
		arg i;
		((1 - ((freqArray[i] - 19000)/1000).tanh)/2) *
		sin(((i + 1) * pi) * pickPos) *
		(
			sin(pi * pickupPos * freqArray[i]/openFreq) *
			(
			    (
					sin(constant * freqArray[i])/
					(constant * freqArray[i])
				) - cos(constant * freqArray[i])
			)
		)/(freqArray[i].pow(2))
	});
	ampArray = ampArray * 2/(constant.pow(2));

	// The Pick
	exciter = Impulse.ar(0) * 0.1;

	// The String
	snd = Klank.ar(
		specificationsArrayRef:
		    Ref.new([freqArray, ampArray, decArray]),
		input: exciter,
		decayscale: rel
	);

	snd = Mix.ar(snd);

	// The Pickup
	snd = RLPF.ar(
		in: snd,
		freq: resFreq,
		rq: rq);

	snd = LPF.ar(
		in: snd,
		freq: toneFreq);

	// An Envelope for Muting the String
	mute = Env.new(
		levels: [1, 1, 0, 0],
		times: [muteSus, 0.05, 0.01]).ar(doneAction: 2);

	// Mute the String
	snd = LPF.ar(
		in: snd,
		freq: LinExp.ar(
			in: mute,
			srclo: 0, srchi: 1,
			dstlo: 20, dsthi: 20000));

	// Output Stuff
	snd = snd * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \guitar,
	tags: [\pitched, \modal]
)
).add;

SynthDef(\reverb, {
		|mix=0.33, room=0.75, damp=0.8|
		var sig, in;

		in = In.ar(\in.ir(1), 2);
		sig = FreeVerb.ar(in, mix, room, damp);

		Out.ar(\out.ir(0), sig);
	}).add;

SynthDef(\comb_del, {
	|max_del=0.2, del_t=0.2, dec=1|
	var sig, in;

	in = In.ar(\in.ir(1), 2);
	sig = CombL.ar(in, max_del, del_t, dec);

	Out.ar(\out.ir(0), sig);
}).add;
)

(

~b_fx = Bus.audio(s, 2);
~d_fx = Bus.audio(s, 2);
~reverb_init = ( Synth(\reverb, [\in: ~b_fx, \out:0]));
~delay_init = ( Synth(\comb_del, [\in: ~d_fx, \out:~b_fx]));
ServerTree.add(~reverb_init);
ServerTree.add(~delay_init);

)

(
Pbindef(\g,
	\instrument, \guitar,
	\freq, Pxrand(Scale.phrygian.degrees+80.midicps, inf),
	\dur, Prand([0.5, 0.25, 0.125], inf),
	\out, ~d_fx,
	\pickPos, Pwhite(0.3, 0.5, inf)
).play;
)

Synth(\guitar, [\freq, 440]);