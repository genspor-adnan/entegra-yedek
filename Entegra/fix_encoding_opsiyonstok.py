target = 'C:/Users/HP/Entegra/Entegra/UOpsiyonStok.pas'

with open(target, 'rb') as f:
    data = f.read()

bad = b'BasitKomut\xef\xbf\xbdal\xef\xbf\xbd\xef\xbf\xbdt\xef\xbf\xbdr'
good = 'BasitKomutÇalıştır'.encode('cp1254')

count = data.count(bad)
print(f"Found {count} corrupted BasitKomutÇalıştır")

fixed = data.replace(bad, good)
with open(target, 'wb') as f:
    f.write(fixed)
print("Done.")
