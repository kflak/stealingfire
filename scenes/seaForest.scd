(
    var group = Group.new();
    var pdefChain, micChain, mic, pdefOut, micOut;
    pdefChain = Chain(s, ~numSpeakers, 
        [
            \comb ! 8, 
            [
                \delay, 8.collect{rrand(0.1, 1.8)}, 
                \decay, 8, 
                \pan, 8.collect{|i| i.linlin(0, 7, -1.0, 1.0)}
            ].lace(48).clump(4)
        ], 
        target: group
    );
    micChain = Chain(s, ~numSpeakers, 
        [
            \comb ! 8, 
            [
                \delay, 8.collect{rrand(0.1, 1.8)}, 
                \decay, 16, 
            ].lace(48).clump(4)
        ], 
        target: group
    );
    mic = Synth(\soundin, [\in, 0, \out, micChain.bus[0], \amp, -12.dbamp]);
    pdefOut = Route(in: pdefChain.bus[1], out: 0, numCh: 2, amp: 1, target: g, addAction: \addToTail);
    micOut = Route(in: micChain.bus[1], out: 0, numCh: 2, amp: 1, target: g, addAction: \addToTail);

    Pdef(\seaForest).fadeTime = 60;
    Pdef(\seaForest, Pbind( \amp, 0)).play;
    Pdef(\seaForest,
        Pbind(
            \instr, \default,
            \midinote, [48, 53, 55],
            \db, -30,
            \pan, Pwhite([-1.0, 1.0]),
            \dur, 1,
            \legato, 0.3,
            \out, pdefChain.bus[0],
        )
    ).play;

    ~seaForestFree = {
        Routine {
            Pdef(\seaForest).stop;
            mic.release(5);
            15.wait;
            [pdefOut, micOut, pdefChain, micChain, group].do(_.free);
        }.play;
    };
)

// ~seaForestFree.();
