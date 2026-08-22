-- ============================================================================
--  Gentegre AI — Kasa motoru F3: virman / doviz donusumu / plan
--  085_fn_kasa_f3.sql
--
--  Uc eksik parca:
--   1) PLAN muafiyeti — plan satiri TEK bacaktir (karsi tarafi henuz yok),
--      "en az iki bacak" ve denge kurali plana uygulanamaz. 076'daki dogrulama
--      plani da denetleseydi hicbir plan kaydedilemezdi.
--   2) KAMBIYO / KURUS FARKI bacagi — doviz alis-satisinda verilen TL ile alinan
--      dovizin yerel karsiligi kuru kurusuna tutmaz; fark 646 (kar) / 656 (zarar)
--      bacagi olarak YAZILIR, yoksa islem "dengesiz" diye reddedilirdi.
--   3) fn_plan_gerceklestir — plan IN-PLACE degismez (K10): gerceklesme YENI bir
--      baslik acar, plandan yalniz gerceklesen_tutar birikir. Legacy'de plan satiri
--      UPDATE ile gercege donusuyordu ve plan izi kayboluyordu.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- ayar ----
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('kasa.kurus_farki_siniri', '0.05', 'sayi', 'firma',
        'Doviz DISI islemlerde otomatik denge bacagi acilabilecek en buyuk fark (TL).')
on conflict (anahtar) do nothing;

-- --------------------------------------------- kambiyo eslestirmeleri ----
-- Rol bazli kural (tur bagimsiz): hangi kasa islemi olursa olsun kambiyo
--   bacagi ayni hesaba gider.
-- rol varchar(12) 'kambiyo_zarar'i (13) almiyordu; bacaktaki rol kolonu da ayni
--   degeri tasiyor - ikisi de 20'ye cikarildi.
alter table public.muhasebe_eslestirme alter column rol type varchar(20);
alter table public.mali_hareket        alter column rol type varchar(20);
insert into public.muhasebe_eslestirme (kural_turu, rol, hesap_plani_id, oncelik, aktif)
select 'rol', v.rol, hp.id, 40, 1
  from (values ('kambiyo_kar', '646'), ('kambiyo_zarar', '656')) as v(rol, kod)
  join public.hesap_plani hp on hp.kod = v.kod
 where not exists (select 1 from public.muhasebe_eslestirme e
                    where e.kural_turu = 'rol' and e.rol = v.rol);

-- ============================================================================
--  1) Bacak uretimi — kambiyo/kurus farki bacagi eklendi
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
    v_fark    numeric(19,4);
    v_sinir   numeric(19,4);
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
                0, v_mid, v_zid, ki.proje_id, ki.merkez_id, ki.cek_senet_id,
                coalesce(tr.bakiye_dahil, 1), left(ki.aciklama, 100), ki.sube_id,
                coalesce(ki.giris_kaynak, 1), ki.ekleyen);

        v_sayi := v_sayi + 1;
    end loop;

    if v_sayi = 0 then
        raise exception 'İşlem türü "%" için bacak üretilemedi (şablon boş veya tutarlar sıfır).',
              tr.ad using errcode = 'GK422';
    end if;

    -- --------------------------------------------- kambiyo / kurus farki ----
    -- Iki bacagin yerel karsiligi tutmuyorsa aradaki fark KAYIP DEGIL, kambiyo
    --   kar/zarar veya kurus yuvarlamasidir; muhasebede 646/656'ya yazilir.
    --
    -- DOVIZ donusumunde (grup='doviz') fark ne olursa olsun yazilir - efektif kur
    --   ile TCMB kuru arasindaki fark tam olarak budur ve tutari kucuk olmak
    --   zorunda degildir. Diger turlerde yalniz KURUS toleransi kadar otomatik
    --   bacak acilir; buyuk fark kullanici hatasidir, dogrulama reddetsin.
    if coalesce(tr.plan_mi, 0) = 0 then
        select coalesce(sum(yerel_borc), 0) - coalesce(sum(yerel_alacak), 0)
          into v_fark from public.mali_hareket where kasa_islem_id = p_id;

        if round(v_fark, 2) <> 0 then
            v_sinir := coalesce((select deger::numeric from public.referans
                                  where anahtar = 'kasa.kurus_farki_siniri'), 0.05);

            if tr.grup = 'doviz' or abs(v_fark) <= v_sinir then
                v_sira := v_sira + 1;
                insert into public.mali_hareket
                    (kasa_islem_id, sira, rol, tur, hesap_turu, islem_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
                     durum, proje_id, merkez_id, ekstrede_kullan, aciklama,
                     sube_id, giris_kaynak, ekleyen)
                values (p_id, v_sira,
                        case when v_fark > 0 then 'kambiyo_kar' else 'kambiyo_zarar' end,
                        ki.tur, 'M', ki.islem_tarihi::timestamp,
                        case when v_fark < 0 then abs(v_fark) else 0 end,
                        case when v_fark > 0 then abs(v_fark) else 0 end,
                        case when v_fark < 0 then abs(v_fark) else 0 end,
                        case when v_fark > 0 then abs(v_fark) else 0 end,
                        'TL', 1, 0, ki.proje_id, ki.merkez_id, 1,
                        case when v_fark > 0 then 'Kambiyo kârı' else 'Kambiyo zararı' end,
                        ki.sube_id, coalesce(ki.giris_kaynak, 1), ki.ekleyen);
                v_sayi := v_sayi + 1;
            end if;
        end if;
    end if;

    return v_sayi;
