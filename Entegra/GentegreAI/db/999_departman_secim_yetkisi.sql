-- =============================================================================
--  999 - BÖLÜM LİSTESİ KENDİ YETKİSİNE AYRILDI
--
--  Kullanıcı (09.10.2026): "hasan olarak girdim.. başvuru menüsüne tıklayınca:
--  Bu islem icin yetkiniz yok."
--
--  TEŞHİS. Hata başvuru listesinden değil, listenin üst şeridindeki BÖLÜM
--  SÜZGECİNDEN geliyordu: `/api/liste/departman` 403. `departman` kaynağının
--  yetki kodu `personel`di, yani bölüm adlarını okumak için personel ÖZLÜK
--  yetkisi gerekiyordu. Kayıt kabul rolünde o yetki bilinçli olarak yok
--  (684: "banko görevlisine hasta listesi vermek için personel özlük
--  kayıtlarını da açmak gerekiyordu").
--
--  Bu 998'in yan etkisi değil, eskiden beri duran bir boşluk; menü
--  temizlendikten sonra başvuru ekranına girilince görünür oldu.
--
--  ÇÖZÜM. Bölüm listesi kendi kodunu alır (`departman`) ve iki kapı ayrılır:
--    * MENÜ kapısı `personel` kalır - İK'daki "Bölüm / Görev" TANIM ekranı
--      İK'nın işi, kayıt kabul menüsünde görünmemeli.
--    * VERİ kapısı `departman` olur - başvuru/randevu süzgeci, çalışma planı
--      ve acil çıkış modalı bölüm adlarını bu yetkiyle okur.
--
--  `departman` menüde HİÇBİR ekran açmaz (saf veri yetkisi, `belge_satir` ve
--  `taraf` gibi) - bu yüzden yetki matrisinde Sistem grubunda durur ve
--  verilmesi kimsenin menüsünü kirletmez.
--
--  DAĞITIM: davranış korunsun diye `personel` görme yetkisi olan her role
--  verilir (onlar bugün de görüyordu), ayrıca `hasta` görme yetkisi olan
--  rollere - hasta gören herkes başvuru/randevu süzgecinde bölüm seçer.
--  Betik idempotent.
-- =============================================================================

begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
values ('departman', 'Bölüm / birim listesi (seçim)', 'Sistem', 0, 9020, 0, '')
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur,
       sira = excluded.sira, urun_modu = excluded.urun_modu, modul = excluded.modul;

-- Bölüm adını okumak YAZMA hakkı vermez: yalnız `gor`. Tanım ekranı
--   (İK > Bölüm / Görev) `personel` yetkisiyle açılmaya devam eder.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select distinct ry.rol_id, y.id, 1, 0, 0, 0
  from public.rol_yetki ry
  join public.yetki ky on ky.id = ry.yetki_id
 cross join public.yetki y
 where y.kod = 'departman'
   and ky.kod in ('personel', 'hasta')
   and ry.gor = 1
on conflict (rol_id, yetki_id) do update set gor = 1;

commit;

-- Kontrol:
--   select r.kod from rol r join rol_yetki ry on ry.rol_id = r.id
--     join yetki y on y.id = ry.yetki_id
--    where y.kod = 'departman' and ry.gor = 1 order by r.kod;
