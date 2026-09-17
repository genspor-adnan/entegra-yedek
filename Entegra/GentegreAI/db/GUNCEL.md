# Yururlukteki tanimlar (uretilmis dosya - ELLE DUZENLEMEYIN)

`araclar/guncel_indeks.ps1` uretir. Gocler tarihtir ve duzenlenmez;
bir nesne birden cok dosyada tanimlanmissa **en yuksek numarali dosya**
yururluktedir - degistirmeniz gereken yer odur.

## Fonksiyonlar (396 ad, 112 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `fn_acil_cikis_kontrol` | `716_acil_servis.sql` | — |
| `fn_acil_protokol_no_uret` | `719_ameliyathane_acil_akis.sql` | — |
| `fn_acil_triyaj_iz` | `716_acil_servis.sql` | — |
| `fn_ad_soyad_ayir` | `166_ebelge_json.sql` | — |
| `fn_ameliyat_no_uret` | `719_ameliyathane_acil_akis.sql` | — |
| `fn_ameliyat_not_imza_kilidi` | `719_ameliyathane_acil_akis.sql` | — |
| `fn_ameliyat_salon_cakisma` | `719_ameliyathane_acil_akis.sql` | — |
| `fn_ameliyat_sayim_uyum` | `715_ameliyathane.sql` | — |
| `fn_ara_metin` | `027_arama_normalize.sql` | — |
| `fn_baslik_harf` | `653_baslik_harfi_kisaltma_ek.sql` | 630_baslik_harf.sql, 651_hizmet_adi_baslik_harfi.sql, 652_baslik_harfi_tireli_kisaltma.sql |
| `fn_baslik_kelime` | `630_baslik_harf.sql` | — |
| `fn_baslik_parca` | `653_baslik_harfi_kisaltma_ek.sql` | 652_baslik_harfi_tireli_kisaltma.sql |
| `fn_basvuru_hekim_dis_mi` | `578_basvuru_hekim_kaynagi.sql` | — |
| `fn_basvuru_hekim_rolu` | `364_kurum_profil_sube.sql` | 361_prim_rol_isaretleri.sql |
| `fn_basvuru_yapan_rolu` | `584_basvuru_yapan_primi.sql` | — |
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
| `fn_belge_satir_dagilim_hesapla` | `600_karma_tutar_geri_yazma.sql` | 476_dagilim_sayac_tazele.sql, 478_pay_kolonlari_dusur.sql, 481_dagilim_kdvli_fiyat.sql, 483_dagilim_sut_bedeli_ekrandan.sql, 485_ozel_kurum_sozlesmesiz.sql, 586_katki_iskontosu.sql, 590_katilim_payi_ve_emekli.sql, 591_katki_kdv_dahil.sql, 592_katilim_kodlari_ve_katki_listesi.sql, 594_dagilim_coz_ve_onizleme.sql |
| `fn_belge_satir_dagilim_tazele` | `586_katki_iskontosu.sql` | 472_dagilim_sigorta_prim.sql, 474_dagilim_tazele_duzeltme.sql, 476_dagilim_sayac_tazele.sql, 483_dagilim_sut_bedeli_ekrandan.sql |
| `fn_belge_satir_dagit` | `599_provizyon_tutari_belirler.sql` | 470_belge_satir_dagilim.sql, 596_tss_provizyon_farki_hastaya.sql |
| `fn_belge_satir_hesap` | `190_belge_fisle.sql` | — |
| `fn_belge_satir_hizmet_kullanim` | `552_stok_ilac_kisa_ad_kullanim.sql` | 550_hizmet_kullanim_puani.sql |
| `fn_belge_satir_kapatma` | `191_kapanma_tazele.sql` | 082_belge_donusum.sql |
| `fn_belge_satir_kapatma_tazele` | `478_pay_kolonlari_dusur.sql` | 082_belge_donusum.sql, 086_belge_donusum_kurallar.sql, 142_siparis_rezervasyon.sql, 289_odeme_paylasimi.sql, 471_dagilim_kapanma_tahsil.sql |
| `fn_belge_satir_paylastir` | `291_katilim_payi.sql` | 289_odeme_paylasimi.sql |
| `fn_belge_satir_rezerve_kirp` | `142_siparis_rezervasyon.sql` | — |
| `fn_belge_satir_tahsil_tazele` | `660_iade_satir_tahsil.sql` | 321_tahsilat_satir_dagitim.sql, 471_dagilim_kapanma_tahsil.sql, 478_pay_kolonlari_dusur.sql |
| `fn_belge_sil` | `217_belge_sil_stok_guard.sql` | 181_belge_sil.sql |
| `fn_belge_silinebilir` | `226_uts_belge_guard.sql` | 181_belge_sil.sql |
| `fn_belge_talep_yazi` | `770_belge_talep_yazisi_para_bicimi.sql` | 768_belge_talep_yazisi.sql |
| `fn_belge_varsayilan_liste` | `601_sgk_tarife_sut_listesi.sql` | 205_belge_fiyat_listesi.sql, 278_odeyen_kurum_varsayilan_liste.sql, 292_varsayilan_liste_kampanya.sql, 302_kurum_sozlesme_fiyat_listesi.sql, 468_kurum_sozlesme_1n.sql, 588_kurum_tarifesi_coklu_sozlesme.sql |
| `fn_belge_yon` | `205_belge_fiyat_listesi.sql` | — |
| `fn_bolum_planli` | `718_hekim_calisma_plani.sql` | — |
| `fn_cari_fiyat_listesi` | `204_cari_fiyat_listesi.sql` | — |
| `fn_ceviri` | `194_ceviri.sql` | — |
| `fn_ceviri_sozluk` | `194_ceviri.sql` | — |
| `fn_cihaz_siradakiler` | `432_cihaz_ara_katman.sql` | — |
| `fn_dagilim_coz` | `603_ek_katki_kaldirildi.sql` | 594_dagilim_coz_ve_onizleme.sql, 595_katki_yalniz_tss_sgk.sql, 602_sut_bedeli_iskontosuz.sql |
| `fn_dagilim_onizle` | `594_dagilim_coz_ve_onizleme.sql` | — |
| `fn_dagilim_pay_grubu` | `470_belge_satir_dagilim.sql` | — |
| `fn_dagilim_rota` | `597_tss_sgk_kullanilmasin.sql` | 470_belge_satir_dagilim.sql, 493_kurum_turu_kurumu_oder.sql |
| `fn_degistirme_tarihi` | `015_sema_log_ebelge.sql` | — |
| `fn_demirbas_is_emri_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_demirbas_kalib_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_demirbas_kalibrasyon_isle` | `723_demirbas_kalibrasyon.sql` | — |
| `fn_demirbas_kod_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_demirbas_olcum_sonuc` | `727_olcum_sapma.sql` | 723_demirbas_kalibrasyon.sql |
| `fn_depo_kural_kontrol` | `093_depo_kurallar.sql` | — |
| `fn_depo_varsayilan_tek` | `090_depo_varsayilan.sql` | — |
| `fn_dis_no_uret` | `706_dis_modulu.sql` | — |
| `fn_dis_plan_toplam_tazele` | `706_dis_modulu.sql` | — |
| `fn_dokuman_kategori_alt_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_kategori_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_klasor_alt_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_klasor_yol` | `431_dokuman_kategori.sql` | — |
| `fn_dokuman_onay_sonuc` | `758_dokuman_onay_omurga.sql` | — |
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
| `fn_ebelge_html` | `769_para_bicimi_tr.sql` | 178_ebelge_onizleme.sql |
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
| `fn_eczane_hazirlama_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_eczane_imha_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_enabiz_siradakiler` | `428_kuyruk_takili_satir.sql` | 415_enabiz_cekirdek.sql |
| `fn_entegrasyon_hesap_id` | `338_entegrasyon_baz_sube.sql` | — |
| `fn_erken_uyari` | `699_erken_uyari_skoru.sql` | — |
| `fn_etiket_anahtar` | `003_goc_taraf.sql` | — |
| `fn_firsat_asama_izle` | `121_firsat.sql` | — |
| `fn_firsat_kazanildi_musteri` | `122_aday_musteri.sql` | — |
| `fn_firsat_no_uret` | `121_firsat.sql` | — |
| `fn_fiyat_carpan` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_fiyat_katki_uret` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_fiyat_katsayi_yukle` | `533_ttb_fiyat_turetilmis.sql` | — |
| `fn_fiyat_liste_turet` | `538_ozel_kat_on.sql` | 536_ozel_fiyat_turet.sql |
| `fn_fiyat_listesi_dongu_kontrol` | `201_fiyat_listesi.sql` | — |
| `fn_fiyat_listesi_ek_katki` | `539_turetilmis_liste_sokuldu.sql` | 468_kurum_sozlesme_1n.sql |
| `fn_fiyat_listesi_fiyat` | `539_turetilmis_liste_sokuldu.sql` | 202_fn_fiyat_listesi.sql, 209_taban_fiyat_izi.sql, 211_taban_satir_izi.sql, 212_yazim_gecis_kurali.sql, 214_yazim_olusma_import.sql, 495_fiyat_satir_kdv_listeden.sql |
| `fn_fiyat_listesi_katki` | `539_turetilmis_liste_sokuldu.sql` | 291_katilim_payi.sql |
| `fn_fiyat_listesi_katki_kdv_dahil` | `591_katki_kdv_dahil.sql` | — |
| `fn_fiyat_listesi_kopyala` | `540_fiyat_listesi_kopyala.sql` | — |
| `fn_fiyat_listesi_kullanim` | `543_fiyat_listesi_sil_koruma.sql` | — |
| `fn_fiyat_listesi_sil_kontrol` | `543_fiyat_listesi_sil_koruma.sql` | — |
| `fn_fiyat_listesi_tarife_modu` | `542_fiyat_listesi_tarife_modu.sql` | — |
| `fn_fiyat_listesi_uret` | `539_turetilmis_liste_sokuldu.sql` | 202_fn_fiyat_listesi.sql, 209_taban_fiyat_izi.sql, 210_taban_liste_izi.sql, 211_taban_satir_izi.sql, 214_yazim_olusma_import.sql |
| `fn_fiyat_listesi_yon_kontrol` | `204_cari_fiyat_listesi.sql` | — |
| `fn_fiyat_sut_yukle` | `535_sut_fiyat_guncelle.sql` | — |
| `fn_fiyat_yuvarla` | `202_fn_fiyat_listesi.sql` | — |
| `fn_fiyat_zam` | `518_fiyat_listesi_tarife_tipi.sql` | — |
| `fn_ftr_no_uret` | `719_ftr_modulu.sql` | — |
| `fn_gelen_belge_kaydet` | `187_gelen_belge.sql` | — |
| `fn_gelen_belge_yanit_yaz` | `187_gelen_belge.sql` | — |
| `fn_gelen_durum_adi` | `187_gelen_belge.sql` | — |
| `fn_gelen_mesajlar` | `189_gelen_mesajlar.sql` | — |
| `fn_goc_sube_coz` | `080_goc_kasa.sql` | — |
| `fn_hakedis_kapat` | `388_prim_kademe_baglandi.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql |
| `fn_hasta_dosya_no` | `366_numara_onek_yil.sql` | 356_hasta_dosya_no_otomatik.sql, 358_numara_sablonu_elle_girilir.sql |
| `fn_hekim_calisma_bloklari` | `748_izin_calisma_plani.sql` | 718_hekim_calisma_plani.sql |
| `fn_hekim_izinli` | `748_izin_calisma_plani.sql` | — |
| `fn_hekim_planli` | `718_hekim_calisma_plani.sql` | — |
| `fn_hesap_atama_adi` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_hesap_plani_alt_ac` | `076_fn_kasa.sql` | — |
| `fn_hizmet_kullan` | `552_stok_ilac_kisa_ad_kullanim.sql` | 550_hizmet_kullanim_puani.sql, 551_hizmet_oto_pasif_durum.sql |
| `fn_hizmet_kullanilmayan_pasife` | `552_stok_ilac_kisa_ad_kullanim.sql` | 550_hizmet_kullanim_puani.sql, 551_hizmet_oto_pasif_durum.sql |
| `fn_hizmet_modalite_coz` | `460_hizmet_modalite_onarim.sql` | — |
| `fn_hizmet_paket_ac` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_paket_derinlik` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_paket_dongu` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `fn_hizmet_puan` | `550_hizmet_kullanim_puani.sql` | — |
| `fn_hizmet_uygunluk` | `482_hizmet_cinsiyet_yas.sql` | — |
| `fn_ilac_alerji_kontrol` | `414_metin_sadelestir.sql` | 413_recete.sql |
| `fn_ilac_fiyat` | `406_ilac_fiyat.sql` | — |
| `fn_ilac_fiyat_golge_tazele` | `406_ilac_fiyat.sql` | — |
| `fn_ilac_kamu_iskonto` | `407_sgk_ek4a_iskonto.sql` | — |
| `fn_ilac_stok_esle` | `511_ilac_stok_koprusu.sql` | — |
| `fn_ilac_stok_fiyati` | `408_ilac_stok_fiyat_matrah.sql` | — |
| `fn_ilac_stok_kart_ac` | `511_ilac_stok_koprusu.sql` | — |
| `fn_isg_aylik_dk` | `741_isg_modulu.sql` | — |
| `fn_isg_periyot_ay` | `741_isg_modulu.sql` | — |
| `fn_iskonto_talep_karar` | `673_iskonto_kalem_orani.sql` | 662_iskonto_onay.sql |
| `fn_its_siradakiler` | `428_kuyruk_takili_satir.sql` | 427_its_bildirim.sql |
| `fn_izin_gun` | `751_dini_bayram_ve_yerel_tatil.sql` | 743_izin_modulu.sql, 749_resmi_tatil.sql |
| `fn_izin_hak_gun` | `743_izin_modulu.sql` | — |
| `fn_kalem_kart_fiyati` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kalem_kullan` | `552_stok_ilac_kisa_ad_kullanim.sql` | — |
| `fn_kampanya_fiyat` | `275_kampanya_liste_kalem_turu.sql` | 272_kampanya_fiyat.sql |
| `fn_kasa_dagitim_iade` | `660_iade_satir_tahsil.sql` | — |
| `fn_kasa_islem_bacak_uret` | `393_bacak_belge_no.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql, 096_kasa_bacak_rol_kontrol.sql, 139_kasa_ekstre_dovizi.sql |
| `fn_kasa_islem_dogrula` | `085_fn_kasa_f3.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_duzelt_hazirla` | `148_kasa_islem_duzelt.sql` | — |
| `fn_kasa_islem_fisle` | `148_kasa_islem_duzelt.sql` | 076_fn_kasa.sql |
| `fn_kasa_islem_iptal` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_kesinlestir` | `152_numara_sablonu.sql` | 076_fn_kasa.sql, 085_fn_kasa_f3.sql |
| `fn_kasa_islem_no_uret` | `152_numara_sablonu.sql` | 073_kasa_islem.sql, 087_numara_kesme_duzeltmesi.sql |
| `fn_kasa_islem_silme_koruma` | `354_kasa_islem_silme_kosullari.sql` | 076_fn_kasa.sql |
| `fn_kategori_aktiflik_yay` | `527_profil_kategori.sql` | — |
| `fn_kategori_ust_zinciri` | `558_prim_kategori_alt_agac.sql` | — |
| `fn_kdv_cevir` | `202_fn_fiyat_listesi.sql` | — |
| `fn_kimlik_kurali` | `679_kimlik_bicimi.sql` | — |
| `fn_klinik_donem_araligi` | `713_klinik_kalite_motor.sql` | — |
| `fn_klinik_donem_hesapla` | `713_klinik_kalite_motor.sql` | — |
| `fn_klinik_gosterge_donem_hesapla` | `711_klinik_kalite.sql` | — |
| `fn_klinik_gosterge_hesapla` | `713_klinik_kalite_motor.sql` | — |
| `fn_klinik_gosterge_sonuc` | `711_klinik_kalite.sql` | — |
| `fn_klinik_kalite_gece` | `714_klinik_kalite_gece.sql` | — |
| `fn_klinik_kod_olay` | `713_klinik_kalite_motor.sql` | — |
| `fn_kontrollu_defter_no` | `730_kontrollu_defter_no.sql` | — |
| `fn_kontrollu_defter_silinmez` | `722_eczane.sql` | — |
| `fn_kontrollu_sayim_uyum` | `722_eczane.sql` | — |
| `fn_kritik_stok_talep` | `732_kritik_stok_talep.sql` | — |
| `fn_kullanici_alan_yetkileri` | `665_cok_rollu_kullanici.sql` | — |
| `fn_kullanici_ana_rol_temizle` | `665_cok_rollu_kullanici.sql` | — |
| `fn_kullanici_kasa` | `197_kasa_atama_tek_alan.sql` | 196_kasa_atama.sql |
| `fn_kullanici_rol_dogrula` | `665_cok_rollu_kullanici.sql` | — |
| `fn_kullanici_rolleri` | `665_cok_rollu_kullanici.sql` | — |
| `fn_kullanici_subeleri` | `666_sube_yerel_ayarlar.sql` | 665_cok_rollu_kullanici.sql |
| `fn_kullanici_yetki_surumu` | `665_cok_rollu_kullanici.sql` | — |
| `fn_kullanici_yetkileri` | `665_cok_rollu_kullanici.sql` | 020_sema_kimlik.sql, 068_taraf_rol_id_kolonlari.sql, 661_basvuru_fiyat_iskonto_yetkisi.sql |
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
| `fn_lab_istem_no_uret` | `634_hasta_belge_numaralari.sql` | 633_lab_istem_no_ayari.sql |
| `fn_lab_istem_sonuc_zamani` | `486_lab_tetkik_calisma_zamani.sql` | — |
| `fn_lab_kk_gecerli` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kk_hedef` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kk_kumulatif` | `442_lab_kalite_kontrol.sql` | — |
| `fn_lab_kultur_ozet` | `771_kultur_ozeti_para_bicimi.sql` | 436_lab_mikrobiyoloji.sql |
| `fn_lab_loinc_esle` | `530_lab_loinc_eslesme.sql` | — |
| `fn_lab_loinc_numune_uyar` | `530_lab_loinc_eslesme.sql` | — |
| `fn_lab_referans` | `644_lab_referans_cinsiyetsiz.sql` | 433_lab_v1.sql, 434_lab_cihaz_esleme.sql |
| `fn_lab_referans_kime` | `488_lab_yas_metni.sql` | — |
| `fn_lab_referans_metin` | `644_lab_referans_cinsiyetsiz.sql` | 643_lab_satir_katalog_dolgusu.sql |
| `fn_lab_sayi_metni` | `644_lab_referans_cinsiyetsiz.sql` | — |
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
| `fn_numara_kimlik_uret` | `634_hasta_belge_numaralari.sql` | — |
| `fn_numara_onek_coz` | `366_numara_onek_yil.sql` | — |
| `fn_numara_onek_yilli` | `366_numara_onek_yil.sql` | — |
| `fn_numara_sablonu_bul` | `154_numara_sablonu_seed.sql` | 152_numara_sablonu.sql |
| `fn_numara_sirada` | `152_numara_sablonu.sql` | — |
| `fn_order_doz_gunluk` | `698_order_doz_uretimi.sql` | — |
| `fn_order_uygulama_uret` | `698_order_doz_uretimi.sql` | — |
| `fn_panel_profil` | `513_panel_blok_sirasi.sql` | 508_panel_kurum_profili.sql, 512_panel_tip_merkezi_tam.sql |
| `fn_para_tr` | `769_para_bicimi_tr.sql` | — |
| `fn_parola_ata` | `068_taraf_rol_id_kolonlari.sql` | 020_sema_kimlik.sql |
| `fn_parola_dogru` | `020_sema_kimlik.sql` | — |
| `fn_plan_gerceklestir` | `085_fn_kasa_f3.sql` | — |
| `fn_prim_belge_turu` | `332_prim_zamani.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql, 331_kurum_tahakkuk_prim.sql |
| `fn_prim_gelir_belgesi` | `589_prim_gelir_belgesi_kovalar.sql` | 332_prim_zamani.sql, 472_dagilim_sigorta_prim.sql |
| `fn_prim_kademe_orani` | `388_prim_kademe_baglandi.sql` | — |
| `fn_prim_kademe_uygula` | `390_kademe_sinir.sql` | 388_prim_kademe_baglandi.sql, 389_prim_kademe_duzeltme.sql |
| `fn_prim_onayla` | `330_prim_tahsilat_turu_durum.sql` | — |
| `fn_prim_plan_satiri` | `558_prim_kategori_alt_agac.sql` | 324_prim_semasi.sql, 327_prim_hedef_kategori.sql, 328_prim_kapsam_kampanya_deseni.sql, 330_prim_tahsilat_turu_durum.sql, 332_prim_zamani.sql, 375_prim_plani_taraf.sql, 379_prim_plani_rol.sql, 380_prim_plani_odeyen_tipi.sql |
| `fn_prim_rol_aday_sayisi` | `362_gonderen_calisma_sekli.sql` | — |
| `fn_prim_rol_plani_var` | `584_basvuru_yapan_primi.sql` | — |
| `fn_prim_taslak_mi` | `330_prim_tahsilat_turu_durum.sql` | — |
| `fn_prim_uret` | `339_prim_taslak_uretilmez.sql` | 324_prim_semasi.sql, 326_radyoloji_prim_rol.sql, 328_prim_kapsam_kampanya_deseni.sql, 330_prim_tahsilat_turu_durum.sql, 331_kurum_tahakkuk_prim.sql, 332_prim_zamani.sql |
| `fn_prim_uret_belge` | `492_prim_dagilim_kovalari.sql` | 332_prim_zamani.sql |
| `fn_rad_istem_hizmet_kullanim` | `550_hizmet_kullanim_puani.sql` | — |
| `fn_rad_rol_tazele` | `332_prim_zamani.sql` | 326_radyoloji_prim_rol.sql |
| `fn_radyoloji_accession` | `283_radyoloji_cekirdek.sql` | — |
| `fn_radyoloji_rapor_no` | `303_radyoloji_rapor_no.sql` | — |
| `fn_radyoloji_rapor_onaylanabilir` | `284_radyoloji_operasyon.sql` | — |
| `fn_radyoloji_sonuc_durumu` | `418_muayene_istem_bagi.sql` | — |
| `fn_resmi_tatil_uret` | `749_resmi_tatil.sql` | — |
| `fn_rol_sistem_koru` | `664_sistem_rolleri.sql` | — |
| `fn_satinalma_agirlik_kilit` | `724_satinalma.sql` | — |
| `fn_satinalma_kabul_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_satinalma_kabul_sonuc` | `735_kabul_sonuc_bekleyen.sql` | 733_mal_kabul_satir.sql |
| `fn_satinalma_talep_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_satinalma_teklif_no_uret` | `731_tedarik_numaralari.sql` | — |
| `fn_sayi_sade` | `732_kritik_stok_talep.sql` | — |
| `fn_servis_is_emri_topla` | `773_teknik_servis.sql` | — |
| `fn_servis_sla_bitis` | `773_teknik_servis.sql` | — |
| `fn_sgk_katilim_emanet_yaz` | `477_katilim_emanet_doviz.sql` | 473_katilim_emaneti.sql |
| `fn_sigorta_durum_ekran` | `631_provizyon_durum_cevrimi.sql` | — |
| `fn_sigorta_ozet_tazele` | `631_provizyon_durum_cevrimi.sql` | 430_sigorta_v1.sql |
| `fn_sigorta_pay_dagit` | `472_dagilim_sigorta_prim.sql` | 430_sigorta_v1.sql |
| `fn_sigorta_pay_geri_al` | `472_dagilim_sigorta_prim.sql` | — |
| `fn_sigorta_ref_no` | `430_sigorta_v1.sql` | — |
| `fn_siradaki_hasta` | `410_hekim_calisma_listesi.sql` | — |
| `fn_skrs_ad` | `630_baslik_harf.sql` | 610_skrs_cozucu.sql, 618_fn_skrs_kod_tek_imza.sql |
| `fn_skrs_ambar_uret` | `521_skrs_katalog_kurulum.sql` | — |
| `fn_skrs_guid` | `618_fn_skrs_kod_tek_imza.sql` | 610_skrs_cozucu.sql |
| `fn_skrs_hedef_ad` | `630_baslik_harf.sql` | 613_skrs_hedef_ad.sql, 618_fn_skrs_kod_tek_imza.sql |
| `fn_skrs_kod` | `618_fn_skrs_kod_tek_imza.sql` | 503_skrs_kod_dikisi.sql, 610_skrs_cozucu.sql |
| `fn_sls_carpan_manuel` | `539_turetilmis_liste_sokuldu.sql` | 209_taban_fiyat_izi.sql, 212_yazim_gecis_kurali.sql, 213_fiyat_elle_degisim.sql, 214_yazim_olusma_import.sql |
| `fn_slug` | `021_goc_kimlik.sql` | — |
| `fn_stok_kart_fiyat` | `128_fn_stok_kart_fiyat.sql` | — |
| `fn_stok_kopyala` | `127_stok_kopyala_fiyat.sql` | 126_fn_stok_kopyala.sql |
| `fn_stok_kullanilmayan_pasife` | `552_stok_ilac_kisa_ad_kullanim.sql` | — |
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
| `fn_tr_baslik` | `563_gorev_adi_bicim.sql` | — |
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
| `fn_yatak_ucreti_tahakkuk` | `700_yatis_tahakkuk.sql` | — |
| `fn_yerel_para` | `111_ekstre_doviz_gruplu.sql` | — |
| `fn_yetki_surumu_artir` | `020_sema_kimlik.sql` | — |
| `tg_basvuru_yapan_hekim` | `584_basvuru_yapan_primi.sql` | — |
| `tg_basvuru_yapan_satir` | `584_basvuru_yapan_primi.sql` | — |
| `tg_belge_basvuru_sozlesme` | `598_tss_sgk_kullan_tetigi.sql` | 469_basvuru_sozlesme.sql, 485_ozel_kurum_sozlesmesiz.sql, 494_basvuru_kurumu_oder.sql |
| `tg_belge_satir_dagilim_denge` | `470_belge_satir_dagilim.sql` | — |
| `tg_belge_satir_iskonto_kilit` | `681_iskonto_kilit_koruma.sql` | 662_iskonto_onay.sql |
| `tg_belge_satir_kilit_silme` | `681_iskonto_kilit_koruma.sql` | — |
| `tg_belge_satir_rol_dogrula` | `361_prim_rol_isaretleri.sql` | — |
| `tg_belge_satir_uygunluk` | `482_hizmet_cinsiyet_yas.sql` | — |
| `tg_departman_dongu_engel` | `257_departman_ustbirim.sql` | — |
| `tg_dis_lab_isemri_bag` | `709_dis_numara_tetikleri.sql` | — |
| `tg_dis_lab_isemri_no` | `709_dis_numara_tetikleri.sql` | — |
| `tg_dis_plan_no` | `709_dis_numara_tetikleri.sql` | — |
| `tg_dis_sil_koru` | `720_ftr_seans_sil_koruma.sql` | — |
| `tg_fiyat_satir_birim` | `506_fiyat_satir_birim.sql` | — |
| `tg_fiyat_satir_tarife` | `539_turetilmis_liste_sokuldu.sql` | 518_fiyat_listesi_tarife_tipi.sql, 533_ttb_fiyat_turetilmis.sql |
| `tg_ftr_program_no` | `719_ftr_modulu.sql` | — |
| `tg_ftr_seans_sil_koru` | `720_ftr_seans_sil_koruma.sql` | — |
| `tg_hizmet_paket_bayrak` | `502_hizmet_paket_bayragi.sql` | — |
| `tg_hizmet_paket_bayrak_kontrol` | `502_hizmet_paket_bayragi.sql` | — |
| `tg_hizmet_paket_dongu` | `510_hizmet_paket_stok_icerigi.sql` | 500_hizmet_paket_dongu.sql |
| `tg_hizmet_radyoloji_bayrak` | `514_hizmet_radyoloji_bayragi.sql` | — |
| `tg_kasa_dagitim_kontrol` | `660_iade_satir_tahsil.sql` | 321_tahsilat_satir_dagitim.sql, 323_tahsilat_kdv_dahil.sql, 471_dagilim_kapanma_tahsil.sql |
| `tg_kasa_dagitim_sil_tazele` | `354_kasa_islem_silme_kosullari.sql` | — |
| `tg_kasa_dagitim_tazele` | `321_tahsilat_satir_dagitim.sql` | — |
| `tg_kasa_islem_iade_dagit` | `660_iade_satir_tahsil.sql` | — |
| `tg_kasa_islem_sil_fis` | `354_kasa_islem_silme_kosullari.sql` | — |
| `tg_kasa_islem_tahsil_tazele` | `321_tahsilat_satir_dagitim.sql` | — |
| `tg_kategori_aktiflik` | `527_profil_kategori.sql` | — |
| `tg_kategori_dongu_engel` | `270_kategori_agaci.sql` | — |
| `tg_kurum_sozlesme_kontrol` | `601_sgk_tarife_sut_listesi.sql` | 468_kurum_sozlesme_1n.sql, 493_kurum_turu_kurumu_oder.sql, 517_kurum_sozlesme_sgk_carisi.sql |
| `tg_lab_istem_no` | `641_lab_istem_no_tetik.sql` | — |
| `tg_lab_istem_satir_katalog` | `643_lab_satir_katalog_dolgusu.sql` | — |
| `tg_lab_panel_hizmet` | `501_panel_icerigi_tek_kaynak.sql` | — |
| `tg_lab_panel_satir_yaz` | `639_hemogram_23_parametre.sql` | 501_panel_icerigi_tek_kaynak.sql |
| `tg_lab_varyant_sinif` | `439_lab_genetik.sql` | — |
| `tg_masraf_toplam` | `766_masraf_satir_kilit_duzeltmesi.sql` | 764_masraf_beyani.sql |
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
| `tg_randevu_izin_kontrol` | `748_izin_calisma_plani.sql` | — |
| `tg_servis_toplam` | `773_teknik_servis.sql` | — |
| `tg_sube_vkn_dogrula` | `170_sube_vkn_dogrula.sql` | — |
| `tg_tani_kronik_yansit` | `420_hasta_tibbi_gecmis.sql` | — |
| `tg_taraf_hasta_dosya_no` | `396_hasta_dosya_no_otomatik.sql` | 356_hasta_dosya_no_otomatik.sql, 358_numara_sablonu_elle_girilir.sql |
| `tg_taraf_hasta_kurum_tek_aktif` | `248_taraf_hasta_kurum.sql` | — |
| `tg_taraf_hasta_kurum_yansit` | `277_hasta_kurum_tek_kaynak.sql` | — |
| `tg_taraf_prim_rol_dogrula` | `369_primli_calisma_sekli.sql` | 361_prim_rol_isaretleri.sql, 362_gonderen_calisma_sekli.sql |
| `tg_yatis_izlem_skor` | `699_erken_uyari_skoru.sql` | — |
| `tg_yatis_order_doz` | `698_order_doz_uretimi.sql` | — |

