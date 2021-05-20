
ruleorder: adjust_metadata_divisions_global > adjust_metadata_regions

rule reassignment_japan_quarantine_metadata:
    message: "Exclude Japanese quarantine strains"
    input:
        metadata = _get_unified_metadata
    output:
        metadata = "results/metadata_with_reassignments.tsv"
    shell:
        """
        perl japanese_build/reassignment_japan_quarantine_metadata.pl {input.metadata}  > {output.metadata}

        """

rule adjust_metadata_division_japan:
    message:
        """
        Adjusting metadata for build '{wildcards.build_name} :: Division'
        """
    input:
        metadata = rules.reassignment_japan_quarantine_metadata.output.metadata
    output:
        metadata = "results/{build_name}/metadata_adjusted_division_japan.tsv"
    log:
        "logs/adjust_metadata_division_{build_name}.txt"
    conda: config["conda_environment"]
    shell:
        """
         perl japanese_build/adjust_division_by_orilab.pl {input.metadata}  japanese_build/orilab_prefecture.txt > {output.metadata} 
        """
rule adjust_metadata_divisions_global:
    message:
        """
        Adjusting metadata for build '{wildcards.build_name}'
        """
    input:
        metadata = rules.adjust_metadata_division_japan.output.metadata
    output:
        metadata = "results/{build_name}/metadata_adjusted.tsv"
    params:
        country = lambda wildcards: config["builds"][wildcards.build_name]["country"]
    log:
        "logs/adjust_metadata_division_{build_name}.txt"
    conda: config["conda_environment"]
    shell:
        """
        python3 japanese_build/adjust_division_meta.py \
            --country {params.country:q} \
            --metadata {input.metadata} \
            --output {output.metadata} 2>&1 | tee {log}
        """

ruleorder: finalize_japan > finalize

rule add_labels:
    message: "Remove extraneous colorings for main build and move frequencies"
    input:
        auspice_json = rules.incorporate_travel_history.output.auspice_json,
        tree = rules.refine.output.tree,
        clades = rules.clades.output.clade_data,
        mutations = rules.ancestral.output.node_data
    output:
        auspice_json = "results/{build_name}/ncov_with_accessions_and_travel_branches_and_labels.json",
    log:
        "logs/add_labels_{build_name}.txt"
    conda: config["conda_environment"]
    shell:
        """
        python3 scripts/add_labels.py \
            --input {input.auspice_json} \
            --tree {input.tree} \
            --mutations {input.mutations} \
            --clades {input.clades} \
            --output {output.auspice_json} 2>&1 | tee {log}
        """

rule finalize_japan:
    message: "Remove extraneous colorings for main build and move frequencies"
    input:
        auspice_json = rules.add_labels.output.auspice_json,
        root_json = rules.export.output.root_sequence_json,
        frequencies = rules.tip_frequencies.output.tip_frequencies_json
    output:
        auspice_json = "auspice/ncov_{build_name}.json",
        root_json = "auspice/ncov_{build_name}_root-sequence.json",
        tip_frequency_json = "auspice/ncov_{build_name}_tip-frequencies.json"
    log:
        "logs/fix_colorings_{build_name}.txt"
    conda: config["conda_environment"]
    shell:
        """
        python3 scripts/fix-colorings.py \
            --input {input.auspice_json} \
            --output {output.auspice_json} 2>&1 | tee {log} &&
        cp {input.frequencies} {output.tip_frequency_json} &&
        cp {input.root_json} {output.root_json}
        """
