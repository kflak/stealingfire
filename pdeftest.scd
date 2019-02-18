(
    ~lfobus = 4.collect({Bus.control(s, 1)});
)
(
    ~lfosynth = [
        Synth(\lfosin, [\amp, 100, \offset, 400, \out, ~lfobus[0]], target:~group[\fx]),
        Synth(\lfosin, [\amp, 0.5, \offset, 0, \out, ~lfobus[1]], target:~group[\fx]),
        Synth(\lfosin, [\amp, 2, \offset, -1, \out, ~lfobus[2]], target:~group[\fx]),
        Synth(\lfosin, [\amp, 2, \offset, 0.5, \out, ~lfobus[3]], target:~group[\fx]),
    ];
)
(
    Pdef(\test, 
        Pbind(
            \instr, \default,
            \freq, ~lfobus[0].asMap,
            \ampscale, ~lfobus[1].asMap,
            \amp, Pseg(Pseq([0.001, 1], inf), Pwhite(1, 20, inf), \exp),
            // \amp, 0.1,
            // \pan, ~lfobus[2].asMap,
            \pan, 0,
            // \dur, ~lfobus[3].asMap,
            \dur, 1,
            \legato, 0.3,
            \group, ~group[\instr]
        )
    ).play
)

s.plotTree;
s.boot;

s.meter;
~lfosynth[0].set(\offset, 800);
~lfosynth[0].set(\amp, 176);
~lfosynth[1].set(\amp, 0.1, \offset, 0.7);
~lfosynth[0].set(\freq, 20);
~lfosynth[2].set(\freq, 0.1);
~lfosynth[3].set(\freq, 0.1, \amp, 5, \offset, 2.6);
~lfosynth.do(_.free);

~lfobus[3].index;

Pdef(\test).stop;

(
    ~melody = Pbind(
        \type, \phrase,
        \instrument, \improv,
        \note, Pseq([0, 1, 3, 2, 1, -1, 0, 2, 1, 0]),
        \dur, Pseq([1, 1, 2, 1, 0.5, 2, 1, 0.5, 1, 2])
    )
)

~melody.play;

(
    Pdef(\improv, {|note, dur|
        Pbind(
            \instrument, \default,
            \dur, dur/4,
            \note, Pseries(note, 1),
            \legato, 1
        )
    });
)

(
    (
        \type: \phrase,
        \instrument: \improv,
        \note: 0,
        \amp: 0.1,
        \legato: 0.1,
        \dur: 1
    ).play;

    (
        \note: 5,
        \octave: 4,
        \dur: 1,
        \amp: 0.5
    ).play;
)

b = Buffer.read(s, "/home/kf/sc/primemover/audio/lullaby/aiuaiu.aiff");
b.stop;

(
    Pdef(\lullagrain,
        Pmono(
            \grbuf,
            \dur, 0.05,
            \trig, Pseq([1, 0], inf),
            \db, 0,
            \pos, Pwhite(0.0, 1.0),
            \pan, Pwhite(-1, 1),
            \grainsize, Pwhite(0.01, 0.1),
            \buf, b
        )
    ).play;
)
Pdef(\monotest).stop;


