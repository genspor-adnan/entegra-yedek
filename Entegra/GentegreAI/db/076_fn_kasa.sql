-- ============================================================================
--  Gentegre AI — Kasa islem MOTORU (F2)
--  076_fn_kasa.sql
--
--  Is kurallari SQL tarafinda tek yerde: bacak uretimi, dogrulama,
--  kesinlestirme, fisleme, iptal. C# yalnizca cagirir - kural kopyalamaz.
--
--  ANA KURAL (K5): durum=2 (gerceklesti) basligin bacaklari DENGELI olmak
--    zorunda (sum(yerel_borc) = sum(yerel_alacak)). Fis bu dengeyi aynen
--    kopyalar, boylece muhasebe fisi tanim geregi dengelidir.
--
--  ISARET (K4): muhasebe isareti. Hesap bacaginda borc = hesaba GIRIS.
--    Tahsilatta cari ALACAKLANIR, odemede BORCLANIR.
--
--  HATA KODU: is-kurali ihlalleri errcode 'GK422' ile atilir; API bunu
--    422 IS_KURALI yanitina cevirir (P0001 = beklenmeyen hata / 500).
-- ============================================================================
\set ON_ERROR_STOP on

-- Bacagin sablondaki ROLU fis eslemesinde gerekiyor (44 komisyon -> 770,
--   58 faiz -> 780). Sablonda vardi, bacakta yoktu.
alter table public.mali_hareket add column if not exists rol varchar(12) not null default '';
comment on column public.mali_hareket.rol is
  'Bacagin sablondaki rolu (ana/cari/masraf/karsi/kalem). Muhasebe eslestirmesinde tur+rol istisnasi icin kullanilir.';

-- ============================================================================
--  1) Cari alt hesabi (120.<taraf_id>) - yoksa acar
-- ============================================================================
create or replace function public.fn_hesap_plani_alt_ac(p_ust_id integer, p_taraf_id integer)
returns integer
language plpgsql
as $$
declare
    v_ust  record;
    v_kod  varchar(20);
    v_id   integer;
    v_ad   varchar(100);
begin
    if p_ust_id is null or p_taraf_id is null then return p_ust_id; end if;

    select id, kod, sinif, doviz_cinsi, seviye into v_ust
      from public.hesap_plani where id = p_ust_id;
    if not found then return p_ust_id; end if;

    v_kod := v_ust.kod || '.' || p_taraf_id::text;

    select id into v_id from public.hesap_plani where kod = v_kod;
    if v_id is not null then return v_id; end if;

    select left(coalesce(nullif(btrim(unvan), ''), 'CARI ' || p_taraf_id), 100)
      into v_ad from public.taraf where id = p_taraf_id;

    insert into public.hesap_plani (kod, ad, ust_id, seviye, sinif, doviz_cinsi, calisir_mi, cari_alt_hesap, durum)
    values (v_kod, coalesce(v_ad, 'CARI ' || p_taraf_id), v_ust.id,
            coalesce(v_ust.seviye, 1) + 1, v_ust.sinif, v_ust.doviz_cinsi, 1, 0, 1)
    on conflict (kod) do nothing
    returning id into v_id;

    if v_id is null then
        select id into v_id from public.hesap_plani where kod = v_kod;
    end if;

    -- ust hesap artik yaprak degil
    update public.hesap_plani set calisir_mi = 0 where id = v_ust.id and calisir_mi = 1;
    return coalesce(v_id, p_ust_id);
end $$;

-- ============================================================================
--  2) Bacak -> muhasebe hesabi cozumu
--     Sira: hesap karti > tur+rol istisnasi > kalem > cari > hesap_turu
-- ============================================================================
create or replace function public.fn_muh_hesap_coz(p_hareket_id integer)
returns integer
language plpgsql
as $$
declare
    h      record;
    t      record;
    v_id   integer;
    v_kod  varchar(25);
    v_yon  smallint;
    v_alt  smallint;
