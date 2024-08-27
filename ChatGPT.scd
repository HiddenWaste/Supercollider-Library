//THis is a project of supercollider written using primarily chatgpt. Pretty fun to go through
//and use it for something like this cause you can alos notice some of the interesting quirky things it does
//Such as when you ask it to play a specific note it will play a decimal of that note's frequency
//whereas I would use the .midiratio method.



// Boot the server
s.boot;
s.reboot;

// Define a simple sin wave synthdef
(
SynthDef(\sin, {
    arg freq = 440, amp = 0.5, dur = 1;
    var env = EnvGen.kr(Env.linen(0.1, dur, 0.1), doneAction: Done.freeSelf);
    var sig = SinOsc.ar(freq) * env * amp;
    Out.ar(0, sig);
)
}).add;

// Define a simple square wave synthdef
(
SynthDef(\square, {
    arg freq = 440, amp = 0.5, dur = 1;
    var env = EnvGen.kr(Env.linen(0.1, dur, 0.1), doneAction: Done.freeSelf);
    var sig = LFPulse.ar(freq) * env * amp;
    Out.ar(0, sig);
}).add;
)

// Define a simple saw wave synthdef
(
SynthDef(\saw, {
    arg freq = 440, amp = 0.5, dur = 1;
    var env = EnvGen.kr(Env.linen(0.1, dur, 0.1), doneAction: Done.freeSelf);
    var sig = LFSaw.ar(freq) * env * amp;
    Out.ar(0, sig);
}).add;
)

// Play the sin, square, and saw wave synthdefs at C3, E3, and G3
Task({
    Synth(\sin, [\freq, 261.63, \amp, 0.5, \dur, 0.7]); // C3
    0.7.wait;
    Synth(\square, [\freq, 261.63, \amp, 0.3, \dur, 0.7]); // C3
    0.7.wait;
    Synth(\saw, [\freq, 261.63, \amp, 0.3, \dur, 0.7]); // C3
    0.7.wait;

    Synth(\sin, [\freq, 329.63, \amp, 0.5, \dur, 0.7]); // E3
    0.7.wait;
    Synth(\square, [\freq, 329.63, \amp, 0.3, \dur, 0.7]); // E3
    0.7.wait;
    Synth(\saw, [\freq, 329.63, \amp, 0.3, \dur, 0.7]); // E3
    0.7.wait;

    Synth(\sin, [\freq, 392.00, \amp, 0.5, \dur, 0.7]); // G3
    0.7.wait;
    Synth(\square, [\freq, 392.00, \amp, 0.3, \dur, 0.7]); // G3
    0.7.wait;
    Synth(\saw, [\freq, 392.00, \amp, 0.3, \dur, 0.7]); // G3
    0.7.wait;
}).play;