-- ============================================================================
--  Gentegre AI — LOG TABLO KODU ÇAKIŞMALARININ TAMAMI AYIKLANIYOR
--  757_log_tablo_id_ayiklama.sql
--
--  Kullanıcı: "kalanları da ayıkla."
--
--  755 (avans 907/908) ve 756 (905/906) tek tek ayıklamıştı. Bu dosya
--  katalogdaki VE `Uclar`/`Depolar` sabitlerindeki bütün çakışmaları birden
--  kapatıyor: 37 tablo yeni numaraya taşındı (1263-1311 aralığı).
--
--  ============ NEDEN BU KADAR ÇOK =====================================
--  Kullanılan numaraların TEK BİR LİSTESİ YOKTU. Numaralar katalog
--  dosyalarına ve uç sabitlerine dağılmış durumda; yeni bir kart yazan
--  kişi boş sandığı bir numarayı alıyordu. Üç modül birden aynı bloğa
--  oturmuştu:
--
--    · İSG (741)          -> eczanenin 1200-1206 bloğuna
--    · Ameliyathane       -> Medula'nın 1150-1154 bloğuna
--    · Göz ek kartları    -> göz çizimi/dikte sözlüğünün 1108-1109'una
--
--  Bir daha olmaması için asıl önlem bu dosya değil, katalogdaki
--  benzersizlik testi (`LogTabloIdTestleri`): aynı numarayı iki tabloya
--  veren değişiklik artık testten geri döner.
--
--  ============ GEÇMİŞ SATIRLAR: YALNIZ KESİN OLANLAR ==================
--  Her taşıma "bu satır TAM OLARAK BİR adaya ait" koşuluyla yapılıyor:
--  `kayit_id` hedef tabloda VAR ve aynı numarayı paylaşan öteki tabloların
--  HİÇBİRİNDE yok. İki adaya birden uyan ya da hiçbirine uymayan (kaydı
--  silinmiş) satır YERİNDE BIRAKILIYOR.
--
--  Bu satırlar için bilgi zaten kayıptı - iki tablo aynı numaradayken
--  hangisine ait oldukları yazılmamıştı. Tahminle taşımak, belirsiz bir
--  satırı kendinden emin ama yanlış bir satıra çevirirdi; denetim izinde
--  bu daha kötüdür.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  ÜÇ TAŞIMA YAPILAMIYOR: `kullanici_sube` ve `zamanli_is` tablolarında `id`
--  kolonu yok (bağ tabloları), dolayısıyla bir log satırının onlara ait olup
--  olmadığı `kayit_id` ile ölçülemiyor. Kod tarafında numaraları ayrıldı
--  (904 -> 1297, 962 -> 1289) ama geçmiş satırlar yerinde kalıyor; aynı
--  numaradaki `lab_istem_satir` da bu yüzden taşınmıyor - ayıramadığımız bir
--  kümeden tek tarafı çekmek kalanı yanlış biçimde kesinleştirirdi.
-- ---------------------------------------------------------------------------

-- 903 -> 1263 (stok_uts)
update public.islem_log l set tablo_id = 1263
 where l.tablo_id = 903
   and exists (select 1 from public.stok_uts x where x.id = l.kayit_id)
   and not exists (select 1 from public.rol y where y.id = l.kayit_id);

-- 909 -> 1264 (kurum_sozlesme)
update public.islem_log l set tablo_id = 1264
 where l.tablo_id = 909
   and exists (select 1 from public.kurum_sozlesme x where x.id = l.kayit_id)
   and not exists (select 1 from public.hesap y where y.id = l.kayit_id)
   and not exists (select 1 from public.taraf_kurum y where y.id = l.kayit_id);

-- 909 -> 1265 (taraf_kurum)
update public.islem_log l set tablo_id = 1265
 where l.tablo_id = 909
   and exists (select 1 from public.taraf_kurum x where x.id = l.kayit_id)
   and not exists (select 1 from public.hesap y where y.id = l.kayit_id)
   and not exists (select 1 from public.kurum_sozlesme y where y.id = l.kayit_id);

-- 913 -> 1266 (personel_gorev)
update public.islem_log l set tablo_id = 1266
 where l.tablo_id = 913
   and exists (select 1 from public.personel_gorev x where x.id = l.kayit_id)
   and not exists (select 1 from public.proje y where y.id = l.kayit_id);

-- 914 -> 1267 (hesap_plani)
update public.islem_log l set tablo_id = 1267
 where l.tablo_id = 914
   and exists (select 1 from public.hesap_plani x where x.id = l.kayit_id)
   and not exists (select 1 from public.kampanya y where y.id = l.kayit_id);

