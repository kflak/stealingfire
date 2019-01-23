(
    SynthDef(\lfosaw, {
        arg out, amp=1.0, freq=1, offset=0, da=2, gate=1, attack=0.1, rel=0.1;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1.0, rel), gate: gate, doneAction: da);
        sig = Saw.ar(freq) * env * amp;
        sig = sig + offset;
        Out.kr(out, sig);
    }).add;

    SynthDef(\lfosin, {
        arg out, amp=1.0, freq=1, offset=0, da=2, gate=1, attack=0.1, rel=0.1;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1.0, rel), gate: gate, doneAction: da);
        sig = SinOsc.ar(freq) * env * amp;
        sig = sig + offset;
        Out.kr(out, sig);
    }).add;

    SynthDef(\route, {
        arg in, out, amp, da=2, gate=1;
        var sig, env;
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: gate, doneAction: da);
        sig = In.ar(in, ~numSpeakers);
        sig = sig * env * amp;
        Out.ar(out, sig);
    }).add;

    SynthDef(\mixToDualMono, {
        arg in, attack=0.1, rel=0.1, amp=1, out=0, gate=1;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1, rel), gate: gate, doneAction: 2);
        sig = In.ar(in, ~numSpeakers);
        sig = sig.sum;
        sig = sig ! 2;
        sig = sig * amp * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\soundin, {
        arg in, gate=0, da=0, amp=0.2, pan=0, width=2.0, out=0;
        var sig, env;
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: gate, doneAction: da);
        //not sure if this is a good idea, but now the index given to soundin
        //will be the same as the index listed on the soundcard...
        sig = SoundIn.ar((in - 1).clip(0, 19));
        sig = sig * env * amp;
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\compressor, {
        arg in, attack=0.1, rel=0.1, amp=1, out=0, gate=1, ratio=2, gain=1, thresh=0.7;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1, rel), gate: gate, doneAction: 2);
        sig = In.ar(in, ~numSpeakers);
        sig = Compander.ar(sig, sig, slopeAbove: 1/ratio, thresh: thresh, mul: gain);
        sig = sig * amp * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\limiter, {
        arg in, attack=0.1, rel=0.1, amp=1, out=0, gate=1, limit=0.9;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1, rel), gate: gate, doneAction: 2);
        sig = In.ar(in, ~numSpeakers);
        sig = Limiter.ar(sig, limit);
        sig = sig * amp * env;
        Out.ar(out, sig);
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

    // ******************** instruments ********************

    SynthDef(\pitchFollower, { 
        arg in, out, pitchratio=0.5, da=2, pan=0, width=2, amp=0.1, gate=1;
        var input, freq, hasFreq, sig, env;
        input = SoundIn.ar(in);
        # freq, hasFreq = Pitch.kr(input);
        env = EnvGen.kr(Env.asr(0.1, amp, 0.1), gate: gate, doneAction: da);
        sig = SinOsc.ar(freq * pitchratio) * input + input;
        sig = sig * Amplitude.kr(sig);
        sig = sig * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\reso,{
        arg decay=0.2, freq=40, spread=2, attack=0.01, rel=0.4, amp=0.1, pan=0, width=2, out=0;
        var sig, env, numresonators, freqs, amps, decays;
        numresonators = 12;
        env = EnvGen.kr(Env.perc(attack, rel, curve: -8), doneAction: 2);
        freqs = Array.fill(numresonators, {|i| Rand(i * freq, i * freq * spread)});
        amps = Array.geom(numresonators, 1, 0.9);
        decays = Array.geom(numresonators, 1, 0.9);
        sig = DynKlank.ar(
            `[freqs, amps, decays], 
            PinkNoise.ar(0.1), 
            0.5,
            decayscale: decay
        );
        sig = sig * amp * env;
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\playbufgate,{
        arg buf=0, attack=0.0, rel=10, da=2, amp=0.3, pan=0, width=2, out=0, gate=1, lagup=0.1, lagdown=0.1, loop=1.0, startpos=0, rate=1;
        var sig, env;
        env = EnvGen.kr(Env.asr(attack, 1, rel, curve: -4), gate, doneAction: da);
        sig = PlayBuf.ar(1, buf, rate: BufRateScale.kr(buf) * rate, startPos: startpos, loop: loop);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        sig = sig * amp * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\playbuf,{
        arg buf=0, attack=0.0, rel=10, amp=0.3, pan=0, width=2, out=0, loop=1.0;
        var sig, env, startpos=0, rate=1;
        env = EnvGen.kr(Env.perc(attack, rel, curve: -4), doneAction: 2);
        sig = PlayBuf.ar(1, buf, rate: BufRateScale.kr(buf) * rate, startPos: startpos, loop: loop);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        sig = sig * amp * env;
        Out.ar(out, sig);
    }).add;

    SynthDef(\klank, { arg out=0, freq=440, spread=2, decay=0.3, ring=1, 
        attack=0.8, rel=10, pan=0, width=2, amp = 0.3;
        var sig, harm, amps, env;
        harm = Array.geom(8, freq, spread);
        amps = Array.geom(8, 1, decay);
        ring = Array.fill(8, ring);
        env = EnvGen.kr(Env.perc(attack, rel, curve: -4), doneAction: 2);
        sig = Klank.ar(`[harm, amps, ring], ClipNoise.ar(0.003));
        sig = sig * env * amp;
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\klang,{
        arg freq=440, attack=0.8, rel=10, amp=0.3, pan=0, width=2, out=0, spread=2, decay=0.3;
        var sig, env, freqs, amps;
        env = EnvGen.kr(Env.perc(attack, rel), doneAction: 2);
        freqs = Array.geom(8, freq, spread); 
        amps = Array.geom(8, 1, decay);
        sig = Klang.ar(`[freqs, amps, nil]);
        sig = sig * amp * env;
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\dynKlang, { arg out=0, freq=440, spread=2, decay=0.3, 
        attack=0.8, rel=10, gate=1, pan=0, width=2, 
        fmfreq=0.1, fmdepth=100, amfreq=0.01, amdepth=100,
        amp = 0.3, fx1lvl=0, fx1=0, fx2lvl=0, fx2=0, fx3, fx3lvl=0, fx4, fx4lvl=0;
        var sig, harm, amps, env;
        harm = Array.geom(8, freq, spread);
        amps = Array.geom(8, 1, decay);
        env = EnvGen.kr(Env.asr(attack, 1, rel, curve: -4), gate, doneAction: 2);
        sig = DynKlang.ar(`[harm + SinOsc.kr(fmfreq, mul: fmdepth), amps, nil]);
        sig = sig * SinOsc.ar(amfreq, amdepth);
        sig = sig * env * amp;
        sig = sig * AmpCompA.kr(freq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;


    SynthDef(\click, {
        arg amp=0.3, pan=0, width=2, rel=0.0001, out=0;
        var sig, env;
        env = EnvGen.kr(Env.perc(0, 1), doneAction: 2);
        sig = EnvGen.ar(Env([0, 1, 0], [0, rel]));
        sig = sig * amp	* env;
        sig = LeakDC.ar(sig);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\bpnoiseGate, {
        arg freq=440, amp=0.3, pan=0, width=2, gate=1,
        amfreq=1, amdepth=0, attack=0.5, rel=3, out=0, 
        rq=1, hipassfreq=20, da=2;
        var sig, env;
        freq = freq.clip(20, 20000);
        sig = BPF.ar(PinkNoise.ar, freq, rq: rq);
        env = EnvGen.kr(Env.asr(attack, amp, rel), gate, doneAction: da);
        sig = sig * env * AmpCompA.kr(freq);
        sig = BHiPass.ar(sig, freq: hipassfreq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\bpnoise, {
        arg freq=440, amp=0.3, pan=0, width=2, out=0, attack=1, rel=1,
        rq=1, hipassfreq=20;
        var sig, env;
        freq = freq.clip(20, 20000);
        sig = BPF.ar(PinkNoise.ar, freq, rq: rq);
        env = EnvGen.kr(Env.perc(attack, rel), doneAction: 2);
        sig = sig * env * amp * AmpCompA.kr(freq);
        sig = BHiPass.ar(sig, freq: hipassfreq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;


    SynthDef(\pmEnv, {
        arg freq=440, modfreq=20, pmindex=0, amp=0.3, pan=0, width=2, amfreq=1, amdepth=0.5, attack=0.5, rel=3, out=0;
        var sig, env, filterenv, amenv;
        sig = PMOsc.ar(freq, modfreq, pmindex); 
        env = EnvGen.kr(Env.perc(attack, rel), doneAction: 2);
        amenv = amfreq * env;
        sig = sig * env * AmpCompA.kr(freq) * SinOsc.kr(amenv, amdepth);
        sig = sig * amp;
        filterenv = freq * 2 * env;
        filterenv = filterenv.clip(20.0, 20000.0);
        sig = LPF.ar(sig, filterenv);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\sineGate, {
        arg freq=440, amp=0.3, pan=0, width=2, gate=1, amfreq=1, amdepth=0.5, 
        attack=0.5, rel=3, out=0, da=2;
        var sig, env;
        sig = SinOsc.ar(freq); 
        env = EnvGen.kr(Env.asr(attack, amp, rel), gate: gate, doneAction: da);
        sig = sig * env * AmpCompA.kr(freq) * SinOsc.kr(amfreq, amdepth);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\sine, {
        arg freq=440, amp=0.3, pan=0, width=2, gate=0, amfreq=1, amdepth=0.5, 
        attack=0.5, rel=3, out=0, da=2;
        var sig, env;
        sig = SinOsc.ar(freq); 
        env = EnvGen.kr(Env.perc(attack, rel, -4), doneAction: da);
        sig = sig * env * AmpCompA.kr(freq) * SinOsc.kr(amfreq, amdepth);
        sig = sig * amp;
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fm, {
        arg carfreq=440, modfreq=440, amp=0.3, pan=0, width=2,
        attack=0.5, rel=3, modattack=0.5, modrel=0.5, moddepth=1, out=0;
        var sig, carenv, mod, modenv;
        modenv = EnvGen.kr(Env.perc(modattack, modrel, -4));
        mod = SinOsc.ar(modfreq);
        mod = mod * modenv * moddepth;
        sig = SinOsc.ar(carfreq + mod);
        carenv = EnvGen.kr(Env.perc(attack, rel, -4), doneAction: 2);
        sig = sig * carenv * AmpCompA.kr(carfreq);
        sig = sig * amp;
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fmGate, {
        arg carfreq=440, modfreq=440, amp=0.3, pan=0, width=2, gate=1,
        attack=0.5, rel=3, modattack=0.5, modrel=0.5, moddepth=1, out=0, 
        amfreq=1, amdepth=1;
        var sig, carenv, mod, modenv, am;
        am = SinOsc.kr(amfreq) * amdepth;
        modenv = EnvGen.kr(Env.asr(modattack, 1, modrel), gate: gate);
        mod = SinOsc.ar(modfreq);
        mod = mod * modenv * moddepth;
        sig = SinOsc.ar(carfreq + mod) * am;
        carenv = EnvGen.kr(Env.asr(attack, amp, rel), gate: gate, doneAction: 2);
        sig = sig * carenv * AmpCompA.kr(carfreq);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
    }).add;

    SynthDef(\clickdust, {
        arg density=10, amp=0.3, pan=0, width=2, attack=0.5, rel=3, ctrlin=0, out=0;
        var sig, env, trig;
        sig = Dust.ar(density);
        env = EnvGen.kr(Env.perc(attack, rel, -4), doneAction: 2);
        sig = sig * env * amp;
        sig = LeakDC.ar(sig);
        sig = PanAz.ar(~numSpeakers, sig, pan, width: width);
        Out.ar(out, sig);
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

    // ******************** effects ********************
    SynthDef(\jpverb, {
        arg in=16, out, amp=1, attack=0.02, rel=0.1, gate=1, da=2, 
        revtime=1, damp=0, size=1, early=0.707;
        var source, sig, env;
        env = EnvGen.kr(Env.asr(attack, amp, rel), gate: gate, doneAction: da);
        source = In.ar(in, ~numSpeakers);
        source = Mix.ar(source) * env;
        sig = JPverb.ar(source, revtime, damp, size, early);
        sig = SplayAz.ar(~numSpeakers, sig, spread: 0.5, width:~numSpeakers);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fbdelay, {
        arg in, out, amp=0.3, fb=0.2, gate=1, da=2, mindelay=0.4, maxdelay=1.0;
        var sigs, sig, env, src, fbNode, fbNodes, n=5, delays;
        // delays = Array.series(n, 0.3, 0.2);
        delays = Array.fill(n, {|i| i.linlin(0, n, mindelay, maxdelay)});
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: gate, doneAction: da);
        src = In.ar(in, 1);
        fbNodes = {FbNode(1, 2.0)} ! n;
        sigs = n.collect {
            arg i;
            sig = src 
            + (fbNodes[i].delay(delays[i])*fb) 
            + (fbNodes[(i+1) % n].delay(delays[i])*fb) 
            + (fbNodes[(i - 1) % n].delay(delays[i])*fb);
            sig = LeakDC.ar(sig);
            fbNodes[i].write(sig);
        };
        sigs = sigs * env * amp;
        sigs = SplayAz.ar(~numSpeakers, sigs, spread: 1, width:~numSpeakers, center: 0);
        Out.ar(out, sigs);
    }).add;

    SynthDef(\grdelay, {
        arg in, out, amp=0.3, fb=0.2, gate=1, da=2, mindelay=0.4, maxdelay=1.0, 
        modfreq=0.1, moddepth=0.0, limit=0.8,
        locut=100, density=10.0, grainsize=0.1, grainsizerand=0;
        var sigs, env, src, trig, pan, fbNode, fbNodes, n=3, delays, delaybuffersize=4.0, mod, grainrandomizer;
        trig = Dust.kr(density);
        delays = Array.fill(n, {|i| i.linlin(0, n - 1, mindelay, maxdelay)});
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: gate, doneAction: da);
        pan = TRand.kr(-1.0, 1.0, trig);
        grainrandomizer = TRand.kr(0.0, grainsizerand, trig);
        src = In.ar(in, ~numSpeakers);
        src = GrainIn.ar(
            ~numSpeakers, 
            trig, 
            grainsize + grainrandomizer, 
            src.sum / ~numSpeakers, 
            pan
        );
        fbNodes = {FbNode(1, delaybuffersize)} ! n;
        sigs = n.collect {
            arg i;
            var delay = delays[i];
            var sig;
            delay = delay.clip(0.0001, delaybuffersize);
            sig = src[i % 1] 
            + (fbNodes[i].delay(delay) * fb * 0.85) 
            + (fbNodes[(i+1) % n].delay(delay) * fb * 0.35) 
            + (fbNodes[(i - 1) % n].delay(delay) * fb * 0.35);
            sig = LeakDC.ar(sig);
            sig = HPF.ar(sig, locut);
            fbNodes[i].write(sig);
        };
        sigs = sigs * env * amp;
        sigs = Limiter.ar(sigs, limit);
        sigs = SplayAz.ar(~numSpeakers, sigs, spread: 1, width:~numSpeakers, center: 0);
        Out.ar(out, sigs);
    }).add;

    SynthDef(\grdelay1, {
        arg in, out, amp=0.1, fb=0.1, gate=1, da=2, delay=0.2, maxdelay=1.0, 
        rate=1, jitter=0, freq=20, grainsize=0.2, panMin= -1.0, panMax=1.0;
        var sig, src, env, trig, phase, buf, local, pos, frames, sr, pan;
        env = EnvGen.kr(Env.asr(0.01, 1.0, 0.01), gate: gate, doneAction: da);
        sr = SampleRate.ir;
        frames = max(0, maxdelay * sr).round;
        buf = LocalBuf(frames);
        phase = Phasor.ar(0, rate: 1, start:0, end: frames);
        src = In.ar(in);
        BufWr.ar(src, buf, phase);
        trig = Impulse.kr(freq);
        pos = phase.linlin(0, frames, 0.0, 1.0);
        pan = TRand.kr(panMin, panMax, trig);
        sig = GrainBuf.ar(~numSpeakers, trig, grainsize, buf, rate, pos, pan: pan);
        //feedback loop begin
        local = LocalIn.ar(~numSpeakers);
        jitter = TRand.kr(0, jitter, trig);
        local = DelayL.ar(local + sig, maxdelay, delay + jitter);
        local = LeakDC.ar(local);
        local = local.rotate(1);
        LocalOut.ar(local * fb);
        //end feedback loop
        sig = (sig + local) * env * amp;
        Out.ar(out, sig);
    }).add;

    SynthDef(\dust, {
        var sig, env;
        env = EnvGen.kr(Env.asr(
            \attack.kr(0.01), 
            1, 
            \release.kr(0.01)
        ), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = Dust.ar(\density.kr(10));
        sig = sig * \amp.kr(1) * env;
        sig = PanAz.ar(~numSpeakers, sig, \pan.kr(0), width: \width.kr(2));
        Out.ar(\out.kr, sig);
    }).add;

    SynthDef(\comb, {
        var sig, env;
        env = EnvGen.kr(Env.asr(
            \attack.kr(0.01), 
            1, 
            \release.kr(0.01)
        ), gate: \gate.kr(1), doneAction: \da.kr(2));
        sig = In.ar(\in.kr, ~numSpeakers);
        sig = CombC.ar(sig, \maxDelay.ir(1), \delay.kr(0.1), \decay.kr(1));
        sig = sig * \amp.kr(1) * env;
        Out.ar(\out.kr(0), sig);
    });
        
)