begin
    select m.id, m.tur, m.hesap_turu, m.hesap_id, m.taraf_id, m.masraf_id, m.hizmet_id,
           m.rol, m.doviz_cinsi, m.borc, m.alacak
      into h
      from public.mali_hareket m where m.id = p_hareket_id;
    if not found then
        raise exception 'Mali hareket bulunamadi: %', p_hareket_id using errcode = 'GK422';
    end if;

    -- (1) hesap kartinin kendi muhasebe hesabi
    if h.hesap_id is not null then
        select muh_hesap_id into v_id from public.hesap where id = h.hesap_id;
        if v_id is not null then return v_id; end if;
    end if;

    -- (2) tur + rol istisnasi (komisyon, faiz, kur farki)
    if coalesce(h.rol, '') <> '' then
        select e.hesap_plani_id into v_id
          from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'tur'
           and e.kasa_islem_tur = h.tur and e.rol = h.rol
         order by e.oncelik, e.id limit 1;
        if v_id is not null then return v_id; end if;
    end if;

    -- (3) kalem bacagi (masraf / hizmet)
    if h.masraf_id is not null then
        select m.muh_hesap_id, m.muh_kodu into v_id, v_kod
          from public.masraf m where m.id = h.masraf_id;
        if v_id is not null then return v_id; end if;
        if coalesce(btrim(v_kod), '') <> '' then
            select id into v_id from public.hesap_plani where kod = btrim(v_kod);
            if v_id is not null then return v_id; end if;
        end if;
        select e.hesap_plani_id into v_id from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'kalem_varsayilan' and e.rol = 'masraf'
         order by e.oncelik, e.id limit 1;
        if v_id is not null then return v_id; end if;
    end if;

    if h.hizmet_id is not null then
        select z.muh_hesap_id, z.muh_kodu into v_id, v_kod
          from public.hizmet z where z.id = h.hizmet_id;
        if v_id is not null then return v_id; end if;
        if coalesce(btrim(v_kod), '') <> '' then
            select id into v_id from public.hesap_plani where kod = btrim(v_kod);
            if v_id is not null then return v_id; end if;
        end if;
        select e.hesap_plani_id into v_id from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'kalem_varsayilan' and e.rol = 'hizmet'
         order by e.oncelik, e.id limit 1;
        if v_id is not null then return v_id; end if;
    end if;

    -- (4) cari bacagi
    if h.hesap_turu = 'C' and h.taraf_id is not null then
        select muh_hesap_id, musteri, tedarikci, personel into t
          from public.taraf where id = h.taraf_id;
        if t.muh_hesap_id is not null then return t.muh_hesap_id; end if;

        v_yon := case when coalesce(t.personel, 0) = 1                                then 3
                      when coalesce(t.tedarikci, 0) = 1 and coalesce(t.musteri, 0) = 0 then 2
                      else 1 end;

        select e.hesap_plani_id into v_id from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'cari' and e.yon = v_yon
         order by e.oncelik, e.id limit 1;

        if v_id is not null then
            select cari_alt_hesap into v_alt from public.hesap_plani where id = v_id;
            if coalesce(v_alt, 0) = 1 then
                v_id := public.fn_hesap_plani_alt_ac(v_id, h.taraf_id);
            end if;
            return v_id;
        end if;
    end if;

    -- (5) hesap turu varsayilani
    select e.hesap_plani_id into v_id from public.muhasebe_eslestirme e
     where e.aktif = 1 and e.kural_turu = 'hesap_turu'
       and e.hesap_turu = h.hesap_turu
       and (e.doviz_mi = 0 or (e.doviz_mi = 1 and h.doviz_cinsi <> 'TL'))
     order by e.doviz_mi desc, e.oncelik, e.id limit 1;
    if v_id is not null then return v_id; end if;

    raise exception 'Muhasebe eşlemesi bulunamadı (bacak %, hesap türü "%", rol "%"). Hesap planı eşleştirmesini tanımlayın.',
          p_hareket_id, h.hesap_turu, coalesce(h.rol, '') using errcode = 'GK422';
end $$;

-- ============================================================================
--  3) Sablondan bacak uretimi
--     Istemci bacak gondermediginde calisir. Sablon = kasa_islem_turu.sablon
--     [{rol, yon:'B'|'A', tutar:'@tutar'|'@masraf_tutar'|'@karsi_tutar'}]
-- ============================================================================
create or replace function public.fn_kasa_islem_bacak_uret(p_id integer)
returns integer
language plpgsql
as $$
declare
    ki        record;
    tr        record;
    s         jsonb;
    v_rol     text;
    v_yon     text;
    v_tutar   numeric(19,4);
    v_yerel   numeric(19,4);
    v_sira    smallint := 0;
    v_sayi    integer  := 0;
    v_hid     integer;
    v_htur    varchar(1);
    v_tid     integer;
    v_mid     integer;
    v_zid     integer;
    v_doviz   varchar(6);
    v_kur     numeric(19,6);
