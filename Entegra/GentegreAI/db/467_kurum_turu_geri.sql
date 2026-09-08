-- =====================================================================
-- 467 - KURUM TÜRÜ YİNE ÜÇE İNDİ (kullanıcı: "kurum tipi tekrar 3'e düşecek")
--
-- 466'da TSS ayrı bir KURUM TÜRÜ yapılmıştı (1 Özel · 2 ÖSS · 3 TSS · 4 SGK).
-- Uygulamada TSS bir kurum türü değil, ÖSS kurumuyla yapılan SÖZLEŞMENİN
-- türüdür: aynı sigorta şirketiyle hem ÖSS hem TSS hem Karma poliçe çalışılır.
-- Türü dörde çıkarmak, aynı şirketi üç ayrı cari kaydı açmaya zorluyordu.
--
-- YENİ (466 öncesine dönüş): 1 Özel · 2 ÖSS · 3 SGK.
-- TSS/Karma ayrımı 468'de açılan `kurum_sozlesme.alt_kurum` alanına taşınır.
--
-- TAŞIMA İKİ YÖNLÜ:
--   a) 466'nın SGK 3 -> 4 taşıması geri alınır (yedekten kontrollü).
--   b) 466'dan SONRA açılmış TSS kayıtları (tur = 3) ÖSS'ye (2) çekilir ve
--      yedekte işaretlenir - 468 bunlara alt_kurum = 202 (TSS) sözleşmesi açar.
--      İşaretlemeden çekmek, TSS anlaşmasını sessizce ÖSS'ye çevirirdi.
--
-- IDEMPOTENT: taşınacak satır yedekten kontrol edilir; ikinci koşuda kimse
-- ikinci kez taşınmaz.
-- =====================================================================

create table if not exists public._yedek_kurum_turu_467 (
    tablo     varchar(40) not null,
    kayit_id  integer     not null,
    eski_tur  smallint    not null,
    yeni_tur  smallint    not null,
    tarih     timestamp   not null default now(),
    primary key (tablo, kayit_id)
);

-- ---------------------------------------------------------------- a) 4 -> 3 --
insert into public._yedek_kurum_turu_467 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_kurum', k.id, k.tur, 3
  from public.taraf_kurum k
 where k.tur = 4
on conflict (tablo, kayit_id) do nothing;

update public.taraf_kurum k set tur = 3, degistirme_tarihi = now()
 where k.tur = 4
   and exists (select 1 from public._yedek_kurum_turu_467 y
                where y.tablo = 'taraf_kurum' and y.kayit_id = k.id
                  and y.eski_tur = 4);

insert into public._yedek_kurum_turu_467 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_hasta_kurum', h.id, h.tur, 3
  from public.taraf_hasta_kurum h
 where h.tur = 4
on conflict (tablo, kayit_id) do nothing;

update public.taraf_hasta_kurum h set tur = 3
 where h.tur = 4
   and exists (select 1 from public._yedek_kurum_turu_467 y
                where y.tablo = 'taraf_hasta_kurum' and y.kayit_id = h.id
                  and y.eski_tur = 4);

-- ------------------------------------------------ b) TSS (3) -> ÖSS (2) --
-- Bu satırlar 466 ile 467 arasında TSS olarak açılmış kayıtlardır. Yedekteki
--   eski_tur = 3 işareti, 468'in hangi sözleşmeye TSS alt kurumu vereceğini
--   söyler - bilgi burada kaybolursa bir daha bulunamaz.
insert into public._yedek_kurum_turu_467 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_kurum', k.id, 3, 2
  from public.taraf_kurum k
 where k.tur = 3
   and not exists (select 1 from public._yedek_kurum_turu_467 y
                    where y.tablo = 'taraf_kurum' and y.kayit_id = k.id)
on conflict (tablo, kayit_id) do nothing;

update public.taraf_kurum k set tur = 2, degistirme_tarihi = now()
 where k.tur = 3
   and exists (select 1 from public._yedek_kurum_turu_467 y
                where y.tablo = 'taraf_kurum' and y.kayit_id = k.id
                  and y.eski_tur = 3 and y.yeni_tur = 2);

insert into public._yedek_kurum_turu_467 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_hasta_kurum', h.id, 3, 2
  from public.taraf_hasta_kurum h
 where h.tur = 3
   and not exists (select 1 from public._yedek_kurum_turu_467 y
                    where y.tablo = 'taraf_hasta_kurum' and y.kayit_id = h.id)
on conflict (tablo, kayit_id) do nothing;

update public.taraf_hasta_kurum h set tur = 2
 where h.tur = 3
   and exists (select 1 from public._yedek_kurum_turu_467 y
                where y.tablo = 'taraf_hasta_kurum' and y.kayit_id = h.id
                  and y.eski_tur = 3 and y.yeni_tur = 2);

-- ------------------------------------------------------------ kod listesi --
do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'taraf.kurum_turu';
    if v_liste is null then
        raise notice '467: taraf.kurum_turu kod listesi yok - atlandi';
        return;
    end if;

    update public.kod_deger set ad = 'Özel', sira = 10, aktif = 1
     where liste_id = v_liste and deger = 1;

    update public.kod_deger set ad = 'ÖSS (Özel Sağlık Sigortası)', sira = 20, aktif = 1
     where liste_id = v_liste and deger = 2;

    update public.kod_deger set ad = 'SGK', sira = 30, aktif = 1
     where liste_id = v_liste and deger = 3;

    -- 4 SİLİNMEZ, PASİFE alınır: eski log satırları hâlâ "4" yazıyor;
    --   kod kaybolursa geçmiş kayıt "bilinmeyen tür" olarak okunurdu.
    update public.kod_deger set aktif = 0
     where liste_id = v_liste and deger = 4;
end $$;

-- Varsayılan yine SGK, ama artık 3.
alter table public.taraf_kurum alter column tur set default 3;

-- PRİM PLANI ödeyen tipi de aynı kod uzayını kullanıyor (466'da 4'e çekilmişti).
do $$
begin
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'prim_plani'
                  and column_name = 'odeyen_tipi') then
        update public.prim_plani set odeyen_tipi = 3 where odeyen_tipi = 4;
    end if;
end $$;

do $$
begin
    raise notice '467 tamam: % kayit 4->3, % kayit TSS(3)->OSS(2) tasindi',
        (select count(*) from public._yedek_kurum_turu_467 where eski_tur = 4),
        (select count(*) from public._yedek_kurum_turu_467 where eski_tur = 3);
end $$;
