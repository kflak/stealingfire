(
    var chain = [
        [\master, \route],
        [\comp, \compressor],
        [\limit, \limiter],
        [\eq, \eq],
        [\send, \route]
    ];
    ~freeMaster = {
        if(~master.size.isPositive){
            ~master[\synth].do(_.release);
            ~master[\bus].do(_.free);
            ~master[\in].free;
            ~master = nil;
        };
    };
    ~freeMaster.();
    ~master = (
        \in: Bus.audio(s, ~numSpeakers),
        \synth: Dictionary.new(),
        \bus: Bus.audio(s, ~numSpeakers) ! chain.size
        );
    chain.do({|i, idx|
        ~master[\synth].put(i[0], Synth(i[1], target: ~group[\master], addAction: \addToTail));
        if(idx == 0){
            ~master[\synth][i].set(\in, ~master[\in], \out, ~master[\bus][idx]);
        }{
            ~master[\synth][i].set(\in, ~master[\bus][idx - 1], \out, ~master[\bus][idx]);
        };
    });
)
