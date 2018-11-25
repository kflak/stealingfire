(
    //  [track, initial_amplitude, synth, outbus, target_group]
    ~tr = [	
        [\jpverb, 1.0, \jpverb,	\master, \fx], 
        [\grdelay, 1.0, \grdelay, \master, \fx], 
        [\grdelayMedium, -6.dbamp, \grdelay, \master, \fx], 
        [\grdelayLong, -6.dbamp, \grdelay, \master, \fx], 
        [\master, 1.0, \chstrip, 0, \master], 
    ];

    //create audio bus dictionary
    ~bus = IdentityDictionary();

    //set up fx channels and channelstrips
    ~ch = IdentityDictionary();

    //instrument and mixer tracks
    ~tr.do{|item|
        item.postln;	
        //create input audio bus for each track
        ~bus.put(item[0], Bus.audio(s, ~numSpeakers));
        //create channel synths...
        ~ch.put(
            item[0], 
            Synth(
                item[2], 
                [ 
                    \in, ~bus[item[0]], 
                    \out, ~bus[item[3]], 
                    \amp, item[1],
                ], 
                target: ~group[item[4]]
            )
        );
    };

    //microphones
    ~mic = ~numMics.collect{|idx|
        postf("mic% %\n", idx);
        //create channel synths...
        Synth(\soundin, 
            [ 
                \in, idx + ~micOffset,
                \lvlin, -6.dbamp,
                \lvlout, -6.dbamp,
                \out, ~bus[\master],
                \fx1, ~bus[\jpverb],
                \fx1lvl, 0,
                \fx2, ~bus[\grdelayMedium],
                \fx2lvl, 0,
                \fx3, ~bus[\grdelayLong],
                \fx3lvl, 0,
                \gate, 0,
                \da, 0,
            ], 
            target: ~group[\in]
        )
    };

    //subs
    ~numSubs.do{|item, idx|
        postf("sub% %\n", idx, item);
        //create channel synths...
        ~ch.put(
            (\sub++idx).asSymbol,
            Synth(\mixToMono, 
                [ 
                    \in, 0,
                    \amp, -6.dbamp,
                    \out, ~subBus + idx,
                    \gate, 1,
                    \da, 2,
                ], 
                target: ~group[\sub]
            )
        );
    };

    //set additional synth args
    ~ch[\tens].set(
        \compgain, 2.dbamp, 
        \ratio, 2, 
        \limit, 0.dbamp, 
        \locut, 50
    );
    ~ch[\fast].set(
        \compgain, 12.dbamp, 
        \ratio, 16, 
        \thresh, -10.dbamp, 
        \limit, 0.dbamp, 
        \locut, 50
    );
    ~ch[\crunchy].set( 
        \compgain, 7.dbamp, 
        \ratio, 8, 
        \hishelfdb, -6,
        \thresh, -5.dbamp, 
        \limit, 0.dbamp, 
        \locut, 100
    );
    ~ch[\fm].set(
        \compgain, 0.dbamp, 
        \ratio, 8, 
        \limit, 0.dbamp, 
        \thresh, -12.dbamp, 
        \locut, 40
    );
    ~ch[\cello].set( 
        \peakfreq, 600, 
        \peakdb, -6
    );
    ~ch[\heartbeat].set(
        \gate, 1,
        \attack, 90
    );
    ~ch[\breath].set(
        \gate, 1,
        \attack, 90
    );
    ~ch[\sineGrain].set(
        \compgain, 0.dbamp, 
        \ratio, 4, 
        \limit, 0.dbamp, 
        \thresh, -12.dbamp, 
        \locut, 80
    );
    ~ch[\grdelay].set(
        \lo_cut, 40, 
        \density, 20, 
        \grain_size, 0.001, 
        \grain_size_rand, 0.3, 
        \min_delay, 0.3, 
        \max_delay, 1.5, 
        \fb, 0.05, 
        \mod_freq, 0.05, 
        \mod_depth, 0.1
    );
    ~ch[\grdelayMedium].set(
        \lo_cut, 40, 
        \density, 10, 
        \grain_size, 1.0, 
        \grain_size_rand, 0.3, 
        \min_delay, 1.0, 
        \max_delay, 4.0, 
        \fb, 0.3, 
        \mod_freq, 0.05, 
        \mod_depth, 0.1
    );
    ~ch[\grdelayLong].set(
        \lo_cut, 40, 
        \density, 10, 
        \grain_size, 1.0, 
        \grain_size_rand, 0.3, 
        \min_delay, 1.0, 
        \max_delay, 4.0, 
        \fb, 0.5, 
        \mod_freq, 0.05, 
        \mod_depth, 0.1
    );
    ~ch[\master].set(
        \compgain, 8.dbamp, 
        \ratio, 4, 
        \limit, -0.3.dbamp, 
        \thresh, -3.dbamp, 
        \locut, 40,
    );
)

// (
//     ~ch[\mic0].set(\gate, 0);
//     ~ch[\mic1].set(\gate, 0);
//     ~ch[\mic2].set(\gate, 0);
//     ~ch[\mic3].set(\gate, 0);
// )
// (
//     ~ch[\mic0].set(\gate, 1);
//     ~ch[\mic1].set(\gate, 1);
//     ~ch[\mic2].set(\gate, 1);
//     ~ch[\mic3].set(\gate, 1);
// )