mytrainset = io_loadset('bcilab:/userdata/test/imag.set');

myapproach = {'CSP', 'SignalProcessing',{'EpochExtraction',{'EventTypes',{'S  1','S  2'}}}};

[loss,model] = bci_train({'data',mytrainset, 'approach',myapproach});

bci_visualize(model);