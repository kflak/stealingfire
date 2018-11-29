(
    ~mbCC[\wind].value;
    ~mbIDs.do{|id, idx| ~mbCC[\windCC][idx].stop; ~mbCC[\windSynth][idx].release};

    ~mbCC[\scrub].value;
    ~mbCC[\scrubIDs].do{|id, idx| ~mbCC[\scrub][idx].stop; ~mbCC[\scrubSynth][idx].release};
)
