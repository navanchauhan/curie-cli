if [ -z "$1" ]
  then
    echo "CSV path not provided! 😠"
	exit
fi
input="$1"

echo "Reading ligands from $input"

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
			code=$(echo "$a")
		fi
		if ((i == 2))
		then
			echo "==========================================="
			echo "Generating Structure for $a"
		fi
		if ((i == 3))
		then
			echo "obabel -:"$a" --gen3d -opdbqt -O$code.pdbqt"
			obabel -:"$a" --gen3d -opdbqt -O$code.pdbqt
			echo "==========================================="
		fi
		mv $code.pdbqt ligands/
	done
	file=$((file+1))
done < "$input"
