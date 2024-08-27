s.boot               //Start server for audio interpretation
s.reboot             //reboot server for audio device means
s.quit               //Cut server contact for this session
Server.killAll       //Kill server connections for all sessions

{ [FSinOsc.ar(rand(300,660), rand(70), 0.3), SinOsc.ar(rand(100,440), 0, 0.2)] }.play;

{ SinOsc.kr(660, 2.0, 0.3, 0.0) }.play


(
{             // Open the Function
    FSinOsc.ar(    // Make an audio rate SinOsc
		rand(330),     // frequency of 440 Hz, or the tuning A
        0,     // initial phase of 0, or the beginning of the cycle
        2)     // mul of 0.2
}.play;            // close the Function and call 'play' on it
)


//Testing changing frequency using another sin wave
{ [SinOsc.ar( (SinOsc.kr(330, 0, 1, 0)), 0, 50, 0),     //a control rate sine wave modulating frequency?
	SinOsc.ar(rand(100,440), 0, 0.2)]
}.play

//Playing with the saw oscillator
{ [Saw.ar(660, 0.2), Saw.ar(330, 0.2), Saw.ar(115,0.2)] }.play

{ [PinkNoise.ar(0.2), PinkNoise.ar(0.2)] }.play

(
{
    var a, b;
    a = [SinOsc.ar(440, 0, 0.2), Saw.ar(662, 0.2)];
    b = [SinOsc.ar(442, 0, 0.2), Saw.ar(660, 0.2)];
    Mix([a, b]).postln;
}.play;
)

(
    var n = 10;
    { Mix.fill(n, { [SinOsc.ar(500 + 500.0.rand, 0, 1 / n),
	SinOsc.ar(500 + 500.0.rand, 0, 1 / n)]
}) }.play;
)

(
    var n = 8;
    {
        Mix.fill(n, { arg index;
            var freq;
            index.postln;
            freq = 440 + index;
            freq.postln;
            SinOsc.ar(freq , 0, 1 / n)
        })
    }.play;
)

//shorthad if only freqs are different
{ Saw.ar([330, 660], 0.1, 0.2) }.play



//FSinOsc is just a fast sin wave
//FSinOsc.ar(start, end, duration)
{ [FSinOsc.ar(XLine.kr(200, 1500, 1)) * 0.2, FSinOsc.ar(XLine.kr(200, 1500, 2)) * 0.2]  }.play;

// loses amplitude towards the end
{ FSinOsc.ar(FSinOsc.ar(XLine.kr(4, 401, 8), 0.0, 200, 800)) * 0.2 }.play;

{ (Pan2.ar(PinkNoise.ar(0.2), SinOsc.kr(0.5)),
	Saw.ar([330, 660], 0.1, 0.2))
}.play


