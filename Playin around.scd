Server.default = s = Server.internal.boot

play({SinOsc.ar(LFNoise0.kr(12, mul: 600, add: 1000), 0.4)})

//Additive Synthesis example
play({   //play a sound
	var sines = 2, speed = 6;   //establishes variables for speed and number of sine waves
	Mix.fill(sines, //the sound is "filled with a mix of number of sine waves
		{arg x;
			Pan2.ar(
				SinOsc.ar(x+1*100, //Sine wave oscillators tuned to multiples of 100
					mul: max(0,    //Start of multiplication for
						LFNoise0.kr(speed) +
						Line.kr(1, -1, 30)
					)
).rand2(1.0))})/sines})

//Not a fan of this sound ^

rand(100)

exprand(1.0, 100.0)

play({SinOsc.ar(LFNoise0.kr(12, mul: 600, add: 1000, exprand(1.0, 1000.0)))})

play({SinOsc.ar(LFNoise0.kr(rand(20), mul: exprand(1.0, 100.0), add: rand(500)), exprand(3.0, 50,0))})
//Very much like playing with this one ^

{
	f = {play({SinOsc.ar(LFNoise0.kr(rand(20), mul: exprand(1.0, 100.0), add: rand(500)), exprand(1.0, 100,0))})};
	f.value;
}




// can also define then play
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;

Impulse.kr(20)