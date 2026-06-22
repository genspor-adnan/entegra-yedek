import os
from collections import Counter

ROOT = r'C:\Users\HP\Entegra\Entegra'
SKIP = {'__history', '.git', '3dparty', 'Archive', 'backup.1', 'backup.2', 'Temp'}
FFFD = b'\xef\xbf\xbd'

ctx = Counter()  # pattern -> count

def cp(data, i, w):
    """Return ASCII representation around position i, with FFFD as '?'"""
    s = data[max(0,i-w):i+3+w]
    out = []
    j = 0
    while j < len(s):
        if s[j:j+3] == FFFD:
            out.append('?')
            j += 3
        elif 32 <= s[j] < 127:
            out.append(chr(s[j]))
            j += 1
        else:
            out.append('.')
            j += 1
    return ''.join(out).strip()

for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP]
    for f in files:
        if not f.lower().endswith(('.pas', '.dfm', '.sql', '.dpr')):
            continue
        path = os.path.join(dirpath, f)
        with open(path, 'rb') as fp:
            data = fp.read()
        i = 0
        while True:
            i = data.find(FFFD, i)
            if i < 0:
                break
            # extract 6 chars before and 6 after
            pat = cp(data, i, 6)
            ctx[pat] += 1
            i += 3

# en yaygin 50 pattern
print("Top 50 patterns (count, context with ? = FFFD):")
for pat, n in ctx.most_common(50):
    print(f"  {n:4d}  {pat}")