## Gorunumler (231 ad, 52 tanesi birden cok dosyada)

| Nesne | Yururlukteki dosya | Onceki tanimlar |
|---|---|---|
| `cari` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `hasta` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `lab_panel_satir` | `501_panel_icerigi_tek_kaynak.sql` | — |
| `musteri` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `personel` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `personel_acil_kisi` | `335_hasta_kimlik_tamamlama.sql` | — |
| `tedarikci` | `019_sema_cok_sube.sql` | 017_sema_sube_rol.sql |
| `v_acil_sure` | `716_acil_servis.sql` | — |
| `v_acil_yatak_lookup` | `716_acil_servis.sql` | — |
| `v_alt_kurum_lookup` | `468_kurum_sozlesme_1n.sql` | — |
| `v_ameliyat_salon_lookup` | `715_ameliyathane.sql` | — |
| `v_banka_lookup` | `109_banka.sql` | — |
| `v_banka_sube_lookup` | `110_banka_sube_bagli_ve_kur.sql` | 109_banka.sql |
| `v_basvuru_hekim` | `718_hekim_calisma_plani.sql` | 578_basvuru_hekim_kaynagi.sql, 583_basvuru_hekim_arama.sql |
| `v_belge_acik_satir` | `471_dagilim_kapanma_tahsil.sql` | 082_belge_donusum.sql, 290_acik_satir_pay.sql, 293_acik_satir_kalem_adi.sql, 352_donusum_tutar_bazli.sql |
| `v_belge_donusum` | `086_belge_donusum_kurallar.sql` | — |
| `v_belge_satir_izlem` | `115_izlem_depo.sql` | 114_belge_izlem.sql |
| `v_belge_satir_tahsilat` | `471_dagilim_kapanma_tahsil.sql` | 321_tahsilat_satir_dagitim.sql, 323_tahsilat_kdv_dahil.sql |
| `v_belge_sevkiyat` | `177_belge_sevkiyat.sql` | — |
| `v_belge_yazi_sablonu` | `768_belge_talep_yazisi.sql` | — |
| `v_butce_durum` | `724_satinalma.sql` | — |
| `v_cari_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_cari_lookup` | `122_aday_musteri.sql` | 037_kisi_karti.sql |
| `v_cek_senet_portfoy` | `072_cek_senet.sql` | — |
| `v_cihaz_lookup` | `432_cihaz_ara_katman.sql` | — |
| `v_demirbas_durum` | `728_demirbas_kalibrasyon_tabi.sql` | 723_demirbas_kalibrasyon.sql |
| `v_demirbas_is_emri_onay` | `752_onarim_onayi.sql` | — |
| `v_departman_agac_lookup` | `577_dis_hekim_bolum_brans.sql` | — |
| `v_departman_lookup` | `256_departman_durum.sql` | 251_departman.sql, 254_departman_kod.sql |
| `v_depo_lookup` | `093_depo_kurallar.sql` | 088_belge_irsaliye_alanlari.sql |
| `v_dis_gunluk_akis` | `706_dis_modulu.sql` | — |
| `v_dis_hasta` | `706_dis_modulu.sql` | — |
| `v_dis_hekim_lookup` | `309_dis_hekim_kurum_taraf_bag.sql` | 305_dis_hekim.sql, 308_dis_hekim_kurum_ad_kaldir.sql |
| `v_dis_islem_lookup` | `706_dis_modulu.sql` | — |
| `v_dis_lab_isemri` | `706_dis_modulu.sql` | — |
| `v_dis_lab_lookup` | `706_dis_modulu.sql` | — |
| `v_dis_plan_lookup` | `706_dis_modulu.sql` | — |
| `v_dis_seans` | `706_dis_modulu.sql` | — |
| `v_dis_tedavi_plani` | `706_dis_modulu.sql` | — |
| `v_dis_unit_lookup` | `706_dis_modulu.sql` | — |
| `v_dokuman_akis_lookup` | `758_dokuman_onay_omurga.sql` | 431_dokuman_kategori.sql |
| `v_dokuman_baglanti` | `423_dokuman_iliski.sql` | — |
| `v_dokuman_erisim` | `425_dokuman_erisim.sql` | — |
| `v_dokuman_kategori_lookup` | `431_dokuman_kategori.sql` | — |
| `v_dokuman_klasor_lookup` | `421_dokuman_lookup.sql` | — |
| `v_dokuman_onay_adim` | `758_dokuman_onay_omurga.sql` | 422_dokuman_kart_gorunumleri.sql |
| `v_dokuman_paylasim` | `424_dokuman_paylasim.sql` | — |
| `v_dokuman_turu_lookup` | `421_dokuman_lookup.sql` | — |
| `v_ebelge_entegrator_lookup` | `171_sube_ebelge_mukellef.sql` | — |
| `v_ebelge_gonderici` | `169_sube_ebelge_kimlik.sql` | 165_firma_bilgileri.sql |
| `v_ebelge_turu_lookup` | `156_ebelge_seri.sql` | — |
| `v_ebelge_yon_lookup` | `159_ebelge_xslt.sql` | — |
| `v_eczane_miad` | `722_eczane.sql` | — |
| `v_entegrasyon_hesap_lookup` | `430_sigorta_v1.sql` | — |
| `v_entegrasyon_kod_lookup` | `337_entegrasyon_uts_ebelge.sql` | 336_entegrasyon_hesap.sql |
| `v_firsat_asama_gecmis` | `121_firsat.sql` | — |
| `v_firsat_liste` | `121_firsat.sql` | — |
| `v_fiyat_listesi_alis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_kullanim` | `539_turetilmis_liste_sokuldu.sql` | 204_cari_fiyat_listesi.sql |
| `v_fiyat_listesi_lookup` | `201_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_satir` | `539_turetilmis_liste_sokuldu.sql` | 201_fiyat_listesi.sql, 507_fiyat_satir_gorunum_kdv_kategori.sql |
| `v_fiyat_listesi_satis_lookup` | `204_cari_fiyat_listesi.sql` | — |
| `v_fiyat_listesi_tarife_lookup` | `587_fiyat_listesi_tarife_lookup.sql` | — |
| `v_form_istek` | `740_form_motoru.sql` | — |
| `v_form_kural` | `740_form_motoru.sql` | — |
| `v_form_sablon` | `740_form_motoru.sql` | — |
| `v_form_sablon_lookup` | `740_form_motoru.sql` | — |
| `v_ftr_degerlendirme` | `719_ftr_modulu.sql` | — |
| `v_ftr_degerlendirme_lookup` | `719_ftr_modulu.sql` | — |
| `v_ftr_hizmet_lookup` | `719_ftr_modulu.sql` | — |
| `v_ftr_kabin_lookup` | `719_ftr_modulu.sql` | — |
| `v_ftr_olcek` | `719_ftr_modulu.sql` | — |
| `v_ftr_program` | `719_ftr_modulu.sql` | — |
| `v_ftr_program_lookup` | `719_ftr_modulu.sql` | — |
| `v_ftr_seans` | `719_ftr_modulu.sql` | — |
| `v_ftr_unite` | `719_ftr_modulu.sql` | — |
| `v_ftr_unite_lookup` | `719_ftr_modulu.sql` | — |
| `v_gorev_agac_lookup` | `571_gorev_agac_lookup.sql` | — |
| `v_gorev_lookup` | `255_personel_gorev.sql` | — |
| `v_goz_cihaz_lookup` | `693_goz_lookup.sql` | — |
| `v_goz_protokol_lookup` | `693_goz_lookup.sql` | — |
| `v_goz_takip_lookup` | `693_goz_lookup.sql` | — |
| `v_goz_tetkik_lookup` | `693_goz_lookup.sql` | — |
| `v_goz_unite_akis` | `691_goz_modulu.sql` | — |
| `v_hakedis_ozet` | `330_prim_tahsilat_turu_durum.sql` | 324_prim_semasi.sql |
| `v_hakedis_satir` | `363_hakedis_rol_isaret_kontrolu.sql` | 324_prim_semasi.sql, 330_prim_tahsilat_turu_durum.sql, 332_prim_zamani.sql |
| `v_hasta_lookup` | `266_aday_hasta.sql` | 244_hasta_lookup.sql, 262_hasta_lookup_kimlik.sql, 263_hasta_lookup_cinsiyet_yas.sql, 264_hasta_lookup_cinsiyet_bos.sql |
| `v_hasta_tibbi_ozet` | `420_hasta_tibbi_gecmis.sql` | — |
| `v_hekim_calisma_istisna` | `718_hekim_calisma_plani.sql` | — |
| `v_hekim_calisma_sablon` | `718_hekim_calisma_plani.sql` | — |
| `v_hekim_lookup` | `718_hekim_calisma_plani.sql` | 252_personel_randevu_verilebilir.sql, 253_hekim_pasif_dislama.sql |
| `v_hesap_atama_lookup` | `199_kasa_atama_listesi.sql` | 197_kasa_atama_tek_alan.sql |
| `v_hesap_bakiye` | `077_v_ekstre.sql` | — |
| `v_hesap_ekstre` | `111_ekstre_doviz_gruplu.sql` | 077_v_ekstre.sql, 097_ekstre_kaynak_kayit.sql |
| `v_hesap_lookup` | `071_kasa_master.sql` | — |
| `v_hesap_plani_lookup` | `074_muhasebe.sql` | — |
| `v_hizmet_baslik_lookup` | `521_skrs_katalog_kurulum.sql` | — |
| `v_hizmet_kategori_lookup` | `544_stok_kategori_marka_model.sql` | — |
| `v_hizmet_lookup` | `482_hizmet_cinsiyet_yas.sql` | 071_kasa_master.sql |
| `v_hizmet_paket_eksik` | `502_hizmet_paket_bayragi.sql` | — |
| `v_hizmet_paket_ozet` | `496_hizmet_paket.sql` | — |
| `v_hizmet_radyoloji_eksik` | `514_hizmet_radyoloji_bayragi.sql` | — |
| `v_iade_edilebilir_satir` | `133_iade_irsaliye.sql` | 132_iade_satirlari.sql |
| `v_icd_lookup` | `409_muayene_v1.sql` | — |
| `v_ilac_stoksuz` | `511_ilac_stok_koprusu.sql` | — |
| `v_is_merkezi_lookup` | `429_uretim_v1.sql` | — |
| `v_isg_asi` | `741_isg_modulu.sql` | — |
| `v_isg_bolum_lookup` | `741_isg_modulu.sql` | — |
| `v_isg_calisan` | `741_isg_modulu.sql` | — |
| `v_isg_calisan_lookup` | `741_isg_modulu.sql` | — |
| `v_isg_firma` | `741_isg_modulu.sql` | — |
| `v_isg_firma_lookup` | `741_isg_modulu.sql` | — |
| `v_isg_isveren_lookup` | `741_isg_modulu.sql` | — |
| `v_isg_muayene` | `741_isg_modulu.sql` | — |
| `v_isg_olay` | `741_isg_modulu.sql` | — |
| `v_isg_ziyaret` | `741_isg_modulu.sql` | — |
| `v_kabul_irsaliye_lookup` | `737_mal_kabul_duzeltmeleri.sql` | — |
| `v_kabul_its_bildirim` | `736_kabul_its_bildirim.sql` | — |
| `v_kabul_karekod_satir` | `737_mal_kabul_duzeltmeleri.sql` | 734_kabul_karekod.sql |
| `v_kabul_siparis_lookup` | `737_mal_kabul_duzeltmeleri.sql` | — |
| `v_kampanya_lookup` | `268_kampanya.sql` | — |
| `v_kasa_islem_dagitim` | `322_avans_mahsup.sql` | — |
| `v_kategori_lookup` | `505_skrs_liste_duzeltme_kategori_tur.sql` | 250_kategori_lookup.sql, 270_kategori_agaci.sql, 347_sonomed_rad_kategori.sql |
| `v_klinik_gosterge_lookup` | `711_klinik_kalite.sql` | — |
| `v_klinik_olgu_lookup` | `712_klinik_olgu_lookup.sql` | — |
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
| `v_medula_fatura` | `707_medula.sql` | — |
| `v_medula_fatura_lookup` | `707_medula.sql` | — |
| `v_medula_kuyruk` | `707_medula.sql` | — |
| `v_medula_takip` | `707_medula.sql` | — |
| `v_mesaj_sohbet` | `342_mesajlasma.sql` | — |
| `v_muayene_sablon_alan_lookup` | `409_muayene_v1.sql` | — |
| `v_muayene_sablon_lookup` | `411_muayene_sablon_makro.sql` | 409_muayene_v1.sql |
| `v_numara_hasta_belge` | `636_hasta_belge_numara_gorunumu.sql` | — |
| `v_numara_ik` | `767_ik_talep_numaralari.sql` | — |
| `v_numara_tedarik` | `731_tedarik_numaralari.sql` | — |
| `v_numara_turu_alis` | `334_tahakkuk_tur_takas.sql` | 152_numara_sablonu.sql, 153_numara_turu_gorunum_tip.sql |
| `v_numara_turu_ik` | `767_ik_talep_numaralari.sql` | — |
| `v_numara_turu_kimlik` | `719_ameliyathane_acil_akis.sql` | 358_numara_sablonu_elle_girilir.sql, 633_lab_istem_no_ayari.sql, 634_hasta_belge_numaralari.sql, 635_recete_no_numaralandirma.sql |
| `v_numara_turu_odeme` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_satis` | `334_tahakkuk_tur_takas.sql` | 152_numara_sablonu.sql, 153_numara_turu_gorunum_tip.sql |
| `v_numara_turu_servis` | `773_teknik_servis.sql` | — |
| `v_numara_turu_tahsilat` | `153_numara_turu_gorunum_tip.sql` | 152_numara_sablonu.sql |
| `v_numara_turu_tedarik` | `731_tedarik_numaralari.sql` | — |
| `v_oda_lookup` | `696_yatan_lookup.sql` | — |
| `v_onay_akis` | `742_onay_akis_ekrani.sql` | — |
| `v_onay_akis_adim` | `742_onay_akis_ekrani.sql` | — |
| `v_onay_akis_lookup` | `746_onay_bildirim_vekalet.sql` | — |
| `v_onay_bekleyen` | `745_onay_sirasi_gelen.sql` | 738_onay_omurgasi.sql |
| `v_onay_kutusu` | `765_personel_belge_talebi.sql` | 739_onay_gelen_kutusu.sql, 744_izin_onay_kutusu.sql, 752_onarim_onayi.sql, 753_avans_modulu.sql, 754_iskonto_omurga.sql, 755_avans_kaynak_tur_duzeltmesi.sql, 758_dokuman_onay_omurga.sql, 764_masraf_beyani.sql |
| `v_onay_sozlu` | `763_sozlu_onay_takibi.sql` | — |
| `v_onay_vekalet` | `746_onay_bildirim_vekalet.sql` | — |
| `v_personel_avans` | `755_avans_kaynak_tur_duzeltmesi.sql` | 753_avans_modulu.sql |
| `v_personel_belge_talep` | `765_personel_belge_talebi.sql` | — |
| `v_personel_izin` | `743_izin_modulu.sql` | — |
| `v_personel_izin_bakiye` | `743_izin_modulu.sql` | — |
| `v_personel_lookup` | `054_personel_ozluk_mockup_uyum.sql` | — |
| `v_personel_masraf` | `764_masraf_beyani.sql` | — |
| `v_plan_vade` | `077_v_ekstre.sql` | — |
| `v_prim_rol_aday` | `576_personel_departman_tek_kaynak.sql` | 361_prim_rol_isaretleri.sql, 362_gonderen_calisma_sekli.sql, 367_prim_rol_aday_bolum.sql, 369_primli_calisma_sekli.sql |
| `v_prim_rol_lookup` | `391_prim_rol_lookup_onarim.sql` | 362_gonderen_calisma_sekli.sql |
| `v_prim_taraf_lookup` | `378_prim_taraf_lookup_aktif.sql` | 375_prim_plani_taraf.sql, 377_prim_taraf_lookup_genis.sql |
| `v_proje_ekstre` | `077_v_ekstre.sql` | — |
| `v_proje_lookup` | `071_kasa_master.sql` | — |
| `v_rad_cihaz_lookup` | `286_radyoloji_lookup.sql` | — |
| `v_rad_hekim_lookup` | `718_hekim_calisma_plani.sql` | 283_radyoloji_cekirdek.sql, 313_rad_hekim_lookup_dis_hekim.sql |
| `v_rad_tetkik_lookup` | `286_radyoloji_lookup.sql` | — |
| `v_radyoloji_cihaz_lookup` | `316_randevu_cihaz_kaynagi.sql` | — |
| `v_radyoloji_kritik_takip` | `318_radyoloji_takip_listeleri.sql` | — |
| `v_radyoloji_protokol_malzeme` | `320_radyoloji_sarf.sql` | — |
| `v_radyoloji_teslim_takip` | `318_radyoloji_takip_listeleri.sql` | — |
| `v_radyoloji_tetkik` | `304_radyoloji_istem_acma.sql` | — |
| `v_radyoloji_worklist` | `296_belge_basvuru.sql` | 283_radyoloji_cekirdek.sql |
| `v_randevu_bolum_lookup` | `718_hekim_calisma_plani.sql` | 251_departman.sql, 254_departman_kod.sql, 256_departman_durum.sql |
| `v_randevu_tetkik_sure` | `317_randevu_tetkik_uyum.sql` | — |
| `v_resmi_tatil` | `751_dini_bayram_ve_yerel_tatil.sql` | 749_resmi_tatil.sql, 750_tatil_duzeltmeleri.sql |
| `v_rol_lookup` | `425_dokuman_erisim.sql` | — |
| `v_satinalma_kabul` | `736_kabul_its_bildirim.sql` | 733_mal_kabul_satir.sql, 734_kabul_karekod.sql |
| `v_satinalma_talep_onay` | `739_onay_gelen_kutusu.sql` | — |
| `v_servis_cagri` | `773_teknik_servis.sql` | — |
| `v_servis_emanet` | `773_teknik_servis.sql` | — |
| `v_servis_is_emri` | `773_teknik_servis.sql` | — |
| `v_servis_sozlesme` | `773_teknik_servis.sql` | — |
| `v_servis_ziyaret` | `773_teknik_servis.sql` | — |
| `v_sgk_katilim_emanet` | `473_katilim_emaneti.sql` | — |
| `v_sigorta_hesap_lookup` | `430_sigorta_v1.sql` | — |
| `v_sigorta_saglayici_lookup` | `430_sigorta_v1.sql` | — |
| `v_skrs_ham_alan` | `520_skrs_katalog_ambari.sql` | — |
| `v_skrs_klinik_lookup` | `615_skrs_lookup_gorunumleri.sql` | 455_skrs_klinik.sql |
| `v_skrs_meslek_lookup` | `615_skrs_lookup_gorunumleri.sql` | — |
| `v_skrs_sapma` | `503_skrs_kod_dikisi.sql` | — |
| `v_skrs_ulke_lookup` | `615_skrs_lookup_gorunumleri.sql` | — |
| `v_stok_kategori_lookup` | `544_stok_kategori_marka_model.sql` | — |
| `v_stok_kullanilabilir` | `142_siparis_rezervasyon.sql` | — |
| `v_stok_lookup` | `121_firsat.sql` | — |
| `v_stok_onek_dagilim` | `524_stok_kategorisi.sql` | — |
| `v_sube_antet` | `772_sube_antet_ve_logo.sql` | — |
| `v_sube_baz_lookup` | `227_baz_sube.sql` | — |
| `v_sube_lookup` | `718_hekim_calisma_plani.sql` | — |
| `v_tahsilat_turu_lookup` | `330_prim_tahsilat_turu_durum.sql` | — |
| `v_taraf_avans` | `322_avans_mahsup.sql` | — |
| `v_taraf_cihaz` | `773_teknik_servis.sql` | — |
| `v_tedarikci_skor` | `724_satinalma.sql` | — |
| `v_ulke_lookup` | `119_stok_uts.sql` | — |
| `v_uretim_emri_lookup` | `429_uretim_v1.sql` | — |
| `v_uretim_hareket` | `429_uretim_v1.sql` | — |
| `v_urun_agaci_lookup` | `429_uretim_v1.sql` | — |
| `v_yatak_lookup` | `696_yatan_lookup.sql` | — |
| `v_yatak_panosu` | `695_yatan_hasta.sql` | — |

