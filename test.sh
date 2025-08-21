export PATH=$PATH:/usr/local/bin
#!/bin/bash
start=2
end=7
step=0.1
record_file="results.txt"

>$record_file #clear all

for value in $(seq $start $step $end);do
	formatted_value=$(printf "%.1f" $value)
	echo "Running with --args $formatted_value"
	#running python command
	python3 test.py --args $formatted_value
	#running LAMMPS command
	#mpirun -np 8 lmp_mpi -in in.flat_membrane
	dump_file="msd_results_$formatted_value.txt"
	dump_file_r="boxsize_${formatted_value}.txt"
	#running python command
	#diffusion=$(python3 calculate_diffusion.py --file $dump_file)
	#r_0tension=$(python3 2.py --file $dump_file_r)
	#python3 data.py --file $dump_file
	export MATLAB_INPUT_FILE="dump_$formatted_value.lammpstrj"
	matlab -nodesktop -nosplash -batch "getaframe()"
	export MATLAB_PARAM= "a_$formatted_value"
	matlab -nodesktop -nosplash -batch "bending_rigidity()"
	matlab_output=$(matlab -nodesktop -nosplash -batch "fit_two_regime()" 2>&1)
	tension=$(echo "$matlab_output" | grep "TENSION=" | cut -d'=' -f2)
	bending=$(echo "$matlab_output" | grep "BENDING=" | cut -d'=' -f2)

	echo "$formatted_value $tension $bending" >> $record_file
done
