# Eski HBYS (GEN3000) → GentegreAI aktarımı

Eski Delphi HBYS'nin (MSSQL, mantıksal dosya adı `GEN3000`) verisini yeni web ürününe taşır. İlk örnek:
**KOŞUYOLU** görüntüleme merkezi, 2026 yılı. Aynı araçlarla diğer eski HBYS kurulumları aktarılır.

## Dosyalar

| Dosya | Ne yapar |
|---|---|
| `al.ps1` | 1. aşama — MSSQL'den hedef PG'nin `eski` şemasına **ham kopya** (yorumsuz; tablolar otomatik kurulur). Raporları açar: zlib → "BDOC" + OLE → `Package` akışı → .docx → düz metin + **biçimli HTML** (kalın / italik / hizalama / punto / renk, gerçek tablolar, gövdedeki resimler `data:` olarak; EMF / WMF / BMP PNG'ye çevrilir). Eski .doc içerik Word COM ile yalnız metne açılır. Şifre kolonlarını ve hasta resmini kopyalamaz. Örnek için `-RaporLimit N` (en yeni N) ya da `-RaporId 1,2,3`; `-Devam` mevcutların yanına ekler. |
| `sozluk.sql` | **Bilgi alanı** — `eski.tanim`: eski tablo / kolon / kod değerlerinin anlamı, yeni sistemdeki karşılığı ve nasıl doğrulandığı (`olcum` / `kullanici` / `ad`). Tek kaynak budur; kurallar buradan okunur. |
| `esle.sql` | 2. aşama — `eski` → yeni şema. Yeniden çalıştırılabilir (önce kendi yazdıklarını siler), tek işlem, sonunda `eski.aktarim_rapor` mutabakatı. |
| `accession_sayac.sql` | Radyoloji accession şablonu ve sayacı (aşağıda). |
| `kategori_alt.sql` | Hizmet alt kategorileri: Radyoloji (MR / BT / Ultrason / Doppler / Röntgen / Mamografi / Kemik Dansitometri / Kontrast-Sarf, modaliteden) ve Laboratuvar (Biyokimya / Hormon / Hematoloji / Seroloji-İmmünoloji / Mikrobiyoloji, eski kod önekinden). Eşleme masası uygulamasından sonra; yeniden çalıştırılabilir, yalnız kökte duran hizmeti taşır. |

## Sıra (yeni bir kurulum için)

> **Yeniden çalıştırma yalnız kurum kullanmaya başlamadan.** `esle.sql` başta aktarılan hasta / kurum / sözleşmeye bağlı elle girilmiş başvuru ya da radyoloji istemi arar; varsa hiçbir şey silmeden durur. O kurulumda yalnız artımlı adım (eksik kayıt ekleyen ayrı betik) çalıştırılır.

```powershell
# 0) MSSQL yedeğini yerel SQL Server'a aç (KOSUYOLU örneği; servis hesabı okuyabilmeli)
# 1) Boş HBYS veritabanı
powershell -ExecutionPolicy Bypass -File db\kur.ps1 -SadeceSema -Db <DB>
#    SKRS dış verisi istenirse: skrs_ham ve skrs.klinik / hekim.brans kod listelerini dev DB'den kopyala
#    (bkz. "Bilinen sorunlar"), aynı komutu yeniden çalıştır.
# 2) Kurulum örneklerini boşalt (demo hekim, SUT/HUV kataloğu, şablonlar) - admin/şube/rol kalır
docker exec gentegre-pg18 psql -U postgres -d <DB> -c "select * from fn_aktarim_oncesi_bosalt(true)"
# 3) Bilgi alanı + ham kopya
docker cp aktarim\eski-hbys\sozluk.sql gentegre-pg18:/tmp/ ; docker exec gentegre-pg18 psql -U postgres -d <DB> -f /tmp/sozluk.sql
powershell -ExecutionPolicy Bypass -File aktarim\eski-hbys\al.ps1 -MssqlDb <MSSQL_DB> -PgDb <DB> -Yil 2026
# 4) Eşleme + mutabakat
docker cp aktarim\eski-hbys\esle.sql gentegre-pg18:/tmp/ ; docker exec gentegre-pg18 psql -U postgres -d <DB> -f /tmp/esle.sql
```

Yeni kurulumda **önce `eski.tanim`'ı o kurulumun verisiyle karşılaştırın** — farklı kod değerleri (başka
`TAHSILAT.TUR`, başka `KURUM.GRUBU`, farklı kod önekleri) çıkarsa önce sözlüğe, sonra `esle.sql`'e eklenir.
Dağılım sorgusu örneği `sozluk.sql` başındaki yorumda.

## Bakanlık (SKRS) standardına oturtma

