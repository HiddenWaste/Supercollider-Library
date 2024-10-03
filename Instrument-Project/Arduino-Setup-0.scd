// Let's Learn how to read arduino data into SuperColldier!

// This first command shows the current Serial Port Devices available
SerialPort.listDevices;

// Now we should create a global variable in which we open the Serial port for reading
~ino = SerialPort.new(".COM3", 9600);     // Using Windows Serial Naming????

// Now we create a sort of 'Serial Def' that handles receiving

SerialPort.devices;

//====================================================================
//====================================================================

// Here  is the section where we will setup the first trigger
//     of audio in SuperCollider from Arduino Input!


// Let's make a simple pulse that we will trigger first.

s.boot; // We cam finally boot the server!

(
SynthDef(\tri, {
	arg out=0, freq=440, pha=0, amp=0.8;
	var sig, env;

	sig = LFTri.ar(freq, pha);

	env = EnvGen.ar(Env.perc(0.01, 1), doneAction:2);

	sig = sig * env * amp;

	sig = Pan2.ar(sig, out);
}
).add;
)

Synth(\tri); // Test To Make Sure it can be heard

s.boot;
s.meter;
s.plotTree;