-- 915 -> 1268 (masraf_merkezi)
update public.islem_log l set tablo_id = 1268
 where l.tablo_id = 915
   and exists (select 1 from public.masraf_merkezi x where x.id = l.kayit_id)
   and not exists (select 1 from public.kampanya_satir y where y.id = l.kayit_id);

-- 918 -> 1269 (depo)
update public.islem_log l set tablo_id = 1269
 where l.tablo_id = 918
   and exists (select 1 from public.depo x where x.id = l.kayit_id)
   and not exists (select 1 from public.numara_sablonu y where y.id = l.kayit_id)
   and not exists (select 1 from public.firsat y where y.id = l.kayit_id)
   and not exists (select 1 from public.gorev y where y.id = l.kayit_id);

-- 918 -> 1270 (firsat)
update public.islem_log l set tablo_id = 1270
 where l.tablo_id = 918
   and exists (select 1 from public.firsat x where x.id = l.kayit_id)
   and not exists (select 1 from public.numara_sablonu y where y.id = l.kayit_id)
   and not exists (select 1 from public.depo y where y.id = l.kayit_id)
   and not exists (select 1 from public.gorev y where y.id = l.kayit_id);

-- 918 -> 1271 (gorev)
update public.islem_log l set tablo_id = 1271
 where l.tablo_id = 918
   and exists (select 1 from public.gorev x where x.id = l.kayit_id)
   and not exists (select 1 from public.numara_sablonu y where y.id = l.kayit_id)
   and not exists (select 1 from public.depo y where y.id = l.kayit_id)
   and not exists (select 1 from public.firsat y where y.id = l.kayit_id);

-- 919 -> 1272 (ebelge_seri)
update public.islem_log l set tablo_id = 1272
 where l.tablo_id = 919
   and exists (select 1 from public.ebelge_seri x where x.id = l.kayit_id)
   and not exists (select 1 from public.banka y where y.id = l.kayit_id)
   and not exists (select 1 from public.firsat_urun y where y.id = l.kayit_id);

-- 919 -> 1273 (firsat_urun)
update public.islem_log l set tablo_id = 1273
 where l.tablo_id = 919
   and exists (select 1 from public.firsat_urun x where x.id = l.kayit_id)
   and not exists (select 1 from public.banka y where y.id = l.kayit_id)
   and not exists (select 1 from public.ebelge_seri y where y.id = l.kayit_id);

-- 920 -> 1274 (stok_paket)
update public.islem_log l set tablo_id = 1274
 where l.tablo_id = 920
   and exists (select 1 from public.stok_paket x where x.id = l.kayit_id)
   and not exists (select 1 from public.banka_sube y where y.id = l.kayit_id);

-- 921 -> 1275 (hizmet_paket)
update public.islem_log l set tablo_id = 1275
 where l.tablo_id = 921
   and exists (select 1 from public.hizmet_paket x where x.id = l.kayit_id)
   and not exists (select 1 from public.hizmet y where y.id = l.kayit_id);

-- 923 -> 1276 (sube)
update public.islem_log l set tablo_id = 1276
 where l.tablo_id = 923
   and exists (select 1 from public.sube x where x.id = l.kayit_id)
   and not exists (select 1 from public.fiyat_listesi y where y.id = l.kayit_id);

-- 925 -> 1269 (depo)
update public.islem_log l set tablo_id = 1269
 where l.tablo_id = 925
   and exists (select 1 from public.depo x where x.id = l.kayit_id)
   and not exists (select 1 from public.demirbas y where y.id = l.kayit_id);

-- 942 -> 1277 (radyoloji_sablon_alan)
update public.islem_log l set tablo_id = 1277
 where l.tablo_id = 942
   and exists (select 1 from public.radyoloji_sablon_alan x where x.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_bolum y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_makro y where y.id = l.kayit_id);

-- 942 -> 1278 (radyoloji_sablon_bolum)
update public.islem_log l set tablo_id = 1278
 where l.tablo_id = 942
   and exists (select 1 from public.radyoloji_sablon_bolum x where x.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_alan y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_makro y where y.id = l.kayit_id);

-- 942 -> 1279 (radyoloji_sablon_makro)
update public.islem_log l set tablo_id = 1279
 where l.tablo_id = 942
   and exists (select 1 from public.radyoloji_sablon_makro x where x.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_alan y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_sablon_bolum y where y.id = l.kayit_id);

-- 943 -> 1280 (radyoloji_protokol)
update public.islem_log l set tablo_id = 1280
 where l.tablo_id = 943
   and exists (select 1 from public.radyoloji_protokol x where x.id = l.kayit_id)
   and not exists (select 1 from public.kurum_icmal y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_protokol_malzeme y where y.id = l.kayit_id);

