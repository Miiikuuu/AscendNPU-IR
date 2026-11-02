"""Recompute the reported statistics from all published NPU-event samples."""
import json
from pathlib import Path
import statistics
import sys

result = json.loads(Path(sys.argv[1]).read_text())
medians = {}
for variant in ('baseline', 'candidate'):
    for mode in ('off', 'double', 'nbuf'):
        values = [row['us'] for row in result['rows']
                  if row['variant'] == variant and row['mode'] == mode]
        assert len(values) == 30
        medians[variant, mode] = statistics.median(values)
        print(variant, mode, 'n=', len(values), 'median_us=', statistics.median(values),
              'mean_us=', statistics.mean(values), 'min_us=', min(values), 'max_us=', max(values))
assert len(result['rows']) == 180
print('Nbuffer reduction_pct=', 100 * (1 - medians['candidate', 'nbuf'] / medians['baseline', 'nbuf']))
pairs = []
for sample in range(30):
    values = {row['variant']: row['us'] for row in result['rows']
              if row['mode'] == 'nbuf' and row['sample'] == sample}
    pairs.append(100 * (1 - values['candidate'] / values['baseline']))
print('Paired reduction_pct: min=', min(pairs), 'median=', statistics.median(pairs), 'max=', max(pairs))
