(
    var group = Group.new();
    var plingChain, micChain, micBus, plingBus; 
    var lullaSynth, lullaGrain, lullaBuf, lullaChain, lullaBus;
    var mic;
    var pling;

    plingBus = Bus.audio(s, ~numSpeakers);
    plingChain = 8.collect{ Synth(\comb, [\in, plingBus, \out, 0, \delay, rrand(0.1, 1.8)], group) };


    lullaBus = Bus.audio(s, ~numSpeakers);
    lullaBuf = Buffer.read(s, "/home/kf/sc/primemover/audio/lullaby/aiuaiu.aiff");
    lullaChain = Synth(\fold, [\in, lullaBus, \out, 0, \gain, 10.dbamp], group, \addToTail);
    lullaSynth = Synth(\grbuf, [\out, lullaBus, \buf, lullaBuf], group);

    micBus = Bus.audio(s, ~numSpeakers);
    micChain = 8.collect{ Synth( \comb, [\delay, rrand(0.1, 1.8), \decay, 16 ], group) };
    mic = Synth(\soundin, [\in, 0, \out, micBus, \amp, -12.dbamp], group);

    pling = Pbind(
        \instr, \default,
        \midinote, [48, 53, 55],
        \db, -30,
        \pan, Pwhite([-1.0, 1.0]),
        \dur, 1,
        \legato, 0.3,
        \out, plingBus,
        \group, group
    );

    lullaGrain = Pbind (
        \type, \set,
        \id, lullaSynth.nodeID,
        \args, #[\trig, \amp, \pan, \pos, \rate, \grainsize],
        \dur, 0.0125,
        \trig, Prand([1, 0], inf),
        \db, 6,
        \pos, Pwhite(0.0, 1.0),
        \rate, Pwhite(-24, 0).midiratio,
        \pan, Pwhite(-1, 1),
        \grainsize, Pwhite(0.0001, 0.01),
    );

    ~seaForest = Routine {
        Pdef(\seaForest).fadeTime = 20;
        Pdef(\seaForest, Pbind( \amp, 0)).play;
        1.wait;
        Pdef(\seaForest, pling).play;
        20.wait;
        Pdef(\seaForest, Ppar([pling, lullaGrain], inf)).play;
        20.wait;
        Pdef(\seaForest).fadeTime = 10;
        Pdef(\seaForest, lullaGrain).play;
    }.play;

    ~seaForestFree = {
        Routine {
            var releaseTime = 5;
            Pdef(\seaForest).stop;
            Pdef(\seaForest).clear;
            mic.release(releaseTime);
            micChain.do(_.release(releaseTime));
            lullaChain.release(releaseTime);
            lullaSynth.release(releaseTime);
            plingChain.do(_.release(releaseTime));
            releaseTime.wait;
            group.free;
        }.play;
    };
)

// ~seaForestFree.();
// s.meter;
// s.plotTree;

