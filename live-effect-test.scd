// First, free any existing synths
Server.local.freeAll;
s.boot;
s.meter;

(
// Create a SynthDef for processing input with reverb
SynthDef(\inputReverb, {
    arg mix = 0.8,    // Reverb mix (0-1)
        room = 0.9,   // Room size (0-1)
        damp = 0.7,   // High frequency damping (0-1)
        amp = 1.0;    // Overall amplitude

    var input, wet, sig;

    // Get stereo input from sound card
    input = SoundIn.ar([0,1]);

    // Apply reverb
    wet = FreeVerb.ar(
		input, // Right channel
        mix,             // Mix
        room,            // Room size
        damp            // Damping
    );

	sig = wet * amp;

    // Output the processed signal
    Out.ar(0, sig);
}).add;
)

// Create the synth
~reverbSynth = Synth(\inputReverb);

// Optional: Create control window
Window.closeAll;
(
Window("Reverb Controls", Rect(200, 200, 300, 200)).front.layout_(
    VLayout(
        Slider().action_({|sl| ~reverbSynth.set(\mix, sl.value)}),
        StaticText().string_("Mix"),
        Slider().action_({|sl| ~reverbSynth.set(\room, sl.value)}),
        StaticText().string_("Room Size"),
        Slider().action_({|sl| ~reverbSynth.set(\damp, sl.value)}),
        StaticText().string_("Damping"),
        Slider().action_({|sl| ~reverbSynth.set(\amp, sl.value)}),
        StaticText().string_("Amplitude")
    )
);

s.meter;
)

s.devices
s.options.inDevice_("Primary Sound Capture Driver");  // Modify this line with your chosen device
s.reboot;
// To stop processing, evaluate:
// ~reverbSynth.free;