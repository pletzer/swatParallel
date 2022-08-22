import defopt
import seaborn as sn
import re
import glob
import subprocess
from matplotlib import pylab
import numpy as np

def main(*, jobid: int=-1):
    """
    Get the execution times of each worker
    :param jobid jobid
    """

    data = {
        'worker': [],
        'time_s': []
    }

    result = subprocess.run(['sacct', '-j', f'{jobid}'], capture_output=True, text=True)

    # parse the result
    for line in result.stdout.split('\n'):
        m = re.match(r'^' + f'{jobid}' + r'_(\d+)\s+swt\-', line)
        if m:
            worker_index = int(m.group(1))
            time_str = line.split()[3]
            hh, mm, ss = time_str.split(':')
            exec_time = int(hh)*3600 + int(mm)*60 + int(ss)
            data['worker'].append(worker_index)
            data['time_s'].append(exec_time)

    print(data)
    tot_time = np.sum(data["time_s"])
    max_time = max(data["time_s"])
    print(f'cum time s: {tot_time}')
    sn.barplot(x='worker', y='time_s', data=data)
    pylab.title(f'{jobid} time: cum {tot_time}s max {max_time}s')
    pylab.show()

if __name__ == '__main__':
    defopt.run(main)

