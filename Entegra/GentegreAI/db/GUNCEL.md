# Yururlukteki tanimlar (uretilmis dosya - ELLE DUZENLEMEYIN)

`araclar/guncel_indeks.ps1` uretir. Gocler tarihtir ve duzenlenmez;
bir nesne birden cok dosyada tanimlanmissa **en yuksek numarali dosya**
yururluktedir - degistirmeniz gereken yer odur.

## Fonksiyonlar (114 ad, 26 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `fn_ad_soyad_ayir` | `166_ebelge_json.sql` | — |
| `fn_ara_metin` | `027_arama_normalize.sql` | — |
| `fn_belge_diptoplam` | `095_diptoplam_kdv_iskonto2.sql` | 024_fn_belge_diptoplam.sql |
| `fn_belge_durum_kapatma` | `086_belge_donusum_kurallar.sql` | — |
| `fn_belge_fis_geri_al` | `190_belge_fisle.sql` | — |
| `fn_belge_fis_uretilsin` | `192_mali_ayarlar.sql` | — |
| `fn_belge_fisle` | `190_belge_fisle.sql` | — |
| `fn_belge_fisle_toplu` | `190_belge_fisle.sql` | — |
| `fn_belge_fiyatlandir` | `205_belge_fiyat_listesi.sql` | — |
| `fn_belge_kalem_fiyati` | `204_cari_fiyat_listesi.sql` | — |
| `fn_belge_kapanma_tazele` | `191_kapanma_tazele.sql` | — |
| `fn_belge_no_anahtar` | `025_fn_belge_no.sql` | — |
| `fn_belge_no_uret` | `152_numara_sablonu.sql` | 025_fn_belge_no.sql, 087_numara_kesme_duzeltmesi.sql |
| `fn_belge_rezerve` | `142_siparis_rezervasyon.sql` | — |
| `fn_belge_satir_hesap` | `190_belge_fisle.sql` | — |
| `fn_belge_satir_kapatma` | `191_kapanma_tazele.sql` | 082_belge_donusum.sql |
| `fn_belge_satir_kapatma_tazele` | `142_siparis_rezervasyon.sql` | 082_belge_donusum.sql, 086_belge_donusum_kurallar.sql |
| `fn_belge_satir_rezerve_kirp` | `142_siparis_rezervasyon.sql` | — |
| `fn_belge_sil` | `181_belge_sil.sql` | — |
| `fn_belge_silinebilir` | `181_belge_sil.sql` | — |
| `fn_belge_varsayilan_liste` | `205_belge_fiyat_listesi.sql` | — |
| `fn_belge_yon` | `205_belge_fiyat_listesi.sql` | — |
| `fn_cari_fiyat_listesi` | `204_cari_fiyat_listesi.sql` | — |
| `fn_ceviri` | `194_ceviri.sql` | — |
| `fn_ceviri_sozluk` | `194_ceviri.sql` | — |
| `fn_degistirme_tarihi` | `015_sema_log_ebelge.sql` | — |
| `fn_depo_kural_kontrol` | `093_depo_kurallar.sql` | — |
| `fn_depo_varsayilan_tek` | `090_depo_varsayilan.sql` | — |
| `fn_doviz_iso` | `083_doviz_kod_iso.sql` | — |
| `fn_doviz_kur_getir` | `083_doviz_kod_iso.sql` | — |
| `fn_ebelge_acik` | `179_ebelge_ana_salter.sql` | — |
| `fn_ebelge_alici_bilgi` | `184_ebelge_alici_mail.sql` | — |
| `fn_ebelge_birim_kodu` | `166_ebelge_json.sql` | — |
| `fn_ebelge_durum_aciklama` | `188_ebelge_iptal.sql` | 180_ebelge_refaktor.sql |
| `fn_ebelge_durum_adi` | `188_ebelge_iptal.sql` | 180_ebelge_refaktor.sql |
| `fn_ebelge_entegrator` | `171_sube_ebelge_mukellef.sql` | 167_ebelge_entegrator.sql |
| `fn_ebelge_gonderim_dogrula` | `167_ebelge_entegrator.sql` | — |
| `fn_ebelge_gonderim_govdesi` | `171_sube_ebelge_mukellef.sql` | 167_ebelge_entegrator.sql |
| `fn_ebelge_govde_izibiz` | `166_ebelge_json.sql` | — |
| `fn_ebelge_hazirla` | `186_gib_kullanici_alias.sql` | 163_ebelge_hazirla.sql, 179_ebelge_ana_salter.sql |
| `fn_ebelge_hesap` | `171_sube_ebelge_mukellef.sql` | — |
| `fn_ebelge_html` | `178_ebelge_onizleme.sql` | — |
| `fn_ebelge_iptal_edilebilir` | `188_ebelge_iptal.sql` | — |
| `fn_ebelge_iptal_yaz` | `188_ebelge_iptal.sql` | — |
| `fn_ebelge_kimlik_semasi` | `166_ebelge_json.sql` | — |
| `fn_ebelge_mesajlar` | `178_ebelge_onizleme.sql` | — |
| `fn_ebelge_mukellef_mi` | `172_ebelge_mukellefiyet.sql` | — |
| `fn_ebelge_no_uret` | `163_ebelge_hazirla.sql` | — |
| `fn_ebelge_para_kodu` | `166_ebelge_json.sql` | — |
| `fn_ebelge_seri_bul` | `156_ebelge_seri.sql` | — |
| `fn_ebelge_seri_degistir` | `164_ebelge_sifirla_seri.sql` | — |
| `fn_ebelge_seri_listesi` | `164_ebelge_sifirla_seri.sql` | — |
| `fn_ebelge_sifirla` | `164_ebelge_sifirla_seri.sql` | — |
| `fn_ebelge_taraf_json` | `180_ebelge_refaktor.sql` | — |
| `fn_ebelge_toplu_hazirla` | `183_ebelge_toplu.sql` | — |
| `fn_ebelge_tur_adi` | `172_ebelge_mukellefiyet.sql` | — |
| `fn_ebelge_ubl` | `182_ebelge_ubl.sql` | — |
| `fn_ebelge_url` | `167_ebelge_entegrator.sql` | — |
| `fn_ebelge_xslt_bul` | `160_xslt_dokumana_tasindi.sql` | 159_ebelge_xslt.sql |
| `fn_etiket_anahtar` | `003_goc_taraf.sql` | — |
| `fn_firsat_asama_izle` | `121_firsat.sql` | — |
| `fn_firsat_kazanildi_musteri` | `122_aday_musteri.sql` | — |
| `fn_firsat_no_uret` | `121_firsat.sql` | — |
| `fn_fiyat_listesi_dongu_kontrol` | `201_fiyat_listesi.sql` | — |
| `fn_fiyat_listesi_fiyat` | `202_fn_fiyat_listesi.sql` | — |
| `fn_fiyat_listesi_uret` | `202_fn_fiyat_listesi.sql` | — |
| `fn_fiyat_listesi_yon_kontrol` | `204_cari_fiyat_listesi.sql` | — |
| `fn_fiyat_yuvarla` | `202_fn_fiyat_listesi.sql` | — |
| `fn_gelen_belge_kaydet` | `187_gelen_belge.sql` | — |
| `fn_gelen_belge_yanit_yaz` | `187_gelen_belge.sql` | — |
| `fn_gelen_durum_adi` | `187_gelen_belge.sql` | — |
| `fn_gelen_mesajlar` | `189_gelen_mesajlar.sql` | — |
| `fn_goc_sube_coz` | `080_goc_kasa.sql` | — |
| `fn_hesap_atama_adi` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_hesap_plani_alt_ac` | `076_fn_kasa.sql` | — |
| `fn_kalem_kart_fiyati` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kasa_islem_bacak_uret` | `139_kasa_ekstre_dovizi.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql, 096_kasa_bacak_rol_kontrol.sql |
| `fn_kasa_islem_dogrula` | `085_fn_kasa_f3.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_duzelt_hazirla` | `148_kasa_islem_duzelt.sql` | — |
| `fn_kasa_islem_fisle` | `148_kasa_islem_duzelt.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_iptal` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_kesinlestir` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_no_uret` | `152_numara_sablonu.sql` | 073_kasa_islem.sql, 087_numara_kesme_duzeltmesi.sql |
| `fn_kasa_islem_silme_koruma` | `076_fn_kasa.sql` | — |
| `fn_kdv_cevir` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kullanici_kasa` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_kullanici_yetkileri` | `068_taraf_rol_id_kolonlari.sql` | 020_sema_kimlik.sql |
| `fn_mizan` | `077_v_ekstre.sql` | — |
| `fn_muh_hesap_coz` | `138_ceksenet_muhasebe_eslestirme.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_muhasebe_donem_kontrol` | `147_donem_kontrol_timestamp.sql` | 074_muhasebe.sql |
| `fn_muhasebe_fis_no_uret` | `087_numara_kesme_duzeltmesi.sql` | 074_muhasebe.sql |
| `fn_mukellef_sorgu_gerekli` | `185_mukellef_sorgu_tazelik.sql` | — |
| `fn_numara_sablonu_bul` | `154_numara_sablonu_seed.sql` | 152_numara_sablonu.sql |
| `fn_numara_sirada` | `152_numara_sablonu.sql` | — |
| `fn_parola_ata` | `068_taraf_rol_id_kolonlari.sql` | 020_sema_kimlik.sql |
| `fn_parola_dogru` | `020_sema_kimlik.sql` | — |
| `fn_plan_gerceklestir` | `085_fn_kasa_f3.sql` | — |
| `fn_slug` | `021_goc_kimlik.sql` | — |
| `fn_stok_kart_fiyat` | `128_fn_stok_kart_fiyat.sql` | — |
| `fn_stok_kopyala` | `127_stok_kopyala_fiyat.sql` | 126_fn_stok_kopyala.sql |
| `fn_stok_paket_kontrol` | `124_stok_paket.sql` | — |
| `fn_stok_rezerve_tazele` | `142_siparis_rezervasyon.sql` | — |
| `fn_sube_depo_subeleri` | `174_merkez_depo_kullan.sql` | 173_sube_depo.sql |
| `fn_sube_ebelge_hazir` | `169_sube_ebelge_kimlik.sql` | — |
| `fn_sube_gorsel` | `193_firma_kase.sql` | — |
| `fn_sube_mali` | `192_mali_ayarlar.sql` | — |
| `fn_sube_merkez_id` | `169_sube_ebelge_kimlik.sql` | — |
| `fn_taraf_kisi_unvan_ata` | `037_kisi_karti.sql` | — |
| `fn_telefon_rakam` | `123_telefon_arama.sql` | — |
| `fn_tevkifat_orani` | `176_tevkifat_istisna.sql` | — |
| `fn_ubl_taraf` | `182_ebelge_ubl.sql` | — |
| `fn_yerel_para` | `111_ekstre_doviz_gruplu.sql` | — |
| `fn_yetki_surumu_artir` | `020_sema_kimlik.sql` | — |
| `tg_sube_vkn_dogrula` | `170_sube_vkn_dogrula.sql` | — |

## Gorunumler (49 ad, 18 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `cari` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `hasta` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `musteri` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `personel` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `tedarikci` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `v_banka_lookup` | `109_banka.sql` | — |
| `v_banka_sube_lookup` | `110_banka_sube_bagli_ve_kur.sql` | 109_banka.sql |
| `v_belge_acik_satir` | `082_belge_donusum.sql` | — |
| `v_belge_donusum` | `086_belge_donusum_kurallar.sql` | — |
| `v_belge_satir_izlem` | `115_izlem_depo.sql` | 114_belge_izlem.sql |
| `v_belge_sevkiyat` | `177_belge_sevkiyat.sql` | — |
| `v_cari_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_cari_lookup` | `122_aday_musteri.sql` | 037_kisi_karti.sql |
| `v_cek_senet_portfoy` | `072_cek_senet.sql` | — |
| `v_depo_lookup` | `093_depo_kurallar.sql` | 088_belge_irsaliye_alanlari.sql |
| `v_ebelge_entegrator_lookup` | `171_sube_ebelge_mukellef.sql` | — |
| `v_ebelge_gonderici` | `169_sube_ebelge_kimlik.sql` | 165_firma_bilgileri.sql |
| `v_ebelge_turu_lookup` | `156_ebelge_seri.sql` | — |
| `v_ebelge_yon_lookup` | `159_ebelge_xslt.sql` | — |
| `v_firsat_asama_gecmis` | `121_firsat.sql` | — |
| `v_firsat_liste` | `121_firsat.sql` | — |
| `v_fiyat_listesi_alis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_kullanim` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_lookup` | `201_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_satir` | `201_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_satis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_hesap_atama_lookup` | `199_kasa_atama_listesi.sql` | 197_kasa_atama_tek_alan.sql |
| `v_hesap_bakiye` | `077_v_ekstre.sql` | — |
| `v_hesap_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_hesap_lookup` | `071_kasa_master.sql` | — |
| `v_hesap_plani_lookup` | `074_muhasebe.sql` | — |
| `v_hizmet_lookup` | `071_kasa_master.sql` | — |
| `v_iade_edilebilir_satir` | `133_iade_irsaliye.sql` | 132_iade_satirlari.sql |
| `v_kullanici_lookup` | `156_ebelge_seri.sql` | — |
| `v_mali_hareket_ek` | `077_v_ekstre.sql` | — |
| `v_masraf_ekstre` | `077_v_ekstre.sql` | — |
| `v_masraf_lookup` | `071_kasa_master.sql` | — |
| `v_masraf_merkezi_lookup` | `071_kasa_master.sql` | — |
| `v_numara_turu_alis` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_odeme` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_satis` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_tahsilat` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_personel_lookup` | `054_personel_ozluk_mockup_uyum.sql` | — |
| `v_plan_vade` | `077_v_ekstre.sql` | — |
| `v_proje_ekstre` | `077_v_ekstre.sql` | — |
| `v_proje_lookup` | `071_kasa_master.sql` | — |
| `v_stok_kullanilabilir` | `142_siparis_rezervasyon.sql` | — |
| `v_stok_lookup` | `121_firsat.sql` | — |
| `v_ulke_lookup` | `119_stok_uts.sql` | — |

