\set ON_ERROR_STOP on
-- ============================================================================
--  1205 — belge_satir: iskonto aralığı kısıtı (0–100)
--
--  Kod inceleme 30.10.2026 K40: BelgeHesap.SatirTutari iskonto > 100'de negatif,
--  < 0'da brütten büyük tutar üretir; ne uygulama ne DB denetliyordu. Çekirdeğe
--  BelgeHesap.Dogrula eklendi; DB tarafı burada. Kısıt NOT VALID eklenir:
--  mevcut (müşteri) verisi kısıtı bozsa bile göç durmaz; ardından validate
--  denenir - başarısızsa uyarı verilir, yanlış satırlar sorguyla raporlanır ve
--  kısıt NOT VALID kalır (yeni satırlar yine denetlenir).
-- ============================================================================
begin;

alter table public.belge_satir drop constraint if exists ck_belge_satir_iskonto;
alter table public.belge_satir
    add constraint ck_belge_satir_iskonto
    check (coalesce(iskonto, 0) between 0 and 100 and coalesce(iskonto2, 0) between 0 and 100)
    not valid;

do $$
begin
    begin
        alter table public.belge_satir validate constraint ck_belge_satir_iskonto;
    exception when check_violation then
        raise warning '1205: belge_satir iskonto 0-100 dışında satır var; kısıt NOT VALID kaldı. '
                      'Bakınız: select id, belge_id, iskonto, iskonto2 from public.belge_satir '
                      'where not (coalesce(iskonto,0) between 0 and 100 and coalesce(iskonto2,0) between 0 and 100);';
    end;
end $$;

commit;
