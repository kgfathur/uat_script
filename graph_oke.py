import sys, os
import matplotlib.pyplot as plt
import numpy as np

cwd = os.getcwd()

arglen = len(sys.argv)
# print ('arg len:', arglen)                              # just for debug
print ('.')

if (arglen > 1 ):
    log = sys.argv[1]
    param = 'param'
    hostname = 'server'
    # print ('log set by args')                           # just for debug   
else:
    log = cwd + '/log'
    param = 'param'
    hostname = 'server'

# print ('run from: ', cwd)                             # just for debug
# print ('file set to: ', log)                         # just for debug
print ('.')

f = open(log, "r")
if f.mode == 'r':
    log_file = f.read()
    # print (log_file)

files = log_file.split('\n')
try:
    files.remove("")
except:
    print ()

# # ++++++++++++++++++++++++++++++++++++

# # ++++++++++++++++++++++++++++++++++++

# print (files)
for data in files:
    print ('.')
    # print (data)
    datas = data.split(' ')
    # print (datas)
    hostname = datas[1]

    plot = cwd + '/output/' + hostname + '/plots'
    # print ('plot set to: ', plot)                                  # just for debug

    fp = open(plot, "r")
    if fp.mode == 'r':
        plot_file = fp.read()
        # print (plot_file)

        plots = plot_file.split('\n')
        try:
            plots.remove("")
        except:
            print ()
        
        for ploti in plots:
            print ('.', end='')
            # print (ploti)                         # just for debug
            # print ("plotting:", ploti)              # just for debug

            data_oke = list()
            with open(ploti) as fi:
                for di in fi:
                    di = di.rstrip('\n')
                    data_oke.append(di.split(' '))

            # print (data_oke)                          # just for debug
            data_arr = np.array(data_oke)
            iface = ''
            param = data_oke[0][1]

##          prepare to plotting
            fig, ax = plt.subplots(constrained_layout=True)
            
            if param == "cpu":
                # print ("cpu")                         # just for debug
                xlabel = data_arr[2:,0]
                x = np.arange(len(xlabel))
                y_user = data_arr[2:,1].astype('float64')
                y_sys = data_arr[2:,2].astype('float64')
                y_idle = data_arr[2:,3].astype('float64')

                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_user, 'b-', linewidth=3)
                ax.plot(x, y_sys, 'g-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Pesentase (%)', fontsize=14)
                ax.legend(['%usr','%sys'], loc='center left', bbox_to_anchor=(1, 0.5))
                plt.xticks(x, xlabel, rotation=90)

                
                plt.suptitle('Penggunaan CPU pada\nServer %s' % (hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s.png' % (cwd, hostname, hostname, param), dpi=150)

                plt.cla()
                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_idle, 'b-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Pesentase (%)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['%usr','%sys'], loc='center left', bbox_to_anchor=(1, 0.5))

                plt.suptitle('Idle CPU pada Server %s' % (hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s_idle.png' % (cwd, hostname, hostname, param), dpi=150)
                
            elif param == "ram":
                # print ("ram")                         # just for debug
                
                xlabel = data_arr[2:,0]
                x = np.arange(len(xlabel))
                y_kbmem = data_arr[2:,1].astype('float64')
                y_memused = data_arr[2:,2].astype('float64')
                y_kbcache = data_arr[2:,3].astype('float64')

                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_kbmem, 'b-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Kilobyte (kB)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['kbmemused'], loc='center left', bbox_to_anchor=(1, 0.5))

                plt.suptitle('kbmemused pada Server %s' % (hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s_kbmem.png' % (cwd, hostname, hostname, param), dpi=150)

                plt.cla()

                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_memused, 'b-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Kilobyte (kB)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['%memused'], loc='center left', bbox_to_anchor=(1, 0.5))

                titles='%memused'
                plt.suptitle('%s pada Server %s' % (titles, hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s_memused.png' % (cwd, hostname, hostname, param), dpi=150)

                plt.cla()

                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_kbcache, 'b-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Kilobyte (kB)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['kbcached'], loc='center left', bbox_to_anchor=(1, 0.5))

                plt.suptitle('kbcached pada Server %s' % (hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s_kbcache.png' % (cwd, hostname, hostname, param), dpi=150)

                plt.cla()
                
            elif param == "swap":
                # print ("swap")                         # just for debug
                
                xlabel = data_arr[2:,0]
                x = np.arange(len(xlabel))
                y_kbswpused = data_arr[2:,1].astype('float64')

                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_kbswpused, 'b-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Kilobyte (kB)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['kbswpused'], loc='center left', bbox_to_anchor=(1, 0.5))

                plt.suptitle('kbswpused pada Server %s' % (hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s.png' % (cwd, hostname, hostname, param), dpi=150)
                
            elif "net" in param:
                iface=data_oke[0][2]
                # print ("network", iface)                         # just for debug

                xlabel = data_arr[2:,0]
                x = np.arange(len(xlabel))
                y_rxbps = data_arr[2:,2].astype('float64')
                y_txbps = data_arr[2:,3].astype('float64')
                
                ax.spines['top'].set_visible(False)
                ax.spines['right'].set_visible(False)
                ax.grid(True, linestyle='--', linewidth=0.5)

                ax.plot(x, y_rxbps, 'b-', linewidth=3)
                ax.plot(x, y_txbps, 'g-', linewidth=3)
                ax.set_xlabel('Tanggal', fontsize=14)
                ax.set_ylabel('Byte/Second(B/s)', fontsize=14)
                plt.xticks(x, xlabel, rotation=90)
                ax.legend(['rxB/s', 'txB/s'], loc='center left', bbox_to_anchor=(1, 0.5))

                plt.suptitle('Network Rate dalam B/s di %s\npada Server %s' % (iface, hostname), fontsize=18, fontweight='bold')
                plt.savefig('%s/output/%s/%s_%s_%s.png' % (cwd, hostname, hostname, param, iface), dpi=150)
                
            else:
                print ("something wrong!")
            
            plt.clf()
            plt.close()

print ()
# plt.show() # don't uncomment