-- 943 -> 1281 (radyoloji_protokol_malzeme)
update public.islem_log l set tablo_id = 1281
 where l.tablo_id = 943
   and exists (select 1 from public.radyoloji_protokol_malzeme x where x.id = l.kayit_id)
   and not exists (select 1 from public.kurum_icmal y where y.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_protokol y where y.id = l.kayit_id);

-- 944 -> 1282 (radyoloji_cihaz_kapatma)
update public.islem_log l set tablo_id = 1282
 where l.tablo_id = 944
   and exists (select 1 from public.radyoloji_cihaz_kapatma x where x.id = l.kayit_id)
   and not exists (select 1 from public.radyoloji_cihaz y where y.id = l.kayit_id);

-- 950 -> 1283 (prim_plani)
update public.islem_log l set tablo_id = 1283
 where l.tablo_id = 950
   and exists (select 1 from public.prim_plani x where x.id = l.kayit_id)
   and not exists (select 1 from public.yatis y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani_satir y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani_taraf y where y.id = l.kayit_id);

-- 950 -> 1284 (prim_plani_satir)
update public.islem_log l set tablo_id = 1284
 where l.tablo_id = 950
   and exists (select 1 from public.prim_plani_satir x where x.id = l.kayit_id)
   and not exists (select 1 from public.yatis y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani_taraf y where y.id = l.kayit_id);

-- 950 -> 1285 (prim_plani_taraf)
update public.islem_log l set tablo_id = 1285
 where l.tablo_id = 950
   and exists (select 1 from public.prim_plani_taraf x where x.id = l.kayit_id)
   and not exists (select 1 from public.yatis y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani y where y.id = l.kayit_id)
   and not exists (select 1 from public.prim_plani_satir y where y.id = l.kayit_id);

-- 960 -> 1286 (onam_metni)
update public.islem_log l set tablo_id = 1286
 where l.tablo_id = 960
   and exists (select 1 from public.onam_metni x where x.id = l.kayit_id)
   and not exists (select 1 from public.muayene y where y.id = l.kayit_id);

-- 961 -> 1287 (bildirim_sablon)
update public.islem_log l set tablo_id = 1287
 where l.tablo_id = 961
   and exists (select 1 from public.bildirim_sablon x where x.id = l.kayit_id)
   and not exists (select 1 from public.lab_istem y where y.id = l.kayit_id);

-- 963 -> 1290 (lab_numune)
update public.islem_log l set tablo_id = 1290
 where l.tablo_id = 963
   and exists (select 1 from public.lab_numune x where x.id = l.kayit_id)
   and not exists (select 1 from public.tani y where y.id = l.kayit_id)
   and not exists (select 1 from public.taraf_prim_rol y where y.id = l.kayit_id);

-- 963 -> 1291 (taraf_prim_rol)
update public.islem_log l set tablo_id = 1291
 where l.tablo_id = 963
   and exists (select 1 from public.taraf_prim_rol x where x.id = l.kayit_id)
   and not exists (select 1 from public.tani y where y.id = l.kayit_id)
   and not exists (select 1 from public.lab_numune y where y.id = l.kayit_id);

-- 966 -> 1292 (muayene_sablon)
update public.islem_log l set tablo_id = 1292
 where l.tablo_id = 966
   and exists (select 1 from public.muayene_sablon x where x.id = l.kayit_id)
   and not exists (select 1 from public.muayene_rapor y where y.id = l.kayit_id);

-- 1016 -> 1293 (lab_cihaz_test_esleme)
update public.islem_log l set tablo_id = 1293
 where l.tablo_id = 1016
   and exists (select 1 from public.lab_cihaz_test_esleme x where x.id = l.kayit_id)
   and not exists (select 1 from public.lab_organizma y where y.id = l.kayit_id);

-- 1108 -> 1304 (goz_kontakt_lens)
update public.islem_log l set tablo_id = 1304
 where l.tablo_id = 1108
   and exists (select 1 from public.goz_kontakt_lens x where x.id = l.kayit_id)
   and not exists (select 1 from public.goz_cizim y where y.id = l.kayit_id);

-- 1109 -> 1305 (goz_islem_protokol)
update public.islem_log l set tablo_id = 1305
 where l.tablo_id = 1109
   and exists (select 1 from public.goz_islem_protokol x where x.id = l.kayit_id)
   and not exists (select 1 from public.dikte_terim y where y.id = l.kayit_id);

-- 1150 -> 1298 (ameliyat)
update public.islem_log l set tablo_id = 1298
 where l.tablo_id = 1150
   and exists (select 1 from public.ameliyat x where x.id = l.kayit_id)
   and not exists (select 1 from public.medula_kuyruk y where y.id = l.kayit_id);

