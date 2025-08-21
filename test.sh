export PATH=$PATH:/usr/local/bin
#!/bin/bash
value=2
export MATLAB_INPUT_FILE="dump_$value.lammpstrj"
matlab -nodesktop -nosplash -batch "run('getaframe.m')"
matlab -nodesktop -nosplash -batch 'bending_rigidity('$value')'
matlab -nodesktop -nosplash -batch "run('fit_two_regime.m')"
