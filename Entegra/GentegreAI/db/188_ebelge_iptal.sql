-- ============================================================================
--  Gentegre AI — GIDEN e-BELGE IPTALI / ITIRAZ
--  188_ebelge_iptal.sql
--
--  Gonderilen belge yanlissa ne olacagi tanimli degildi. Uc ayri gercek var,
--  hepsi ayni "iptal" dugmesinin arkasinda ama kurallari FARKLI:
--
--    e-ARSIV : GIB'e raporlanmadan once entegrator uzerinden IPTAL edilir.
--              Iptal edilen belge numarasi TEKRAR KULLANILMAZ.
--    e-FATURA: tek tarafli iptal YOKTUR. Alicidan RED yaniti beklenir ya da
--              GIB iptal portalina IPTAL TALEBI gonderilir; talep alici
--              tarafindan onaylanana kadar belge gecerlidir.
--    e-IRSALIYE: iptal yok; yanlis irsaliye icin yeni irsaliye/iade dusunulur.
--
--  DURUM KODLARI (giden, mevcut serinin devami):
--    21 e-Arsiv iptal edildi · 22 e-Fatura iptal TALEBI gonderildi
--    23 iptal talebi kabul edildi · 24 iptal talebi reddedildi
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.e_belge
    add column if not exists iptal_tarihi   timestamp,
    add column if not exists iptal_gerekce  varchar(500) not null default '';

comment on column public.e_belge.iptal_gerekce is
  'Iptal/itiraz gerekcesi (188). e-Arsivde entegratore gider, e-Faturada talep metnidir.';

-- Durum adlari: iptal asamalari eklendi.
create or replace function public.fn_ebelge_durum_adi(p_durum integer,
                                                      p_kagit text default '')
returns text language sql immutable as $$
    select case coalesce(p_durum, 0)
                when 0  then p_kagit
                when 1  then 'e-Fatura'    when 2  then 'e-Fatura ✓'
                when 3  then 'Kabul'       when 4  then 'Red'
                when 11 then 'e-Arşiv'     when 12 then 'e-Arşiv ✓'
                when 21 then 'İptal'       when 22 then 'İptal talebi'
                when 23 then 'İptal edildi' when 24 then 'İptal reddedildi'
                when 51 then 'e-İrsaliye'  when 52 then 'e-İrsaliye ✓'
                when 53 then 'Kabul'       when 54 then 'Red'
                else 'Bilinmiyor' end
$$;

create or replace function public.fn_ebelge_durum_aciklama(p_durum integer)
returns text language sql immutable as $$
    select case coalesce(p_durum, 0)
                when 0  then 'Hazırlanmadı'
                when 1  then 'Hazırlandı (e-Fatura)'    when 2  then 'Gönderildi (e-Fatura)'
                when 11 then 'Hazırlandı (e-Arşiv)'     when 12 then 'Gönderildi (e-Arşiv)'
                when 21 then 'İptal edildi (e-Arşiv)'
                when 22 then 'İptal talebi gönderildi (e-Fatura)'
                when 23 then 'İptal talebi kabul edildi'
                when 24 then 'İptal talebi reddedildi'
                when 51 then 'Hazırlandı (e-İrsaliye)'  when 52 then 'Gönderildi (e-İrsaliye)'
                else 'Bilinmiyor' end
$$;

-- ---------------------------------------------------------------------------
--  Iptal edilebilir mi? Kural TEK yerde: uc de arayuz de ayni cevabi alsin.
--    yeni_durum > 0 ise iptal mumkundur; degilse sebep doner.
-- ---------------------------------------------------------------------------
create or replace function public.fn_ebelge_iptal_edilebilir(p_belge_id integer)
returns table (uygun boolean, yeni_durum smallint, sebep text)
language plpgsql stable as $$
declare e record;
begin
    select eb.*, bl.efatura_durum
      into e
      from public.e_belge eb
      join public.belge bl on bl.id = eb.belge_id
     where eb.belge_id = p_belge_id and eb.yon = 1
     order by eb.id desc limit 1;

    if e.id is null then
        return query select false, 0::smallint, 'Bu belge için e-Belge kaydı yok.'::text;
        return;
    end if;

    if e.durum in (21, 22, 23) then
        return query select false, 0::smallint, 'Bu belge için iptal zaten işlenmiş.'::text;
        return;
    end if;

    -- e-ARSIV: gonderilmis olmali (durum 12); hazirlanmis ama gonderilmemis
    --   belge icin dogru islem "Hazırı Geri Al"dir, iptal degil.
    if e.belge_turu = 2 then
        if e.durum <> 12 then
            return query select false, 0::smallint,
                   'Gönderilmemiş e-Arşiv iptal edilmez; "Hazırı Geri Al" kullanın.'::text;
        else
            return query select true, 21::smallint, ''::text;
        end if;
        return;
    end if;

    -- e-FATURA: tek tarafli iptal yok, IPTAL TALEBI gonderilir.
    if e.belge_turu = 1 then
        if e.durum <> 2 then
            return query select false, 0::smallint,
                   'Gönderilmemiş e-Fatura için iptal talebi açılamaz; "Hazırı Geri Al" kullanın.'::text;
        else
            return query select true, 22::smallint, ''::text;
        end if;
        return;
    end if;

    -- e-IRSALIYE ve digerleri.
    return query select false, 0::smallint,
           'e-İrsaliyede iptal yoktur; düzeltme yeni irsaliye ile yapılır.'::text;
end $$;

comment on function public.fn_ebelge_iptal_edilebilir(integer) is
  'Giden e-Belge iptal edilebilir mi ve edilirse hangi duruma gecer (188).';

-- ---------------------------------------------------------------------------
--  Iptal sonucunu isle (entegrator cagrisi BASARILI dondukten sonra).
-- ---------------------------------------------------------------------------
create or replace function public.fn_ebelge_iptal_yaz(p_belge_id integer,
                                                      p_yeni_durum smallint,
                                                      p_gerekce varchar,
                                                      p_kullanici integer)
returns void language plpgsql as $$
begin
    update public.e_belge eb
       set durum             = p_yeni_durum,
           iptal_tarihi      = now()::timestamp,
           iptal_gerekce     = coalesce(p_gerekce, ''),
           degistiren        = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where eb.belge_id = p_belge_id and eb.yon = 1
       and eb.id = (select max(x.id) from public.e_belge x
                     where x.belge_id = p_belge_id and x.yon = 1);

    update public.belge
       set efatura_durum     = p_yeni_durum,
           degistiren        = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where id = p_belge_id;
end $$;

do $$
begin
    raise notice '188 tamam: e-Arsiv iptali / e-Fatura iptal talebi durumlari ve kurallari.';
end $$;
