

TIME_UNITS = {'': 'Seconds', 'm': 'Milliseconds (ms)', 'u': 'Microseconds (us)', 'n': 'Nanoseconds (ns)'}
ALLOWED_COLUMNS = ['min', 'max', 'mean', 'stddev', 'median', 'iqr', 'ops', 'outliers', 'rounds', 'iterations']

def slugify(name):
    for c in r'\/:*?<>| ':
        name = name.replace(c, '_').replace('__', '_')
    return name