begin
    select * into ki from public.kasa_islem where id = p_id;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum >= 2 then
        raise exception 'Gerçekleşmiş işlemin bacakları yeniden üretilemez (işlem %).', p_id using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;

    delete from public.mali_hareket where kasa_islem_id = p_id;

    for s in select jsonb_array_elements(tr.sablon) loop
        v_rol := s ->> 'rol';
        v_yon := coalesce(s ->> 'yon', 'B');

        v_tutar := case coalesce(s ->> 'tutar', '@tutar')
                       when '@tutar'        then ki.tutar
                       when '@masraf_tutar' then ki.masraf_tutar
                       when '@karsi_tutar'  then ki.karsi_tutar
                       else 0 end;
        if coalesce(v_tutar, 0) = 0 then continue; end if;   -- masraf yoksa o bacak yok

        v_hid := null; v_htur := '-'; v_tid := null; v_mid := null; v_zid := null;
        v_doviz := ki.doviz_cinsi; v_kur := ki.doviz_kuru;

        if v_rol = 'ana' then
            v_hid := ki.hesap_id;
        elsif v_rol = 'karsi' then
            v_hid := ki.karsi_hesap_id;
            if coalesce(s ->> 'tutar', '') = '@karsi_tutar' then
                v_doviz := nullif(ki.karsi_doviz_cinsi, '');
                v_kur   := nullif(ki.karsi_kur, 0);
            end if;
        elsif v_rol = 'cari' then
            v_htur := 'C';
            v_tid  := ki.taraf_id;
        elsif v_rol = 'karsi_cari' then
            v_htur := 'C';
            v_tid  := ki.karsi_taraf_id;
        elsif v_rol in ('masraf', 'kalem') then
            v_htur := 'M';
            v_mid  := ki.masraf_id;
            v_zid  := ki.hizmet_id;
        end if;

        if v_hid is not null then
            select h.tur, h.doviz_cinsi into v_htur, v_doviz from public.hesap h where h.id = v_hid;
            if v_doviz = ki.doviz_cinsi then v_kur := ki.doviz_kuru; end if;
        end if;

        v_doviz := coalesce(nullif(v_doviz, ''), 'TL');
        v_kur   := case when v_doviz = 'TL' then 1 else coalesce(nullif(v_kur, 0), ki.doviz_kuru, 1) end;
        v_yerel := round(v_tutar * v_kur, 2);
        v_sira  := v_sira + 1;

        insert into public.mali_hareket
            (kasa_islem_id, sira, rol, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no,
             islem_tarihi, plan_tarihi,
             borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
             durum, masraf_id, hizmet_id, proje_id, merkez_id, cek_senet_id,
             ekstrede_kullan, aciklama, sube_id, giris_kaynak, ekleyen)
        values (p_id, v_sira, coalesce(v_rol, ''), ki.tur, coalesce(v_htur, '-'), v_hid, v_tid,
                ki.belge_id, '', ki.islem_tarihi::timestamp, ki.plan_tarihi,
                case when v_yon = 'B' then v_tutar else 0 end,
                case when v_yon = 'A' then v_tutar else 0 end,
                case when v_yon = 'B' then v_yerel else 0 end,
                case when v_yon = 'A' then v_yerel else 0 end,
                v_doviz, v_kur,
                ki.durum, v_mid, v_zid, ki.proje_id, ki.merkez_id, ki.cek_senet_id,
                coalesce(tr.bakiye_dahil, 1), left(ki.aciklama, 100), ki.sube_id,
                coalesce(ki.giris_kaynak, 1), ki.ekleyen);

        v_sayi := v_sayi + 1;
    end loop;

    if v_sayi = 0 then
        raise exception 'İşlem türü "%" için bacak üretilemedi (şablon boş veya tutarlar sıfır).',
              tr.ad using errcode = 'GK422';
    end if;
    return v_sayi;
end $$;

-- ============================================================================
--  4) Dogrulama (K5 dahil)
-- ============================================================================
create or replace function public.fn_kasa_islem_dogrula(p_id integer)
returns void
language plpgsql
as $$
declare
    ki        record;
    tr        record;
    b         record;
    v_sayi    integer;
    v_borc    numeric(19,4);
    v_alacak  numeric(19,4);
    v_cari    integer;
