import numpy as np
from cmath import rect
from pathlib import Path
import pytest

import sys; sys.path.append('/Users/rob/Library/Python/3.11/lib/site-packages')

from stanio.stanio.csv import read_csv
from stanio.stanio.reshape import *

file='/Users/rob/.julia/dev/StanIO/data/test_data/test_data_chain_1.csv'
header, data = read_csv(file)
header

params=parse_header(header)
params
