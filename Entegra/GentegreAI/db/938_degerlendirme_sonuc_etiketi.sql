-- =====================================================================
--  938_degerlendirme_sonuc_etiketi.sql
--  "DEĞERLENDİRME / PLAN" ETİKETİ "DEĞERLENDİRME / SONUÇ" OLDU (kullanıcı:
--  muayene kartı alanı, özet sekmesi ve tamamlama kontrolü aynı adı taşır).
--
--  Etiket kart kataloğundan (KartKatalogu.Saglik) gelir; burada yalnız
--  İngilizce sözlüğe yeni anahtar eklenir. Eski 'Değerlendirme / Plan'
--  satırı (851) durur: yeniden başlatılmamış API hâlâ onu gönderebilir.
--
--  Idempotent (`on conflict do update`).
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Değerlendirme / Sonuç', 1, 'Assessment / outcome')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
begin
    raise notice '938 tamam: Değerlendirme / Sonuç çevirisi.';
end $$;
