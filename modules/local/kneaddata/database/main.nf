process KNEADDATA_DATABASE {
    tag "${kneaddata_db_type}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kneaddata:0.12.0--pyhdfd78af_1':
        'biocontainers/kneaddata:0.12.0--pyhdfd78af_1' }"

    input:
    val kneaddata_db_type

    output:
    path "kneaddata_${kneaddata_db_type}/"  , emit: kneaddata_db
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    https_proxy=http://klone-dip1-A-ib:3128
    export https_proxy
    kneaddata_database \\
        --download $kneaddata_db_type bowtie2 kneaddata_${kneaddata_db_type}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: \$(echo \$(kneaddata --version 2>&1 | sed 's/^.*v//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir kneaddata_${kneaddata_db_type}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kneaddata: \$(echo \$(kneaddata --version 2>&1 | sed 's/^.*v//' ))
    END_VERSIONS
    """
}
