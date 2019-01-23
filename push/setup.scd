(
    ~pPad  = (36..99).clump(8); //rgb
    ~pTopKnob  = (71..79);
    ~pTopKnobNote = (0..8);
    ~pLeftKnob  = (14..15);
    ~pLeftKnobNote = [10, 9];
    ~pFirst= (20..27); //rg
    ~pSecond= (102..109); //rgb
    ~pTimeRes = (36..43); //rg
    ~pBtn = (
        play: 85,
        rec: 86,
        new: 87,
        dupl: 88,
        auto: 89,
        fix: 90,
        quant: 116,
        double: 117,
        delete: 118,
        undo: 119,
        metro: 9,
        tap: 3,
        down: 47,
        left: 44,
        right: 45,
        up: 46,
        select: 48,
        shift: 49,
        note: 50,
        session: 51,
        addfx: 52,
        addtrack: 53,
        octavedown: 54,
        octaveup: 55,
        repeat: 56,
        accent: 57,
        scales: 58,
        user: 59,
        mute: 60,
        solo: 61,
        forward: 62,
        back: 63,
        device: 110,
        browse: 111,
        track: 112,
        clip: 113,
        volume: 114,
        pan: 115
    );
    ~pRGB = (
        \off: 0,
        \white: 3,
        \red: 5,
        \orange: 9,
        \yellow: 13,
        \green: 87,
        \blue: 41,
    );
    ~pRG = (
        \off: 0,
        \redlo: 1,
        \red: 4,
        \orangelo: 7,
        \orange: 10,
        \yellowlo: 13,
        \yellow: 16,
        \greenlo: 19,
        \green: 22,
    );
    ~pBtnLed = (
        \off: 0,
        \on: 4
    );

    MIDIdef.polytouch(\listenA, {|...args|
        args.postln;
    }, ~pPad[0..7].flatten, srcID: ~pushuid);

    MIDIdef.noteOn(\listen, {|...args|
        args.postln;
    });

    MIDIdef.cc(\listenB, {|...args|
        args.postln;
    }, srcID: ~pushuid);

    MIDIdef.cc(\knobs, {|val, knob|
        if(val > 63){val = val - 128;};
        [val, knob].postln;
    }, ~pTopKnob++~pLeftKnob, srcID: ~pushuid);

    MIDIdef.noteOn(\knobOn, {|val, knob|
        [val, knob].postln;
    }, ~pTopKnob++~pLeftKnob, srcID: ~pushuid);

    MIDIdef.noteOff(\knobOff, {|val, knob|
        [val, knob].postln;
    }, ~pTopKnob++~pLeftKnob, srcID: ~pushuid);

    MIDIdef.noteOn(\padOn, {|val, pad|
        [val, pad].postln;
    }, ~pPad.flatten, srcID: ~pushuid);

    MIDIdef.noteOff(\padOff, {|val, pad|
        [val, pad].postln;
    }, ~pPad.flatten, srcID: ~pushuid);

    ~pFirst.do{|i| ~push.control(0, i, ~pRG[\green])};
    ~pSecond.do{|i| ~push.control(0, i, ~pRGB[\red])};
    ~pTimeRes.do({|i| ~push.control(0, i, ~pRG[\yellow])});
    ~pPad.flatten.do{|i| ~push.noteOn(0, i, ~pRGB[\orange])};
    ~pBtn.do{|i| ~push.control(0, i, ~pBtnLed[\on])};
)
