// Synthdefs imported from synthdef files




////////////////////
// analog bubbles //
////////////////////

val x0 = play {
  val f = LFSaw.kr(0.4).mulAdd(24, LFSaw.kr(Seq(8, 7.23)).mulAdd(3, 80)).midiCps // glissando function
  CombN.ar(SinOsc.ar(f)*0.04, 0.2, 0.2, 4) // echoing sine wave
}

x0.free()

val df1 = SynthDef("AnalogBubbles") {
  val f1 = "freq1".kr(0.4)
  val f2 = "freq2".kr(8.0)
  val d  = "detune".kr(0.90375)
  val f  = LFSaw.ar(f1).mulAdd(24, LFSaw.ar(Seq(f2, f2 * d)).mulAdd(3, 80)).midiCps // glissando function
  val x  = CombN.ar(SinOsc.ar(f) * 0.04, 0.2, 0.2, 4) // echoing sine wave
  Out.ar(0, x)
}
val x1 = df1.play()

x1.set("freq1" -> 0.1)

x1.set("freq2" -> 222.2)

x1.set("detune" -> 0.44)

s.freeAll()


// NOw for a section I can practice with some percussive sounds
