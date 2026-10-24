#!/bin/bash

cd /data/hugo/GENOMES_ESKAPE || exit 1

mkdir -p PROKKA_RESULTS

for species_dir in \
    1_Enterococcus_faecium \
    2_Staphylococcus_aureus \
    3_Klebsiella_pneumoniae \
    4_Acinetobacter_baumannii \
    5_Pseudomonas_aeruginosa \
    6_Enterobacter_cloacae
do

    mkdir -p "PROKKA_RESULTS/${species_dir}"

    for genome in "${species_dir}"/*.fna
    do
        strain=$(basename "$genome" .fna)

        # Crear locus tag válido para Prokka
        locustag=$(echo "$strain" | sed 's/[^A-Za-z0-9]//g')

        echo "========================================"
        echo "Species: ${species_dir}"
        echo "Genome:  ${strain}"
        echo "========================================"

        prokka \
            --outdir "PROKKA_RESULTS/${species_dir}/${strain}" \
            --prefix "${strain}" \
            --locustag "${locustag}" \
            --cpus 32 \
            --force \
            "$genome"

    done
done
