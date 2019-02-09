c = Chain(0, 2, chain: [\compressor, \compressor, \limiter, \eq])
d = Chain(0, 2, chain: [[\compressor, \compressor], \limiter, \eq])

//test
c.bus;
c.numCh;
c.dump;
c.free;
c.group;

c.chain[3];
s.plotTree;

(
    Pdef(\test,
        Pbind(
            \instr, \default,
            \db, -30,
            \pan, 0,
            \dur, 1,
            \legato, 0.3,
            \out, c.bus[0],
            \group, c.group
        )
    ).play;
)
Pdef(\test).stop;


c.chain[0].set(\gain, 1);

d.chain[0][1].get(\in, {|i| i.postln});
d.chain;
d.bus;
d.free;

