-- =============================================================================
--  1274 - BELGE KISA ADLARI SÖZLÜĞE  (07.11.2026)
--
--  · Belge kartı sekme başlığı tür önekli ("Fat-Akana", "İrs-Terme"); yabancı dilde çevirinin ilk 3 harfi
--    ("Inv-", "Del-"). `belgeKisaAdi` adlarından Fiş / Konsinye / Transfer / Tahakkuk etiket kapsamında
--    çevirisizdi (Transfer yalnız Virman/Nakil anahtarıyla, Tahakkuk yalnız 'kod' kapsamında) - önek Türkçe kalıyordu.
--  · İdempotent: olan satıra dokunmaz (kurulum kendi çevirisini değiştirmiş olabilir).
-- =============================================================================

insert into public.ceviri (kapsam, anahtar, dil, metin)
select v.kapsam, v.tr, v.dil, v.karsilik
  from (values
    ('etiket', 'Fiş',       1::smallint, 'Receipt'),
    ('etiket', 'Fiş',       2,           'Beleg'),
    ('etiket', 'Konsinye',  1,           'Consignment'),
    ('etiket', 'Konsinye',  2,           'Kommission'),
    ('etiket', 'Transfer',  1,           'Transfer'),
    ('etiket', 'Transfer',  2,           'Umbuchung'),
    ('etiket', 'Tahakkuk',  1,           'Accrual'),
    ('etiket', 'Tahakkuk',  2,           'Abgrenzung'),
    ('etiket', 'İrsaliye',  2,           'Lieferschein'),
    ('etiket', 'Sipariş',   2,           'Bestellung'),
    ('etiket', 'Teklif',    2,           'Angebot'),
    ('etiket', 'Talep',     2,           'Anforderung'),
    ('etiket', 'Belge',     2,           'Beleg')
  ) as v(kapsam, tr, dil, karsilik)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = v.kapsam and c.anahtar = v.tr and c.dil = v.dil);

do $kontrol$
begin
    raise notice '1274 tamam: belge kısa adları - dil 1 %, dil 2 %',
        (select count(*) from public.ceviri where dil = 1 and kapsam = 'etiket'
            and anahtar in ('Fatura','İrsaliye','Fiş','Sipariş','Teklif','Tahakkuk','Konsinye','Transfer','Talep','Belge')),
        (select count(*) from public.ceviri where dil = 2 and kapsam = 'etiket'
            and anahtar in ('Fatura','İrsaliye','Fiş','Sipariş','Teklif','Tahakkuk','Konsinye','Transfer','Talep','Belge'));
end $kontrol$;
