import os

ROOT = r'C:\Users\HP\Entegra\Entegra'
SKIP = {'__history', '.git', '3dparty', 'Archive', 'backup.1', 'backup.2', 'Temp'}
BAD = b'BasitKomut' + b'\xef\xbf\xbd'

count = 0
for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP]
    for f in files:
        if not f.lower().endswith(('.pas', '.dfm', '.sql', '.dpr')):
            continue
        path = os.path.join(dirpath, f)
        with open(path, 'rb') as fp:
            data = fp.read()
        n = data.count(BAD)
        if n > 0:
            count += n
            print(f"  {os.path.relpath(path, ROOT)}: {n}")
print(f"\nTotal corrupted BasitKomut: {count}")
