-- ============================================================================
--  1117_muayene_rapor_no.sql
--  MUAYENE RAPOR NUMARASI (kullanıcı 16.10.2026: "muayene için raporno şablonu ekle ayarlar kısmına,
--  dosyano protokolno gibi ve otomatik raporno ver" · "R ile başlayan 5 haneli rakam şimdilik" ·
--  "istersem ben ayarı değiştireyim").
--
--  1. Numara türü 920 "Muayene Rapor No" (v_numara_turu_kimlik): Genel Ayarlar › Numaralama ›
--     Hasta belgeleri gridinde dosya no / protokol no ile aynı yerde ayarlanır.
--  2. Varsayılan şablon: ön ek "R", 5 hane, 00001'den (tüm şubeler). Kurumun şablonu varsa dokunulmaz.
--  3. Numarayı TETİK yazar (719 deseni): rapor nereden eklenirse eklensin (muayene penceresi, kart)
--     rapor_no boşsa şablondan verilir; "elle girilir" ayarında boş bırakılır. Şablon yoksa boş
--     kalır (bugünkü davranış).
--  Mevcut raporlar numaralanmaz (geçmiş kayıt). Tekrar çalıştırılabilir.
-- ============================================================================

create or replace view public.v_numara_turu_kimlik as
 select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif,
        1::smallint as sira
union all
 select  19, 'Başvuru Protokol No'::varchar,  1::smallint, 2::smallint
union all
 select 907, 'Acil Protokol No'::varchar,     1::smallint, 3::smallint
union all
 select 902, 'Muayene No'::varchar,           1::smallint, 4::smallint
union all
 select 905, 'Reçete No'::varchar,            1::smallint, 5::smallint
union all
 select 920, 'Muayene Rapor No'::varchar,     1::smallint, 6::smallint
union all
 select 901, 'Laboratuvar İstem No'::varchar, 1::smallint, 7::smallint
union all
 select 903, 'Radyoloji İstem No'::varchar,   1::smallint, 8::smallint
union all
 select 906, 'Ameliyat No'::varchar,          1::smallint, 9::smallint
union all
 select 904, 'e-Nabız Paket No'::varchar,     1::smallint, 10::smallint;

comment on view public.v_numara_turu_kimlik is
  '1117: hasta belgelerinin numara turleri (635 + ameliyat 906 / acil protokol 907 / muayene rapor 920). '
  'Sira hastanin izledigi yolu verir; sablon yoksa numara BOS kalir.';

-- Varsayılan şablon (yalnız 920 için hiç şablon yoksa).
-- hane / baslangic başlama numarasından türetilir ('00001' -> 5 hane, 1'den).
insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no, sube_id, durum, aciklama, elle_girilir)
select 920, date '2026-01-01', 'R', '00001', 0, 1, 'Muayene rapor numarası (1117)', 0
 where not exists (select 1 from public.numara_sablonu where tur = 920);

create or replace function public.tg_muayene_rapor_no() returns trigger language plpgsql as $$
declare
    v_sablon public.numara_sablonu;
begin
    if coalesce(btrim(new.rapor_no), '') <> '' then return new; end if;
    v_sablon := public.fn_numara_sablonu_bul(920, new.sube_id, current_date);
    if v_sablon.id is null or v_sablon.elle_girilir = 1 then return new; end if;
    new.rapor_no := public.fn_numara_kimlik_uret(920, new.sube_id, 'muayene_rapor', 'rapor_no', current_date);
    return new;
end $$;

drop trigger if exists tg_muayene_rapor_no on public.muayene_rapor;
create trigger tg_muayene_rapor_no before insert on public.muayene_rapor
    for each row execute function public.tg_muayene_rapor_no();
