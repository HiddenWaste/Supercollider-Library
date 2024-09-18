SynthDef.new(\sine, {                                       // Define a new SynthDef called \sine
    arg freq = 440, amp = 0.5, dur = 0.5;                   // Default values for freq, amp, and dur
    var env, sig;                                           // Declare variables for the envelope and signal
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);    // Create an envelope with a percussive shape
    sig = SinOsc.ar(freq) * amp * env;                      // Generate a sine wave and apply the envelope
    Out.ar([0, 1], sig);                                    // Use [0, 1] to specify stereo output
    }).add;                                                 // Add the SynthDef to the server

SynthDef.new(\saw, {
    arg freq = 440, amp = 0.5, dur = 0.5;
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    sig = Saw.ar(freq) * amp * env;
    Out.ar([0, 1], sig);
    }).add;

SynthDef.new(\pulse, {
    arg freq = 440, amp = 0.5, dur = 0.5, width = 0.5;
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    sig = Pulse.ar(freq, width) * amp * env;
    Out.ar([0, 1], sig);
    }).add;





// --------------------------------------------------------------

//  Now for some slighly more complex ones I've built more recently

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = Pan2.ar(sig, 0);

	sig = sig * env * amp;

	Out.ar(out, sig);
}).add
)

// Not only can I now use some of these Ugens more reliably and understand whats going on
// I blocked the code as one, 