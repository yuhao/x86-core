for j in 0 1 2 3 # which dram bank
do
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 # which line
	do
		for k in 0 1 2 3 # byte offset
		do
			cat $1.img |
			awk -v I=$i -v J=$j -v K=$k '
				BEGIN{
					FS = " ";
				}
				{
					if(NR > (J * 2048) + I * 128 && NR <= ((J * 2048) + (I + 1) * 128)) print($(5-K));
				}
			' > img/img${j}_${i}_${k}.list
		done
	done
done
