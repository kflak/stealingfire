(
    ~projectfolder = "/home/kf/sc/tbo";
    ~numSpeakers = 2;
    ~numSubs = 0;
    ~hasQmidiNet = false;
    ~hasPush = false;

    MIDIClient.init;
    MIDIClient.sources.do{|device, idx|
        if(device.name.contains("Ableton Push MIDI 2")){
            MIDIIn.connect(idx, device);
            "% connected\n".postf(device.name);
            ~hasPush = true;
            ~push = MIDIOut.newByName("Ableton Push", "Ableton Push MIDI 2");
            ~pushuid = device.uid;
        }
    };

    Buffer.freeAll;
    s.quit;
    s.options.numInputBusChannels = 8;
    s.options.numOutputBusChannels = ~numSpeakers + ~numSubs;
    //make sure there's enough memory for the delay lines
    s.options.memSize = 2**20;
    //make sure there's enough buffers
    s.options.numBuffers = 2048;
    //make sure there's enough internal buffers
    s.options.numWireBufs = 256;
    s.latency  = 0.02;
    s.waitForBoot(
        {
            "Start".postln;
            //load synthdefs
            this.executeFile((~projectfolder+/+"sdefs.scd").standardizePath);
            "SynthDefs done".postln;

            ////set up groups
            //this.executeFile((~projectfolder+/+"groups.scd").standardizePath);
            //"groups.scd done".postln;

            // // set up minibee global variables
            // this.executeFile((~projectfolder+/+"minibee/mbGlob.scd").standardizePath);
            // "mbGlob.scd done".postln;

            // set up mbDeltaTrigs
            // this.executeFile((~projectfolder+/+"minibee/mbDeltaTrigs.scd").standardizePath);
            // "mbDeltaTrigs.scd done".postln;

            // in the end, load the cues and pray that it works
            // this.executeFile((~projectfolder+/+"cues.scd").standardizePath);
            // "cues.scd done".postln;
        }
    );
)
