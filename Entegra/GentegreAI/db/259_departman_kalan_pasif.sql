-- 259: 258'de pasife çekilemeyen departman (kullanıcı isteğinin devamı).
--
-- "SATINALMA & INSAN KAYNAKLARI" 258'deki lower() eşleşmesine takılmadı:
-- Türkçe I/İ dönüşümü PG'nin varsayılan (ICU tr-TR) collation'ında ASCII
-- lower()'dan farklı davranıyor. Ad ARANMADAN, kimliği belli tek satır
-- olduğu için kodla değil kalıpla hedefleniyor.

update public.departman
   set durum = 0, degistirme_tarihi = now()::timestamp
 where durum = 1
   and ad like '%SATINALMA%'
   and ad like '%KAYNAK%';