begin
    select * into ki from public.kasa_islem where id = p_id;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;
    if coalesce(tr.aktif, 0) <> 1 then
        raise exception 'İşlem türü pasif: %', tr.ad using errcode = 'GK422';
    end if;

    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);

    if ki.proje_id is not null
       and not exists (select 1 from public.proje where id = ki.proje_id and durum = 1) then
        raise exception 'Proje kapalı veya iptal - işlem bu projeye bağlanamaz.' using errcode = 'GK422';
    end if;

    select count(*), coalesce(sum(yerel_borc), 0), coalesce(sum(yerel_alacak), 0)
      into v_sayi, v_borc, v_alacak
      from public.mali_hareket where kasa_islem_id = p_id;

    if v_sayi < 2 then
        raise exception 'İşlemde en az iki bacak olmalı (bulunan: %).', v_sayi using errcode = 'GK422';
    end if;

    for b in select * from public.mali_hareket where kasa_islem_id = p_id order by sira loop
        if b.borc = 0 and b.alacak = 0 then
            raise exception 'Bacak %: tutar sıfır olamaz.', b.sira using errcode = 'GK422';
        end if;
        if b.borc <> 0 and b.alacak <> 0 then
            raise exception 'Bacak %: borç ve alacak aynı anda dolu olamaz.', b.sira using errcode = 'GK422';
        end if;
        if b.hesap_id is not null then
            if not exists (select 1 from public.hesap where id = b.hesap_id and durum = 1) then
                raise exception 'Bacak %: hesap pasif.', b.sira using errcode = 'GK422';
            end if;
            if not exists (select 1 from public.hesap
                            where id = b.hesap_id and doviz_cinsi = b.doviz_cinsi) then
                raise exception 'Bacak %: hesabın para birimi bacağın para biriminden (%) farklı.',
                      b.sira, b.doviz_cinsi using errcode = 'GK422';
            end if;
        end if;
        if b.doviz_cinsi = 'TL' and b.doviz_kuru <> 1 then
            raise exception 'Bacak %: TL bacağında kur 1 olmalı.', b.sira using errcode = 'GK422';
        end if;
    end loop;

    select count(*) into v_cari from public.mali_hareket
     where kasa_islem_id = p_id and hesap_turu = 'C' and taraf_id is not null;

    if tr.cari_zorunlu = 1 and v_cari = 0 then
        raise exception 'Bu işlem türü için cari seçilmesi zorunlu.' using errcode = 'GK422';
    end if;
    if tr.cari_zorunlu = -1 and v_cari > 0 then
        raise exception 'Bu işlem türünde cari kullanılamaz.' using errcode = 'GK422';
    end if;

    if round(v_borc, 2) <> round(v_alacak, 2) then
        raise exception 'İşlem dengesiz: borç % / alacak % (fark %).',
              round(v_borc, 2), round(v_alacak, 2), round(v_borc - v_alacak, 2)
              using errcode = 'GK422';
    end if;
end $$;

