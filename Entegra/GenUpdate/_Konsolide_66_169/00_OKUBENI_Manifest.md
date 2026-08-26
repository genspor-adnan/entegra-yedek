# Konsolide GenUpdate — 66→169 (Ağustos 7+)

Bu paket, müşteriye **6 Ağustos'tan sonra kurulmamış** GenDepoUpdate66–169 (104 dosya) betiklerini gözden geçirip **her DB nesnesinin yalnız SON halini** alacak şekilde sadeleştirir.

## Özet

- Taranan update dosyası: **104** (GenDepoUpdate66 … GenDepoUpdate169)
- Toplam nesne tanımı: **223** → benzersiz nesne: **146** → elenen tekrar: **77**
- Tek seferlik yapısal batch (tablo/index/alter/drop + TABLOLAR/GENINI seed): **23**
- Benzersiz GRANT: **115** (hepsi `99_Yetkiler.sql`'de toplandı)
- Tüm nesneler `CREATE OR ALTER` (idempotent, tekrar çalıştırılabilir).
- Dosya içi versiyon-no artışı yok; dağıtılmaması gereken BILIM/dev veri düzeltmesi yok; `#pg` yalnız yorumda (hepsi MSSQL).

## Kurulum sırası (müşteri ANA veritabanı)

```
00_Kurulum_Sema.sql      <- ÖNCE (rol + tablo/şema + TABLOLAR/GENINI seed)
01_Belge_API.sql
02_Belge_Donusum.sql
03_Izleme_SeriLot.sql
04_Silme_API.sql
05_Kart_Kaydet_POS.sql
06_Liste_Ekranlari.sql
07_Mesajlasma.sql
08_Log_Audit.sql
09_Diger.sql
99_Yetkiler.sql          <- EN SON (tüm nesneler oluştuktan sonra GRANT)
```
Türkçe içerik için: `sqlcmd -f 65001` (yalnız BOM yetmez). 01–09 arası sıra önemli değildir (deferred name resolution); 00 ilk, 99 son olmalı.

## Önemli notlar

- **`gentegre_api` rolü**: 00 içinde yoksa oluşturulur; 99'daki GRANT'ler buna bağlı. Rol yoksa 99 sessizce atlanır.
- **166 → eski mesajlaşma temizliği** (`MESAJLOG/MESAJLOGKULLANICI/MESAJLAR` DROP) 00'a dahildir; `IF EXISTS` korumalı, veri saklanmak istenirse bu satırlar atlanabilir.
- Emitte her nesnenin başına `-- kaynak: GenDepoUpdateN` konuldu; ayrıntılı dosya-başı yorumları (dev günlüğü) çıkarıldı — orijinal numaralı dosyalar sizde duruyor.
- Doğrulama: 146 nesnenin **kod gövdesi**, kaynaktaki son tanımıyla birebir eşleşti; kayıp/çift yok; 115 GRANT eksiksiz.

## Nesne → kaynak (son hal) haritası

| Nesne | Tekrar | Son hal |
|---|---|---|
| fn_Api_Belge_DipToplam | 1× | GenDepoUpdate68 |
| fn_Api_Belge_TabNo | 1× | GenDepoUpdate80 |
| fn_Api_DepoDBAdi | 1× | GenDepoUpdate71 |
| fn_Api_Donusum_Esleme | 2× | GenDepoUpdate89 |
| fn_Api_Donusum_Kalan | 1× | GenDepoUpdate73 |
| fn_Prog_BelgeDonusum_Kalan | 1× | GenDepoUpdate89 |
| fn_Prog_BelgeDonusum_KalanKod | 1× | GenDepoUpdate89 |
| fn_Prog_BelgeDonusum_Rota | 3× | GenDepoUpdate120 |
| fn_Prog_BelgeDonusum_YorumTabNo | 1× | GenDepoUpdate92 |
| fn_Prog_Donusum_DonusenAdet | 1× | GenDepoUpdate124 |
| fn_Prog_Donusum_KaynakDonusebilirMi | 1× | GenDepoUpdate130 |
| fn_Prog_GeciciTabloGecerli | 1× | GenDepoUpdate138 |
| fn_Prog_Izleme_DepoAday | 1× | GenDepoUpdate104 |
| fn_Prog_Mesaj_BirebirKanal | 1× | GenDepoUpdate145 |
| fn_Prog_Mesaj_YoneticiSayisi | 1× | GenDepoUpdate158 |
| fn_Prog_Silme_Detay | 2× | GenDepoUpdate129 |
| fn_Prog_Silme_Detay_Ek | 2× | GenDepoUpdate134 |
| fn_Prog_Silme_Engel | 2× | GenDepoUpdate129 |
| fn_Prog_Silme_Engel_Ek | 2× | GenDepoUpdate134 |
| fn_Prog_Silme_Plan | 1× | GenDepoUpdate133 |
| sp_Api_Belge_Donusum_Json | 1× | GenDepoUpdate82 |
| sp_Api_Belge_Durum_Yaz_Ic | 3× | GenDepoUpdate157 |
| sp_Api_Belge_DurumHesapla_Json | 3× | GenDepoUpdate157 |
| sp_Api_Belge_EkAlan_Json | 2× | GenDepoUpdate157 |
| sp_Api_Belge_Getir_Json | 1× | GenDepoUpdate76 |
| sp_Api_Belge_Iptal_Json | 1× | GenDepoUpdate132 |
| sp_Api_Belge_Kaydet_Json | 4× | GenDepoUpdate88 |
| sp_Api_Belge_Klonla_Json | 1× | GenDepoUpdate140 |
| sp_Api_Belge_Liste_Json | 1× | GenDepoUpdate76 |
| sp_Api_Belge_SeriLot_Yaz_Ic | 1× | GenDepoUpdate78 |
| sp_Api_Belge_SeriLot_Yaz_Json | 2× | GenDepoUpdate78 |
| sp_Api_Belge_Sil_Json | 1× | GenDepoUpdate72 |
| sp_Api_Belge_Siparis_Kaydet_Json | 1× | GenDepoUpdate113 |
| sp_Api_Belge_Siparis_Klonla_Json | 1× | GenDepoUpdate142 |
| sp_Api_Belge_Siparis_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Belge_Toplam_Yaz_Ic | 2× | GenDepoUpdate157 |
| sp_Api_Belge_ToplamHesapla_Json | 3× | GenDepoUpdate157 |
| sp_Api_Cari_Kaydet_Json | 1× | GenDepoUpdate141 |
| sp_Api_Cari_Klonla_Json | 1× | GenDepoUpdate141 |
| sp_Api_Cari_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_CekSenet_Sil_Json | 1× | GenDepoUpdate129 |
| sp_Api_Demirbas_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Dokuman_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Donusum_KaynakIptalKontrol_Ic | 1× | GenDepoUpdate131 |
| sp_Api_Donusum_Kontrol_Json | 2× | GenDepoUpdate131 |
| sp_Api_Donusum_Rapor_Json | 1× | GenDepoUpdate75 |
| sp_Api_Donusum_SiparistenBelge_Json | 2× | GenDepoUpdate82 |
| sp_Api_Donusum_Uygula_Json | 3× | GenDepoUpdate143 |
| sp_Api_Firsat_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Fiyat_EksikleriEkle_Json | 1× | GenDepoUpdate139 |
| sp_Api_Gorev_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_IK_Kaydet_Json | 1× | GenDepoUpdate141 |
| sp_Api_IK_Klonla_Json | 1× | GenDepoUpdate141 |
| sp_Api_IK_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Kasa_Sil_Json | 2× | GenDepoUpdate133 |
| sp_Api_KasaHareket_Sil_Json | 1× | GenDepoUpdate137 |
| sp_Api_Kayit_Sil_Json | 2× | GenDepoUpdate133 |
| sp_Api_KrediKarti_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Log_DetaySil_Json | 1× | GenDepoUpdate71 |
| sp_Api_Log_KayitSil_Json | 1× | GenDepoUpdate71 |
| sp_Api_Log_Kaynak_Isaretle | 1× | GenDepoUpdate143 |
| sp_Api_Log_Yaz_Ic | 2× | GenDepoUpdate157 |
| sp_Api_Log_YilTablosu | 1× | GenDepoUpdate71 |
| sp_Api_MasrafGelir_Sil_Json | 1× | GenDepoUpdate129 |
| sp_Api_Mesaj_Gonder_Json | 2× | GenDepoUpdate156 |
| sp_Api_Mesaj_Kanal_Avatar_Json | 1× | GenDepoUpdate154 |
| sp_Api_Mesaj_Kanal_Favori_Json | 1× | GenDepoUpdate162 |
| sp_Api_Mesaj_Kanal_Kaydet_Json | 3× | GenDepoUpdate158 |
| sp_Api_Mesaj_Kanal_Rol_Json | 1× | GenDepoUpdate158 |
| sp_Api_Mesaj_Kanal_Temizle_Json | 3× | GenDepoUpdate165 |
| sp_Api_Mesaj_Okundu_Json | 1× | GenDepoUpdate146 |
| sp_Api_Mesaj_Okunmadi_Json | 1× | GenDepoUpdate163 |
| sp_Api_Mesaj_Sil_Json | 3× | GenDepoUpdate161 |
| sp_Api_Modul_Sil_Ic | 1× | GenDepoUpdate127 |
| sp_Api_POS_Iskonto_Json | 1× | GenDepoUpdate138 |
| sp_Api_POS_Satis_Json | 1× | GenDepoUpdate138 |
| sp_Api_POS_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_POS_Tahsilat_Json | 2× | GenDepoUpdate157 |
| sp_Api_Proje_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Rehber_Kaydet_Ic | 2× | GenDepoUpdate157 |
| sp_Api_Rehber_Klonla_Ic | 2× | GenDepoUpdate157 |
| sp_Api_Servis_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_Stok_Kaydet_Json | 2× | GenDepoUpdate157 |
| sp_Api_Stok_Klonla_Json | 2× | GenDepoUpdate157 |
| sp_Api_Stok_Sil_Json | 1× | GenDepoUpdate133 |
| sp_Api_StokSayim_Sil_Json | 1× | GenDepoUpdate133 |
| sp_Api_Teklif_Sil_Json | 1× | GenDepoUpdate127 |
| sp_Api_UretimEmri_Sil_Json | 1× | GenDepoUpdate134 |
| sp_Api_UretimRecete_Sil_Json | 1× | GenDepoUpdate134 |
| sp_BelgeNoGetir | 1× | GenDepoUpdate136 |
| SP_PRG_FaturaDipToplami | 1× | GenDepoUpdate68 |
| sp_Prog_AlisSatis_IrsFatFisKons_Json2 | 1× | GenDepoUpdate123 |
| sp_Prog_AlisSatis_Siparis_Json2 | 1× | GenDepoUpdate123 |
| sp_Prog_Belge_KaynakDurum_Json | 1× | GenDepoUpdate101 |
| sp_Prog_BelgeDonusum_Dogrula | 5× | GenDepoUpdate114 |
| sp_Prog_BelgeDonusum_IzlemeAktar | 6× | GenDepoUpdate112 |
| sp_Prog_BelgeDonusum_Kaydet | 2× | GenDepoUpdate114 |
| sp_Prog_BelgeDonusum_Kaynak_Json2 | 1× | GenDepoUpdate131 |
| sp_Prog_BelgeDonusum_Sonlandir | 1× | GenDepoUpdate92 |
| sp_Prog_BelgeDonusum_UretimAktar | 1× | GenDepoUpdate92 |
| sp_Prog_BelgeDonusum_Uygula_Json2 | 4× | GenDepoUpdate108 |
| sp_Prog_Cari_Liste_Json2 | 1× | GenDepoUpdate121 |
| sp_Prog_Demirbas_Liste_Json2 | 1× | GenDepoUpdate86 |
| sp_Prog_Dokuman_Liste_Json2 | 1× | GenDepoUpdate83 |
| sp_Prog_Donusum_HedefBelge | 1× | GenDepoUpdate128 |
| sp_Prog_Donusum_KaynakBelge | 1× | GenDepoUpdate128 |
| sp_Prog_Donusum_KopukZincir_Rapor | 1× | GenDepoUpdate118 |
| sp_Prog_Donusum_SatirAdetKontrol | 1× | GenDepoUpdate124 |
| sp_Prog_FatTransfer_Liste_Json2 | 1× | GenDepoUpdate116 |
| sp_Prog_Fatura_Silinebilir_Mi | 2× | GenDepoUpdate126 |
| sp_Prog_Gorev_Liste_Json2 | 1× | GenDepoUpdate85 |
| sp_Prog_Izleme_Aday_Json | 4× | GenDepoUpdate111 |
| sp_Prog_Izleme_Aktar_Json | 4× | GenDepoUpdate109 |
| sp_Prog_Izleme_BakiyeKontrol | 1× | GenDepoUpdate94 |
| sp_Prog_Izleme_BakiyeOnar | 1× | GenDepoUpdate95 |
| sp_Prog_Izleme_BakiyeOnar_GeriAl | 1× | GenDepoUpdate95 |
| sp_Prog_Izleme_Dogrula_Json | 1× | GenDepoUpdate97 |
| sp_Prog_Izleme_Yaz_Json | 2× | GenDepoUpdate108 |
| sp_Prog_Kayit_Silinebilir_Mi | 2× | GenDepoUpdate133 |
| sp_Prog_Log_Liste_Json2 | 1× | GenDepoUpdate144 |
| sp_Prog_Mesaj_Avatar | 1× | GenDepoUpdate148 |
| sp_Prog_Mesaj_Avatar_Toplu | 2× | GenDepoUpdate157 |
| sp_Prog_Mesaj_Gecmis_Json2 | 3× | GenDepoUpdate160 |
| sp_Prog_Mesaj_Icerik_Ara_Json2 | 2× | GenDepoUpdate160 |
| sp_Prog_Mesaj_Kanal_Liste_Json2 | 8× | GenDepoUpdate168 |
| sp_Prog_Mesaj_Kisi_Bilgi_Json2 | 2× | GenDepoUpdate155 |
| sp_Prog_Mesaj_Kisi_Liste_Json2 | 4× | GenDepoUpdate168 |
| sp_Prog_Mesaj_Uye_Liste_Json2 | 1× | GenDepoUpdate150 |
| sp_Prog_Mesaj_Yokla_Json | 2× | GenDepoUpdate164 |
| sp_Prog_Servis_Liste_Json2 | 1× | GenDepoUpdate122 |
| sp_Prog_Siparis_Silinebilir_Mi | 1× | GenDepoUpdate117 |
| sp_Prog_SiradakiNo | 1× | GenDepoUpdate135 |
| sp_Prog_SiradakiNo_Ayarla | 1× | GenDepoUpdate135 |
| sp_Prog_SiradakiNo_Iade | 1× | GenDepoUpdate135 |
| sp_Prog_SiradakiNo_Ic | 1× | GenDepoUpdate135 |
| sp_Prog_StokHizmetAra_Hizmet_Json2 | 1× | GenDepoUpdate67 |
| sp_Prog_StokHizmetAra_Stok_Json2 | 1× | GenDepoUpdate67 |
| sp_Prog_StokTalep_Liste_Json2 | 1× | GenDepoUpdate84 |
| sp_Prog_Teklif_Silinebilir_Mi | 1× | GenDepoUpdate120 |
| sp_Prog_Uretim_Liste_Json2 | 2× | GenDepoUpdate116 |
| sp_Prog_UretimEmri_Liste_Json2 | 1× | GenDepoUpdate86 |
| sp_Prog_UretimFisi_Olustur_Json | 1× | GenDepoUpdate115 |
| TG_IzlemOrjinalYap | 1× | GenDepoUpdate94 |
| TG_StokIzlemeDurumUpdate | 1× | GenDepoUpdate94 |
| Trg_Fatura_MasrafID_Guncelle | 1× | GenDepoUpdate87 |
| Trg_UretimEmriUser_SKT_Guncelle | 1× | GenDepoUpdate87 |