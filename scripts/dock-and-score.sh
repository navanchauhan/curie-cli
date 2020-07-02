if [ -z "$1" ]
  then
    echo "CSV path not provided! 😠"
	exit
fi
input="$1"
echo "Reading ligands from $input"

targets=()

for file in ./configs/*
do
	targets+=($file)
done

total=$(wc -l $input | awk '{print $1}')
file=1
while IFS= read -r line
do
	mails=$(echo $line | tr "," "\n")
	i=0
	code=""
	echo "Structure $file of $total"
	for a in $mails; do
		i=$((i+1))
		if ((i == 1))
		then
			echo $a
			for target in ${targets[@]}; do
				echo "Docking $(basename $target .txt) and $a"
				vina --config $target --ligand ligands/$a.pdbqt
				sentence=$(awk '{if(NR==2) print $0}' ./ligands/$(echo $a)_out.pdbqt)
				mkdir -p ./Reports/$(basename $target .txt)/$(echo $a)/
				mkdir ./$(basename $target .txt)/
				cp ligands/$(echo $a)_out.pdbqt ./$(basename $target .txt)/
				mv ligands/$(echo $a)_out.pdbqt ./Reports/$(basename $target .txt)/$(echo $a)/$(echo $a).pdbqt
				f=1
				for word in $sentence; do
					if ((f == 4))
					then
						echo "$(echo $a),$word" >> $(basename $target .txt).csv
					fi
					f=$((f+1))
				done
			done
		fi
	done
	file=$((file+1))
done < "$input"


