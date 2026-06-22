import sys

target = 'C:/Users/HP/Entegra/Entegra/UEBelgeOlusturucu.pas'

with open(target, 'rb') as f:
    data = f.read()

# BasitKomutÇalıştır in various corrupted UTF-8 forms
bad = b'BasitKomut\xef\xbf\xbdal\xef\xbf\xbd\xef\xbf\xbdt\xef\xbf\xbdr'
# BasitKomutÇalıştır in cp1254
good = 'BasitKomutÇalıştır'.encode('cp1254')

count = data.count(bad)
print(f"Found {count} occurrences of corrupted BasitKomutÇalıştır")

fixed = data.replace(bad, good)

with open(target, 'wb') as f:
    f.write(fixed)

print("Done.")
