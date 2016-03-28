import biosig # used to import gdf data files
import numpy as np # numpy - used for array and matrices operations
import math as math # used for basic mathematical operations

# Filter design Libs: http://docs.scipy.org/doc/scipy/reference/signal.html
# from scipy.signal import firwin # Design a fir filter
# from scipy.signal import freqz # Plots filter frequency response
# from scipy.signal import lfilter # Applies designed filter to data
# from scipy.signal import filtfilt # Applies designed filter to data
# from scipy.signal import butter # Applies designed filter to data

import scipy.signal as sp
import scipy.linalg as lg

from pylab import plot, show, pi

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

sample_rate = 0;
n_channels = 25;

q = 750 # Number of samples per extracted epoch


def load(fname):

    global sample_rate
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


def selectChannels(data_in, channels):
    
    # Select channels
    data_out = data_in[channels,:]

    # Update number of channels
    global n_channels
    n_channels = data_out.shape[0]

    return data_out


def extractEpoch(data_in,labels,code):

    index = np.array(np.where(labels[:,0] == code))
    # sample = np.floor (1e-6 * labels[index,1] * sample_rate)

    sample = labels[index,1] # extract the sample position which corresponds to the beggining of each trial

    data_out = np.zeros((index.size, n_channels, q))

    # data_out = np.array([])
    j = 0
    for i in sample.flat:
        # print i
        # np.append(data_out, data_in[:,i:(i+q)], axis=2)
        data_out[j,:,:] = data_in[:,i:(i+q)]
        j+=1

    # data_out has dimension = [epoch, channels, samples]

    return data_out


def Filter(data_in):
    global sample_rate

    filter_order = 15

    nyq_rate = sample_rate / 2

    f1, f2 = 8.0, 30.0
    w1, w2 = f1 / nyq_rate, f2 / nyq_rate

    # filter_coef = sp.firwin(filter_order, [w1, w2], pass_zero=False) # band pass

    filter_coef = sp.firwin(filter_order, w2) # low pass


    # b, a = sp.butter(filter_order, [f2 / nyq_rate], btype='low')
    # data_out = filtfilt(b, a, data_in)
    
    # b, a = sp.butter(filter_order, [f1 / nyq_rate], btype='high')
    # data_out = sp.filtfilt(b, a, data_out)

    # data_out = sp.lfilter(filter_coef, 1, data_in) # coef A, coef B (denominator), input signal

    # data_out = sp.filtfilt(filter_coef, 1, data_in, padtype = None, padlen =0) # coef A, coef B (denominator), input signal

    data_out = sp.lfilter(filter_coef, [1.0], data_in) # coef A, coef B (denominator), input signal

    return data_out


def designCSP(dataA, dataB, nb):

    # return v, a, d
    global n_channels

    cA = np.zeros([dataA.shape[0], n_channels, n_channels])
    cB = np.zeros([dataB.shape[0], n_channels, n_channels])

    # Compute the covariance matrix of each epoch of the same class (A and B)
    for i in range(dataA.shape[0]):
        # cA[i,...] = np.cov(dataA[i,:,:])
        cA[i,...] = np.dot(dataA[i,:,:], dataA[i,:,:].transpose())

    cA_mean = cA.mean(0) # compute the mean of the covariance matrices of each epoch

    for i in range(dataB.shape[0]):
        # cB[i,...] = np.cov(dataB[i,:,:])
        cB[i,...] = np.dot(dataB[i,:,:], dataB[i,:,:].transpose())

    cB_mean = cB.mean(0) # compute the mean of the covariance matrices of each epoch

    lamb, v = lg.eig(cA_mean + cB_mean) # eigvalue and eigvector decomposition

    lamb = lamb.real # return only real part of eigen vector

    index = np.argsort(lamb) # returns the index of array lamb in crescent order

    index = index[::-1] # reverse the order, now index has the positon of lamb in descendent order

    lamb = lamb[index] # sort the eingenvalues in descendent order

    v = v.take(index, axis=1) # the same goes for the eigenvectors along axis y

    Q = np.dot(np.diag(1 / np.sqrt(lamb)), v.transpose()) # whitening matrix computation

    D, V = lg.eig(np.dot(Q, np.dot(cA_mean, Q.transpose()))) # eig decomposition of whiten cov matrix

    W_full = np.dot(V.transpose(), Q)

    W = W_full[:nb,:] # select only the neighbours defined in NB; get the first 3 eigenvectors
    W = np.vstack((W,W_full[-nb:,:])) # get the three last eigenvectors

    return W

# def applyCSP(W, data_in):

#     data_out = np.dot(W, data_in)





    

# Main -----
# ----------

channels = range(22) # select only EEG channels (exclude EOG)

# EXTRACT EVENTS AND SAVE IT IN A NP ARRAY. COL 1 = TYPE; COL 2 = LATENCY
t_events = np.loadtxt(open(train_events_path,"rb"), skiprows=1, usecols=(1,2))
e_events = np.loadtxt(open(eval_events_path,"rb"), skiprows=1, usecols=(1,2))

# LOAD DATASETS
data_train_raw = load(data_train_path)

data_train = selectChannels(data_train_raw, channels)
def applyCSP(W, data_in):

#     data_out = np.dot(W, data_in)
data_train = np.nan_to_num(data_train) # Replace nan values with 0 and inf with finite number

data_eval_raw = load(data_eval_path)

data_eval = selectChannels(data_eval_raw, channels)

data_eval = np.nan_to_num(data_eval) # Replace nan values with 0 and inf with finite number

epoch_trainA = extractEpoch(data_train, t_events, codeA)
epoch_trainB = extractEpoch(data_train, t_events, codeB)

W = designCSP(epoch_trainA, epoch_trainB, 3)

# Y = applyCSP(W, )


