-- ============================================================================
--  Gentegre AI — ANA SALTER = "e-Fatura Mükellefi" kutusu
--  179_ebelge_ana_salter.sql
--
--  Kullanici: "ana salter e-Fatura mukellefi check".
--
--  ONCEKI DURUM: firma geneli `ebelge.aktif` ayari ANA SALTER, sube bazli
--  mukellefiyet bayraklari tur salteriydi. Iki katman ayni soruyu iki yerden
--  soruyordu: "bu firma e-Belge kesiyor mu?" Ayar acik ama mukellef isaretsizse
--  (ya da tersi) hicbir sey calismiyor, sebebi de iki ekrana bakmadan
--  anlasilmiyordu.
--
--  YENI DURUM: TEK KAYNAK - subenin (ya da kimligini kullandigi merkezin)
--  `efatura_mukellef` bayragi. Gercek hayatta da boyle: e-Arsiv ve e-Irsaliye
--  mukellefiyeti e-Fatura mukellefiyetinin uzantisidir, once o vardir.
--
--  `ebelge.aktif` ayari ONCE varsayilan subeye tasinir, sonra SILINIR.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_sube  integer := (select id from public.sube where varsayilan = 1 and aktif = 1
                         order by id limit 1);
    v_acik  boolean := coalesce((select deger from public.referans
                                  where anahtar = 'ebelge.aktif'), '0') = '1';
begin
    if v_sube is null then
        select min(id) into v_sube from public.sube;
    end if;
    if v_sube is null then
        raise notice '179: sube yok, goc atlandi.';
        return;
    end if;

    -- Ayar ACIKSA e-Fatura mukellefiyeti isaretlenir: eski kurulumda "e-Belge
    --   kullanimda" diyen firma yeni kuralda da kesmeye devam etsin.
    if v_acik then
        update public.sube set efatura_mukellef = 1
         where id = v_sube and efatura_mukellef <> 1;
        raise notice '179: ebelge.aktif aciti -> sube % e-Fatura mukellefi isaretlendi.', v_sube;
    else
        raise notice '179: ebelge.aktif kapali - mukellefiyet bayraklari oldugu gibi birakildi.';
    end if;
end $$;

delete from public.referans where anahtar = 'ebelge.aktif';

-- --------------------------------------------------------- ana salter -------
-- Tek soru, tek cevap: bu sube e-Belge kesiyor mu?
create or replace function public.fn_ebelge_acik(p_sube_id integer default null)
returns boolean language sql stable as $$
    select public.fn_ebelge_mukellef_mi(
             coalesce(p_sube_id, (select id from public.sube
                                   where varsayilan = 1 and aktif = 1 order by id limit 1)),
             1)
$$;

comment on function public.fn_ebelge_acik(integer) is
  'ANA SALTER: sube (ya da kimligini kullandigi merkez) e-Fatura mukellefi mi (179).';

-- Hazirlama artik ayara degil bu saltere bakar.
create or replace function public.fn_ebelge_hazirla(p_belge_id integer, p_kullanici integer)
returns table (e_belge_id bigint, belge_turu smallint, belge_no varchar, seri varchar, uyari text)
language plpgsql as $$
declare
    b            record;
    v_mukellef   boolean;
    v_tur        smallint;
    v_seri       varchar;
    v_no         varchar;
    v_durum      smallint;
    v_uyari      text := '';
    v_id         bigint;
