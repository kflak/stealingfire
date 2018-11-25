(
    var cues = [
    ];

    var cuelist = CuePlayer.new;

    // cuelist.hook = {|c| text.string = "Next cue:\n"++titles[c.current+1]};

    cues.do{ |item| 
        var file = PathName.new(~projectfolder+/+"cues"+/+item).fullPath;
        cuelist.add(file);
        postf("% added to cuelist\n", file);
    };

    cuelist.gui(
        monitorInChannels: s.options.numInputBusChannels,
        monitorOutChannels: s.options.numOutputBusChannels,
        options:(
            shortcuts:true,
            metronome: false,
        )
    );
)
