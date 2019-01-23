(
    //global settings for minibees
    ~mbIDs = (1..7);
    ~mbData = IdentityDictionary.new;
    ~mbIDs.collect{|id| ~mbData.put(id, MBData.new(id))};
)
