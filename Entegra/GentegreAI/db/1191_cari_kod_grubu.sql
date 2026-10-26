-- =============================================================================
--  1191  CARİ KODU GRUPTAN SIRADAKİ (Delphi kod grubu gibi)
--
--  Kullanıcı (26.10.2026, ZONE / MEDX geçişi): Delphi'de müşteri kodu kod grubundan üretiliyor
--  (120.01.604 → 120.01.605, tedarikçi 320.01.304 → 320.01.305; THesapKoduPicker.SiradakiKoduGetir:
--  grubun altındaki en büyük sayısal son parça + 1, grubun hane sayısında). Web'de kod boş bırakılınca
--  kaydın ID'si yazılıyordu → "ikisini de yap".
--
--  Ayar (Genel Ayarlar, public.referans): cari.kod_grubu_musteri / cari.kod_grubu_tedarikci, ör. '120.01'.
--  Boş = eski davranış (ID). Kod elle girilirse dokunulmaz.
--  fn_taraf_kod_uret(id): yeni kartın rolüne göre grubu bulur; grubun altındaki ('<grup>.<sayı>')
--  en büyük sayı + 1, mevcut kodların hane sayısında (yoksa 3). Aynı gruba eşzamanlı iki kayıt
--  aynı kodu almasın diye grup başına işlem kilidi.
--  İdempotent; tablo / veri değişmez.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create or replace function public.fn_taraf_kod_uret(p_taraf_id integer)
returns varchar
language plpgsql
as $function$
declare
    v_musteri   smallint;
    v_tedarikci smallint;
    v_grup      text;
    v_son       bigint;
    v_hane      integer;
    v_yeni      text;
begin
    select coalesce(t.musteri, 0), coalesce(t.tedarikci, 0)
      into v_musteri, v_tedarikci
      from public.taraf t where t.id = p_taraf_id;
    if not found then return null; end if;

    -- Tedarikçi kartı müşteri bayrağını da taşır (Delphi'den gelenler ve yeni tedarikçi: musteri = 1,
    --   tedarikci = 1) - önce tedarikçi bakılır.
    v_grup := case when v_tedarikci = 1 then 'cari.kod_grubu_tedarikci'
                   when v_musteri = 1 then 'cari.kod_grubu_musteri' end;
    if v_grup is null then return null; end if;
    select nullif(btrim(r.deger), '') into v_grup from public.referans r where r.anahtar = v_grup;
    -- Sondaki nokta yazılmışsa ('120.01.') tek noktaya indirilir.
    v_grup := nullif(rtrim(coalesce(v_grup, ''), '.'), '');
    if v_grup is null then return null; end if;

    perform pg_advisory_xact_lock(hashtext('taraf.kod|' || v_grup));

    select max(substr(t.kod, length(v_grup) + 2)::bigint),
           max(length(substr(t.kod, length(v_grup) + 2)))
      into v_son, v_hane
      from public.taraf t
     where left(t.kod, length(v_grup) + 1) = v_grup || '.'
       and substr(t.kod, length(v_grup) + 2) ~ '^[0-9]{1,18}$'
       and t.id <> p_taraf_id;

    v_yeni := (coalesce(v_son, 0) + 1)::text;
    return v_grup || '.' || lpad(v_yeni, greatest(coalesce(v_hane, 3), length(v_yeni)), '0');
end $function$;

comment on function public.fn_taraf_kod_uret(integer) is
  '1191: yeni cari kartinda bos kod - rolun kod grubundan (cari.kod_grubu_musteri / _tedarikci) siradaki kod; grup yoksa null (ID kod olur).';

commit;
