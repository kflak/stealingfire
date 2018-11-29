(

    ~pushColor = (
        \off: 12,
        \redlo: 13,
        \redhi: 15,
        \amberlo: 29,
        \amberhi: 63,
        \yellow: 62,
        \greenlo: 28,
        \greenhi: 60
    );

    MIDIdef.noteOn(\listen, {|...args|
        args.postln;
    });
)

~push.noteOn(0, 45, 1);
