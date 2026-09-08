-- =====================================================================
-- 466 - KURUM TÜRÜNE TSS EKLENDİ (kullanıcı)
--
-- ESKİ: 1 Özel · 2 ÖSS · 3 SGK
-- YENİ: 1 Özel · 2 ÖSS (Özel Sağlık Sigortası) · 3 TSS (Tamamlayıcı Sağlık
--       Sigortası) · 4 SGK
--
-- TSS ile ÖSS aynı şey değil: TSS'de ASIL ÖDEYİCİ SGK'dır, tamamlayıcı poliçe
-- yalnız farkı üstlenir - provizyon SGK'dan alınır, fark özel sigortaya
-- faturalanır. İkisini tek kodda toplamak provizyon akışını yanlış kuruyordu.
--
-- SGK KODU 3 -> 4: mevcut kayıtlar TAŞINIR, yoksa eski SGK kurumları bir gecede
-- "TSS" olur ve provizyon akışı sessizce değişirdi. Taşıma ÖNCE veri, SONRA
-- kod listesi sırasıyla yapılır; her satırın eski değeri yedek tabloda kalır.
--
-- IDEMPOTENT: ikinci koşuda taşınacak satır kalmaz (tur=3 olanlar zaten TSS
-- olarak kaydedilmiş yeni satırlardır) - bu yüzden taşıma YEDEKTEN kontrol
-- edilir, kör bir "3 -> 4" tekrarı yapılmaz.
-- =====================================================================

create table if not exists public._yedek_kurum_turu_466 (
    tablo     varchar(40) not null,
    kayit_id  integer     not null,
    eski_tur  smallint    not null,
    yeni_tur  smallint    not null,
    tarih     timestamp   not null default now(),
    primary key (tablo, kayit_id)
);

-- 1) VERİ: SGK (3) -> 4. Yalnız bir kez; yedekte kaydı olan satır atlanır.
insert into public._yedek_kurum_turu_466 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_kurum', k.id, k.tur, 4
  from public.taraf_kurum k
 where k.tur = 3
on conflict (tablo, kayit_id) do nothing;

update public.taraf_kurum k set tur = 4, degistirme_tarihi = now()
 where k.tur = 3
   and exists (select 1 from public._yedek_kurum_turu_466 y
                where y.tablo = 'taraf_kurum' and y.kayit_id = k.id
                  and y.eski_tur = 3);

insert into public._yedek_kurum_turu_466 (tablo, kayit_id, eski_tur, yeni_tur)
select 'taraf_hasta_kurum', h.id, h.tur, 4
  from public.taraf_hasta_kurum h
 where h.tur = 3
on conflict (tablo, kayit_id) do nothing;

update public.taraf_hasta_kurum h set tur = 4
 where h.tur = 3
   and exists (select 1 from public._yedek_kurum_turu_466 y
                where y.tablo = 'taraf_hasta_kurum' and y.kayit_id = h.id
                  and y.eski_tur = 3);

-- 2) KOD LİSTESİ: 4 = SGK, 3 = TSS, adlar açıldı.
do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'taraf.kurum_turu';
    if v_liste is null then
        raise notice '466: taraf.kurum_turu kod listesi yok - atlandi';
        return;
    end if;

    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
    values (v_liste, 4, 0, 'SGK', 40, 1)
    on conflict (liste_id, deger, dil) do update
        set ad = excluded.ad, sira = excluded.sira, aktif = 1;

    update public.kod_deger
       set ad = 'TSS (Tamamlayıcı Sağlık Sigortası)', sira = 30, aktif = 1
     where liste_id = v_liste and deger = 3;

    update public.kod_deger set ad = 'Özel', sira = 10
     where liste_id = v_liste and deger = 1;

    update public.kod_deger set ad = 'ÖSS (Özel Sağlık Sigortası)', sira = 20
     where liste_id = v_liste and deger = 2;
end $$;

do $$
begin
    raise notice '466 tamam: % kurum sozlesmesi ve % hasta kurumu SGK 4 e tasindi',
        (select count(*) from public._yedek_kurum_turu_466 where tablo = 'taraf_kurum'),
        (select count(*) from public._yedek_kurum_turu_466 where tablo = 'taraf_hasta_kurum');
end $$;

-- 3) VARSAYILAN: sozlesme turu verilmeden acilan kayit SGK olsun - eskiden
--    default 3 SGK'ydi, 3 artik TSS; degistirilmezse sessizce yanlis tur.
alter table public.taraf_kurum alter column tur set default 4;
