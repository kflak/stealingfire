g = Group.new();
h = Group.new();
c = Chain(2, [\compressor, [\attack, 0.3], \limiter, [], \eq, []])

//test
c.bus;
c.numCh;
c.dump;
c.free;
c.group;
c.chain[0].get(\attack, {|i| i.postln});
d.dump;
d.free;
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

