import biosig # used to import gdf data files
import numpy as np # numpy - used for array and matrices operations
import math as math # used for basic mathematical operations

# DATASETS PATH
data_train_path = "/arquivos/Documents/eeg_data/doutorado_cleison/A01T.gdf"
data_eval_path = "/arquivos/Documents/eeg_data/doutorado_cleison/A01E.gdf"
# filename = "/arquivos/downloads/testpport_1to100.bdf"

# EVENTS INFO PATH
train_events_path = "/arquivos/Documents/eeg_data/doutorado_cleison/train_events/A01T.csv"
eval_events_path = "/arquivos/Documents/eeg_data/doutorado_cleison/true_labels/A01E.csv"

# DATASET VARIABLES:
codeA = 769 # Class 1 label = left hand mov
codeB = 770 # Class 2 label = right hand mov

global sample_rate = 0;
n_channels = 25;

q = 750 # Number of samples per extracted epoch


def load(fname):
    # Loads GDF competition data
    HDR = biosig.constructHDR(0, 0)
    HDR = biosig.sopen(fname, 'r', HDR)

    #   turn off all channels 
    #    for i in range(HDR.NS):
    #        HDR.CHANNEL[i].OnOff = 0

    #   turn on specific channels 
    #    HDR.CHANNEL[0].OnOff = 1
    #    HDR.CHANNEL[1].OnOff = 1
    #    HDR.CHANNEL[HDR.NS-1].OnOff = 1
    sample_rate = HDR.SampleRate
    data = biosig.sread(0, HDR.NRec, HDR)

    biosig.sclose(HDR)
    biosig.destructHDR(HDR)

    return data

def extractEpoch(data_in,labels,code):

    index = np.array(np.where(labels[:,0] == code))
    sample = np.floor (1e-6 * labels[index,1] * sample_rate)

    # data_out = np.zeros((n_channels, q, index.size))

    data_out = np.array([])

    for i in sample.flat:
        # print i
        np.append(data_out, data_in[:,i:(i+q)], axis=2)

    return data_out



# Main -----
# ----------

# EXTRACT EVENTS AND SAVE IT IN A NP ARRAY. COL 1 = TYPE; COL 2 = LATENCY
t_events = np.loadtxt(open(train_events_path,"rb"), skiprows=1, usecols=(1,2))
e_events = np.loadtxt(open(eval_events_path,"rb"), skiprows=1, usecols=(1,2))

# LOAD DATASETS
data_train = load(data_train_path)
data_eval = load(data_eval_path)

# epoch_trainA = extractEpoch(data_train, t_events, codeA)
# epoch_trainB = extractEpoch(data_train, t_events, codeB)