Aktarım eski hizmetleri **yalnız kullanılanlar** olarak eski koduyla açar (kullanılmayanlar aktarılmaz). Sonra
**Stok & Hizmet › SKRS Eşleme Masası** (göç 1222 / 1223): "Masayı doldur" her eski hizmete SUT adayları hesaplar
(tür / modalite süzgeci, ad sadeleştirme, "dikkat": terim farkı, girişimsel terim, taraf seçimi). Kararlar: onayla
(SUT kodu) · kuruma özel · aday yok; "Yüksek güvenlileri onayla" yalnız %80 üstü ve uyarısız olanları onaylar.
**Uygula**: hizmet YERİNDE SUT kod / ada çevrilir, eski kod `hizmet_eski_kod`'a (listede "Eski kod", aramada
bulunur); aynı SUT'a düşen ikinci eski hizmet pasif olur, başvuru satırı / fiyat listesi / radyoloji istem-şablon /
randevu asıl hizmete yönlenir - silme yok. Yetki: hizmet kartını değiştirebilen.

Aynı masanın **Bölüm** ve **Branş** sekmeleri (göç 1224): eski POLIKLINIK → SKRS kodlu bölüm (departman), eski UZMANLIK →
SKRS branş. Öneriler ürünle gelen eş anlam sözlüğünden (`skrs_esanlam`, puan 1.00) ya da ad benzerliğinden; KENDİ İSTEĞİ /
HEKİM DIŞI "yok say" önerilir. Uygula: dış hekimin bölümü en sık gönderdiği polikliniğin kararına göre, branşı
(taraf_personel.brans + görev) uzmanlık kararına göre yeniden yazılır. Eski şema (`eski.gelisler` / `eski.doktorlar`) gerekir.

## Nereye ne gider (özet — ayrıntı `eski.tanim`)

