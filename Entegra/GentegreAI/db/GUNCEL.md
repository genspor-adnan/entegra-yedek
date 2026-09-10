# Yururlukteki tanimlar (uretilmis dosya - ELLE DUZENLEMEYIN)

`araclar/guncel_indeks.ps1` uretir. Gocler tarihtir ve duzenlenmez;
bir nesne birden cok dosyada tanimlanmissa **en yuksek numarali dosya**
yururluktedir - degistirmeniz gereken yer odur.

## Fonksiyonlar (283 ad, 82 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `fn_ad_soyad_ayir` | `166_ebelge_json.sql` | — |
| `fn_ara_metin` | `027_arama_normalize.sql` | — |
| `fn_basvuru_hekim_rolu` | `364_kurum_profil_sube.sql` | 361_prim_rol_isaretleri.sql |
| `fn_belge_diptoplam` | `372_diptoplam_kdvli.sql` | 024_fn_belge_diptoplam.sql, 095_diptoplam_kdv_iskonto2.sql |
| `fn_belge_durum_kapatma` | `086_belge_donusum_kurallar.sql` | — |
| `fn_belge_fis_geri_al` | `190_belge_fisle.sql` | — |
| `fn_belge_fis_turu_uygun` | `429_uretim_v1.sql` | 280_taahhut_belgesi_fislenmez.sql, 281_tahakkuk_fislenmez.sql |
| `fn_belge_fis_uretilsin` | `281_tahakkuk_fislenmez.sql` | 192_mali_ayarlar.sql, 280_taahhut_belgesi_fislenmez.sql |
| `fn_belge_fisle` | `190_belge_fisle.sql` | — |
| `fn_belge_fisle_toplu` | `190_belge_fisle.sql` | — |
| `fn_belge_fiyatlandir` | `205_belge_fiyat_listesi.sql` | — |
| `fn_belge_kalem_fiyati` | `204_cari_fiyat_listesi.sql` | — |
| `fn_belge_kapanma_tazele` | `471_dagilim_kapanma_tahsil.sql` | 191_kapanma_tazele.sql, 289_odeme_paylasimi.sql, 395_kapanma_miktarla.sql |
| `fn_belge_kisa_adi` | `394_tahsilat_aciklama_belgeden.sql` | — |
| `fn_belge_no_anahtar` | `025_fn_belge_no.sql` | — |
| `fn_belge_no_uret` | `366_numara_onek_yil.sql` | 025_fn_belge_no.sql, 087_numara_kesme_duzeltmesi.sql, 152_numara_sablonu.sql |
| `fn_belge_rezerve` | `142_siparis_rezervasyon.sql` | — |
| `fn_belge_satir_dagilim_hesapla` | `485_ozel_kurum_sozlesmesiz.sql` | 476_dagilim_sayac_tazele.sql, 478_pay_kolonlari_dusur.sql, 481_dagilim_kdvli_fiyat.sql, 483_dagilim_sut_bedeli_ekrandan.sql |
| `fn_belge_satir_dagilim_tazele` | `483_dagilim_sut_bedeli_ekrandan.sql` | 472_dagilim_sigorta_prim.sql, 474_dagilim_tazele_duzeltme.sql, 476_dagilim_sayac_tazele.sql |
| `fn_belge_satir_dagit` | `470_belge_satir_dagilim.sql` | — |
| `fn_belge_satir_hesap` | `190_belge_fisle.sql` | — |
| `fn_belge_satir_kapatma` | `191_kapanma_tazele.sql` | 082_belge_donusum.sql |
| `fn_belge_satir_kapatma_tazele` | `478_pay_kolonlari_dusur.sql` | 082_belge_donusum.sql, 086_belge_donusum_kurallar.sql, 142_siparis_rezervasyon.sql, 289_odeme_paylasimi.sql, 471_dagilim_kapanma_tahsil.sql |
| `fn_belge_satir_paylastir` | `291_katilim_payi.sql` | 289_odeme_paylasimi.sql |
| `fn_belge_satir_rezerve_kirp` | `142_siparis_rezervasyon.sql` | — |
| `fn_belge_satir_tahsil_tazele` | `478_pay_kolonlari_dusur.sql` | 321_tahsilat_satir_dagitim.sql, 471_dagilim_kapanma_tahsil.sql |
| `fn_belge_sil` | `217_belge_sil_stok_guard.sql` | 181_belge_sil.sql |
| `fn_belge_silinebilir` | `226_uts_belge_guard.sql` | 181_belge_sil.sql |
| `fn_belge_varsayilan_liste` | `468_kurum_sozlesme_1n.sql` | 205_belge_fiyat_listesi.sql, 278_odeyen_kurum_varsayilan_liste.sql, 292_varsayilan_liste_kampanya.sql, 302_kurum_sozlesme_fiyat_listesi.sql |
| `fn_belge_yon` | `205_belge_fiyat_listesi.sql` | — |
| `fn_cari_fiyat_listesi` | `204_cari_fiyat_listesi.sql` | — |
| `fn_ceviri` | `194_ceviri.sql` | — |
| `fn_ceviri_sozluk` | `194_ceviri.sql` | — |
| `fn_cihaz_siradakiler` | `432_cihaz_ara_katman.sql` | — |
| `fn_dagilim_pay_grubu` | `470_belge_satir_dagilim.sql` | — |
| `fn_dagilim_rota` | `493_kurum_turu_kurumu_oder.sql` | 470_belge_satir_dagilim.sql |
| `fn_degistirme_tarihi` | `015_sema_log_ebelge.sql` | — |
| `fn_depo_kural_kontrol` | `093_depo_kurallar.sql` | — |
| `fn_depo_varsayilan_tek` | `090_depo_varsayilan.sql` | — |
| `fn_dokuman_kategori_alt_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_kategori_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_klasor_alt_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_klasor_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_tipi` | `431_dokuman_kategori.sql` | — |
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
| `fn_ebelge_hesap` | `338_entegrasyon_baz_sube.sql` | 171_sube_ebelge_mukellef.sql, 337_entegrasyon_uts_ebelge.sql |
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
| `fn_enabiz_siradakiler` | `428_kuyruk_takili_satir.sql` | 415_enabiz_cekirdek.sql |
| `fn_entegrasyon_hesap_id` | `338_entegrasyon_baz_sube.sql` | — |
| `fn_etiket_anahtar` | `003_goc_taraf.sql` | — |
| `fn_firsat_asama_izle` | `121_firsat.sql` | — |
| `fn_firsat_kazanildi_musteri` | `122_aday_musteri.sql` | — |
| `fn_firsat_no_uret` | `121_firsat.sql` | — |
| `fn_fiyat_carpan` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_fiyat_katki_uret` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_fiyat_listesi_dongu_kontrol` | `201_fiyat_listesi.sql` | — |
| `fn_fiyat_listesi_ek_katki` | `468_kurum_sozlesme_1n.sql` | — |
| `fn_fiyat_listesi_fiyat` | `495_fiyat_satir_kdv_listeden.sql` | 202_fn_fiyat_listesi.sql, 209_taban_fiyat_izi.sql, 211_taban_satir_izi.sql, 212_yazim_gecis_kurali.sql, 214_yazim_olusma_import.sql |
| `fn_fiyat_listesi_katki` | `291_katilim_payi.sql` | — |
| `fn_fiyat_listesi_uret` | `214_yazim_olusma_import.sql` | 202_fn_fiyat_listesi.sql, 209_taban_fiyat_izi.sql, 210_taban_liste_izi.sql, 211_taban_satir_izi.sql |
| `fn_fiyat_listesi_yon_kontrol` | `204_cari_fiyat_listesi.sql` | — |
| `fn_fiyat_yuvarla` | `202_fn_fiyat_listesi.sql` | — |
| `fn_fiyat_zam` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_gelen_belge_kaydet` | `187_gelen_belge.sql` | — |
| `fn_gelen_belge_yanit_yaz` | `187_gelen_belge.sql` | — |
| `fn_gelen_durum_adi` | `187_gelen_belge.sql` | — |
| `fn_gelen_mesajlar` | `189_gelen_mesajlar.sql` | — |
| `fn_goc_sube_coz` | `080_goc_kasa.sql` | — |
| `fn_hakedis_kapat` | `388_prim_kademe_baglandi.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql |
| `fn_hasta_dosya_no` | `366_numara_onek_yil.sql` | 356_hasta_dosya_no_otomatik.sql, 358_numara_sablonu_elle_girilir.sql |
| `fn_hesap_atama_adi` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_hesap_plani_alt_ac` | `076_fn_kasa.sql` | — |
| `fn_hizmet_modalite_coz` | `460_hizmet_modalite_onarim.sql` | — |
| `fn_hizmet_paket_ac` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_paket_derinlik` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_paket_dongu` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_uygunluk` | `482_hizmet_cinsiyet_yas.sql` | — |
| `fn_ilac_alerji_kontrol` | `414_metin_sadelestir.sql` | 413_recete.sql |
| `fn_ilac_fiyat` | `406_ilac_fiyat.sql` | — |
| `fn_ilac_fiyat_golge_tazele` | `406_ilac_fiyat.sql` | — |
| `fn_ilac_kamu_iskonto` | `407_sgk_ek4a_iskonto.sql` | — |
| `fn_ilac_stok_esle` | `511_ilac_stok_koprusu.sql` | — |
| `fn_ilac_stok_fiyati` | `408_ilac_stok_fiyat_matrah.sql` | — |
| `fn_ilac_stok_kart_ac` | `511_ilac_stok_koprusu.sql` | — |
| `fn_its_siradakiler` | `428_kuyruk_takili_satir.sql` | 427_its_bildirim.sql |
| `fn_kalem_kart_fiyati` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kampanya_fiyat` | `275_kampanya_liste_kalem_turu.sql` | 272_kampanya_fiyat.sql |
| `fn_kasa_islem_bacak_uret` | `393_bacak_belge_no.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql, 096_kasa_bacak_rol_kontrol.sql, 139_kasa_ekstre_dovizi.sql |
| `fn_kasa_islem_dogrula` | `085_fn_kasa_f3.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_duzelt_hazirla` | `148_kasa_islem_duzelt.sql` | — |
| `fn_kasa_islem_fisle` | `148_kasa_islem_duzelt.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_iptal` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_kesinlestir` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_no_uret` | `152_numara_sablonu.sql` | 073_kasa_islem.sql, 087_numara_kesme_duzeltmesi.sql |
| `fn_kasa_islem_silme_koruma` | `354_kasa_islem_silme_kosullari.sql` | 076_fn_kasa.sql |
| `fn_kategori_aktiflik_yay` | `527_profil_kategori.sql` | — |
| `fn_kdv_cevir` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kullanici_kasa` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_kullanici_yetkileri` | `068_taraf_rol_id_kolonlari.sql` | 020_sema_kimlik.sql |
| `fn_kurum_entegrasyon_durumu` | `491_kurum_entegrasyon_durumu.sql` | — |
| `fn_kurum_kampanya` | `274_belge_kampanya.sql` | 272_kampanya_fiyat.sql |
| `fn_kurum_kategori_uygula` | `527_profil_kategori.sql` | — |
| `fn_kurum_kurulum_adimlari` | `490_kurum_kurulum_adimlari.sql` | — |
| `fn_kurum_modul_acik` | `364_kurum_profil_sube.sql` | 359_kurum_profil.sql |
| `fn_kurum_profil` | `364_kurum_profil_sube.sql` | — |
| `fn_kurum_sozlesme_sec` | `468_kurum_sozlesme_1n.sql` | — |
| `fn_lab_acmg_sinif` | `439_lab_genetik.sql` | — |
| `fn_lab_antibiyogram_bildirim` | `437_lab_kombinasyon_ajani.sql` | 436_lab_mikrobiyoloji.sql |
| `fn_lab_antibiyogram_paneli` | `509_mikro_organizma_besiyeri.sql` | — |
| `fn_lab_barkod_kontrol` | `433_lab_v1.sql` | — |
| `fn_lab_barkod_uret` | `433_lab_v1.sql` | — |
| `fn_lab_bayrak` | `434_lab_cihaz_esleme.sql` | 433_lab_v1.sql |
| `fn_lab_calisma_sonuc_zamani` | `487_lab_calisma_takvimi.sql` | — |
| `fn_lab_cfu` | `509_mikro_organizma_besiyeri.sql` | — |
| `fn_lab_cihaz_calisma_listesi` | `434_lab_cihaz_esleme.sql` | — |
| `fn_lab_cihaz_tetkik` | `434_lab_cihaz_esleme.sql` | — |
| `fn_lab_dis_gonderim_no` | `445_lab_dis_gonderim.sql` | — |
| `fn_lab_genetik_ozet` | `439_lab_genetik.sql` | — |
| `fn_lab_indeks_etki` | `444_lab_serum_indeksi.sql` | — |
| `fn_lab_istem_sonuc_zamani` | `486_lab_tetkik_calisma_zamani.sql` | — |
| `fn_lab_kk_gecerli` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kk_hedef` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kk_kumulatif` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kultur_ozet` | `436_lab_mikrobiyoloji.sql` | — |
| `fn_lab_loinc_esle` | `530_lab_loinc_eslesme.sql` | — |
| `fn_lab_loinc_numune_uyar` | `530_lab_loinc_eslesme.sql` | — |
| `fn_lab_referans` | `434_lab_cihaz_esleme.sql` | 433_lab_v1.sql |
| `fn_lab_referans_kime` | `488_lab_yas_metni.sql` | — |
| `fn_lab_tetkik_bolum` | `529_lab_tetkik_katalogu_skrs.sql` | — |
| `fn_lab_tetkik_numune` | `529_lab_tetkik_katalogu_skrs.sql` | — |
| `fn_lab_tetkik_sonuc_zamani` | `487_lab_calisma_takvimi.sql` | 486_lab_tetkik_calisma_zamani.sql |
| `fn_lab_westgard` | `442_lab_kalite_kontrol.sql` | — |
| `fn_metin_anahtar` | `414_metin_sadelestir.sql` | — |
| `fn_metin_sadelestir` | `414_metin_sadelestir.sql` | — |
| `fn_mizan` | `077_v_ekstre.sql` | — |
| `fn_muh_hesap_coz` | `138_ceksenet_muhasebe_eslestirme.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_muhasebe_donem_kontrol` | `147_donem_kontrol_timestamp.sql` | 074_muhasebe.sql |
| `fn_muhasebe_fis_no_uret` | `087_numara_kesme_duzeltmesi.sql` | 074_muhasebe.sql |
| `fn_mukellef_sorgu_gerekli` | `185_mukellef_sorgu_tazelik.sql` | — |
| `fn_numara_onek_coz` | `366_numara_onek_yil.sql` | — |
| `fn_numara_onek_yilli` | `366_numara_onek_yil.sql` | — |
| `fn_numara_sablonu_bul` | `154_numara_sablonu_seed.sql` | 152_numara_sablonu.sql |
| `fn_numara_sirada` | `152_numara_sablonu.sql` | — |
| `fn_panel_profil` | `513_panel_blok_sirasi.sql` | 508_panel_kurum_profili.sql, 512_panel_tip_merkezi_tam.sql |
| `fn_parola_ata` | `068_taraf_rol_id_kolonlari.sql` | 020_sema_kimlik.sql |
| `fn_parola_dogru` | `020_sema_kimlik.sql` | — |
| `fn_plan_gerceklestir` | `085_fn_kasa_f3.sql` | — |
| `fn_prim_belge_turu` | `332_prim_zamani.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql, 331_kurum_tahakkuk_prim.sql |
| `fn_prim_gelir_belgesi` | `472_dagilim_sigorta_prim.sql` | 332_prim_zamani.sql |
| `fn_prim_kademe_orani` | `388_prim_kademe_baglandi.sql` | — |
| `fn_prim_kademe_uygula` | `390_kademe_sinir.sql` | 388_prim_kademe_baglandi.sql, 389_prim_kademe_duzeltme.sql |
| `fn_prim_onayla` | `330_prim_tahsilat_turu_durum.sql` | — |
| `fn_prim_plan_satiri` | `380_prim_plani_odeyen_tipi.sql` | 324_prim_semasi.sql, 327_prim_hedef_kategori.sql, 328_prim_kapsam_kampanya_deseni.sql, 330_prim_tahsilat_turu_durum.sql, 332_prim_zamani.sql, 375_prim_plani_taraf.sql, 379_prim_plani_rol.sql |
| `fn_prim_rol_aday_sayisi` | `362_gonderen_calisma_sekli.sql` | — |
| `fn_prim_taslak_mi` | `330_prim_tahsilat_turu_durum.sql` | — |
| `fn_prim_uret` | `339_prim_taslak_uretilmez.sql` | 324_prim_semasi.sql, 326_radyoloji_prim_rol.sql, 328_prim_kapsam_kampanya_deseni.sql, 330_prim_tahsilat_turu_durum.sql, 331_kurum_tahakkuk_prim.sql, 332_prim_zamani.sql |
| `fn_prim_uret_belge` | `492_prim_dagilim_kovalari.sql` | 332_prim_zamani.sql |
| `fn_rad_rol_tazele` | `332_prim_zamani.sql` | 326_radyoloji_prim_rol.sql |
| `fn_radyoloji_accession` | `283_radyoloji_cekirdek.sql` | — |
| `fn_radyoloji_rapor_no` | `303_radyoloji_rapor_no.sql` | — |
| `fn_radyoloji_rapor_onaylanabilir` | `284_radyoloji_operasyon.sql` | — |
| `fn_radyoloji_sonuc_durumu` | `418_muayene_istem_bagi.sql` | — |
| `fn_sgk_katilim_emanet_yaz` | `477_katilim_emanet_doviz.sql` | 473_katilim_emaneti.sql |
| `fn_sigorta_ozet_tazele` | `430_sigorta_v1.sql` | — |
| `fn_sigorta_pay_dagit` | `472_dagilim_sigorta_prim.sql` | 430_sigorta_v1.sql |
| `fn_sigorta_pay_geri_al` | `472_dagilim_sigorta_prim.sql` | — |
| `fn_sigorta_ref_no` | `430_sigorta_v1.sql` | — |
| `fn_siradaki_hasta` | `410_hekim_calisma_listesi.sql` | — |
| `fn_skrs_ambar_uret` | `521_skrs_katalog_kurulum.sql` | — |
| `fn_skrs_kod` | `503_skrs_kod_dikisi.sql` | — |
| `fn_sls_carpan_manuel` | `214_yazim_olusma_import.sql` | 209_taban_fiyat_izi.sql, 212_yazim_gecis_kurali.sql, 213_fiyat_elle_degisim.sql |
| `fn_slug` | `021_goc_kimlik.sql` | — |
| `fn_stok_kart_fiyat` | `128_fn_stok_kart_fiyat.sql` | — |
| `fn_stok_kopyala` | `127_stok_kopyala_fiyat.sql` | 126_fn_stok_kopyala.sql |
| `fn_stok_paket_kontrol` | `124_stok_paket.sql` | — |
| `fn_stok_rezerve_tazele` | `142_siparis_rezervasyon.sql` | — |
| `fn_sube_depo_subeleri` | `227_baz_sube.sql` | 173_sube_depo.sql, 174_merkez_depo_kullan.sql |
| `fn_sube_ebelge_hazir` | `169_sube_ebelge_kimlik.sql` | — |
| `fn_sube_ebelge_kimlik_turet` | `228_ebelge_baz_kimlik.sql` | — |
| `fn_sube_gorsel` | `193_firma_kase.sql` | — |
| `fn_sube_mali` | `192_mali_ayarlar.sql` | — |
| `fn_sube_merkez_id` | `169_sube_ebelge_kimlik.sql` | — |
| `fn_taraf_kampanya` | `468_kurum_sozlesme_1n.sql` | 274_belge_kampanya.sql |
| `fn_taraf_kisi_unvan_ata` | `037_kisi_karti.sql` | — |
| `fn_telefon_rakam` | `123_telefon_arama.sql` | — |
| `fn_tevkifat_orani` | `176_tevkifat_istisna.sql` | — |
| `fn_ubl_taraf` | `182_ebelge_ubl.sql` | — |
| `fn_uretim_emri_no` | `429_uretim_v1.sql` | — |
| `fn_uretim_malzeme_hazirlik` | `429_uretim_v1.sql` | — |
| `fn_uretim_stok_maliyeti` | `429_uretim_v1.sql` | — |
| `fn_uretim_zaman_hesapla` | `429_uretim_v1.sql` | — |
| `fn_uretim_zaman_topla` | `429_uretim_v1.sql` | — |
| `fn_urun_agaci_maliyet` | `429_uretim_v1.sql` | — |
| `fn_urun_modu` | `489_urun_modu_profilden.sql` | — |
| `fn_uts_hesap` | `338_entegrasyon_baz_sube.sql` | 223_uts_sema.sql, 227_baz_sube.sql, 337_entegrasyon_uts_ebelge.sql |
| `fn_yas_metni` | `488_lab_yas_metni.sql` | — |
| `fn_yerel_para` | `111_ekstre_doviz_gruplu.sql` | — |
| `fn_yetki_surumu_artir` | `020_sema_kimlik.sql` | — |
| `tg_belge_basvuru_sozlesme` | `494_basvuru_kurumu_oder.sql` | 469_basvuru_sozlesme.sql, 485_ozel_kurum_sozlesmesiz.sql |
| `tg_belge_satir_dagilim_denge` | `470_belge_satir_dagilim.sql` | — |
| `tg_belge_satir_rol_dogrula` | `361_prim_rol_isaretleri.sql` | — |
| `tg_belge_satir_uygunluk` | `482_hizmet_cinsiyet_yas.sql` | — |
| `tg_departman_dongu_engel` | `257_departman_ustbirim.sql` | — |
| `tg_fiyat_satir_birim` | `506_fiyat_satir_birim.sql` | — |
| `tg_fiyat_satir_tarife` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `tg_hizmet_paket_bayrak` | `502_hizmet_paket_bayragi.sql` | — |
| `tg_hizmet_paket_bayrak_kontrol` | `502_hizmet_paket_bayragi.sql` | — |
| `tg_hizmet_paket_dongu` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `tg_hizmet_radyoloji_bayrak` | `514_hizmet_radyoloji_bayragi.sql` | — |
| `tg_kasa_dagitim_kontrol` | `471_dagilim_kapanma_tahsil.sql` | 321_tahsilat_satir_dagitim.sql, 323_tahsilat_kdv_dahil.sql |
| `tg_kasa_dagitim_sil_tazele` | `354_kasa_islem_silme_kosullari.sql` | — |
| `tg_kasa_dagitim_tazele` | `321_tahsilat_satir_dagitim.sql` | — |
| `tg_kasa_islem_sil_fis` | `354_kasa_islem_silme_kosullari.sql` | — |
| `tg_kasa_islem_tahsil_tazele` | `321_tahsilat_satir_dagitim.sql` | — |
| `tg_kategori_aktiflik` | `527_profil_kategori.sql` | — |
| `tg_kategori_dongu_engel` | `270_kategori_agaci.sql` | — |
| `tg_kurum_sozlesme_kontrol` | `517_kurum_sozlesme_sgk_carisi.sql` | 468_kurum_sozlesme_1n.sql, 493_kurum_turu_kurumu_oder.sql |
| `tg_lab_panel_hizmet` | `501_panel_icerigi_tek_kaynak.sql` | — |
| `tg_lab_panel_satir_yaz` | `501_panel_icerigi_tek_kaynak.sql` | — |
| `tg_lab_varyant_sinif` | `439_lab_genetik.sql` | — |
| `tg_mesaj_sohbet_tazele` | `342_mesajlasma.sql` | — |
| `tg_muayene_durum_istemden` | `418_muayene_istem_bagi.sql` | — |
| `tg_muayene_istem_radyoloji` | `418_muayene_istem_bagi.sql` | — |
| `tg_muayene_rapor_bitis` | `464_muayene_rapor_mockup.sql` | — |
| `tg_muayene_rapor_hasta` | `462_muayene_rapor.sql` | — |
| `tg_muayene_vital_bki` | `463_vital_bki.sql` | — |
| `tg_prim_belge_tur` | `332_prim_zamani.sql` | 330_prim_tahsilat_turu_durum.sql |
| `tg_prim_dagitim` | `324_prim_semasi.sql` | — |
| `tg_prim_donusum` | `332_prim_zamani.sql` | 324_prim_semasi.sql |
| `tg_prim_donusum_sil` | `332_prim_zamani.sql` | — |
| `tg_prim_hedef_tek` | `327_prim_hedef_kategori.sql` | — |
| `tg_prim_kapsam` | `329_prim_satir_silme_mesaji.sql` | 328_prim_kapsam_kampanya_deseni.sql |
| `tg_prim_kasa_durum` | `324_prim_semasi.sql` | — |
| `tg_prim_plani_silme` | `329_prim_satir_silme_mesaji.sql` | — |
| `tg_prim_plani_taraf_dogrula` | `386_prim_taraf_hata_mesaji.sql` | 382_prim_taraf_dis_hekim_kurali.sql, 383_prim_taraf_rol_kurali.sql, 384_prim_taraf_aktif_sarti.sql |
| `tg_prim_plani_zaman` | `333_prim_zamani_ilk_kapi.sql` | — |
| `tg_prim_satir_rol` | `385_prim_satir_rol_plandan.sql` | — |
| `tg_prim_satir_silme` | `329_prim_satir_silme_mesaji.sql` | — |
| `tg_prim_satir_zaman` | `333_prim_zamani_ilk_kapi.sql` | — |
| `tg_rad_rol_istem` | `326_radyoloji_prim_rol.sql` | — |
| `tg_rad_rol_rapor` | `326_radyoloji_prim_rol.sql` | — |
| `tg_radyoloji_cekim_kontrolu` | `312_cekim_kontrolu_is_kurali_kodu.sql` | 310_radyoloji_kontrol_listesi.sql |
| `tg_radyoloji_istem_guncelle` | `287_radyoloji_accession_tetik.sql` | — |
| `tg_radyoloji_istem_hazirla` | `287_radyoloji_accession_tetik.sql` | — |
| `tg_radyoloji_istem_hizmet` | `459_radyoloji_istem_hizmet_kontrolu.sql` | — |
| `tg_radyoloji_istem_uygunluk` | `482_hizmet_cinsiyet_yas.sql` | — |
| `tg_radyoloji_protokol_bayrak` | `514_hizmet_radyoloji_bayragi.sql` | — |
| `tg_radyoloji_protokol_metin` | `515_radyoloji_protokol_combo.sql` | — |
| `tg_randevu_cakisma` | `317_randevu_tetkik_uyum.sql` | 316_randevu_cihaz_kaynagi.sql |
| `tg_sube_vkn_dogrula` | `170_sube_vkn_dogrula.sql` | — |
| `tg_tani_kronik_yansit` | `420_hasta_tibbi_gecmis.sql` | — |
| `tg_taraf_hasta_dosya_no` | `396_hasta_dosya_no_otomatik.sql` | 356_hasta_dosya_no_otomatik.sql, 358_numara_sablonu_elle_girilir.sql |
| `tg_taraf_hasta_kurum_tek_aktif` | `248_taraf_hasta_kurum.sql` | — |
| `tg_taraf_hasta_kurum_yansit` | `277_hasta_kurum_tek_kaynak.sql` | — |
| `tg_taraf_prim_rol_dogrula` | `369_primli_calisma_sekli.sql` | 361_prim_rol_isaretleri.sql, 362_gonderen_calisma_sekli.sql |

