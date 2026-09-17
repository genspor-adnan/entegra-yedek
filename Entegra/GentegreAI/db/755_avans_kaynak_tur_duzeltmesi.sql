-- ============================================================================
--  Gentegre AI — AVANSIN KAYNAK TÜRÜ DÜZELTİLİYOR (907/908 → 1257/1258)
--  755_avans_kaynak_tur_duzeltmesi.sql
--
--  Kullanıcı: "907 çakışmasını düzelt."
--
--  753'te avans modülü yazılırken `personel_avans`a **907**, kesinti planına
--  **908** verilmişti. Bu numaralar BOŞ DEĞİLDİ:
--
--      907 = Hasta Bilgisi (taraf_hasta)
--      908 = Kasa İşlemi   (kasa_islem)
--
--  (Kanonik liste `KaynakKatalogu.Log.cs` içindeki `TabloAdiIfade` case'i;
--   ayrı bir kayıt tablosu yok, numaralar Delphi `ISLEMLOG.TABLOID`
--   uzayından geliyor.)
--
--  ============ NEDEN ÖNEMLİ ===========================================
--  Numara üç yerde birden anlam taşıyor:
--
--    1) `islem_log.tablo_id` — DENETİM İZİ. Avans kaydının değişiklik logu
--       "Hasta Bilgisi" etiketiyle ve HASTA id'si sanılacak bir `kayit_id`
--       ile yazılıyordu: avans #3'ün logu, log ekranında 3 numaralı hastanın
--       kaydı gibi görünüyor. Denetim izinin tek işi "kim neyi değiştirdi"
--       sorusunu cevaplamak; yanlış kaydı göstermesi izin kendisini
--       değersizleştirir.
--
--    2) `onay.kaynak_tur` — ONAY OMURGASI. Zincir kayda `kaynak_tur +
--       kaynak_id` ile bağlanıyor. Hastaya zincir açılmadığı için bugün
--       karışmıyordu, ama bu bir tesadüf; hasta kartına bir gün onay
--       gelseydi iki kayıt aynı anahtarı paylaşırdı ve gelen kutusu
--       birini öteki sanardı.
--
--    3) `kasa_islem.kaynak_tur` — avans ödemesi kasa hareketine `907` ile
--       bağlanıyordu, yani "bu kasa hareketinin kaynağı bir HASTA KAYDI"
--       diyordu.
--
--  ============ NEDEN 1257/1258 ========================================
--  Boş bir aralık seçildi: katalogda kullanılan en yüksek numara 1256
--  (754'te iskonto talebine verildi). Avansı 9xx bloğunun içine sıkıştırmak
--  yerine yeni ve kesin boş iki numara almak, aynı hatayı üçüncü kez
--  yapma riskini ortadan kaldırıyor.
--
--  ============ GEÇMİŞ LOG SATIRLARI TAŞINMIYOR ========================
--  `islem_log`'da 907 ile yazılmış satırların hangisinin avans hangisinin
--  hasta olduğu SATIRIN KENDİSİNDEN ANLAŞILMIYOR - ayrım tam da kaybolan
--  bilgi. `kayit_id`si bir avansla eşleşenleri taşımak, aynı id'ye sahip
--  gerçek bir hasta kaydını da yanlışlıkla avans yapardı; denetim izini
--  onarmak için ikinci kez bozmak olurdu.
--
--  Bu bir kayıp değil çünkü 753 hiçbir müşteriye gitmedi: 907 ile yazılmış
--  avans logu yalnız geliştirme veritabanında oluştu ve o satırlar bu
--  dosyada AYIKLANARAK siliniyor (aşağıda, `bilgi` anahtarlarıyla).
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) ONAY AKIŞI VE YÜRÜYEN ZİNCİRLER
-- ---------------------------------------------------------------------------
update public.onay_akis
   set kaynak_tur = 1257, degistirme_tarihi = now()
 where kod = 'personel.avans' and kaynak_tur = 907;

-- Zincirler AKIŞ ÜZERİNDEN bulunur, kaynak_tur üzerinden değil: 907'ye
--   bakarak seçseydik, hasta kartına açılmış (bugün yok ama olabilecek)
--   bir zinciri de avans sanıp taşırdık.
update public.onay o
   set kaynak_tur = 1257, degistirme_tarihi = now()
  from public.onay_akis k
 where k.id = o.akis_id and k.kod = 'personel.avans' and o.kaynak_tur = 907;

