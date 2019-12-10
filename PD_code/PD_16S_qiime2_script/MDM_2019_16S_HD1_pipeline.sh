#!/bin/bash


#SBATCH -N 1 # node count
#SBATCH -c 5
#SBATCH -t 30:00:00
#SBATCH --mem=70000
#SBATCH --mail-type=end
#SBATCH --mail-user=jglopez@princeton.edu
#SBATCH -D /tigress/DONIA/scripts/MDM_2019_16S/
#SBATCH -o /tigress/DONIA/scripts/MDM_2019_16S/logs_HD1/qiime2_pipeline-%j.out

location='/tigress/DONIA/data/donia/MDM_2019_16S_HD1'
name='MDM_2019_16S_HD1'

module load anaconda3

source activate /tigress/MOLBIO/local/pythonenv/qiime2-2018.6

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $location/${name}_manifest.txt \
  --output-path $location/$name.qza \
  --source-format PairedEndFastqManifestPhred33 

qiime demux summarize \
  --i-data $location/$name.qza \
  --o-visualization $location/${name}_quality.qzv

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs $location/$name.qza \
  --p-trunc-len-f 165 \
  --p-trunc-len-r 140 \
  --output-dir $location/${name}_dada2/ \
  --p-n-threads 5

qiime feature-classifier classify-sklearn \
  --i-classifier /tigress/DONIA/data/donia/16S_qiime2/classifier/99_otus_gg_classifier.qza \
  --i-reads $location/${name}_dada2/representative_sequences.qza \
  --o-classification $location/${name}_taxonomy.qza \
  --p-n-jobs 1

mkdir $location/tree

qiime alignment mafft \
  --i-sequences $location/${name}_dada2/representative_sequences.qza \
  --o-alignment $location/tree/aligned_representative_sequences.qza

qiime alignment mask \
  --i-alignment $location/tree/aligned_representative_sequences.qza \
  --o-masked-alignment $location/tree/masked_aligned_representative_sequences.qza

qiime phylogeny fasttree \
  --i-alignment $location/tree/masked_aligned_representative_sequences.qza \
  --o-tree $location/tree/unrooted_tree.qza

qiime phylogeny midpoint-root \
  --i-tree $location/tree/unrooted_tree.qza \
  --o-rooted-tree $location/tree/rooted_tree.qza

qiime diversity alpha-rarefaction \
  --i-table $location/${name}_dada2/table.qza \
  --i-phylogeny $location/tree/rooted_tree.qza \
  --p-max-depth 40000 \
  --p-steps 80 \
  --p-iterations 1000 \
  --output-dir $location/diversity_analysis

qiime taxa collapse \
  --i-table $location/${name}_dada2/table.qza \
  --i-taxonomy $location/${name}_taxonomy.qza \
  --p-level 5 \
  --output-dir $location/collapsed_table

qiime feature-table relative-frequency \
  --i-table $location/collapsed_table/collapsed_table.qza \
  --o-relative-frequency-table $location/collapsed_table/collapsed_table_relative.qza

qiime tools export \
  $location/collapsed_table/collapsed_table_relative.qza \
  --output-dir $location/export_collapsed/

biom convert \
  -i $location/export_collapsed/feature-table.biom \
  -o $location/export_collapsed/${name}_family_table.txt \
  --to-tsv 

qiime tools export \
  $location/${name}_dada2/table.qza \
  --output-dir $location/export_asv/

biom convert \
  -i $location/export_asv/feature-table.biom \
  -o $location/export_asv/${name}_asv_table.txt \
  --to-tsv
