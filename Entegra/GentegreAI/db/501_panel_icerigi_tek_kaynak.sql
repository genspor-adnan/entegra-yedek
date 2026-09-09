-- =====================================================================
--  501_panel_icerigi_tek_kaynak.sql
--  PANEL İÇERİĞİ TEK YERDE: `hizmet_paket`.
--
--  İki ayrı içerik deposu vardı:
--    * `hizmet_paket`  (496) - satılabilir panel/paketin içeriği, hizmet -> hizmet
--    * `lab_panel_satir`     - laboratuvar panelinin tetkikleri, lab_tetkik -> lab_tetkik
--  Aynı bilgi iki yerde bakım ister ve kaçınılmaz olarak ayrışır: katalogdan
--  panele tetkik eklenince laboratuvar görmez, laboratuvardan eklenince
--  faturaya/istem patlatmasına girmez.
--
--  ÇÖZÜM: içerik yalnız `hizmet_paket`'te durur. `lab_panel` laboratuvara
--  ÖZGÜ alanları taşımaya devam eder (kod, bölüm, açıklama, hizmet bağı);
--  `lab_panel_satir` artık bir GÖRÜNÜM - okuması hizmet_paket'ten gelir,
--  yazması INSTEAD OF tetikleriyle oraya düşer. Böylece iki ekran da
--  (hizmet kartı "Panel İçeriği" ve laboratuvar panel kartı) çalışmaya
--  devam eder, depo tektir.
--
--  KÖPRÜ: `lab_tetkik.hizmet_id` ve `lab_panel.hizmet_id`. Aktarılan veride
--  ikisi de boştu; kod ya da normalize AD eşleşmesiyle bağlanır, eşleşmeyen
--  ve panelde geçen kayıtlar için katalogda hizmet AÇILIR (istenen bir tetkik
--  zaten faturalanabilir bir hizmettir). Eşleşmeyen ve panelde geçmeyen
--  kayıtlara dokunulmaz.
-- =====================================================================

do $$
declare
    v_sube      integer;
    v_lab_kat   integer;
    v_pak_kat   integer;
    v_baglanan  integer := 0;
    v_acilan    integer := 0;
    v_tasinan   integer := 0;
    r           record;
    v_id        integer;
    v_kod       varchar(40);
begin
    -- hizmet.sube_id yabancı anahtarlı: varsayılan şube alınır.
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    -- Hedef kategoriler (498'de kurulan ağaç).
    select id into v_lab_kat from public.kategori
     where tur = 2 and ad = 'Laboratuvar' and ust_id is null order by id limit 1;
    select id into v_pak_kat from public.kategori
     where tur = 2 and ad = 'Paketler & Paneller' and ust_id is null order by id limit 1;

    -- ------------------------------------------- lab_tetkik -> hizmet --
    update public.lab_tetkik t
       set hizmet_id = h.id
      from public.hizmet h
     where t.hizmet_id is null
       and (h.kod = t.kod
         or regexp_replace(upper(translate(h.ad, 'ıİşŞğĞüÜöÖçÇ', 'IISSGGUUOOCC')), '[^A-Z0-9+-]', '', 'g')
          = regexp_replace(upper(translate(t.ad, 'ıİşŞğĞüÜöÖçÇ', 'IISSGGUUOOCC')), '[^A-Z0-9+-]', '', 'g'));
    get diagnostics v_baglanan = row_count;

    -- Panelde geçen ama katalogda karşılığı olmayan tetkik: hizmet açılır.
    for r in
        select distinct t.id, t.kod, t.ad
          from public.lab_tetkik t
          join public.lab_panel_satir s on s.tetkik_id = t.id
         where t.hizmet_id is null
    loop
        v_kod := left('LAB.' || r.kod, 40);
        if exists (select 1 from public.hizmet where kod = v_kod) then
            v_kod := left('LAB.' || r.kod || '.' || r.id, 40);
        end if;
        insert into public.hizmet (kod, ad, kategori, durum, kdv, birim, sube_id)
        values (v_kod, r.ad, v_lab_kat, 1, 0, 0, v_sube)
        returning id into v_id;
        update public.lab_tetkik set hizmet_id = v_id where id = r.id;
        v_acilan := v_acilan + 1;
    end loop;

    -- --------------------------------------------- lab_panel -> hizmet --
    update public.lab_panel p
       set hizmet_id = h.id
      from public.hizmet h
     where p.hizmet_id is null
       and (h.kod = p.kod
         or regexp_replace(upper(translate(h.ad, 'ıİşŞğĞüÜöÖçÇ', 'IISSGGUUOOCC')), '[^A-Z0-9+-]', '', 'g')
          = regexp_replace(upper(translate(p.ad, 'ıİşŞğĞüÜöÖçÇ', 'IISSGGUUOOCC')), '[^A-Z0-9+-]', '', 'g'));

    for r in select id, kod, ad from public.lab_panel where hizmet_id is null loop
        v_kod := left(r.kod, 40);
        if v_kod = '' or exists (select 1 from public.hizmet where kod = v_kod) then
            v_kod := left('PNL.' || r.id, 40);
        end if;
        insert into public.hizmet (kod, ad, kategori, durum, kdv, birim, sube_id)
        values (v_kod, r.ad, coalesce(v_pak_kat, v_lab_kat), 1, 0, 0, v_sube)
        returning id into v_id;
        update public.lab_panel set hizmet_id = v_id where id = r.id;
        v_acilan := v_acilan + 1;
    end loop;

    -- ------------------------------------------------ içeriği taşı --
    insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira)
    select p.hizmet_id, t.hizmet_id, s.sira
      from public.lab_panel_satir s
      join public.lab_panel  p on p.id = s.panel_id
      join public.lab_tetkik t on t.id = s.tetkik_id
     where p.hizmet_id is not null and t.hizmet_id is not null
       and p.hizmet_id <> t.hizmet_id
    on conflict (paket_hizmet_id, icerik_hizmet_id) do nothing;
    get diagnostics v_tasinan = row_count;

    raise notice 'Köprü: % tetkik/panel eşleşti, % yeni hizmet açıldı, % içerik satırı taşındı.',
                 v_baglanan, v_acilan, v_tasinan;