end $$;

-- ============================================================================
--  2) Dogrulama — plan muafiyeti
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
    v_plan    boolean;
begin
    select * into ki from public.kasa_islem where id = p_id;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;
    if coalesce(tr.aktif, 0) <> 1 then
        raise exception 'İşlem türü pasif: %', tr.ad using errcode = 'GK422';
    end if;

    -- PLAN: tek bacakli, karsi tarafi henuz yok - denge aranmaz (K5 muafiyeti).
    v_plan := coalesce(tr.plan_mi, 0) = 1 or ki.durum = 1;

    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);

    if ki.proje_id is not null
       and not exists (select 1 from public.proje where id = ki.proje_id and durum = 1) then
        raise exception 'Proje kapalı veya iptal - işlem bu projeye bağlanamaz.' using errcode = 'GK422';
    end if;

    if v_plan and coalesce(ki.plan_tarihi, ki.islem_tarihi) is null then
        raise exception 'Plan kaydında vade (plan tarihi) zorunlu.' using errcode = 'GK422';
    end if;

    select count(*), coalesce(sum(yerel_borc), 0), coalesce(sum(yerel_alacak), 0)
      into v_sayi, v_borc, v_alacak
      from public.mali_hareket where kasa_islem_id = p_id;

    if v_sayi = 0 then
        raise exception 'İşlemin hiç bacağı yok.' using errcode = 'GK422';
    end if;
    if not v_plan and v_sayi < 2 then
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

    -- Virman / doviz: iki AYRI hesap sart (ayni hesaba virman anlamsiz).
    if tr.grup in ('virman', 'doviz') and tr.ana_hesap_turu <> '' then
        if ki.hesap_id is null or ki.karsi_hesap_id is null then
            raise exception 'Virman/döviz işleminde hem kaynak hem karşı hesap seçilmeli.'
                  using errcode = 'GK422';
        end if;
        if ki.hesap_id = ki.karsi_hesap_id then
            raise exception 'Kaynak ve karşı hesap aynı olamaz.' using errcode = 'GK422';
        end if;
    end if;

    if ki.tur = 49 and (ki.taraf_id is null or ki.karsi_taraf_id is null) then
        raise exception 'Cari virmanda hem kaynak hem karşı cari seçilmeli.' using errcode = 'GK422';
    end if;
    if ki.tur = 49 and ki.taraf_id = ki.karsi_taraf_id then
        raise exception 'Kaynak ve karşı cari aynı olamaz.' using errcode = 'GK422';
    end if;

    select count(*) into v_cari from public.mali_hareket
     where kasa_islem_id = p_id and hesap_turu = 'C' and taraf_id is not null;

    if tr.cari_zorunlu = 1 and v_cari = 0 then
        raise exception 'Bu işlem türü için cari seçilmesi zorunlu.' using errcode = 'GK422';
    end if;
    if tr.cari_zorunlu = -1 and v_cari > 0 then
        raise exception 'Bu işlem türünde cari kullanılamaz.' using errcode = 'GK422';
    end if;

    if not v_plan and round(v_borc, 2) <> round(v_alacak, 2) then
        raise exception 'İşlem dengesiz: borç % / alacak % (fark %). Kur ya da tutarları kontrol edin.',
              round(v_borc, 2), round(v_alacak, 2), round(v_borc - v_alacak, 2)
              using errcode = 'GK422';
    end if;