-- ============================================================================
--  5) Fisleme (idempotent)
-- ============================================================================
create or replace function public.fn_kasa_islem_fisle(p_id integer, p_kullanici integer default 0)
returns integer
language plpgsql
as $$
declare
    ki       record;
    tr       record;
    b        record;
    v_fis    integer;
    v_donem  integer;
    v_sira   smallint := 0;
    v_borc   numeric(19,4) := 0;
    v_alacak numeric(19,4) := 0;
    v_hp     integer;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum <> 2 then
        raise exception 'Yalnız gerçekleşmiş işlem fişlenebilir (durum %).', ki.durum using errcode = 'GK422';
    end if;

    -- idempotency: zaten kayitli fis varsa aynisini don
    if ki.muhasebe_fis_id is not null
       and exists (select 1 from public.muhasebe_fis where id = ki.muhasebe_fis_id and durum = 1) then
        return ki.muhasebe_fis_id;
    end if;
    select id into v_fis from public.muhasebe_fis
     where kaynak_tur = 1 and kaynak_id = p_id and durum = 1;
    if v_fis is not null then
        update public.kasa_islem set muhasebe_fis_id = v_fis where id = p_id;
        return v_fis;
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;
    if coalesce(tr.fis_mi, 0) <> 1 then return null; end if;

    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);
    select id into v_donem from public.muhasebe_donem
     where yil = extract(year from ki.islem_tarihi)::smallint
       and ay  = extract(month from ki.islem_tarihi)::smallint;

    insert into public.muhasebe_fis
        (fis_no, fis_tarihi, tur, durum, kaynak_tur, kaynak_id, donem_id,
         aciklama, sube_id, ekleyen)
    values ('', ki.islem_tarihi, coalesce(tr.fis_turu, 1), 1, 1, p_id, v_donem,
            left(coalesce(nullif(ki.aciklama, ''), tr.ad) ||
                 case when ki.taraf_unvan <> '' then ' - ' || ki.taraf_unvan else '' end, 200),
            ki.sube_id, p_kullanici)
    returning id into v_fis;

    for b in select * from public.mali_hareket where kasa_islem_id = p_id order by sira loop
        v_hp   := public.fn_muh_hesap_coz(b.id);
        v_sira := v_sira + 1;

        insert into public.muhasebe_fis_satir
            (fis_id, sira, hesap_plani_id, borc, alacak,
             doviz_cinsi, doviz_borc, doviz_alacak, doviz_kuru,
             taraf_id, proje_id, merkez_id, masraf_id, hizmet_id, mali_hareket_id, aciklama)
        values (v_fis, v_sira, v_hp, b.yerel_borc, b.yerel_alacak,
                b.doviz_cinsi,
                case when b.doviz_cinsi = 'TL' then 0 else b.borc end,
                case when b.doviz_cinsi = 'TL' then 0 else b.alacak end,
                b.doviz_kuru,
                b.taraf_id, b.proje_id, b.merkez_id, b.masraf_id, b.hizmet_id, b.id,
                left(coalesce(nullif(b.aciklama, ''), tr.ad), 200));

        v_borc   := v_borc + b.yerel_borc;
        v_alacak := v_alacak + b.yerel_alacak;
    end loop;

    if round(v_borc, 2) <> round(v_alacak, 2) then
        raise exception 'Fiş dengesiz: borç % / alacak %.', v_borc, v_alacak using errcode = 'GK422';
    end if;

    update public.muhasebe_fis
       set toplam_borc = v_borc, toplam_alacak = v_alacak,
           fis_no = public.fn_muhasebe_fis_no_uret(extract(year from ki.islem_tarihi)::integer)
     where id = v_fis;

    update public.kasa_islem set muhasebe_fis_id = v_fis where id = p_id;
    return v_fis;
end $$;

-- ============================================================================
--  6) Kesinlestirme — numara EN SON
-- ============================================================================
create or replace function public.fn_kasa_islem_kesinlestir(p_id integer, p_kullanici integer default 0)
returns integer
language plpgsql
as $$
declare
    ki      record;
    tr      record;
    v_sayi  integer;
    v_fis   integer;
    v_no    text;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum = 2 then
        raise exception 'İşlem zaten gerçekleşmiş (makbuz %).',
              coalesce(nullif(ki.islem_no, ''), p_id::text) using errcode = 'GK422';
    end if;
    if ki.durum = 3 then
        raise exception 'İptal edilmiş işlem kesinleştirilemez.' using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;

    select count(*) into v_sayi from public.mali_hareket where kasa_islem_id = p_id;
    if v_sayi = 0 then
        perform public.fn_kasa_islem_bacak_uret(p_id);
    end if;

    update public.kasa_islem
       set durum = 2, degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_id;
    update public.mali_hareket set durum = 2 where kasa_islem_id = p_id;

    perform public.fn_kasa_islem_dogrula(p_id);

    -- plan bagi: kismi gerceklesme plandan dusulur (K10)
    if ki.plan_islem_id is not null then
        update public.kasa_islem p
           set gerceklesen_tutar = p.gerceklesen_tutar + ki.tutar,
               durum = case when p.gerceklesen_tutar + ki.tutar >= p.tutar then 4 else p.durum end
         where p.id = ki.plan_islem_id;
    end if;

    if coalesce(tr.fis_mi, 0) = 1
       and coalesce((select deger from public.referans where anahtar = 'muhasebe.otomatik_fis'), '1') <> '0' then
        v_fis := public.fn_kasa_islem_fisle(p_id, p_kullanici);
    end if;

    -- numara EN SON: onceki adimlarin herhangi biri patlarsa numara harcanmaz
    if coalesce(nullif(ki.islem_no, ''), '') = '' then
        v_no := public.fn_kasa_islem_no_uret(ki.tur, ki.sube_id,
                                             extract(year from ki.islem_tarihi)::integer);
        update public.kasa_islem set islem_no = v_no,
               makbuz_no = case when makbuz_no = '' then v_no else makbuz_no end
         where id = p_id;
    end if;

    return p_id;
