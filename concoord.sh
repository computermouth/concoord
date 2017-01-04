#!/bin/bash

for ARG in "$@"
do

	NUM_PATHS=$(xmlstarlet sel -t -v "count(//_:path)" $ARG)

	FILENAME=$(xmlstarlet sel -t -v "//_:svg/@sodipodi:docname" $ARG | sed 's/.svg//g')

	ARR_PATHNAMES=($(xmlstarlet sel -t -v "//_:svg/_:g[_:path]/@inkscape:label" $ARG))

	TEMP_PATHCOLORS=$(xmlstarlet sel -t -v "//_:svg/_:g/_:path/@style" $ARG | grep -oh "fill:#......" |sed 's/fill:#//g')
	readarray -t ARR_PATHCOLORS <<<"$TEMP_PATHCOLORS"

	TEMP_PATHD=$(xmlstarlet sel -t -v "//_:svg/_:g/_:path/@d" $ARG | sed 's/M //g' | sed 's/m //g' | sed 's/ Z//g' | sed 's/ z//g')
	readarray -t ARR_PATHD <<<"$TEMP_PATHD"

	if [ ! -f ${FILENAME}.h ]; then

		for ((i=0; i<${NUM_PATHS}; i++))
		do
			TMPX=$(echo ${ARR_PATHD[$i]} | sed 's/,[^ ]*/,/g' | rev | cut -c 2- | rev)
			TMPY=$(echo ${ARR_PATHD[$i]} | rev | sed 's/,[^ ]*//g' | rev | sed 's/ /, /g')
			TMPX=$(echo ${TMPX} | sed 's/\.5//g')
			TMPY=$(echo ${TMPY} | sed 's/\.5//g')
			POINTS=$(echo ${ARR_PATHD[$i]} | grep -o ',' | wc -l)
			TMP_CR=$(echo ${ARR_PATHCOLORS[$i]} | cut -c 1-2)
			TMP_CB=$(echo ${ARR_PATHCOLORS[$i]} | cut -c 3-4)
			TMP_CG=$(echo ${ARR_PATHCOLORS[$i]} | cut -c 5-6)
			TMP_CR=$(echo $((16#${TMP_CR})))
			TMP_CG=$(echo $((16#${TMP_CG})))
			TMP_CB=$(echo $((16#${TMP_CB})))
			echo "NP_SH("
			echo -e "\t${ARR_PATHNAMES[$i]},"
			echo -e "\tNP_VS(${POINTS}),"
			echo -e "\tNP_VX(${POINTS}),"
			echo -e "\tNP_VY(${POINTS}),"
			echo -e "\tNP_AX(${TMPX}),"
			echo -e "\tNP_AY(${TMPY}),"
			echo -e "\tNP_CO(${TMP_CR}, ${TMP_CB}, ${TMP_CG}, 255),"
			echo -e ");\n"
			
			echo "NP_SH(" >> ${FILENAME}.h
			echo -e "\t${ARR_PATHNAMES[$i]}," >> ${FILENAME}.h
			echo -e "\tNP_VS(${POINTS})," >> ${FILENAME}.h
			echo -e "\tNP_VX(${POINTS})," >> ${FILENAME}.h
			echo -e "\tNP_VY(${POINTS})," >> ${FILENAME}.h
			echo -e "\tNP_AX(${TMPX})," >> ${FILENAME}.h
			echo -e "\tNP_AY(${TMPY})," >> ${FILENAME}.h
			echo -e "\tNP_CO(${TMP_CR}, ${TMP_CB}, ${TMP_CG}, 255)" >> ${FILENAME}.h
			echo -e ");\n" >> ${FILENAME}.h
		done

	else
		echo "File ${FILENAME}.h already exists, quitting."
		exit 1
	fi

done
