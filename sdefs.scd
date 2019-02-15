(
    SynthDef(\saw, {
        var sig, env, freq;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = Saw.ar(freq);
        sig = sig.curverange(\lo.kr(0.0), \hi.kr(1.0), \curve.kr(0));
        sig = sig * env * \amp.kr(0.2) * AmpComp.kr(freq);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\sine, {
        var sig, env, freq;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = SinOsc.ar(freq);
        sig = sig.curverange(\lo.kr(0.0), \hi.kr(1.0), \curve.kr(0));
        sig = sig * env * \amp.kr(0.2) * AmpComp.kr(freq);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\route, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = sig * env * \amp.kr(1);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\mono, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = sig.sum;
        sig = sig * env * \amp.kr(1);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\panner, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), 1);
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2.0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\soundin, {
        var sig, env;
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = SoundIn.ar(\in.kr(0));
        sig = sig * env * \amp.kr(0.2);
        // sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2.0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\compressor, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = Compander.ar(sig, sig, slopeAbove: \ratio.kr(2).reciprocal, thresh: \thresh.kr(0.7));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\limiter, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = Limiter.ar(sig, \limit.kr(0.9));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\eq, {
        arg in, attack=0.1, rel=0.1, amp=1, out=0, gate=1, da=2,
        locut=20, loshelffreq=200, loshelfdb=0, 
        hishelffreq=1500, hishelfdb=0, hicut=20000, 
        peakfreq=600, peakrq=1, peakdb=0;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1, rel), gate: gate, doneAction: da); 
        sig = In.ar(in, ~numSpeakers);
        sig = BLowShelf.ar(sig, loshelffreq, db: loshelfdb);
        sig = BHiShelf.ar(sig, hishelffreq, db: hishelfdb);
        sig = BHiPass.ar(sig, locut);
        sig = BLowPass.ar(sig, hicut);
        sig = BPeakEQ.ar(sig, peakfreq, peakrq, peakdb);
        sig = sig * amp * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\hishelf, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = BHiShelf(sig, \freq.kr(1000), \db.kr(0));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\hipass, {
        var sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        sig = BHiPass(sig, \freq.kr(20));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    // ******************** instruments ********************

    SynthDef(\pitchFollower, { 
        var in, freq, hasFreq, sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        in = In.ar(\in.kr(~numSpeakers));
        # freq, hasFreq = Pitch.kr(in);
        sig = SinOsc.ar(freq * \pitchratio.kr(0.5)) * in + in;
        sig = sig * Amplitude.kr(sig);
        sig = sig * env * \amp.kr(0.1);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\reso,{
        var sig, env, numresonators, freq, freqs, amps, decays;
        numresonators = 12;
        freq = \freq.kr(40);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        freqs = Array.fill(numresonators, {|i| Rand(i * freq, i * freq * \spread.kr(2))});
        amps = Array.geom(numresonators, 1, 0.9);
        decays = Array.geom(numresonators, 1, 0.9);
        sig = DynKlank.ar(
            `[freqs, amps, decays], 
            PinkNoise.ar(0.1), 
            0.5,
            decayscale: \decay.kr(0.2)
        );
        sig = sig * \amp.kr(0.1) * env;
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\playbuf,{
        var sig, env, buf;
        buf = \buf.kr(0);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = PlayBuf.ar(1, buf, rate: BufRateScale.kr(buf) * \rate.kr(1), startPos: \startPos.kr(0), loop: \loop.kr(1));
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        sig = sig * \amp.kr(0.3) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\klank, { 
        var sig, harm, amps, ring, env, freq, numresonators;
        numresonators = 12;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        harm = Array.geom(numresonators, freq, \spread.kr(2));
        amps = Array.geom(numresonators, 1, \decay.kr(0.3));
        ring = Array.fill(numresonators, \ring.kr(1));
        sig = Klank.ar(`[harm, amps, ring], In.ar(\in.kr(~numSpeakers), ~numSpeakers));
        sig = sig * env * \amp.kr(0.3);
        sig = sig * AmpCompA.kr(freq);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\klang,{
        var sig, env, freq, freqs, amps, numresonators;
        numresonators = 12;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        freqs = Array.geom(8, freq, \spread.kr(2)); 
        amps = Array.geom(8, 1, \decay.kr(0.3));
        sig = Klang.ar(`[freqs, amps, nil]);
        sig = sig * AmpCompA.kr(freq);
        sig = sig * \amp.kr(0.3) * env;
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\dynKlang, { 
        var sig, freq, harm, amps, env;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        harm = Array.geom(8, freq, \spread.kr(2));
        amps = Array.geom(8, 1, \decay.kr(0.3));
        sig = DynKlang.ar(`[harm, amps, nil]);
        sig = sig * env * \amp.kr(0.3);
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\click, {
        var sig, env;
        env = EnvGen.kr(Env.perc(0, 1), doneAction: 2);
        sig = EnvGen.ar(Env([0, 1, 0], [0, \rel.kr(0.0001)]));
        sig = sig * \amp.kr(0.3) * env;
        sig = LeakDC.ar(sig);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\fm, {
        var sig, env, freq, mod, modenv, gate;
        freq = \freq.kr(440);
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        gate = \gate.kr(1);
        modenv = EnvGen.kr(Env.asr(\modattack.kr(0.5), 1, \modrel.kr(0.5), ), gate);
        mod = SinOsc.ar(\modfreq.kr(440));
        mod = mod * modenv * \moddepth.kr(1);
        sig = SinOsc.ar(freq + mod);
        sig = sig * env * \amp.kr(0.3);
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\grbuf, {
        var sig, src, env, trig, buf, pos, pan;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        buf = \buf.kr(0);
        trig = In.ar(\trig.kr(0), 1);
        src = In.ar(\in.kr(~numSpeakers));
        pos = In.ar(\pos.kr(0), 1);
        pan = In.ar(\pan.kr(0), 1);
        sig = GrainBuf.ar(~numSpeakers, trig, \grainsize.kr(0.2), buf, \rate.kr(1), pos, pan: pan);
        sig = sig * env * \amp.kr(0.3);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\fire, { 
        arg hipassfreq=40, bandpassfreq=600, bandpassrq=5.0, 
        pan=0, gate=1, da=2, width=~numSpeakers, 
        attack=1, rel=1, amp=0.2, crackledensity=1;
        var trigs, durscale, resfreq;
        var noise, hissing, crackles, lapping;
        var sig;
        noise = WhiteNoise.ar;
        hissing = HPF.ar(noise, 1000) * LFNoise2.kr(1).squared.squared;
        // Crackle
        trigs = Dust.kr(crackledensity);
        durscale = TRand.kr(1, 1.5, trigs);
        resfreq = TExpRand.kr(100, 1000, trigs);
        crackles = noise * EnvGen.ar(Env.perc(0, 0.02, curve: 0), trigs, timeScale: durscale);
        crackles = crackles + BPF.ar(crackles, resfreq, 20);
        lapping = LeakDC.ar(LeakDC.ar(BPF.ar(noise, 30, 0.2) * 50).clip2(0.9)) * 0.5;
        sig = ([crackles, hissing, lapping] * [0.1, 0.3, 0.6]).sum * 3;
        sig = BPF.ar(sig, bandpassfreq, bandpassrq);
        sig = HPF.ar(sig, hipassfreq);
        sig = EnvGen.ar(Env.asr(attack, amp, rel), gate: gate);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(0, sig)
    }).add;

    SynthDef(\jpverb, {
        var source, sig, env;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        source = In.ar(\in.kr(~numSpeakers), ~numSpeakers);
        source = source.sum * env;
        sig = JPverb.ar(source, \revtime.kr(1), \damp.kr(0), \size.kr(1), \early.kr(0.707));
        sig = SplayAz.ar(~numSpeakers, sig, spread: 0.5, width:~numSpeakers);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\grdelay, {
        var sig, src, env, trig, phase, buf, local, pos, frames, sr, pan, maxDelay, jitter;
        env = EnvGen.kr(Env.asr(\attack.kr(0.1), 1.0, \rel.kr(0.1)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sr = SampleRate.ir;
        maxDelay = \maxDelay.ir(1.0);
        frames = max(0, maxDelay * sr).round;
        buf = LocalBuf(frames);
        phase = Phasor.ar(0, rate: 1, start:0, end: frames);
        src = In.ar(\in.kr(~numSpeakers));
        BufWr.ar(src, buf, phase);
        trig = Impulse.ar(\freq.kr(20));
        pos = phase.linlin(0, frames, 0.0, 1.0);
        pan = TRand.kr(\panMin.kr(-1), \panMax.kr(1), trig);
        sig = GrainBuf.ar(~numSpeakers, trig, \grainsize.kr(0.2), buf, \rate.kr(1), pos, pan: pan);
        //begin feedback loop
        local = LocalIn.ar(~numSpeakers);
        jitter = \jitter.kr(0);
        jitter = TRand.kr(0, jitter, trig);
        local = DelayL.ar(local + sig, maxDelay, \delay.kr(0.2) + jitter);
        local = LeakDC.ar(local);
        local = local.rotate(1);
        LocalOut.ar(local * \fb.kr(0.1));
        //end feedback loop
        sig = (sig + local) * env * \amp.kr(0.3);
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\dust, {
        var sig, env;
        env = EnvGen.kr(Env.asr( \attack.kr(0.01), 1, \release.kr(0.01)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = Dust.ar(\density.kr(10));
        sig = LeakDC.ar(sig);
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\impulse, {
        var sig, env;
        env = EnvGen.kr(Env.asr( \attack.kr(0.01), 1, \release.kr(0.01)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = Impulse.ar(\freq.kr(10));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr, sig);
    }).add;

    SynthDef(\comb, {
        var sig, env;
        env = EnvGen.kr(Env.asr( \attack.kr(0.01), 1, \release.kr(0.01)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr, ~numSpeakers);
        sig = CombC.ar(sig, \maxDelay.ir(1), \delay.kr(0.1), \decay.kr(1));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\phasor, {
        var sig, env, trig;
        trig = In.ar(\reset.kr(0));
        env = EnvGen.kr(Env.asr( \attack.kr(0.01), 1, \release.kr(0.01)), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = Phasor.ar(trig, \rate.kr(1), \start.kr(0), \end.kr(1));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    }).add;
)
