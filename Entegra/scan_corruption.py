import os, re

root = r'C:\Users\HP\Entegra\Entegra'
# UTF-8 encoded U+FFFD (replacement character) byte pattern
FFFD = b'\xef\xbf\xbd'

results = []
for dirpath, dirs, files in os.walk(root):
    # __history klasorlerini atla
    dirs[:] = [d for d in dirs if d.lower() != '__history' and d != '.git']
    for f in files:
        if not f.lower().endswith(('.pas', '.dfm', '.sql', '.dpr')):
            continue
        path = os.path.join(dirpath, f)
        try:
            with open(path, 'rb') as fp:
                data = fp.read()
            count = data.count(FFFD)
            if count > 0:
                results.append((count, path))
        except Exception as e:
            print(f"Error reading {path}: {e}")

results.sort(reverse=True)
for c, p in results[:40]:
    print(f"{c:6d}  {p}")
print(f"\nTotal files with FFFD: {len(results)}")
