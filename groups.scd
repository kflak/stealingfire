(
    ~group = Dictionary();
    ~group.put(\instr, Group.after(~group[\in]));
    ~group.put(\fx, Group.after(~group[\instr]));
    ~group.put(\master, Group.after(~group[\fx]));
    ~group.put(\sub, Group.after(~group[\master]));
)