end $$;

-- ============================================================================
--  3) Muhasebe hesabi cozumu — rol bazli kural (kambiyo) eklendi
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
--  4) Plan gerceklestirme (K10) — plan DEGISMEZ, yeni baslik acilir
-- ============================================================================
create or replace function public.fn_plan_gerceklestir(
    p_plan_id    integer,
    p_hesap_id   integer,
    p_tutar      numeric default null,
    p_tarih      date    default null,
    p_tur        integer default null,
    p_kullanici  integer default 0)
returns integer
language plpgsql
as $$
declare
    pl      record;
    ptr     record;
    v_htur  varchar(1);
    v_hdvz  varchar(6);
    v_tur   integer;
    v_tutar numeric(19,4);
    v_tarih date;
    v_kur   numeric(19,6);
    v_yeni  integer;
begin
    select * into pl from public.kasa_islem where id = p_plan_id for update;
    if not found then
        raise exception 'Plan bulunamadı: %', p_plan_id using errcode = 'GK422';
    end if;

    select * into ptr from public.kasa_islem_turu where kod = pl.tur;
    if coalesce(ptr.plan_mi, 0) <> 1 then
        raise exception 'Bu kayıt bir plan değil (%).', ptr.ad using errcode = 'GK422';
    end if;
    if pl.durum not in (1) then
        raise exception 'Yalnız açık plan gerçekleştirilebilir (durum %).', pl.durum using errcode = 'GK422';
    end if;

    v_tutar := coalesce(nullif(p_tutar, 0), pl.kalan_tutar);
    if v_tutar <= 0 then
        raise exception 'Gerçekleşecek tutar sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;
    if round(v_tutar, 2) > round(pl.kalan_tutar, 2) then
        raise exception 'Tutar planın kalanını aşıyor (kalan %).', round(pl.kalan_tutar, 2)
              using errcode = 'GK422';
    end if;

    select h.tur, h.doviz_cinsi into v_htur, v_hdvz from public.hesap h
     where h.id = p_hesap_id and h.durum = 1;
    if v_htur is null then
        raise exception 'Tahsilat/ödeme hesabı bulunamadı ya da pasif.' using errcode = 'GK422';
    end if;
    if v_hdvz <> pl.doviz_cinsi then
        raise exception 'Hesabın para birimi (%) planın para biriminden (%) farklı.',
              v_hdvz, pl.doviz_cinsi using errcode = 'GK422';
    end if;

    -- Islem turu verilmediyse: planin yonu (tahsilat/odeme) + hesabin turu belirler.
    v_tur := p_tur;
    if v_tur is null then
        v_tur := case when ptr.yon >= 0
                      then case v_htur when 'K' then 21 when 'B' then 22 when 'P' then 25
                                       when 'H' then 26 else 21 end
                      else case v_htur when 'K' then 31 when 'B' then 32 when 'V' then 35
                                       when 'H' then 36 else 31 end
                 end;
    end if;

    v_tarih := coalesce(p_tarih, current_date);
    v_kur := case when pl.doviz_cinsi = 'TL' then 1
                  else coalesce(public.fn_doviz_kur_getir(pl.doviz_cinsi, v_tarih,
                                  case when ptr.yon >= 0 then 1 else 2 end::smallint),
                                pl.doviz_kuru, 1) end;

    insert into public.kasa_islem
        (tur, islem_no, islem_tarihi, durum, taraf_id, taraf_unvan, hesap_id,
         doviz_cinsi, tutar, doviz_kuru, yerel_tutar,
         masraf_id, hizmet_id, proje_id, merkez_id, belge_id, plan_islem_id,
         aciklama, sube_id, giris_kaynak, ekleyen)
    values (v_tur, '', v_tarih, 0, pl.taraf_id, pl.taraf_unvan, p_hesap_id,
            pl.doviz_cinsi, v_tutar, v_kur, round(v_tutar * v_kur, 2),
            pl.masraf_id, pl.hizmet_id, pl.proje_id, pl.merkez_id, pl.belge_id, p_plan_id,
            left(coalesce(nullif(pl.aciklama, ''), ptr.ad) || ' (plan gerçekleşmesi)', 200),
            pl.sube_id, coalesce(pl.giris_kaynak, 1), p_kullanici)
    returning id into v_yeni;

    perform public.fn_kasa_islem_bacak_uret(v_yeni);
    -- kesinlestir plan_islem_id'yi gorup gerceklesen_tutar'i biriktirir ve
    --   kalan sifirlaninca plani durum 4'e alir (076).
    perform public.fn_kasa_islem_kesinlestir(v_yeni, p_kullanici);

    return v_yeni;
