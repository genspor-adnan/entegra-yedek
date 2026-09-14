-- ============================================================================
--  Gentegre AI — GENEL AYARLARDAN "YEREL PARA" VE "SAAT FARKI" KALKIYOR
--  669_genel_ayar_para_saat_kaldir.sql   (666/667'nin devamı)
--
--  Kullanıcı: "Genel Ayarlar daki Yerel para birimi, ve saat farkı nı kaldır"
--             "bunlar artık şube den alınacak"
--
--  NEDEN:
--   · genel.yerel_para — kurum geneli tek para birimi, yurt dışında şubesi
--     olan kurumda cevapsız bir soruydu. Artık `sube.para_birimi` (666).
--   · genel.saat_farki — "UTC+3" gibi ELLE girilen bir kaymaydı; log listeleri
--     SQL'de bu kadar saat ekliyordu. İki sebeple bitti:
--       1) zaman damgaları artık timestamptz (667) - değer bir AN, gösterim
--          istemcinin işi; kayma bırakılsaydı saat İKİ KEZ kaydırılırdı,
--       2) sabit fark yaz saatinde yılda iki kez yanlış olur. Şubenin IANA
--          saat dilimi (`sube.zaman_dilimi`) takvimi bilir.
--
--  VERİ KAYBI YOK: kurumun yazdığı para birimi silinmeden ÖNCE şubelere
--  taşınır. Şube kendi birimini zaten girmişse (varsayılan TRY dışına
--  çıkmışsa) dokunulmaz - kullanıcının bilinçli ayarı ezilmez.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

-- ---------------------------------------------------------------------------
--  1) KURUMUN PARA BİRİMİ ŞUBELERE TAŞINIR
--     Uygulamanın döviz listesi tarihsel olarak 'TL' taşır (db/106); şube
--     kolonu ISO 4217 ister - 'TL' ise 'TRY' yazılır.
-- ---------------------------------------------------------------------------
do $$
declare v_kurum text; v_iso varchar(3); v_sube integer;
begin
    select nullif(trim(deger), '') into v_kurum
      from public.referans where anahtar = 'genel.yerel_para';

    if v_kurum is not null then
        v_iso := case when upper(v_kurum) in ('TL', 'TRY') then 'TRY'
                      else upper(left(v_kurum, 3)) end;

        update public.sube
           set para_birimi = v_iso
         where para_birimi = 'TRY'          -- yalniz DOKUNULMAMIS subeler
           and v_iso <> 'TRY';
        get diagnostics v_sube = row_count;
        raise notice '669: kurum para birimi % -> % · % sube guncellendi',
            v_kurum, v_iso, v_sube;
    else
        raise notice '669: genel.yerel_para tanimli degil - tasima gerekmedi';
    end if;
end $$;

-- ---------------------------------------------------------------------------
--  2) AYARLAR SİLİNİR
--     Satır kalsaydı ekranda görünmese de eski bir sorgu onu okumaya devam
--     edebilirdi; "kaldırıldı" demek satırın da gitmesi demektir.
-- ---------------------------------------------------------------------------
delete from public.referans where anahtar in ('genel.yerel_para', 'genel.saat_farki');

do $$
declare v_kalan integer;
begin
    select count(*) into v_kalan from public.referans
     where anahtar in ('genel.yerel_para', 'genel.saat_farki');
    raise notice '669 tamam: kalan ayar satiri % · sube para birimleri: %',
        v_kalan,
        (select string_agg(distinct para_birimi, ', ') from public.sube);
end $$;

commit;