-- ---------------------------------------------------------------------------
--  2) KASA HAREKETLERİ
--     Avans ödemesi `kasa_islem`e `kaynak_tur = 907` ile bağlanıyordu.
--     Burada ayrım GÜVENLİ: kaynak_id gerçekten bir avans olmalı VE
--     hasta kaydının kasa hareketine kaynak olması diye bir yol yok
--     (hasta hareketleri `taraf_id` üzerinden bağlanır).
-- ---------------------------------------------------------------------------
update public.kasa_islem ki
   set kaynak_tur = 1257
 where ki.kaynak_tur = 907
   and exists (select 1 from public.personel_avans a where a.id = ki.kaynak_id);

-- ---------------------------------------------------------------------------
--  3) GELİŞTİRME ORTAMINDAKİ YANLIŞ ETİKETLİ LOG SATIRLARI
--     Yalnız AVANS ŞEKLİNDEKİ satırlar: avans logu `bilgi` alanında
--     `tutar`/`Tutar` + `taksit` ya da `bayraklar` taşır; hasta bilgisi
--     logunda bu anahtarlar bulunmaz. Eşleşme dar tutuldu - şüpheli satır
--     silinmektense yerinde bırakılır.
--
--     MÜŞTERİDE ÇALIŞMAZ, çünkü orada hiç oluşmadı (753 yayınlanmadı).
-- ---------------------------------------------------------------------------
delete from public.islem_log
 where tablo_id = 907
   and (bilgi ? 'bayraklar'
        or (bilgi ? 'taksit' and (bilgi ? 'tutar' or bilgi ? 'Tutar'))
        or (bilgi ? 'donem'  and (bilgi ? 'tutar' or bilgi ? 'Tutar')));

-- ---------------------------------------------------------------------------
--  4) AVANS LİSTESİ GÖRÜNÜMÜ (753'te 907'ye bakıyordu)
-- ---------------------------------------------------------------------------
create or replace view public.v_personel_avans as
select a.id,
       a.avans_no,
       a.taraf_id,
       coalesce(nullif(t.unvan, ''), '')                as personel_ad,
       coalesce(nullif(p.gorev, ''), '')                as gorev_ad,
       coalesce(nullif(am.unvan, ''), '')               as amir_ad,
       a.talep_tarihi,
       a.tutar,
       a.taksit_sayisi,
       a.ilk_donem,
       a.durum,
       a.odeme_islem_id,
       a.odeme_tarihi,
       a.gerekce,
       a.red_neden,
       a.iptal_neden,
       a.sube_id,
       -- KESİLEN / KALAN: avansın asıl sorusu "ne kadarı geri geldi".
       coalesce((select sum(k.tutar) from public.personel_avans_kesinti k
                  where k.avans_id = a.id and k.durum = 1), 0)     as kesilen_tutar,
       a.tutar - coalesce((select sum(k.tutar) from public.personel_avans_kesinti k
                            where k.avans_id = a.id and k.durum = 1), 0)
                                                                   as kalan_tutar,
       (select count(*) from public.personel_avans_kesinti k
         where k.avans_id = a.id and k.durum = 0)                  as bekleyen_taksit,
       -- GECİKEN KESİNTİ: dönemi geçmiş ama kesilmemiş taksit, unutulmuş
       --   bir mahsuptur - avans kapanmadan personel ayrılırsa tahsil
       --   edilemez.
       (select count(*) from public.personel_avans_kesinti k
         where k.avans_id = a.id and k.durum = 0
           and k.donem < to_char(current_date, 'YYYY-MM'))         as geciken_taksit,
       (select v.adim_ad from public.v_onay_bekleyen v
         -- 1257 (755): onceden 907 idi ve o numara Hasta Bilgisi'nin.
         where v.kaynak_tur = 1257 and v.kaynak_id = a.id
         order by v.sira limit 1)                                  as bekleyen_basamak,
       a.ekleme_tarihi,
       a.degistirme_tarihi
  from public.personel_avans a
  join public.taraf t              on t.id = a.taraf_id
  left join public.taraf_personel p on p.id = a.taraf_id
  left join public.taraf am        on am.id = p.yonetici_taraf_id;

comment on view public.v_personel_avans is
  '753/755: avans listesi - kesilen/kalan/geciken taksit cozulmus halde.';

