// Set tempo and time signature
TempoClock.tempo = 120/60;
4.do { "timeSignature".postln };
// Set scale to A Major

(
a = Scale.major;   //Create a scale of the given kind
a = a.degrees;     //Make variable into an array of the degrees
a = a ++ 12;       //Concatenate the 12th aka the octave onto the array
)

// Define synth sound with stereo output and an envelope
(
SynthDef(\soft_ambient_synth, {
    arg out = 0, freq = 440, sustain = 4, pan = 0, amp = 0.3, attack = 0.5, release = 4;
    var env, osc, filt, verb;
    osc = Saw.ar(freq/2, 0.5); // divide frequency by 2 to drop pitch down one octave
    env = EnvGen.kr(Env.linen(attack, sustain, release), doneAction: 2);
    filt = LPF.ar(osc, 2000); // low-pass filter
    verb = GVerb.ar(filt, 0.3, 50, 0.5); // reverb effect
    verb = verb * env * amp;
    Out.ar(out, Pan2.ar(verb, pan));
}).add;
)

// Play soft ambient synth
Pbind(
    \instrument, \soft_ambient_synth,
    \degree, a.choose,
    \dur, Pwhite(2, 8, inf),
    \sustain, Pwhite(4, 12),
    \amp, Pexprand(0.1, 0.4),
    \pan, Pwhite(-1, 1),
    \attack, Pwhite(0.5, 2),
    \release, Pwhite(4, 10)
).play;

// Define percussive sound with stereo output
(
SynthDef(\percussive_sound, {
    arg out = 0, freq = 440, sustain = 0.2, pan = 0, amp = 0.5;
    var env, osc;
    osc = WhiteNoise.ar();
    env = EnvGen.kr(Env.linen(0.01, sustain, 0.01), doneAction: 2);
    osc = Pan2.ar(osc * env, pan, amp);
    Out.ar(out, [osc, osc]);
}).add;
)

// Play percussive sound
Pbind(
    \instrument, \percussive_sound,
    \degree, Pdup(a.choose, Pwhite(1, 4)),
    \dur, Pexprand(0.1, 0.5),
    \sustain, Pwhite(0.1, 0.3),
    \amp, Pexprand(0.3, 0.6),
    \pan, Pwhite(-1, 1)
).play;
