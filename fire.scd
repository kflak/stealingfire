(
    z = {var trigs, durscale, sig, resfreq;
        trigs = Dust.kr(1);
        durscale = TRand.kr(1, 1.5, trigs);
        resfreq = TExpRand.kr(100, 1000, trigs);
        sig = WhiteNoise.ar * EnvGen.ar(Env.perc(0, 0.02, curve: 0), trigs, timeScale: durscale);
        sig = sig + BPF.ar(sig, resfreq, 20);
        sig = Pan2.ar(sig, TRand.kr(-1.0, 1.0, trigs));
        Out.ar(0, sig);
    }.play;
)
x = {HPF.ar(WhiteNoise.ar, 1000) * LFNoise2.kr(1).squared.squared}.play;
x.free;
y = {WhiteNoise.ar * EnvGen.ar(Env.perc(0, 0.2, curve: 0), Dust.kr(1))}.play;
y.free;
z.free;
a = {LPF.ar(WhiteNoise.ar, 30) * 100}.play;
a.free;
b = {BPF.ar(WhiteNoise.ar, 30, 0.2) * 20}.play;
b.free;
c = {LeakDC.ar(LeakDC.ar(BPF.ar(WhiteNoise.ar, 30, 0.2) * 50).clip2(0.9)) * 0.5}.play;
c.free;


a = Synth(\fire);
b = Synth(\fire,[\bandpassfreq, 1200, \bandpassrq, 1/0.6]);
c = Synth(\fire, [\bandpassfreq, 2600, \bandpassrq, 1/0.4]);
d = Synth(\fire, [\bandpassrq, 1, \hipassfreq, 1000]);

[a, b, c, d].do{|i| i.free};
