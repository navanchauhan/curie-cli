#declare -a ligands=()
#for file in ./ligands/*
#do
#    echo $file
#    ligands+=("$(basename $file .pdbqt)")
#done
#
#for i in "${ligands[@]}"; do echo "$i"; done

if [ -z "$1" ]
  then
    echo "CSV path not provided! 😠"
	exit
fi
input="$1"

ligands=()

while IFS= read -r line
do
	mails=$(echo $line | tr "," "\n")
	i=0
	code=""
	for a in $mails; do
		i=$((i+1))
		if ((i == 1))
		then
			code=$(echo "$a")
		fi
		if ((i == 2))
		then
			#ligands+=("./ligands/$a.pdbqt")
            ligands+=("$a")
		fi
	done
done < "$input"

targets=()

for file in ./configs/*
do
	targets+=($file)
done

for a in ${ligands[@]}; do
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
done