# one byte opcode
cat 382n_cs_lit_one.txt |
awk '
	BEGIN {
		FS = "\t";
	}
	{
		if(NR >= 3)
		{
			for(i = 4;i <= NF;i++)
			{
				if($i == "") printf("0 ");
				else printf("%d ", $i);
			}
			printf("\n");
		}
	}
' > temp

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_01.list

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_00.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_11.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_10.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_21.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_20.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_31.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_30.list

cat temp |
awk '
	{
		if(NR >= 129 && NR <= 160)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_41.list

cat temp |
awk '
	{
		if(NR >= 129 && NR <= 160)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_40.list

cat temp |
awk '
	{
		if(NR >= 161 && NR <= 192)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_51.list

cat temp |
awk '
	{
		if(NR >= 161 && NR <= 192)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_50.list

cat temp |
awk '
	{
		if(NR >= 193 && NR <= 224)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_61.list

cat temp |
awk '
	{
		if(NR >= 193 && NR <= 224)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_60.list

cat temp |
awk '
	{
		if(NR >= 225 && NR <= 256)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_71.list

cat temp |
awk '
	{
		if(NR >= 225 && NR <= 256)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map1_70.list

# two byte opcode
cat 382n_cs_lit_two.txt |
awk '
	BEGIN {
		FS = "\t";
	}
	{
		if(NR >= 3)
		{
			for(i = 4;i <= NF;i++)
			{
				if($i == "") printf("0 ");
				else printf("%d ", $i);
			}
			printf("\n");
		}
	}
' > temp

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_01.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_00.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_11.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_10.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_21.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_20.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_31.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 97 && NR <= 128)
		{
			#print NR, $0;
			#if(NR == 113)
			{
				for(i = 65;i <= 128;i++) printf("%d", $i);
					printf("\n");
			}
		}
	}
' > op_map2_30.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 129 && NR <= 160)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_41.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 129 && NR <= 160)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_40.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 161 && NR <= 192)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_51.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 161 && NR <= 192)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_50.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 193 && NR <= 224)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_61.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 193 && NR <= 224)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_60.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 225 && NR <= 256)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_71.list

cat temp |
awk '
	BEGIN {
		FS = " ";
	}
	{
		if(NR >= 225 && NR <= 256)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map2_70.list




# ext opcode map

cat 382n_cs_lit_ext.txt | 
awk '
	BEGIN {
		FS = "\t";
	}
	{
		if(NR >= 3)
		{
			for(i = 6;i <= NF;i++)
			{
				if($i == "") printf("0 ");
				else printf("%d ", $i);
			}
			printf("\n");
		}
	}
' > temp

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_01.list

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_00.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_11.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_10.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_21.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_20.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_31.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_ext_30.list


# special ucode map

cat 382n_cs_lit_split.txt |
awk '
	BEGIN {
		FS = "\t";
	}
	{
		if(NR >= 3)
		{
			for(i = 4;i <= NF;i++)
			{
				if($i == "") printf("0 ");
				else printf("%d ", $i);
			}
			printf("\n");
		}
	}
'  > temp

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_01.list

cat temp |
awk '
	{
		if(NR >= 1 && NR <= 32)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_00.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_11.list

cat temp |
awk '
	{
		if(NR >= 33 && NR <= 64)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_10.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_21.list

cat temp |
awk '
	{
		if(NR >= 65 && NR <= 96)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_20.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 1;i <= 64;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_31.list

cat temp |
awk '
	{
		if(NR >= 97 && NR <= 128)
		{
			for(i = 65;i <= 128;i++) printf("%d", $i);
			printf("\n");
		}
	}
' > op_map_split_30.list

