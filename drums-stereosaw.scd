// Starting Initializations
s.boot;
s.meter;

Server.killAll;

(
SynthDef(\brush, {
    arg out = 0, freq = 440, amp = 0.1, dur = 1;
    var sig, env;

    // Create pink noise for a smoother sound
    sig = PinkNoise.ar(amp);
    sig = HPF.ar(sig, 500);  // Lower the high-pass filter frequency
    sig = LPF.ar(sig, 2000); // Raise the low-pass filter frequency

    // Envelope to control amplitude over time
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = sig * env;

    // Add reverb with a high mix level for a more pronounced effect
    sig = FreeVerb.ar(sig, mix: 0.80, room: 0.8, damp: 0.7);

	sig = Pan2.ar(sig, SinOsc.kr(0.1, 3.6, 4).range(-1, 1));

    // Reduce the overall volume
    sig = sig * 0.7;

    // Output the signal with panning
	Out.ar(out, sig);
}).add;
)

// PBind for nice and soothing brush sounds
(
Pbind(
    \instrument, \brush,  // The brush synthdef
    \freq, 440,           // Frequency of the brush sound
    \amp, 1,          // Volume (amplitude) of the brush sound
    \dur, 0.75,           // Duration of the brush sound
    \out, Pseq([0, 1], inf).flatten  // Alternate between output channels
).play;
)







// Melodic Testing Range



// Define a custom SynthDef for the saw wave
(
SynthDef(\progression_saw, {
    arg freq, amp = 0.1, dur = 1;
    var sig;
    sig = Saw.ar(freq, 0.1) * amp;
    sig = sig * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2); // Envelope to control duration
    Out.ar(0, sig.dup); // Duplicate signal for stereo output
}).add;
)


{

// Create a pattern to play the progression
(
var progression = [[440, 660], [310, 660], [220, 440]];

Pbind(
    \instrument, \progression_saw,           // The Saw synthdef built for this test
    \freq, Pseq(progression, inf).flatten,   // Progression array passed for frequency argument
	\amp, 0.5,                               // Volume (amplitude) of noise
	\dur, 1,                                  // Duration of each note
	\out, Pseq([0,1], inf).flatten,

).play;
)



// Building off of the drummer example from supercollider documentation
(
{
  var snare, bdrum, hihat;
  var tempo = 4;

  tempo = Impulse.ar(tempo); // for a drunk drummer replace Impulse with Dust !!!
  snare = WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5));
  bdrum = SinOsc.ar(Line.ar(120,60, 1), 0, Decay2.ar(PulseDivider.ar(tempo, 4, 0), 0.005, 0.5));
  hihat = HPF.ar(WhiteNoise.ar(1), 10000) * Decay2.ar(tempo, 0.005, 0.5);

  Out.ar(0, (snare + bdrum + hihat) * 0.4 ! 2)
}.play
)