end $$;

-- ============================================================================
--  7) Iptal — ters baslik + ters fis (silme YOK)
-- ============================================================================
create or replace function public.fn_kasa_islem_iptal(p_id integer, p_kullanici integer default 0,
                                                      p_tarih date default null, p_sebep text default '')
returns integer
language plpgsql
as $$
declare
    ki       record;
    v_yeni   integer;
    v_tarih  date;
    v_fis    integer;
    v_tfis   integer;
    v_borc   numeric(19,4);
    v_alacak numeric(19,4);
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum = 3 then
        raise exception 'İşlem zaten iptal edilmiş.' using errcode = 'GK422';
    end if;
    if ki.durum <> 2 then
        raise exception 'Yalnız gerçekleşmiş işlem iptal edilir; taslak/plan silinir.' using errcode = 'GK422';
    end if;

    v_tarih := coalesce(p_tarih, ki.islem_tarihi);
    perform public.fn_muhasebe_donem_kontrol(v_tarih);

    -- ters baslik
    insert into public.kasa_islem
        (tur, islem_no, makbuz_no, islem_tarihi, durum, taraf_id, karsi_taraf_id, taraf_unvan,
         hesap_id, karsi_hesap_id, doviz_cinsi, tutar, doviz_kuru, yerel_tutar,
         karsi_doviz_cinsi, karsi_tutar, karsi_kur, masraf_tutar, masraf_id, hizmet_id,
         proje_id, merkez_id, cek_senet_id, kredi_taksit_id, kupon_turu_id, belge_id,
         iptal_islem_id, kaynak_tur, kaynak_id, aciklama, sube_id, giris_kaynak, ekleyen)
    values (ki.tur, '', '', v_tarih, 2, ki.taraf_id, ki.karsi_taraf_id, ki.taraf_unvan,
            ki.hesap_id, ki.karsi_hesap_id, ki.doviz_cinsi, ki.tutar, ki.doviz_kuru, ki.yerel_tutar,
            ki.karsi_doviz_cinsi, ki.karsi_tutar, ki.karsi_kur, ki.masraf_tutar, ki.masraf_id, ki.hizmet_id,
            ki.proje_id, ki.merkez_id, ki.cek_senet_id, ki.kredi_taksit_id, ki.kupon_turu_id, ki.belge_id,
            p_id, 6 /* iptal kaynagi */, p_id,
            left('İPTAL: ' || coalesce(nullif(p_sebep, ''), ki.aciklama), 200),
            ki.sube_id, ki.giris_kaynak, p_kullanici)
    returning id into v_yeni;

    -- ters bacaklar (B/A yer degistirir)
    insert into public.mali_hareket
        (kasa_islem_id, sira, rol, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no,
         islem_tarihi, borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
         durum, masraf_id, hizmet_id, proje_id, merkez_id, cek_senet_id,
         ekstrede_kullan, aciklama, sube_id, giris_kaynak, ekleyen)
    select v_yeni, m.sira, m.rol, m.tur, m.hesap_turu, m.hesap_id, m.taraf_id, m.belge_id, m.belge_no,
           v_tarih::timestamp, m.alacak, m.borc, m.yerel_alacak, m.yerel_borc, m.doviz_cinsi, m.doviz_kuru,
           2, m.masraf_id, m.hizmet_id, m.proje_id, m.merkez_id, m.cek_senet_id,
           m.ekstrede_kullan, left('İPTAL: ' || m.aciklama, 100), m.sube_id, m.giris_kaynak, p_kullanici
      from public.mali_hareket m where m.kasa_islem_id = p_id order by m.sira;

    -- ters fis (orijinalin aynadaki hali)
    v_fis := ki.muhasebe_fis_id;
    if v_fis is not null and exists (select 1 from public.muhasebe_fis where id = v_fis and durum = 1) then
        insert into public.muhasebe_fis
            (fis_no, fis_tarihi, tur, durum, kaynak_tur, kaynak_id, ters_fis_id, donem_id,
             aciklama, sube_id, ekleyen)
        select '', v_tarih, f.tur, 3, 1, v_yeni, f.id, f.donem_id,
               left('İPTAL: ' || f.aciklama, 200), f.sube_id, p_kullanici
          from public.muhasebe_fis f where f.id = v_fis
        returning id into v_tfis;

        insert into public.muhasebe_fis_satir
            (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi, doviz_borc, doviz_alacak,
             doviz_kuru, taraf_id, proje_id, merkez_id, masraf_id, hizmet_id, aciklama)
        select v_tfis, s.sira, s.hesap_plani_id, s.alacak, s.borc, s.doviz_cinsi,
               s.doviz_alacak, s.doviz_borc, s.doviz_kuru, s.taraf_id, s.proje_id, s.merkez_id,
               s.masraf_id, s.hizmet_id, left('İPTAL: ' || s.aciklama, 200)
          from public.muhasebe_fis_satir s where s.fis_id = v_fis order by s.sira;

        select coalesce(sum(borc), 0), coalesce(sum(alacak), 0) into v_borc, v_alacak
          from public.muhasebe_fis_satir where fis_id = v_tfis;

        update public.muhasebe_fis
           set toplam_borc = v_borc, toplam_alacak = v_alacak,
               fis_no = public.fn_muhasebe_fis_no_uret(extract(year from v_tarih)::integer)
         where id = v_tfis;

        update public.muhasebe_fis set durum = 2, ters_fis_id = v_tfis where id = v_fis;
        update public.kasa_islem set muhasebe_fis_id = v_tfis where id = v_yeni;
    end if;

    -- plan bagini geri al
    if ki.plan_islem_id is not null then
        update public.kasa_islem p
           set gerceklesen_tutar = greatest(p.gerceklesen_tutar - ki.tutar, 0),
               durum = case when p.durum = 4 then 1 else p.durum end
         where p.id = ki.plan_islem_id;
    end if;

    update public.kasa_islem
       set durum = 3, iptal_islem_id = v_yeni,
           degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_id;
    update public.mali_hareket set durum = 3 where kasa_islem_id = p_id;

    -- ters basligin numarasi EN SON
    update public.kasa_islem
       set islem_no = public.fn_kasa_islem_no_uret(ki.tur, ki.sube_id, extract(year from v_tarih)::integer)
     where id = v_yeni;

    return v_yeni;
