import matplotlib.pyplot as plt # for plot

tempBuff = range(0,1024)
audioBuff = [0] * 1024

print len(tempBuff), len(audioBuff)

plt.plot(tempBuff, audioBuff, linewidth=3)
# plt.draw()

plt.show()