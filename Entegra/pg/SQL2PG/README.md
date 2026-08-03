# SQL2PG

Gentegre MSSQL müşterisini PostgreSQL test/kurulum ortamına taşımak için Delphi VCL aracı.

## Kullanım

```powershell
SQL2PG.exe
```

Ekrandan `SQL2PG.ini` seçilir, tablo listesi düzenlenir ve `Kurulum`, `Migrate`
veya `Kurulum + Migrate` çalıştırılır.

## Modlar

- `install`: `PG\schema` altındaki `.sql` dosyalarını alfabetik sırayla PostgreSQL üzerinde çalıştırır.
- `migrate`: MSSQL kaynak DB'den PostgreSQL hedef DB'ye tablo verisi aktarır.
- `all`: önce `install`, sonra `migrate`.

## Notlar

- Ayarlar `SQL2PG.ini` içindedir; örnek için `SQL2PG.ini.example`.
- Aktarım hedef tabloda var olan kolonlarla kaynak kolonların kesişimini kullanır.
- `ClearBeforeLoad=True` ise hedef tablo aktarım öncesi `TRUNCATE ... CASCADE` edilir.
- İlk sürüm kurulum/test ve kontrollü müşteri migrate içindir; canlı müşteri DB'sinde çalıştırmadan önce DB kopyasında denenmelidir.
