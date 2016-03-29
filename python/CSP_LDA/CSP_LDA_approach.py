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

    global q
    
    epoch_start = 2.5 * sample_rate
    epoch_end = 4.5 * sample_rate

    q = (epoch_end - epoch_start) # 3 seconds of samples per epoch 

    data_out = np.zeros((index.size, n_channels, q))

    # data_out = np.array([])
    j = 0
    for i in sample.flat:
        data_out[j,:,:] = data_in[:,(i + epoch_start):(i + epoch_end)]
        j+=1

    # data_out has dimensions = [epoch, channels, samples]

    return data_out


def Filter(data_in):
    global sample_rate

    filter_order = 5

    nyq_rate = sample_rate / 2

    f1, f2 = 8.0, 30.0
    w1, w2 = f1 / nyq_rate, f2 / nyq_rate

    # filter_coef = sp.firwin(filter_order, [w1, w2], pass_zero=False) # band pass

    # filter_coef = sp.firwin(filter_order, w2) # low pass


    b, a = sp.butter(filter_order, [f2 / nyq_rate], btype='low')
    data_out = sp.filtfilt(b, a, data_in)
    
    b, a = sp.butter(filter_order, [f1 / nyq_rate], btype='high')
    data_out = sp.filtfilt(b, a, data_out)

    # data_out = sp.lfilter(filter_coef, 1, data_in) # coef A, coef B (denominator), input signal

    # data_out = sp.filtfilt(filter_coef, 1, data_in, padtype = None, padlen =0) # coef A, coef B (denominator), input signal

    # data_out = sp.lfilter(filter_coef, [1.0], data_in) # coef A, coef B (denominator), input signal

    return data_out


def designCSP(dataA, dataB, nb):

    # return v, a, d
    global n_channels
    global q

    cA = np.zeros([dataA.shape[0], n_channels, n_channels])
    cB = np.zeros([dataB.shape[0], n_channels, n_channels])

    # Compute the covariance matrix of each epoch of the same class (A and B)
    for i in range(dataA.shape[0]):
        # cA[i,...] = np.cov(dataA[i,:,:])
        c = np.dot(dataA[i,:,:], dataA[i,:,:].transpose())
        cA[i,...] = c / (np.trace(c) * q) 
        # cA[i,...] = c


    cA_mean = cA.mean(0) # compute the mean of the covariance matrices of each epoch

    for i in range(dataB.shape[0]):
        # cB[i,...] = np.cov(dataB[i,:,:])
        c = np.dot(dataB[i,:,:], dataB[i,:,:].transpose())
        cB[i,...] = c / (np.trace(c) * q) 
        # cB[i,...] = c

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

def applyCSP(W, data_in):

    c = np.dot(data_in, data_in.transpose())
    cIN = c / (np.trace(c) * q) 

    cY = np.dot(W, np.dot(cIN, W.transpose()))

    return cY


def featExtract(data_in):

    feat = np.log(np.diag(data_in))
    return feat

def designLDA(dataA, dataB):

    biasA = np.ones([dataA.shape[0],1])
    biasB = np.ones([dataB.shape[0],1])

    dataA = np.concatenate((biasA, dataA), axis = 1)
    dataB = np.concatenate((biasB, dataB), axis = 1)

    dataA_mean = dataA.mean(axis = 0)
    dataB_mean = dataB.mean(axis = 0)

    Sa = np.dot(dataA.T,dataA) - np.dot(dataA_mean,dataA_mean.transpose())
    Sb = np.dot(dataB.T,dataB) - np.dot(dataB_mean,dataB_mean.transpose())

    W = np.dot(lg.inv(Sa + Sb), (dataA_mean - dataB_mean))

    b = 0.5 * np.dot(W.transpose(), (dataA_mean + dataB_mean))

    return W, b

def applyLDA(W, data_in):

    bias = np.ones([data_in.shape[0],1])
    data_in = np.concatenate((bias, data_in), axis = 1)

    L = np.dot(W, data_in.T) # compute linear scores

    return L

def classifyIF(score, b):

    result = np.zeros(score.shape[0])

    for i in range(score.shape[0]):
        if score[i] < b:
            result[i] = 0
        else:
            result[i] = 1

    return result

def computeAcc(resultsA, resultsB):
    count = 0
    count += resultsA.size - sum(resultsA)
    count += sum(resultsB) 

    acc = count / (resultsA.size + resultsB.size)

    return acc * 100

def nanCleaner(data):
    for i in range(data.shape[0]):
        bad_idx = np.isnan(data[i, ...])
        data[i, bad_idx] = np.interp(bad_idx.nonzero()[0], (~bad_idx).nonzero()[0], data[i, ~bad_idx])

    return data


# Main ------------------------------------------------------------------
# -----------------------------------------------------------------------

channels = range(22) # select only EEG channels (exclude EOG)
CSP_N = 3 # number of CSP neighbours

# EXTRACT EVENTS AND SAVE IT IN A NP ARRAY. COL 1 = TYPE; COL 2 = LATENCY
t_events = np.loadtxt(open(train_events_path,"rb"), skiprows=1, usecols=(1,2))
e_events = np.loadtxt(open(eval_events_path,"rb"), skiprows=1, usecols=(1,2))

# LOAD DATASETS
data_train_raw = load(data_train_path)

data_train_raw = selectChannels(data_train_raw, channels)

#     data_out = np.dot(W, data_in)
data_eval_raw = load(data_eval_path)

data_eval_raw = selectChannels(data_eval_raw, channels)

# Data Filter
# data_train = np.nan_to_num(data_train) # Replace nan values with 0 and inf with finite number
# data_eval = np.nan_to_num(data_eval) # Replace nan values with 0 and inf with finite number
data_train = nanCleaner(data_train_raw)
data_eval = nanCleaner(data_eval_raw)


data_train = Filter(data_train)
data_eval = Filter(data_eval)

epoch_trainA = extractEpoch(data_train, t_events, codeA)
epoch_trainB = extractEpoch(data_train, t_events, codeB)

# Train CSP model
W_CSP = designCSP(epoch_trainA, epoch_trainB, CSP_N)

# Apply CSP and extract Features
featA = np.array([0,0,0,0,0,0])

for i in range(epoch_trainA.shape[0]):
    data_spatialF = applyCSP(W_CSP, epoch_trainA[i,...])
    featA = np.vstack((featA,featExtract(data_spatialF)))

featB = np.array([0,0,0,0,0,0])

for i in range(epoch_trainB.shape[0]):
    data_spatialF = applyCSP(W_CSP, epoch_trainB[i,...])
    featB = np.vstack((featB,featExtract(data_spatialF)))

# Remove initilization row (gambiarra, arrumar depois)
featA = np.delete(featA, 0 , 0)
featB = np.delete(featB, 0 , 0)

# Train LDA model
W_LDA, th = designLDA(featA, featB)

# Apply LDA classifier
LA = applyLDA(W_LDA, featA) # for features of class A
LB = applyLDA(W_LDA, featB) # for features of class A

resultsA = classifyIF(LA, th)
resultsB = classifyIF(LB, th)

Accuracy = computeAcc(resultsA, resultsB)

print "Accuracy: ", Accuracy
