// Philip Glass-Inspired Generative Music System - Foundation
// This implementation focuses on establishing a robust foundation with proper resource management,
// clear timing mechanisms, and basic pattern generation capabilities.

(
// First, define a demo routine that we'll start after the system is loaded
~startDemo = {
    // Example pattern: Simple ascending sequence in C major
    var notes = [60, 62, 64, 65];  // C D E F
    var durations = [0.25, 0.25, 0.25, 0.25];

    // Helper function to convert MIDI notes to note names
    var noteToName = { |note|
        var names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
        var octave = (note / 12).floor - 1;
        var noteName = names[note % 12];
        noteName ++ octave
    };

    // Helper function to post pattern info
    var postPattern = { |instrument, notes, durations|
        var noteNames = notes.collect(noteToName);
        "=== Pattern Change ===".postln;
        ("Instrument: " ++ instrument).postln;
        ("Notes: " ++ noteNames.join(", ")).postln;
        ("Durations: " ++ durations.join(", ")).postln;
        "".postln;
    };

    "=== Starting Glass-inspired Demo ===".postln;
    "".postln;

    // Play initial piano pattern
    postPattern.value(\glassPiano, notes, durations);
    ~playPattern.value(
        \glassPiano,
        notes,
        durations,
        0.2
    );

    // Add marimba pattern after 4 beats
    ~mainClock.sched(4, {
        var marimba_notes = [60, 64, 67, 72];  // C E G C(octave up)
        var marimba_durs = [0.5, 0.25, 0.25, 0.5];
        postPattern.value(\glassMarimba, marimba_notes, marimba_durs);
        ~playPattern.value(
            \glassMarimba,
            marimba_notes,
            marimba_durs,
            0.15
        );
    });

    // Add flute pattern after 8 beats
    ~mainClock.sched(8, {
        var flute_notes = [72, 67, 64, 60];  // Descending C G E C
        var flute_durs = [1, 0.5, 0.5, 1];
        postPattern.value(\glassFlute, flute_notes, flute_durs);
        ~playPattern.value(
            \glassFlute,
            flute_notes,
            flute_durs,
            0.1
        );
    });
};

// Wrap system setup in waitForBoot to ensure the server is ready
Server.default.waitForBoot({
    // SECTION 1: GLOBAL VARIABLES AND SETTINGS
    var tempo = 120;
    var clockDiv = 4; // Clock divisions per beat for finer rhythmic control

    // Store active synths and patterns for proper cleanup
    var activeSynths = List.new;
    var activePatterns = List.new;

    // SECTION 2: SYNTHDEFS
    // Each SynthDef includes proper envelope handling and resource freeing

    // Piano SynthDef: Rich harmonics with medium sustain
    SynthDef(\glassPiano, {
        arg midinote = 60, amp = 0.3, gate = 1, pan = 0,
            atk = 0.005, dec = 0.1, sus = 0.8, rel = 0.5;
        var sig, env, freq;

        freq = midinote.midicps;  // Convert MIDI note to frequency at the last moment

        // Multi-oscillator approach for richer harmonics
        sig = Mix.ar([
            SinOsc.ar(freq, 0, 0.5),
            SinOsc.ar(freq * 2, 0, 0.25),
            SinOsc.ar(freq * 3, 0, 0.125)
        ]);

        env = EnvGen.kr(
            Env.adsr(atk, dec, sus, rel),
            gate,
            doneAction: 2
        );

        sig = sig * env * amp;
        sig = Pan2.ar(sig, pan);

        Out.ar(0, sig);
    }).add;

    // Marimba SynthDef: Bright, percussive with natural decay
    SynthDef(\glassMarimba, {
        arg midinote = 60, amp = 0.3, pan = 0;
        var sig, env, freq;

        freq = midinote.midicps;

        sig = SinOsc.ar(
            freq + (SinOsc.ar(freq * 3.817) * freq * 0.013),
            0,
            amp
        );

        env = EnvGen.kr(
            Env.perc(0.003, 0.3, curve: -4),
            doneAction: 2
        );

        sig = sig * env;
        sig = Pan2.ar(sig, pan);

        Out.ar(0, sig);
    }).add;

    // Flute SynthDef: Breathy, pure tone with subtle modulation
    SynthDef(\glassFlute, {
        arg midinote = 60, amp = 0.3, gate = 1, pan = 0,
            atk = 0.1, dec = 0.1, sus = 0.8, rel = 0.3;
        var sig, env, noise, freq;

        freq = midinote.midicps;

        sig = SinOsc.ar(freq, 0, 0.6);
        noise = HPF.ar(WhiteNoise.ar(0.1), 2000);
        sig = sig + noise;

        env = EnvGen.kr(
            Env.adsr(atk, dec, sus, rel),
            gate,
            doneAction: 2
        );

        sig = sig * env * amp;
        sig = Pan2.ar(sig, pan);

        Out.ar(0, sig);
    }).add;

    // SECTION 3: UTILITY FUNCTIONS
    // Function to create additive patterns in Glass style
    ~createAdditivePattern = { |baseNotes, numRepeats = 4|
        var pattern = List.new;
        baseNotes.size.do({ |i|
            pattern.add(baseNotes[0..i]);
        });
        pattern = pattern.collect({ |seq|
            seq ! numRepeats
        }).flatten;
        pattern;
    };

    // SECTION 4: TIMING AND CONTROL
    // Main clock for the system
    ~mainClock = TempoClock.new(tempo/60);

    // Basic pattern player that properly manages resources
    ~playPattern = { |instrument, notes, durations, amp = 0.3|
        var counter = 0;
        var pattern = Pbind(
            \instrument, instrument,
            \midinote, Pfunc({
                var index = counter;
                counter = (counter + 1) % notes.size;
                notes[index];
            }),
            \dur, Pseq(durations, inf),
            \amp, amp
        );

        var player = pattern.play(~mainClock);
        activePatterns.add(player);
        player;
    };

    // Cleanup function to properly free all resources
    ~cleanup = {
        activePatterns.do(_.stop);
        activeSynths.do(_.free);
        ~mainClock.stop;
    };

    // Print confirmation of successful setup
    "Glass-inspired system foundation loaded successfully.".postln;
    "Use ~startDemo.value to begin the demo pattern".postln;
    "Use ~cleanup.value when finished.".postln;
});
)

// To start the demo pattern, evaluate:
~startDemo.value;

// To stop everything:
// ~cleanup.value;