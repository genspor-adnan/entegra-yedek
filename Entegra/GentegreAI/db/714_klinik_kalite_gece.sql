-- 714: Klinik Kalite gece işi.
--
-- 713 motoru ekrandan tetiklenebiliyordu; bu dosya onu her gece kendiliğinden
-- çalıştırır. İş kaydı `zamanli_is` tablosuna, işin kendisi
-- `ZamanliIsler.Kayitli["klinik.kalite"]` altına yazılır (405 deseni: zaman
-- veritabanında, iş kodda).
--
-- TEMEL KARAR — İKİ DÖNEM HESAPLANIR: içinde bulunduğumuz dönem VE bir
--   öncekisi. Yalnız güncel dönem hesaplansaydı, izlem penceresi olan
--   göstergeler eksik kalırdı: aralıkta ameliyat olan hastanın "ilk 60 gün
--   içinde reoperasyon"u şubatta doğar ve o olay, kapanmış döneme aittir.
--   Önceki dönem kullanıcı KESİNLEŞTİRENE kadar tazelenmeye devam eder;
--   kesinleşen satıra motor zaten dokunmaz.
--
-- TEMEL KARAR — HER ŞUBE AYRI HESAPLANIR. Ölçüm şubeye ait bir kayıttır ve
--   Bakanlığa kurum bazında gider; tek seferde şube süzmesiz hesaplasaydık
--   çok şubeli kurumda bütün şubelerin hastaları tek orana karışırdı.
--
-- TEMEL KARAR — HESAP SQL'DE. C# tarafı tek satır: bu fonksiyonu çağırır ve
--   açıklamayı döner. Döngüyü C#'a yazsaydık dönem seçme kuralı iki yerde
--   olurdu (gece işi ve ekran), zamanla ayrışırdı.

create or replace function public.fn_klinik_kalite_gece()
returns table (aciklama text)
language plpgsql
as $fn$
declare
    v_bugun   date := current_date;
    v_yil     smallint;
    v_no      smallint;
    v_o_yil   smallint;
    v_o_no    smallint;
    v_yaz     integer := 0;
    v_atla    integer := 0;
    v_kodsuz  integer := 0;
    v_sube    integer := 0;
    r_sube    record;
    h         record;
begin
    -- İçinde bulunduğumuz 6 aylık dönem (rehberin analiz periyodu).
    v_yil := extract(year from v_bugun)::smallint;
    v_no  := case when extract(month from v_bugun) <= 6 then 1 else 2 end;

    -- Bir önceki dönem: yılın 1. yarısındaysak geçen yılın 2. yarısı.
    if v_no = 1 then
        v_o_yil := (v_yil - 1)::smallint;
        v_o_no  := 2::smallint;
    else
        v_o_yil := v_yil;
        v_o_no  := 1::smallint;
    end if;

    for r_sube in
        select s.id from public.sube s where s.aktif = 1 order by s.id
    loop
        v_sube := v_sube + 1;

        select * into h
          from public.fn_klinik_donem_hesapla(r_sube.id, v_yil, v_no, 6::smallint, 0);
        v_yaz := v_yaz + h.yazilan; v_atla := v_atla + h.atlanan;
        v_kodsuz := v_kodsuz + h.kodsuz;

        select * into h
          from public.fn_klinik_donem_hesapla(r_sube.id, v_o_yil, v_o_no, 6::smallint, 0);
        v_yaz := v_yaz + h.yazilan; v_atla := v_atla + h.atlanan;
        v_kodsuz := v_kodsuz + h.kodsuz;
    end loop;

    -- Açıklama üç sayıyı da söyler: yalnız "tamam" deseydi, kod listesi eksik
    --   olduğu için hiç hesaplanmayan göstergelerin sebebi günlükte görünmezdi.
    return query select
        v_sube || ' şube × 2 dönem (' || v_yil || '/' || v_no || ', '
        || v_o_yil || '/' || v_o_no || '): ' || v_yaz || ' gösterge yazıldı'
        || case when v_atla > 0 then ', ' || v_atla || ' kesinleşmiş korundu' else '' end
        || case when v_kodsuz > 0 then ', ' || v_kodsuz || ' kod listesi eksik' else '' end
        || '.';
end;
$fn$;

comment on function public.fn_klinik_kalite_gece() is
  'Gece işi: aktif her şube için güncel ve bir önceki 6 aylık dönemi hesaplar (714).';

-- ============================================================== iş kaydı ==
-- Periyot 2 = günlük. Saat 02:40: yatak ücreti tahakkuku 01:10'da, TİTCK
--   indirmeleri 04:00'te çalışıyor - araya girip birbirini beklemesinler.
--   Gece, çünkü hesap bütün belge/tanı/reçete tablolarını tarar.
insert into public.zamanli_is (kod, ad, aktif, periyot, gun, saat, dakika, aciklama)
select 'klinik.kalite', 'Klinik Kalite dönem hesaplama', 1, 2, 1, 2, 40,
       'Aktif her şube için güncel ve bir önceki 6 aylık dönemi hesaplar; kesinleşmiş satıra dokunmaz.'
 where not exists (select 1 from public.zamanli_is where kod = 'klinik.kalite');