| Eski | Yeni |
|---|---|
| KIMLIK | `taraf` (grup 101, hasta) + `taraf_hasta` + `taraf_adres`; dosya no `taraf.kod` |
| KURUM (tamamı, Ücretli hariç) | `taraf` (kurum; eski DURUM Pasif -> pasif; tekrarlayan KURUMKODU "-<id>" ekiyle) + `taraf_kurum` (ÖSS 2 / SGK 3 / diğer 4) + tek `kurum_sozlesme` (fiyat listesi yalnız 2026'da kullanılan kurumlarda) |
| DOKTOR | `taraf` (personel, hekim) + `taraf_personel` |
| ISLEMLER | `hizmet` (radyoloji + modalite kod önekinden) |
| FIYATLAR (+ KURUMFIYAT) | `fiyat_listesi` + `fiyat_listesi_satir`, fiyat = KATSAYI × ÇARPAN |
| GELISLER | `belge` (19/30) + `belge_basvuru` |
| PARA | `belge_satir` + `belge_satir_dagilim` (kurum payı = dış kuruma kesilen fatura satırı, kalanı hasta) |
| GELISLER.DOKTOR / DOKTORID (+ DOKTORLAR), POLIKLINIK | isteyen hekim = **dış hekim** (Dış Doktorlar): `taraf` (personel, unvan öneki DOKTORLAR.UNVAN'dan, ad / soyad son kelimeden, bölüm en sık gönderdiği poliklinik) + `taraf_personel` (dis_hekim = 1, tescil = DIPLOMA); e-posta / cep personelde tekil - yalnız geçerli ve ilk geçen taşınır → `radyoloji_istem.istek_hekim_id` |
| OLE | `radyoloji_istem` + `radyoloji_rapor` + `radyoloji_rapor_bolum` (`metin` + `metin_html`); asıl dosya `-RaporKaynakSakla` ile `eski.ole.rapor_kaynak` |
| HAZOLE (rapor şablonları, tamamı; `al.ps1 -Tablolar HAZOLE`) | `radyoloji_sablon` + tek bölüm "Rapor" (`varsayilan_metin` + `varsayilan_html`, göç 1216). Noktasız kod klasör (alınmaz), modalite addan / klasörden; kişisel klasör (DR …, MR-…) tek anlamlı eşleşen radyoloğa `sahip_id`. Açıklama damgası "Eski HBYS şablonu · <klasör>"; yeniden çalıştırmada yalnız değiştirilmemiş ve raporda kullanılmamış olanlar yenilenir. Bölge addan (`pg_temp.eski_sablon_bolge`). Hazır alan paketleri (göç 1217-1220: Lomber / Servikal / Dorsal / Diz / Omuz MR, Tiroid USG, Karotis doppler, Pelvik USG O-RADS, Böbrek Bosniak, Toraks BT Fleischner, Beyin MR) adına uyan şablona `fn_rad_alan_paketi_uygula` ile eklenir. |
| TAHSILAT (VISA / NAKİT / HVL) | `kasa_islem` (kesinleştirilmiş) + `kasa_islem_dagitim` |
| TAHSILAT (ANLAŞ / İSKNT / AÇIK) | aktarılmaz — para hareketi değil (kurum payı / indirim / açık bakiye) |
| FATBASLIK + FATURA | `belge` (15 Satış Faturası) + satırlar; başvuruya `kaynak_tur 30` |

Her yeni kayıt `aktarim_kaynak = 2`, `aktarim_tablo` = eski tablo, `aktarim_id` = eski ID; üçlüsü olmayan
tablolar (`kurum_sozlesme`, `fiyat_listesi`, `kategori`, radyoloji) `eski.esleme`'de.

## Kişisel veri

`eski` şeması hasta kimliği ve raporları ham hâliyle tutar (yeniden işleme için). Aktarım doğrulanıp kurum
canlıya geçince `drop schema eski cascade` ile kaldırılmalı (bilgi alanı `eski.tanim` gerekiyorsa önce
`sozluk.sql`'den yeniden kurulur). Eski sistemin düz metin şifreleri (`SUBELER`, `DOKTOR`) hiç kopyalanmaz.

## Rapor HTML'i

- Sayfa **üst / alt bilgisindeki** resimler (eski antet logosu) alınmaz: yeni sistem çıktıya kendi antetini basar.
  KOŞUYOLU'da resimli 2.754 raporun çoğu yalnız antet logosu taşıyor; gövdede resim (çoğu gömülü Excel ölçüm
  tablosunun görüntüsü) az sayıda.
- Tablo kenarlığı Word'deki tablo kenarlığından (`tblBorders` / "Grid" stili) gelir; kenarsız düzen tabloları
  kenarsız kalır. Birleşik hücreler `colspan` / `rowspan` olur.
- Sunucu beyaz listesi (`api/.../Servisler/RaporHtml.cs`) yalnız gömülü `data:image/png|jpeg|gif|webp` resme izin
  verir; dış adresli resim düşer.

## Bilinen sorunlar (ana üründe düzeltilecek)

- **Boş HBYS kurulumu 559 / 560'ta duruyor:** SKRS kod listeleri (`skrs.klinik`, `hekim.brans`) dış veri
  bekliyor; 560 listelerin eski (ters) hâlde olduğunu varsayıp takas ediyor. Doğru hâliyle kopyalanırsa
  takas onları bozar → KOSUYOLU'da listeler ters kopyalanıp geçildi.
- **`fn_aktarim_oncesi_bosalt` `goz_tetkik_hizmet`'i bilmiyor** → "Boşaltma ilerlemiyor (hizmet, kategori)".
  O tablo elle boşaltılıp geçildi.
- **Boş kurulumda radyoloji istem yetkileri rollere atanmıyor:** 1128 (`radyoloji-istem.liste`) dayandığı
  `radyoloji-istem` kart yetkisini kimse görmezken çalışıyor → menüde "Radyoloji İstem Listesi" yok. KOŞUYOLU'da
  rol atamaları dev DB'den kopyalandı.
- **İskonto kilidi:** aktarım satırları `iskonto_kilit = 1` ile yazılır (iskonto eşiği tetiği); silme kilidi
  de buna bakar — `esle.sql` temizlikte önce kilidi kaldırır.

## Radyoloji yön ve accession (göç 1229)

- **Yön:** eski PARA.YON (1 sağ · 2 sol · 3 bilateral) istemin `yon` alanına aynı kodla taşınır (esle.sql).
  Kabulde yön SORULMAZ (1237, kullanıcı: "sut da nasılsa listeden seçelim"): SUT yönü koda koyar ("MRG, DİZ - SAĞ,
  KONTRASTSIZ"). Eşleme masasında yönsüz eski hizmet ("Diz MR") **Yönlere ayır** kararıyla ailenin her üyesi için
  ayrı SUT hizmetine ayrılır (fiyat liste bazında, protokol, şablon bağı kopyalanır; kısa ad "Diz MR · Sağ ·
  kontrastlı"); eski hizmet pasif kalır, geçmiş hareketler onda.
- **Accession:** `accession_sayac.sql` her eski şubenin Teletıp önekini (SUBELER.TELETIPKURUMONEK, hane
  sayısı) şube bazlı numara şablonu (tür 903) yapar ve sayacı eski programın son numarasından sürdürür
  (KOSUYOLU: KGM + 13 hane). **Geçiş günü** eski veri tazelendikten sonra yeniden çalıştırılır; sayaç
  yalnız ileri alınır. Dışarıdan gelen hastanın kendi numarası kabulde "Dış accession" kolonuna girilir.
