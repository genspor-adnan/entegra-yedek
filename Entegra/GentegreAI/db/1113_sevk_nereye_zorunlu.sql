-- ============================================================================
--  1113_sevk_nereye_zorunlu.sql
--  SEVKTE "NEREYE" ZORUNLU (kullanıcı 15.10.2026: "sevk nereye zorunlu, kayıt olmamalı").
--
--  Nereye türe bağlıdır: kurum dışı (1) = tesis (adı ya da SKRS kodu), kurum içi (2) ve
--  yatış (3) = hedef bölüm. Kartın zorunlu alan listesi sabit olduğu için koşullu kural
--  tetikte. Muayeneden açılan BOŞ taslak (not yazılmamış) oluşabilir - sol menü önce taslak
--  açar; kart kaydedilirken / gönderilirken (güncelleme ya da notlu ekleme) nereye aranır.
--  İptal (0) kaydı denetlenmez. Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_sevk_nereye() returns trigger language plpgsql as $$
begin
    if new.durum = 0 then return new; end if;
    -- Muayeneden açılan boş taslak (henüz hiçbir şey yazılmamış) serbest.
    if tg_op = 'INSERT' and coalesce(btrim(new.notu), '') = '' then return new; end if;
    if new.tur = 1 and coalesce(btrim(new.tesis_ad), '') = '' and coalesce(btrim(new.tesis_kodu), '') = '' then
        raise exception 'Nereye zorunlu: sevk edilen tesisi yazın.' using errcode = 'P0001';
    end if;
    if new.tur in (2, 3) and new.hedef_bolum_id is null then
        raise exception 'Nereye zorunlu: sevk edilen bölümü seçin.' using errcode = 'P0001';
    end if;
    return new;
end $$;

drop trigger if exists trg_sevk_nereye on public.sevk;
create trigger trg_sevk_nereye before insert or update on public.sevk
    for each row execute function public.tg_sevk_nereye();
