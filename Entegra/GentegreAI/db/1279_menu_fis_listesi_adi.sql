-- =============================================================================
--  1279 - GİRİŞ / ÇIKIŞ FİŞİ MENÜ ADI "… LİSTESİ"  (09.11.2026)
--
--  · Stok & Hizmet grubundaki "Giriş Fişi" / "Çıkış Fişi" menü (ve sekme) adı liste adıyla aynı:
--    "Giriş Fişi Listesi" / "Çıkış Fişi Listesi" (kullanıcı; 1276 tahakkuk kalıbı). Yeni adların EN / DE
--    çevirileri sözlüğe; eski ad çevirileri (etiket kapsamı da kullanır) dokunulmaz. İdempotent.
-- =============================================================================

insert into public.ceviri (kapsam, anahtar, dil, metin)
select v.kapsam, v.tr, v.dil, v.karsilik
  from (values
    ('menu', 'Giriş Fişi Listesi', 1::smallint, 'Goods Receipt List'),
    ('menu', 'Giriş Fişi Listesi', 2,           'Wareneingangsliste'),
    ('menu', 'Çıkış Fişi Listesi', 1,           'Goods Issue List'),
    ('menu', 'Çıkış Fişi Listesi', 2,           'Warenausgangsliste')
  ) as v(kapsam, tr, dil, karsilik)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = v.kapsam and c.anahtar = v.tr and c.dil = v.dil);

do $kontrol$
begin
    raise notice '1279 tamam: fiş menü adları - % çeviri',
        (select count(*) from public.ceviri where kapsam = 'menu' and anahtar in ('Giriş Fişi Listesi', 'Çıkış Fişi Listesi'));
end $kontrol$;
