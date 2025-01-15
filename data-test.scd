// granular_poc.scd
s.boot;

// 1. First, initialize basic variables and OSC
(
~procClient = NetAddr("127.0.0.1", 12000);  // Processing
~pyPort = 57120;  // Python input port

// Analysis buses
~analysisBus = Bus.audio(s, 2);
~amplitudeBus = Bus.control(s, 1);
~centroidBus = Bus.control(s, 1);

// State management
~granularActive = false;
)

// 2. SynthDefs
(
// Granular synth with evolution
SynthDef(\evolveGrain, { |out=0, analysisBus, sndbuf|
    var trig, grain, sig, pos;
    var envgate = EnvGate.new;  // This creates its own gate parameter

    // Evolving parameters
    var density = LFNoise2.kr(0.1).range(10, 40);
    var dur = LFNoise2.kr(0.05).range(0.02, 0.2);
    var pos_speed = LFNoise2.kr(0.08).range(0.5, 2);

    trig = Impulse.kr(density);
    pos = LFSaw.kr(pos_speed).range(0, 1);

    grain = GrainBuf.ar(
        2,
        trig,
        dur,
        sndbuf,
        1,
        pos,
        2,
        WhiteNoise.kr * 0.8
    );

    sig = grain * envgate;

    Out.ar(out, sig);
    Out.ar(analysisBus, sig);
}).add;

// Analysis synth
SynthDef(\analyzer, { |in, ampBus, centroidBus|
    var sig = In.ar(in, 2);
    var amp = Amplitude.kr(Mix(sig));
    var chain = FFT(LocalBuf(2048), Mix(sig));
    var centroid = SpecCentroid.kr(chain);

    Out.kr(ampBus, amp);
    Out.kr(centroidBus, centroid);
}).add;
)

// 3. Buffer and initialization
(
// Load a buffer for granular synthesis
~grainBuf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Initialize analysis synth
~analyzerSynth = Synth(\analyzer, [
    \in, ~analysisBus,
    \ampBus, ~amplitudeBus,
    \centroidBus, ~centroidBus
]);
)

// 4. OSC handlers and routines
(
// Handle messages from Python
OSCdef(\pyControl, { |msg|
    var command = msg[1];

    case
        { command == \toggle } {
            if(~granularActive,
                {
                    "Stopping granular synth".postln;
                    ~granularSynth.release; // Use release instead of set(\gate, 0)
                    ~granularActive = false;
                },
                {
                    "Starting granular synth".postln;
                    ~granularSynth = Synth(\evolveGrain, [
                        \analysisBus, ~analysisBus,
                        \sndbuf, ~grainBuf
                    ]);
                    ~granularActive = true;
                }
            );
        }
}, '/granular');

// Analysis data sender routine
~analysisRoutine = Routine({
    loop {
        ~amplitudeBus.get({ |ampVal|
            ~centroidBus.get({ |centVal|
                ~procClient.sendMsg(
                    "/analysis",
                    ampVal,
                    centVal.clip(0, 1000) / 1000  // Normalize centroid
                );
            });
        });
        0.033.wait;  // ~30fps
    }
}).play;
)

s.meter;

// manual toggle function
(
~toggleGranular = {
    if(~granularActive,
        {
            "Stopping granular synth".postln;
            ~granularSynth.release;
            ~granularActive = false;
        },
        {
            "Starting granular synth".postln;
            ~granularSynth = Synth(\evolveGrain, [
                \analysisBus, ~analysisBus,
                \sndbuf, ~grainBuf
            ]);
            ~granularActive = true;
        }
    );
};
)

~toggleGranular.value;


// Testing Section
~grainBuf.numFrames; // Should return a number if buffer loaded
~grainBuf.numChannels; // Should be 1 or 2|