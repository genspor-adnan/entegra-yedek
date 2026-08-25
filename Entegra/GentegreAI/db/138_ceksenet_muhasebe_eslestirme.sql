-- ============================================================================
--  Gentegre AI — CEK/SENET BACAGININ MUHASEBE HESABI
--  138_ceksenet_muhasebe_eslestirme.sql
--
--  Cek/senet ile tahsilat-odeme (23/24/33/34) bacagi PORTFOY sanal hesabina
--  yazilir: `hesap_turu = 'E'`, `hesap_id` yok, kiymetin kendisi `cek_senet_id`
--  ile tasinir. Eslestirme kurallari (kural_turu = 'cek_senet') 074 seed'inde
--  vardi - ALINAN CEK 101, VERILEN CEK 103, ALACAK SENEDI 121, BORC SENEDI 321 -
--  ama `fn_muh_hesap_coz` bu kurallari HIC SORGULAMIYORDU. Sonuc: cek ile
--  tahsilat kesinlestirilemiyordu:
--
--      Muhasebe eşlemesi bulunamadı (bacak N, hesap türü "E", rol "ceksenet").
--
--  Cozucuye cek/senet dali eklenir: bacaktaki kiymetten TUR (1 cek / 2 senet)
--  ve YON (1 alinan / 2 verilen) okunur, kural o ikisiyle bulunur. Dal, hesap
--  kartinin kendi hesabindan (1) sonra, rol istisnalarindan (2) once gelir -
--  kiymetin cinsi rolden daha belirleyicidir.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_muh_hesap_coz(p_hareket_id integer)
returns integer
language plpgsql
as $function$
declare
    h      record;
    t      record;
    c      record;
    v_id   integer;
    v_kod  varchar(25);
    v_yon  smallint;
    v_alt  smallint;
begin
    select m.id, m.tur, m.hesap_turu, m.hesap_id, m.taraf_id, m.masraf_id, m.hizmet_id,
           m.rol, m.doviz_cinsi, m.borc, m.alacak, m.cek_senet_id
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

    -- (1b) CEK/SENET PORTFOYU (138): kiymetin cinsi ve yonu hesabi belirler.
    --      Alinan cek 101, verilen cek 103, alacak senedi 121, borc senedi 321.
    if h.hesap_turu = 'E' and h.cek_senet_id is not null then
        select cs.tur, cs.yon into c from public.cek_senet cs where cs.id = h.cek_senet_id;
        if found then
            select e.hesap_plani_id into v_id
              from public.muhasebe_eslestirme e
             where e.aktif = 1 and e.kural_turu = 'cek_senet'
               and e.hesap_turu = 'E'
               and e.yon = c.yon
               and e.rol = case when c.tur = 2 then 'senet' else 'cek' end
             order by e.oncelik, e.id limit 1;
            if v_id is not null then return v_id; end if;
        end if;
    end if;

    if coalesce(h.rol, '') <> '' then
        -- (2a) tur + rol istisnasi (komisyon, faiz)
        select e.hesap_plani_id into v_id
          from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'tur'
           and e.kasa_islem_tur = h.tur and e.rol = h.rol
         order by e.oncelik, e.id limit 1;
        if v_id is not null then return v_id; end if;

        -- (2b) tur BAGIMSIZ rol kurali (kambiyo kar/zarar)
        select e.hesap_plani_id into v_id
          from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'rol' and e.rol = h.rol
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

        select e.hesap_plani_id into v_id
          from public.muhasebe_eslestirme e
         where e.aktif = 1 and e.kural_turu = 'cari' and e.yon = v_yon
         order by e.oncelik, e.id limit 1;

        if v_id is not null then
            -- Cari ALT HESABI (120.<taraf>) acik ise oraya yazilir.
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
end;
$function$;

comment on function public.fn_muh_hesap_coz(integer) is
  'Bacagin hesap plani karsiligi. 138: cek/senet portfoy bacagi (hesap_turu E) kiymetin tur/yonune gore cozulur.';

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.muhasebe_eslestirme
     where kural_turu = 'cek_senet' and aktif = 1;
    raise notice '138 tamam: cozucude cek/senet dali var, % aktif kural', v_adet;
end $$;