end $$;

-- ============================================================================
--  5) mali_hareket.durum'a DOKUNMA
--
--  076 kesinlestirmede bacaklarin durum'unu 2, iptalde 3 yapiyordu. YANLIS:
--    islemin durumu BASLIKTA (kasa_islem.durum) tutulur, ekstre gorunumleri de
--    oradan okur (v_mali_hareket_ek.islem_durum = coalesce(ki.durum, 2)).
--    Bacaktaki `durum` legacy anlamli bir kolondur - gocten gelen 42 satirda -1
--    var. Uzerine 2/3 yazmak o anlami sessizce siler ve ileride "-1 = iptal"
--    diye filtre yazan herkesi yanıltir.
-- ============================================================================
comment on column public.mali_hareket.durum is
  'LEGACY alan (goc: 0 / -1). Islem durumu BURADA DEGIL kasa_islem.durum''dadir; ekstre gorunumleri islem_durum uzerinden okur. Motor bu kolona yazmaz.';

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
    if ki.durum = 4 then
        raise exception 'Kapanmış plan kesinleştirilemez.' using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;

    select count(*) into v_sayi from public.mali_hareket where kasa_islem_id = p_id;
    if v_sayi = 0 then
        perform public.fn_kasa_islem_bacak_uret(p_id);
    end if;

    update public.kasa_islem
       set durum = 2, degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_id;

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

    insert into public.mali_hareket
        (kasa_islem_id, sira, rol, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no,
         islem_tarihi, borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
         durum, masraf_id, hizmet_id, proje_id, merkez_id, cek_senet_id,
         ekstrede_kullan, aciklama, sube_id, giris_kaynak, ekleyen)
    select v_yeni, m.sira, m.rol, m.tur, m.hesap_turu, m.hesap_id, m.taraf_id, m.belge_id, m.belge_no,
           v_tarih::timestamp, m.alacak, m.borc, m.yerel_alacak, m.yerel_borc, m.doviz_cinsi, m.doviz_kuru,
           0, m.masraf_id, m.hizmet_id, m.proje_id, m.merkez_id, m.cek_senet_id,
           m.ekstrede_kullan, left('İPTAL: ' || m.aciklama, 100), m.sube_id, m.giris_kaynak, p_kullanici
      from public.mali_hareket m where m.kasa_islem_id = p_id order by m.sira;

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

    update public.kasa_islem
       set islem_no = public.fn_kasa_islem_no_uret(ki.tur, ki.sube_id, extract(year from v_tarih)::integer)
     where id = v_yeni;

    return v_yeni;
end $$;

-- ============================================================================
--  6) Dogrulama
-- ============================================================================
do $$
declare v_e integer; v_f integer;
begin
    select count(*) into v_e from public.muhasebe_eslestirme where kural_turu = 'rol';
    select count(*) into v_f from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'fn_plan_gerceklestir';
    raise notice '085 tamam: rol eslestirmesi %, fn_plan_gerceklestir %', v_e, v_f;
end $$;