-- 1151 -> 1306 (ameliyat_islem)
update public.islem_log l set tablo_id = 1306
 where l.tablo_id = 1151
   and exists (select 1 from public.ameliyat_islem x where x.id = l.kayit_id)
   and not exists (select 1 from public.medula_fatura y where y.id = l.kayit_id);

-- 1152 -> 1307 (ameliyat_ekip)
update public.islem_log l set tablo_id = 1307
 where l.tablo_id = 1152
   and exists (select 1 from public.ameliyat_ekip x where x.id = l.kayit_id)
   and not exists (select 1 from public.medula_donem y where y.id = l.kayit_id);

-- 1153 -> 1308 (ameliyat_kontrol)
update public.islem_log l set tablo_id = 1308
 where l.tablo_id = 1153
   and exists (select 1 from public.ameliyat_kontrol x where x.id = l.kayit_id)
   and not exists (select 1 from public.medula_rapor y where y.id = l.kayit_id);

-- 1154 -> 1309 (ameliyat_sarf)
update public.islem_log l set tablo_id = 1309
 where l.tablo_id = 1154
   and exists (select 1 from public.ameliyat_sarf x where x.id = l.kayit_id)
   and not exists (select 1 from public.medula_kesinti y where y.id = l.kayit_id);

-- 1200 -> 1300 (isg_firma)
update public.islem_log l set tablo_id = 1300
 where l.tablo_id = 1200
   and exists (select 1 from public.isg_firma x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_kontrol y where y.id = l.kayit_id);

-- 1201 -> 1301 (isg_firma_bolum)
update public.islem_log l set tablo_id = 1301
 where l.tablo_id = 1201
   and exists (select 1 from public.isg_firma_bolum x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_hazirlama y where y.id = l.kayit_id);

-- 1202 -> 1310 (isg_calisan)
update public.islem_log l set tablo_id = 1310
 where l.tablo_id = 1202
   and exists (select 1 from public.isg_calisan x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_hazirlama_kalem y where y.id = l.kayit_id);

-- 1203 -> 1302 (isg_asi)
update public.islem_log l set tablo_id = 1302
 where l.tablo_id = 1203
   and exists (select 1 from public.isg_asi x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_iade y where y.id = l.kayit_id);

-- 1204 -> 1299 (isg_muayene)
update public.islem_log l set tablo_id = 1299
 where l.tablo_id = 1204
   and exists (select 1 from public.isg_muayene x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_imha y where y.id = l.kayit_id);

-- 1205 -> 1311 (isg_ziyaret)
update public.islem_log l set tablo_id = 1311
 where l.tablo_id = 1205
   and exists (select 1 from public.isg_ziyaret x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_imha_satir y where y.id = l.kayit_id);

-- 1206 -> 1303 (isg_olay)
update public.islem_log l set tablo_id = 1303
 where l.tablo_id = 1206
   and exists (select 1 from public.isg_olay x where x.id = l.kayit_id)
   and not exists (select 1 from public.eczane_doz y where y.id = l.kayit_id);

-- 1244 -> 1294 (onay_vekalet)
update public.islem_log l set tablo_id = 1294
 where l.tablo_id = 1244
   and exists (select 1 from public.onay_vekalet x where x.id = l.kayit_id)
   and not exists (select 1 from public.satinalma_teklif y where y.id = l.kayit_id);

-- 1245 -> 1295 (onay_akis)
update public.islem_log l set tablo_id = 1295
 where l.tablo_id = 1245
   and exists (select 1 from public.onay_akis x where x.id = l.kayit_id)
   and not exists (select 1 from public.satinalma_teklif_kriter y where y.id = l.kayit_id);

-- 1246 -> 1296 (onay_akis_adim)
update public.islem_log l set tablo_id = 1296
 where l.tablo_id = 1246
   and exists (select 1 from public.onay_akis_adim x where x.id = l.kayit_id)
   and not exists (select 1 from public.satinalma_teklif_firma y where y.id = l.kayit_id);

do $$
declare v_kalan int;
begin
    select count(*) into v_kalan from public.islem_log
     where tablo_id in (903,904,909,913,914,915,918,919,920,921,923,925,942,943,944,
                        950,960,961,962,963,966,1016,1108,1109,1150,1151,1152,1153,
                        1154,1200,1201,1202,1203,1204,1205,1206,1244,1245,1246);
    raise notice '757 tamam. Eski numaralarda kalan satir: % '
                 '(kanonik sahibe ait olanlar + ayirt edilemeyenler).', v_kalan;
end $$;
