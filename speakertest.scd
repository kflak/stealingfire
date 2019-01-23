(
    fork{ var dur = 1;
        ~numSpeakers.do{|i, idx| 
            {Out.ar(
                idx, SinOsc.ar(880) * XLine.kr(0.1, 0.00001, dur, doneAction: 2)
            )}.play;
            dur.wait
        };
        // test subs, sum of headphone outputs.
        ~numSubs.do{|i, idx|
            {Out.ar(
                ~numSpeakers + i, SinOsc.ar(88) * XLine.kr(0.3, 0.00001, 4, doneAction: 2)
            )}.play;
            1.wait;
        }
    };
)