end $$;

-- ============================================================================
--  8) Silme korumasi — gerceklesmis/fislenmis islem silinmez
-- ============================================================================
create or replace function public.fn_kasa_islem_silme_koruma()
returns trigger
language plpgsql
as $$
begin
    if old.durum >= 2 then
        raise exception 'Gerçekleşmiş işlem silinemez - İptal kullanın (işlem %, durum %).',
              old.id, old.durum using errcode = 'GK422';
    end if;
    if old.muhasebe_fis_id is not null then
        raise exception 'Muhasebe fişi olan işlem silinemez (işlem %).', old.id using errcode = 'GK422';
    end if;
    return old;
end $$;

drop trigger if exists trg_kasa_islem_silme_koruma on public.kasa_islem;
create trigger trg_kasa_islem_silme_koruma before delete on public.kasa_islem
    for each row execute function public.fn_kasa_islem_silme_koruma();

-- ============================================================================
--  9) Turkce adlar (073/074 seed'leri ASCII yazilmisti; ekranda gorunuyor)
-- ============================================================================
update public.kasa_islem_turu set ad = v.ad from (values
    (2,  'Devir'),                       (21, 'Nakit Tahsilat'),
    (22, 'Banka Tahsilat (Havale/EFT)'), (23, 'Çek ile Tahsilat'),
    (24, 'Senet ile Tahsilat'),          (25, 'Kredi Kartı / POS Tahsilat'),
    (26, 'Kupon ile Tahsilat'),          (31, 'Nakit Ödeme'),
    (32, 'Banka Ödeme (Havale/EFT)'),    (33, 'Çek ile Ödeme'),
    (34, 'Senet ile Ödeme'),             (35, 'Kredi Kartıyla Ödeme'),
    (36, 'Kupon ile Ödeme'),             (40, 'Kasadan Kasaya Virman'),
    (41, 'Kasadan Bankaya'),             (42, 'Bankadan Kasaya'),
    (43, 'Bankadan Bankaya'),            (44, 'POS''tan Bankaya Aktarım'),
    (45, 'Kasada Döviz Alış'),           (46, 'Kasada Döviz Satış'),
    (47, 'Bankada Döviz Alış'),          (48, 'Bankada Döviz Satış'),
    (49, 'Cari Virman'),                 (50, 'Çapraz Kur (Arbitraj)'),
    (51, 'Alınan Çek Tahsil'),           (52, 'Çek Ciro'),
    (53, 'Senet Tahsil'),                (54, 'Çek/Senet Bozdurma'),
    (55, 'Verilen Çek/Senet Ödendi'),    (56, 'Karşılıksız / İade'),
    (57, 'Kredi Kartı Ekstre Ödemesi'),  (58, 'Kredi Taksit Ödemesi'),
    (59, 'Kredi Kullanımı'),             (61, 'Tahsilat Planı'),
    (63, 'Avans Planı'),                 (71, 'Ödeme Planı'),
    (87, 'Kredi Kartı Ödeme İadesi'),    (88, 'Kur Farkı Geliri'),
    (98, 'Kur Farkı Gideri'),            (1,  'Açılış Fişi')
) as v(kod, ad) where kasa_islem_turu.kod = v.kod and kasa_islem_turu.ad <> v.ad;

update public.hesap_plani set ad = v.ad from (values
    ('100','KASA'),                        ('101','ALINAN ÇEKLER'),
    ('102','BANKALAR'),                    ('103','VERİLEN ÇEKLER VE ÖDEME EMİRLERİ (-)'),
    ('108','DİĞER HAZIR DEĞERLER'),        ('108.01','POS Hesapları'),
    ('108.02','Kupon Hesapları'),          ('120','ALICILAR'),
    ('121','ALACAK SENETLERİ'),            ('126','VERİLEN DEPOZİTO VE TEMİNATLAR'),
    ('131','ORTAKLARDAN ALACAKLAR'),       ('135','PERSONELDEN ALACAKLAR'),
    ('150','İLK MADDE VE MALZEME'),        ('153','TİCARİ MALLAR'),
    ('159','VERİLEN SİPARİŞ AVANSLARI'),   ('191','İNDİRİLECEK KDV'),
    ('195','İŞ AVANSLARI'),                ('196','PERSONEL AVANSLARI'),
    ('300','BANKA KREDİLERİ'),             ('303','UZUN VADELİ KREDİLERİN ANAPARA TAKSİTLERİ'),
    ('309','DİĞER MALİ BORÇLAR'),          ('320','SATICILAR'),
    ('321','BORÇ SENETLERİ'),              ('335','PERSONELE BORÇLAR'),
    ('340','ALINAN SİPARİŞ AVANSLARI'),    ('360','ÖDENECEK VERGİ VE FONLAR'),
    ('391','HESAPLANAN KDV'),              ('500','SERMAYE'),
    ('580','GEÇMİŞ YILLAR ZARARLARI (-)'), ('600','YURTİÇİ SATIŞLAR'),
    ('602','DİĞER GELİRLER'),              ('642','FAİZ GELİRLERİ'),
    ('646','KAMBİYO KÂRLARI'),             ('649','DİĞER OLAĞAN GELİR VE KÂRLAR'),
    ('656','KAMBİYO ZARARLARI'),           ('660','KISA VADELİ BORÇLANMA GİDERLERİ'),
    ('740','HİZMET ÜRETİM MALİYETİ'),      ('770','GENEL YÖNETİM GİDERLERİ'),
    ('780','FİNANSMAN GİDERLERİ')
) as v(kod, ad) where hesap_plani.kod = v.kod and hesap_plani.ad <> v.ad;

do $$
declare v_fn integer;
begin
    select count(*) into v_fn from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in
       ('fn_hesap_plani_alt_ac','fn_muh_hesap_coz','fn_kasa_islem_bacak_uret',
        'fn_kasa_islem_dogrula','fn_kasa_islem_fisle','fn_kasa_islem_kesinlestir',
        'fn_kasa_islem_iptal','fn_kasa_islem_silme_koruma');
    raise notice '076 tamam: % motor fonksiyonu kurulu', v_fn;
end $$;