-- ---------------------------------------------------------------------------
--  5) GELEN KUTUSU (754'ün görünümü, avans dalı 1257'ye çekildi)
-- ---------------------------------------------------------------------------
create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
       v.onay_id, v.kaynak_tur, v.kaynak_id, v.sube_id,
       v.akis_kod, v.akis_ad, v.olcu, v.olcu_adi, v.sira, v.adim_ad, v.rol,
       v.atanan_kullanici_id, v.durum, v.gerekce, v.baslama, v.termin,
       v.gecikme_gun,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            when 904  then coalesce(nullif(z.izin_no, ''), 'İzin #' || v.kaynak_id::text)
            when 1224 then coalesce(nullif(w.is_emri_no, ''),
                                    'İş emri #' || v.kaynak_id::text)
            when 1257 then coalesce(nullif(av.avans_no, ''),
                                    'Avans #' || v.kaynak_id::text)
            when 1256 then coalesce(nullif(ib.belge_no, ''),
                                    'Başvuru #' || coalesce(isk.belge_id, 0)::text)
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            when 904  then case z.tur when 1 then 'Yıllık izin'
                                      when 2 then 'Mazeret izni'
                                      when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin'
                                      else 'İzin' end
                           || ' · ' || to_char(z.baslangic_tarihi, 'DD.MM')
                           || '-' || to_char(z.bitis_tarihi, 'DD.MM.YYYY')
            when 1224 then coalesce(nullif(dm.ad, ''), 'Cihaz')
                           || ' · ' || coalesce(nullif(w.ariza_metni, ''), 'onarım')
            when 1257 then coalesce(nullif(av.gerekce, ''), 'Avans')
                           || ' · ' || av.taksit_sayisi::text || ' taksit'
            when 1256 then coalesce(nullif(isk.gerekce, ''), 'İskonto talebi')
                           || ' · ' || (select count(*)::text
                                          from public.iskonto_talep_satir ts
                                         where ts.talep_id = isk.id) || ' kalem'
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            when 904  then coalesce(nullif(zp.gorev, ''), '')
            when 1224 then coalesce(wd.ad, '')
            when 1257 then coalesce(nullif(ap.gorev, ''), '')
            when 1256 then coalesce(ih.unvan, '')
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            when 904  then coalesce(zt.unvan, '')
            when 1224 then coalesce(wb.unvan, '')
            when 1257 then coalesce(at.unvan, '')
            when 1256 then coalesce(ii.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id
  left join public.personel_izin z on v.kaynak_tur = 904 and z.id = v.kaynak_id
  left join public.taraf zt          on zt.id = z.taraf_id
  left join public.taraf_personel zp on zp.id = z.taraf_id
  left join public.demirbas_is_emri w on v.kaynak_tur = 1224 and w.id = v.kaynak_id
  left join public.demirbas dm  on dm.id = w.demirbas_id
  left join public.departman wd on wd.id = w.departman_id
  left join public.taraf wb     on wb.id = w.bildiren_id
  left join public.personel_avans av on v.kaynak_tur = 1257 and av.id = v.kaynak_id
  left join public.taraf at          on at.id = av.taraf_id
  left join public.taraf_personel ap on ap.id = av.taraf_id
  left join public.iskonto_talep isk on v.kaynak_tur = 1256 and isk.id = v.kaynak_id
  left join public.belge ib on ib.id = isk.belge_id
  left join public.taraf ih on ih.id = ib.taraf_id
  left join public.taraf ii on ii.id = isk.isteyen_id;

comment on view public.v_onay_kutusu is
  '739/744/752/753/754/755: butun modullerin bekleyen onaylari (satinalma '
  'talebi · izin · masrafli onarim · avans · iskonto). Avans 1257 (onceden '
  '907 = Hasta Bilgisi ile cakisiyordu).';

do $$
declare v_akis int; v_onay int; v_kasa int;
begin
    select count(*) into v_akis from public.onay_akis
     where kod = 'personel.avans' and kaynak_tur = 1257;
    select count(*) into v_onay from public.onay where kaynak_tur = 1257;
    select count(*) into v_kasa from public.kasa_islem where kaynak_tur = 1257;
    raise notice '755 tamam: avans 907/908 -> 1257/1258 (akis %, zincir %, kasa %).',
                 v_akis, v_onay, v_kasa;
end $$;
