pwd=$(pwd)

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


proteins=()
#for file in ./configs/*
#do
#	proteins+=("$(basename $file .txt)")
#done

proteins+=("6VXX")

#ligands=()
#for file in ./ligands/*
#do
#    ligands+=("$(basename $file .pdbqt)")
#done

for protein in ${proteins[@]}; do
    for ligand in ${ligands[@]}; do
        ###cd $pwd/Reports/$protein/$ligand/
        ###docker run --rm -v ${PWD}:/results -w /results -u $(id -u ${USER}):$(id -g ${USER}) pharmai/plip:latest -f $ligand.pdb  -qpxy
        echo "Saving Protein-Ligand Complex $ligand"
        python3.7 ./scripts/get-best.py -p ./targets/$protein.pdbqt -l ./Reports/$protein/$ligand/$ligand.pdbqt
        fname=$(echo ${protein}_${ligand}.pdb)
        mv best.pdb ./Reports/$protein/$ligand/$fname
        cd $pwd/Reports/$protein/$ligand/
        echo "Processing in PLIP"
        docker run --rm -v ${PWD}:/results -w /results -u $(id -u ${USER}):$(id -g ${USER}) pharmai/plip:latest -f $fname  -qpxy
        cd $pwd
        echo "Generating Images"
        #python3.7 ./scripts/quick-ligand-protein.py -p ./targets/$protein.pdbqt -l ./Reports/$protein/$ligand/$ligand.pdbqt
        #mv closeup-front.png closeup-back.png output-back.png output-front.png ./Reports/$protein/$ligand/
        echo "Generating PDF Report"
        python3.7 ./scripts/makeReport.py --input ./Reports/$protein/$ligand/ > ./Reports/$protein/$ligand/report.md
        cd $pwd/Reports/$protein/$ligand/
        pandoc -V geometry:margin=1in report.md --pdf-engine=xelatex -o $ligand.pdf
        cd $pwd
    done
done