end $$;

-- ------------------------------------------------- tabloyu göze çevir --
-- Eski tablo yedek olarak kalır; adı GÖRÜNÜME devredilir ki iki ekran da
--   (lab panel kartı, lab tetkik kartının "Paneller" sekmesi) çalışsın.
do $$
begin
    -- Yalniz HALA TABLOYSA devret: gocun ikinci kosusunda ad zaten goruntuye
    --   ait, "relation already exists" ile dusuyordu.
    if exists (select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
                where n.nspname = 'public' and c.relname = 'lab_panel_satir'
                  and c.relkind = 'r') then
        alter table public.lab_panel_satir rename to _yedek_lab_panel_satir_501;
    end if;
end $$;

create or replace view public.lab_panel_satir as
select hp.id,
       lp.id                       as panel_id,
       lt.id                       as tetkik_id,
       hp.sira,
       ''::varchar(20)             as gen,
       hp.ekleyen,
       hp.ekleme_tarihi,
       hp.degistiren,
       hp.degistirme_tarihi
  from public.hizmet_paket hp
  join public.lab_panel  lp on lp.hizmet_id = hp.paket_hizmet_id
  join public.lab_tetkik lt on lt.hizmet_id = hp.icerik_hizmet_id;

comment on view public.lab_panel_satir is
    'Panel içeriği - tek kaynak public.hizmet_paket (501). Yazma INSTEAD OF tetikleriyle oraya düşer.';

create or replace function public.tg_lab_panel_satir_yaz() returns trigger
language plpgsql as $$
declare
    v_paket  integer;
    v_icerik integer;
begin
    if tg_op = 'DELETE' then
        delete from public.hizmet_paket where id = old.id;
        return old;
    end if;

    select hizmet_id into v_paket  from public.lab_panel  where id = new.panel_id;
    select hizmet_id into v_icerik from public.lab_tetkik where id = new.tetkik_id;

    -- Köprü kurulmamışsa sessizce yazmak İÇERİĞİ KAYBETTİRİR: panel kartı
    --   satırı kaydedilmiş görünür ama hiçbir yere düşmez.
    if v_paket is null then
        raise exception 'GK422: Panelin hizmet karşılığı tanımlı değil - panel kartında "Hizmet (paket fiyat)" alanını doldurun.';
    end if;
    if v_icerik is null then
        raise exception 'GK422: Tetkikin hizmet karşılığı tanımlı değil - tetkik kartında hizmet bağını kurun.';
    end if;

    if tg_op = 'INSERT' then
        insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira,
                                         ekleyen, degistiren)
        values (v_paket, v_icerik, coalesce(new.sira, 0),
                coalesce(new.ekleyen, 0), coalesce(new.degistiren, 0))
        on conflict (paket_hizmet_id, icerik_hizmet_id)
            do update set sira = excluded.sira
        returning id into new.id;
        return new;
    end if;

    update public.hizmet_paket
       set paket_hizmet_id   = v_paket,
           icerik_hizmet_id  = v_icerik,
           sira              = coalesce(new.sira, 0),
           degistiren        = coalesce(new.degistiren, 0),
           degistirme_tarihi = now()::timestamp
     where id = old.id;
    return new;
end $$;

drop trigger if exists tg_lab_panel_satir_ekle on public.lab_panel_satir;
create trigger tg_lab_panel_satir_ekle instead of insert on public.lab_panel_satir
    for each row execute function public.tg_lab_panel_satir_yaz();
drop trigger if exists tg_lab_panel_satir_guncelle on public.lab_panel_satir;
create trigger tg_lab_panel_satir_guncelle instead of update on public.lab_panel_satir
    for each row execute function public.tg_lab_panel_satir_yaz();
drop trigger if exists tg_lab_panel_satir_sil on public.lab_panel_satir;
create trigger tg_lab_panel_satir_sil instead of delete on public.lab_panel_satir
    for each row execute function public.tg_lab_panel_satir_yaz();

-- Panel kartında hizmet bağı ARTIK ZORUNLU: içerik oradan yazılıyor.
create or replace function public.tg_lab_panel_hizmet() returns trigger
language plpgsql as $$
begin
    if new.hizmet_id is null then
        raise exception 'GK422: Panelin hizmet karşılığı seçilmeli - panel içeriği hizmet katalogunda tutuluyor.';
    end if;
    return new;
end $$;

drop trigger if exists tg_lab_panel_hizmet on public.lab_panel;
create trigger tg_lab_panel_hizmet before insert or update of hizmet_id
    on public.lab_panel for each row execute function public.tg_lab_panel_hizmet();
