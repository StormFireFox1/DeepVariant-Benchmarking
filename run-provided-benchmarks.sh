#!/bin/bash
#
# This script runs Google's provided benchmarks for each possible DeepVariant
# model on their provided test data. It saves the results of each run in separate
# zip files.
#
# This allows for a cursory glance at the performance of the DeepVariant pipeline.
# This script assumes you are running in the DeepVariant Docker container, and that
# the current working directory is /opt/deepvariant.

OUTPUT_DIR="quickstart-output/"
mkdir -p "$OUTPUT_DIR"
for model in "WGS" "WES" "PACBIO" "HYBRID_PACBIO_ILLUMINA"; do
        echo "Executing DeepVariant for model $model..."
        ./bin/run_deepvariant \
                --model_type=$model \
                --ref=./quickstart-testdata/ucsc.hg19.chr20.unittest.fasta \
                --reads=./quickstart-testdata/NA12878_S1.chr20.10_10p1mb.bam \
                --regions "chr20:10,000,000-11,000,000" \
                --output_vcf=./quickstart-output/output.vcf.gz \
                --output_gvcf=./quickstart-output/output.g.vcf.gz \
                --intermediate_results_dir=./quickstart-output/intermediate_results_dir \
                --num_shards=$(nproc --all) \
                --logging_dir=./quickstart-output/logs \
                --runtime_report=true >> "$model.stdout.log" "$model.stderr.log"
        echo "Done!"
        echo "Zipping run..."
        echo "======"
        cd "$OUTPUT_DIR"; zip -r "../$model.run.zip" .
        cd ..
        echo "======"
        echo "Resetting..."
        rm -r "$OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
done

