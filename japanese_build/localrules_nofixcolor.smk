
ruleorder: sanitize_metadata_japan > sanitize_metadata

rule sanitize_metadata_japan:
    input:
        metadata=lambda wildcards: _get_path_for_input("metadata", wildcards.origin)
    output:
        tmp_metadata="results/_sanitized_metadata_division_{origin}.tsv.xz",
        tmp_metadata2="results/_sanitized_metadata_quarantine_{origin}.tsv.xz",
        metadata="results/sanitized_metadata_{origin}.tsv.xz"
    benchmark:
        "benchmarks/sanitize_metadata_{origin}.txt"
    conda:
        config["conda_environment"]
    log:
        "logs/sanitize_metadata_{origin}.txt"
    params:
        parse_location_field=f"--parse-location-field {config['sanitize_metadata']['parse_location_field']}" if config["sanitize_metadata"].get("parse_location_field") else "",
        rename_fields=config["sanitize_metadata"]["rename_fields"],
        strain_prefixes=config["strip_strain_prefixes"],
    shell:
        """
        perl japanese_build/adjust_division_by_orilab.pl <(zcat {input.metadata} )  japanese_build/orilab_prefecture.txt | xz -2 > {output.tmp_metadata} &&\
        perl japanese_build/reassignment_japan_quarantine_metadata.pl <(xzcat {output.tmp_metadata})  | xz -2  > {output.tmp_metadata2} &&\
        python3 scripts/sanitize_metadata.py \
            --metadata {output.tmp_metadata2} \
            {params.parse_location_field} \
            --rename-fields {params.rename_fields:q} \
            --strip-prefixes {params.strain_prefixes:q} \
            --output {output.metadata} 2>&1 | tee {log}
        """


ruleorder: adjust_metadata_divisions_global > adjust_metadata_regions

rule adjust_metadata_divisions_global:
    message:
        """
        Adjusting metadata for build '{wildcards.build_name}'
        """
    input:
        metadata = _get_unified_metadata
    output:
        metadata = "results/{build_name}/metadata_adjusted.tsv.xz"
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


