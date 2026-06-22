# UEBelgeGelen.pas dosyasini UTF-8'den cp1254'e cevir.
# Yeni olusturulan dosyalar Write tool'undan UTF-8 cikiyor; Delphi cp1254 bekliyor.
target = 'C:/Users/HP/Entegra/Entegra/UEBelgeGelen.pas'

with open(target, 'rb') as f:
    raw = f.read()

# Eger zaten cp1254 ise (UTF-8 olarak okunmuyorsa) atla
try:
    text = raw.decode('utf-8')
except UnicodeDecodeError:
    print("Already cp1254 (or other). No conversion.")
    raise SystemExit(0)

# BOM strip
if text.startswith('﻿'):
    text = text[1:]

# Once BasitKomutCalistir (ASCII) -> BasitKomutÇalıştır (Turkce) degisikligi
text = text.replace('BasitKomutCalistir', 'BasitKomutÇalıştır')

# cp1254 olarak yaz
cp = text.encode('cp1254', errors='replace')
with open(target, 'wb') as f:
    f.write(cp)

print(f"Converted to cp1254 ({len(cp)} bytes)")