## Gorunumler (132 ad, 39 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `cari` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `hasta` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `lab_panel_satir` | `501_panel_icerigi_tek_kaynak.sql` | — |
| `musteri` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `personel` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `personel_acil_kisi` | `335_hasta_kimlik_tamamlama.sql` | — |
| `tedarikci` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `v_alt_kurum_lookup` | `468_kurum_sozlesme_1n.sql` | — |
| `v_banka_lookup` | `109_banka.sql` | — |
| `v_banka_sube_lookup` | `110_banka_sube_bagli_ve_kur.sql` | 109_banka.sql |
| `v_belge_acik_satir` | `471_dagilim_kapanma_tahsil.sql` | 082_belge_donusum.sql, 290_acik_satir_pay.sql, 293_acik_satir_kalem_adi.sql, 352_donusum_tutar_bazli.sql |
| `v_belge_donusum` | `086_belge_donusum_kurallar.sql` | — |
| `v_belge_satir_izlem` | `115_izlem_depo.sql` | 114_belge_izlem.sql |
| `v_belge_satir_tahsilat` | `471_dagilim_kapanma_tahsil.sql` | 321_tahsilat_satir_dagitim.sql, 323_tahsilat_kdv_dahil.sql |
| `v_belge_sevkiyat` | `177_belge_sevkiyat.sql` | — |
| `v_cari_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_cari_lookup` | `122_aday_musteri.sql` | 037_kisi_karti.sql |
| `v_cek_senet_portfoy` | `072_cek_senet.sql` | — |
| `v_cihaz_lookup` | `432_cihaz_ara_katman.sql` | — |
| `v_departman_lookup` | `256_departman_durum.sql` | 251_departman.sql, 254_departman_kod.sql |
| `v_depo_lookup` | `093_depo_kurallar.sql` | 088_belge_irsaliye_alanlari.sql |
| `v_dis_hekim_lookup` | `309_dis_hekim_kurum_taraf_bag.sql` | 305_dis_hekim.sql, 308_dis_hekim_kurum_ad_kaldir.sql |
| `v_dokuman_akis_lookup` | `431_dokuman_kategori.sql` | — |
| `v_dokuman_baglanti` | `423_dokuman_iliski.sql` | — |
| `v_dokuman_erisim` | `425_dokuman_erisim.sql` | — |
| `v_dokuman_kategori_lookup` | `431_dokuman_kategori.sql` | — |
| `v_dokuman_klasor_lookup` | `421_dokuman_lookup.sql` | — |
| `v_dokuman_onay_adim` | `422_dokuman_kart_gorunumleri.sql` | — |
| `v_dokuman_paylasim` | `424_dokuman_paylasim.sql` | — |
| `v_dokuman_turu_lookup` | `421_dokuman_lookup.sql` | — |
| `v_ebelge_entegrator_lookup` | `171_sube_ebelge_mukellef.sql` | — |
| `v_ebelge_gonderici` | `169_sube_ebelge_kimlik.sql` | 165_firma_bilgileri.sql |
| `v_ebelge_turu_lookup` | `156_ebelge_seri.sql` | — |
| `v_ebelge_yon_lookup` | `159_ebelge_xslt.sql` | — |
| `v_entegrasyon_hesap_lookup` | `430_sigorta_v1.sql` | — |
| `v_entegrasyon_kod_lookup` | `337_entegrasyon_uts_ebelge.sql` | 336_entegrasyon_hesap.sql |
| `v_firsat_asama_gecmis` | `121_firsat.sql` | — |
| `v_firsat_liste` | `121_firsat.sql` | — |
| `v_fiyat_listesi_alis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_kullanim` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_lookup` | `201_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_satir` | `507_fiyat_satir_gorunum_kdv_kategori.sql` | 201_fiyat_listesi.sql |
| `v_fiyat_listesi_satis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_gorev_lookup` | `255_personel_gorev.sql` | — |
| `v_hakedis_ozet` | `330_prim_tahsilat_turu_durum.sql` | 324_prim_semasi.sql |
| `v_hakedis_satir` | `363_hakedis_rol_isaret_kontrolu.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql, 332_prim_zamani.sql |
| `v_hasta_lookup` | `266_aday_hasta.sql` | 244_hasta_lookup.sql, 262_hasta_lookup_kimlik.sql, 263_hasta_lookup_cinsiyet_yas.sql, 264_hasta_lookup_cinsiyet_bos.sql |
| `v_hasta_tibbi_ozet` | `420_hasta_tibbi_gecmis.sql` | — |
| `v_hekim_lookup` | `253_hekim_pasif_dislama.sql` | 252_personel_randevu_verilebilir.sql |
| `v_hesap_atama_lookup` | `199_kasa_atama_listesi.sql` | 197_kasa_atama_tek_alan.sql |
| `v_hesap_bakiye` | `077_v_ekstre.sql` | — |
| `v_hesap_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_hesap_lookup` | `071_kasa_master.sql` | — |
| `v_hesap_plani_lookup` | `074_muhasebe.sql` | — |
| `v_hizmet_baslik_lookup` | `521_skrs_katalog_kurulum.sql` | — |
| `v_hizmet_lookup` | `482_hizmet_cinsiyet_yas.sql` | 071_kasa_master.sql |
| `v_hizmet_paket_eksik` | `502_hizmet_paket_bayragi.sql` | — |
| `v_hizmet_paket_ozet` | `496_hizmet_paket.sql` | — |
| `v_hizmet_radyoloji_eksik` | `514_hizmet_radyoloji_bayragi.sql` | — |
| `v_iade_edilebilir_satir` | `133_iade_irsaliye.sql` | 132_iade_satirlari.sql |
| `v_icd_lookup` | `409_muayene_v1.sql` | — |
| `v_ilac_stoksuz` | `511_ilac_stok_koprusu.sql` | — |
| `v_is_merkezi_lookup` | `429_uretim_v1.sql` | — |
| `v_kampanya_lookup` | `268_kampanya.sql` | — |
| `v_kasa_islem_dagitim` | `322_avans_mahsup.sql` | — |
| `v_kategori_lookup` | `505_skrs_liste_duzeltme_kategori_tur.sql` | 250_kategori_lookup.sql, 270_kategori_agaci.sql, 347_sonomed_rad_kategori.sql |
| `v_kullanici_lookup` | `156_ebelge_seri.sql` | — |
| `v_kurum_lookup` | `478_pay_kolonlari_dusur.sql` | 249_kurum_sozlesme.sql, 250_kategori_lookup.sql |
| `v_kurum_sozlesme_lookup` | `468_kurum_sozlesme_1n.sql` | — |
| `v_lab_antibiyotik_lookup` | `436_lab_mikrobiyoloji.sql` | — |
| `v_lab_besiyeri_lookup` | `436_lab_mikrobiyoloji.sql` | — |
| `v_lab_cihaz_esleme` | `434_lab_cihaz_esleme.sql` | — |
| `v_lab_dis_geciken` | `445_lab_dis_gonderim.sql` | — |
| `v_lab_dis_lab_lookup` | `445_lab_dis_gonderim.sql` | — |
| `v_lab_gen_lookup` | `439_lab_genetik.sql` | — |
| `v_lab_genetik_panel_lookup` | `439_lab_genetik.sql` | — |
| `v_lab_genetik_run_lookup` | `439_lab_genetik.sql` | — |
| `v_lab_kk_lj` | `442_lab_kalite_kontrol.sql` | — |
| `v_lab_kk_lot_lookup` | `442_lab_kalite_kontrol.sql` | — |
| `v_lab_loinc_oneri` | `530_lab_loinc_eslesme.sql` | — |
| `v_lab_numune_lookup` | `479_lab_numune_lookup.sql` | — |
| `v_lab_organizma_lookup` | `436_lab_mikrobiyoloji.sql` | — |
| `v_lab_panel_lookup` | `433_lab_v1.sql` | — |
| `v_lab_tetkik_lookup` | `433_lab_v1.sql` | — |
| `v_lab_varyant_yeniden` | `439_lab_genetik.sql` | — |
| `v_mali_hareket_ek` | `392_iptal_ters_kayit_ekstre.sql` | 077_v_ekstre.sql |
| `v_masraf_ekstre` | `077_v_ekstre.sql` | — |
| `v_masraf_lookup` | `071_kasa_master.sql` | — |
| `v_masraf_merkezi_lookup` | `071_kasa_master.sql` | — |
| `v_mesaj_sohbet` | `342_mesajlasma.sql` | — |
| `v_muayene_sablon_alan_lookup` | `409_muayene_v1.sql` | — |
| `v_muayene_sablon_lookup` | `411_muayene_sablon_makro.sql` | 409_muayene_v1.sql |
| `v_numara_turu_alis` | `334_tahakkuk_tur_takas.sql` | 152_numara_sablonu.sql, 153_numara_turu_gorunum_tip.sql |
| `v_numara_turu_kimlik` | `358_numara_sablonu_elle_girilir.sql` | — |
| `v_numara_turu_odeme` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_satis` | `334_tahakkuk_tur_takas.sql` | 152_numara_sablonu.sql, 153_numara_turu_gorunum_tip.sql |
| `v_numara_turu_tahsilat` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_personel_lookup` | `054_personel_ozluk_mockup_uyum.sql` | — |
| `v_plan_vade` | `077_v_ekstre.sql` | — |
| `v_prim_rol_aday` | `369_primli_calisma_sekli.sql` | 361_prim_rol_isaretleri.sql, 362_gonderen_calisma_sekli.sql, 367_prim_rol_aday_bolum.sql |
| `v_prim_rol_lookup` | `391_prim_rol_lookup_onarim.sql` | 362_gonderen_calisma_sekli.sql |
| `v_prim_taraf_lookup` | `378_prim_taraf_lookup_aktif.sql` | 375_prim_plani_taraf.sql, 377_prim_taraf_lookup_genis.sql |
| `v_proje_ekstre` | `077_v_ekstre.sql` | — |
| `v_proje_lookup` | `071_kasa_master.sql` | — |
| `v_rad_cihaz_lookup` | `286_radyoloji_lookup.sql` | — |
| `v_rad_hekim_lookup` | `313_rad_hekim_lookup_dis_hekim.sql` | 283_radyoloji_cekirdek.sql |
| `v_rad_tetkik_lookup` | `286_radyoloji_lookup.sql` | — |
| `v_radyoloji_cihaz_lookup` | `316_randevu_cihaz_kaynagi.sql` | — |
| `v_radyoloji_kritik_takip` | `318_radyoloji_takip_listeleri.sql` | — |
| `v_radyoloji_protokol_malzeme` | `320_radyoloji_sarf.sql` | — |
| `v_radyoloji_teslim_takip` | `318_radyoloji_takip_listeleri.sql` | — |
| `v_radyoloji_tetkik` | `304_radyoloji_istem_acma.sql` | — |
| `v_radyoloji_worklist` | `296_belge_basvuru.sql` | 283_radyoloji_cekirdek.sql |
| `v_randevu_bolum_lookup` | `256_departman_durum.sql` | 251_departman.sql, 254_departman_kod.sql |
| `v_randevu_tetkik_sure` | `317_randevu_tetkik_uyum.sql` | — |
| `v_rol_lookup` | `425_dokuman_erisim.sql` | — |
| `v_sgk_katilim_emanet` | `473_katilim_emaneti.sql` | — |
| `v_sigorta_hesap_lookup` | `430_sigorta_v1.sql` | — |
| `v_sigorta_saglayici_lookup` | `430_sigorta_v1.sql` | — |
| `v_skrs_ham_alan` | `520_skrs_katalog_ambari.sql` | — |
| `v_skrs_klinik_lookup` | `455_skrs_klinik.sql` | — |
| `v_skrs_sapma` | `503_skrs_kod_dikisi.sql` | — |
| `v_stok_kullanilabilir` | `142_siparis_rezervasyon.sql` | — |
| `v_stok_lookup` | `121_firsat.sql` | — |
| `v_stok_onek_dagilim` | `524_stok_kategorisi.sql` | — |
| `v_sube_baz_lookup` | `227_baz_sube.sql` | — |
| `v_tahsilat_turu_lookup` | `330_prim_tahsilat_turu_durum.sql` | — |
| `v_taraf_avans` | `322_avans_mahsup.sql` | — |
| `v_ulke_lookup` | `119_stok_uts.sql` | — |
| `v_uretim_emri_lookup` | `429_uretim_v1.sql` | — |
| `v_uretim_hareket` | `429_uretim_v1.sql` | — |
| `v_urun_agaci_lookup` | `429_uretim_v1.sql` | — |

