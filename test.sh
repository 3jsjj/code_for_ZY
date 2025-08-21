export PATH=$PATH:/usr/local/bin
#!/bin/bash
start=2
end=7
step=0.1
record_file="results.txt"

>$record_file #clear all

for value in $(seq $start $step $end);do
	echo "Running with --args $value"
	#running python command
	python3 test.py --args $value
	#running LAMMPS command
	mpirun -np 8 lmp_mpi -in in.flat_membrane
	dump_file="msd_results_$value.txt"
	dump_file_r="boxsize_${value}.txt"
	#running python command
	#diffusion=$(python3 calculate_diffusion.py --file $dump_file)
	#r_0tension=$(python3 2.py --file $dump_file_r)
	#python3 data.py --file $dump_file
	export MATLAB_INPUT_FILE="dump_$value.lammpstrj"
	matlab -nodesktop -nosplash -batch "run('getaframe.m')"
	matlab -nodesktop -nosplash -batch "bending_rigidity('a_$value')"
	matlab -nodesktop -nosplash -batch "fit_two_regime('b_$value')"


	echo "$value $tension" >> $record_file
done