begin
    select bl.*, t.efatura as taraf_efatura, t.vkno as taraf_vkno, t.unvan as taraf_ad
      into b
      from public.belge bl
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id;

    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    if coalesce(b.efatura_durum, 0) <> 0 then
        raise exception 'Bu belge için e-Belge zaten hazırlanmış (durum %).', b.efatura_durum;
    end if;
    if b.tur not in (15, 14) then
        raise exception 'e-Belge yalnızca satış faturası ve satış irsaliyesi için hazırlanır.';
    end if;

    -- ANA SALTER (179): e-Fatura mukellefiyeti. Ayri bir "e-Belge kullanimda"
    --   ayari YOK - ayni soruyu iki yerden sormak tutarsizlik uretiyordu.
    if not public.fn_ebelge_acik(b.sube_id) then
        raise exception 'Bu şube e-Fatura mükellefi değil; e-Belge kesilemez. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.';
    end if;
    if b.tur = 14 and not public.fn_ebelge_mukellef_mi(b.sube_id, 7) then
        raise exception 'Bu şube e-İrsaliye mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.';
    end if;

    -- DOGRULAMALAR - numara/seri TUKETILMEDEN.
    if coalesce(b.taraf_id, 0) = 0 then
        raise exception 'Belgede cari seçilmemiş.';
    end if;
    if coalesce(btrim(b.taraf_vkno), '') = '' then
        raise exception '% için vergi/kimlik numarası girilmemiş; e-Belge gönderilemez.', b.taraf_ad;
    end if;
    if not exists (select 1 from public.belge_satir s where s.belge_id = b.id) then
        raise exception 'Belgede kalem yok.';
    end if;
    if coalesce(b.genel_toplam, 0) <= 0 then
        raise exception 'Belge tutarı sıfır; e-Belge hazırlanamaz.';
    end if;
    if b.tur = 14
       and coalesce(btrim((select sv.arac_plaka from public.v_belge_sevkiyat sv
                            where sv.belge_id = b.id)), '') = ''
       and coalesce((select sv.tasiyici_id from public.v_belge_sevkiyat sv
                      where sv.belge_id = b.id), 0) = 0 then
        raise exception 'e-İrsaliyede taşıyıcı ya da araç plakası girilmeli (Taşıyıcı / Sevkiyat sekmesi).';
    end if;

    -- BELGE TURU: alici GIB mukellefi mi (cari kartindaki bayrak).
    v_mukellef := coalesce(b.taraf_efatura, 0) = 1;
    if b.tur = 14 then
        v_tur := 7; v_durum := 51;
    elsif coalesce(b.senaryo, 0) = 3 or v_mukellef then
        v_tur := 1; v_durum := 1;
        if coalesce(b.senaryo, 0) = 3 and not v_mukellef then
            v_uyari := 'İhracat faturası: alıcı GİB mükellefi değil, belge e-Fatura olarak hazırlandı.';
        end if;
    else
        v_tur := 2; v_durum := 11;
        v_uyari := 'Alıcı e-Fatura mükellefi değil; belge e-Arşiv olarak hazırlandı.';
    end if;

    if not public.fn_ebelge_mukellef_mi(b.sube_id, v_tur) then
        raise exception 'Bu şube % mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.',
              public.fn_ebelge_tur_adi(v_tur);
    end if;

    v_seri := public.fn_ebelge_seri_bul(v_tur, coalesce(b.senaryo, 0), p_kullanici);
    if coalesce(btrim(v_seri), '') = '' then
        raise exception 'Bu belge türü için seri tanımı yok. Firma Bilgileri › e-Belge › Seri Bilgileri''nden ekleyin.';
    end if;

    v_no := public.fn_ebelge_no_uret(v_seri, extract(year from b.belge_tarihi)::integer);

    insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, belge_no,
                                uuid, alici_alias, durum, ekleyen)
    values (b.id, b.taraf_id, v_tur, 1, v_no,
            gen_random_uuid()::text, '', 1, p_kullanici)
    returning id into v_id;

    update public.belge bl
       set efatura_durum = v_durum,
           efatura_sonuc = 0,
           belge_no = case when coalesce(btrim(bl.belge_no), '') in ('', '0')
                           then v_no else bl.belge_no end,
           degistiren = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where bl.id = b.id;

    return query select v_id, v_tur, v_no::varchar, v_seri::varchar, v_uyari;
end $$;

do $$
declare r record;
begin
    for r in select s.id, s.ad, public.fn_ebelge_acik(s.id) as acik,
                    s.efatura_mukellef, s.earsiv_mukellef, s.eirsaliye_mukellef
               from public.sube s order by s.id loop
        raise notice '179: sube % (%) e-Belge acik=% [eFatura=% eArsiv=% eIrsaliye=%]',
            r.id, r.ad, r.acik, r.efatura_mukellef, r.earsiv_mukellef, r.eirsaliye_mukellef;
    end loop;
    raise notice '179 tamam: ana salter = e-Fatura mukellefiyeti; ebelge.aktif ayari kaldirildi.';
end $$;
