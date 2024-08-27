s.boot;
Server.killAll;

MIDIClient.init;

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOnTest, {"key down".postln});

MIDIdef(\noteOnTest).disable          //Disables an active mididef
MIDIdef(\noteOnTest).enable           //Emables an active mididef
MIDIdef(\noteOnTest).free             //frees a mididef
MIDIdef.freeAll;                      //Destroys all mididefs



//WORKING MIDIDEF!!!! Also prints the read velocity and midi note number
(
MIDIdef.noteOn(\SineSynthStart, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	{
		var sig, env;
		sig = SinOsc.ar(nn.midicps)!2;
		env = EnvGen.kr(Env.perc, doneAction:2);
		sig = sig * env * vel.linexp(1, 127, 0.01, 0.3);
	}.play;
});
)

//For more complex usage create a synthdef instead!
(
SynthDef.new(\tone1, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

//*/Now rather than using a whole ugen in mididef substantiate the synth
// (
// MIDIdef.noteOn(\noteOnTest, {
// 	arg vel, nn, chan, src;
// 	[vel, nn].postln;
// 	Synth.new(\tone, [\freq, nn.midicps, \amp, vel.linexp(1, 127, 0.05, 0.3)]);
// });
// )


//testing
//x = Synth.new(\tone, [\gate, 1]);

(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\tone,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1, 127, 0.05, 0.3),
			\gate, 1,
	]);
});

MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	[vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});
)

~notes = Array.newClear(128);
