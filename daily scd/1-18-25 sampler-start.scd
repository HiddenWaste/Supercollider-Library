(
s.waitForBoot({
    s.meter;
    s.plotTree;
});
)

// Define sample names and create arrays to store buffers and samplers
~sample_names = ["kick", "tom", "snare", "808-clap", "closed-hat", "open-hat"];
~buffers = Array.newClear(~sample_names.size);
~samplers = Array.newClear(~sample_names.size);

// Load all samples
(
~sample_names.do({ |name, i|
    var path = "C:/Sample Library/Custom Packs/pack_0/" ++ name ++ ".wav";
    ~buffers[i] = Buffer.read(s, path, action: { |buf|
        ["Loaded buffer for", name, buf].postln;
    });
});
)

// Create a sampler synth with one-shot playback instead of looping
(
SynthDef(\sampler, {
    |bufnum = 0, rate = 1, amp = 0.5|
    var env = EnvGen.kr(Env.perc(0.01, 1), doneAction: 2);
    var out = PlayBuf.ar(
        numChannels: 1,
        bufnum: bufnum,
        rate: BufRateScale.kr(bufnum) * rate,
        trigger: 1,
        startPos: 0,
        loop: 0  // Changed to non-looping
    ) * env * amp;
    Out.ar(0, out!2);  // Stereo output
}).add;
)

// Function to play samples with default volumes appropriate for each type
~play = { |index, amp|
    var defaultAmps = [0.7, 0.6, 0.6, 0.5, 0.4, 0.4];  // Default amplitudes for each sample
    Synth(\sampler, [
        \bufnum, ~buffers[index].bufnum,
        \amp, amp ? defaultAmps[index]
    ]);
};

// Simple beat pattern
(
~pattern = Pbind(
    \instrument, \sampler,
    \bufnum, Pseq([
        ~buffers[0].bufnum, // kick
        ~buffers[4].bufnum, // closed hat
        ~buffers[2].bufnum, // snare
        ~buffers[4].bufnum, // closed hat
    ], inf),
    \amp, Pseq([0.7, 0.4, 0.6, 0.4], inf),
    \dur, 0.5  // each step is half a second (120 BPM)
).play;
)

// Stop the pattern
// ~pattern.stop;

// Test individual samples
/*
~play.(0);  // kick
~play.(1);  // tom
~play.(2);  // snare
~play.(3);  // clap
~play.(4);  // closed hat
~play.(5);  // open hat
*/