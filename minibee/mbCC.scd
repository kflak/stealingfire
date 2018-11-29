(
    ~mbCC = IdentityDictionary.new();

    ~mbCC.put(\windIDs, ~mbIDs);
    ~mbCC.put(\windSynth,
        ~mbCC[\windIDs].collect{|id, idx|
            Synth(\cleangate, [
                \buf, ~buffers[\nurme_wind][idx], 
                \loop, 1, 
                \amp, 0.0, 
                \lagup, 0.5,
                \lagdown, 1.5,
                \pan, idx.linlin(0, ~mbIDs.size, 0.0, 1.0),
                \width, ~numSpeakers,
                \da, 2,
                \gate, 1,
                \hipassfreq, 120,
                \out, ~bus[\master],
            ], target: ~group[\instr],)
        };
    );
    ~mbCC.put(\windCC,
        ~mbCC[\windIDs].collect{|id, idx|
            TaskProxy.new({
                var amp, lowpassfreq, fx1lvl;
                var synth = ~mbCC[\windSynth][idx];
                var delta, x, y;
                inf.do{
                    delta = ~mbData[id].delta;
                    x = ~mbData[id].x;
                    y = ~mbData[id].y;
                    amp = (delta * 35.0).clip(0.0, 1.0);
                    lowpassfreq = x * 10000.0 + 40;
                    fx1lvl = (delta * 15.0).clip(0.0, 1.0);
                    synth.set(\amp, amp, \lowpassfreq, lowpassfreq, \fx1lvl, fx1lvl);
                    ~mbResamplingFreq.reciprocal.wait;
                };
            }).play;
        };
    );

    ~mbCC.put(\scrubIDs, ~mbIDs);
    ~mbCC.put(\scrubSynth, 
        ~mbCC[\scrubIDs].collect{|id, idx|
            Synth(\scrub, [
                \buf, ~buffers[\song][idx],
                \amp, 0.0, 
                \grainsize, 1,
                \lagup, 1,
                \lagdown, 1.5,
                \gate, 1,
                \hipassfreq, 120,
                \out, ~bus[\master],
            ], target: ~group[\instr],)
        };
    );

    ~mbCC.put(\scrubCC,
        ~mbCC[\scrubIDs].collect{|id, idx|
            TaskProxy.new({
                var amp, pos, fx1lvl;
                var synth = ~mbCC[\scrubSynth][idx];
                var delta, x, y;
                inf.do{
                    delta = ~mbData[id].delta;
                    x = ~mbData[id].x;
                    y = ~mbData[id].y;
                    amp = (delta * 6.0).clip(0.0, -12.dbamp);
                    if (amp < 0.1){amp = 0};
                    fx1lvl = (delta * 6.0).clip(0.0, -12.dbamp);
                    pos = x;
                    synth.set(\amp, amp, \pos, pos, \fx1lvl, fx1lvl);
                    ~mbResamplingFreq.reciprocal.wait;
                };
            }).play;
        };
    )
)
