#!/bin/bash

# The following paths need to be configured

FEDORA_DATA_ROOT="."
OUTFILE="stats"

function collect_stats {
    echo '==='
    date
    date "+%m%d%H%M%Y.%S"
    echo "File count:"
    printf " %d\t%s\n" $(find $FEDORA_DATA_ROOT/objectStore -type f | wc -l) $FEDORA_DATA_ROOT/objectStore
    printf " %d\t%s\n" $(find $FEDORA_DATA_ROOT/datastreamStore -type f | wc -l) $FEDORA_DATA_ROOT/datastreamStore
    echo "Size (kb):"
    du -sk $FEDORA_DATA_ROOT/objectStore $FEDORA_DATA_ROOT/datastreamStore
}

collect_stats >> $OUTFILE
