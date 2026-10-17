-- =============================================================================
--  1125  `belge` YETKİSİNİN ADI: "Belgeler" -> "Başvuru Kartı"
--
--  Kullanıcı (17.10.2026): "rol kartında kayıt kabul altında belgeler rename Başvuru Kartı".
--
--  1115'ten sonra Kayıt Kabul › Başvuru Listesi ekranı `basvuru.liste` kodunda; `belge` kodu
--  başvuru kartının (ve kart içindeki istem / kesinleştirme aksiyonlarının) veri kapısı olarak
--  kaldı. Matriste Kayıt Kabul grubunda "Belgeler" diye görünüyordu - ne açtığını söylemiyordu.
--  ERP'nin satış / alış belgeleri 998'den beri kendi kodlarında (belge.satis, belge.alis...).
--
--  Yalnız ad değişir; kod, haklar, rol_yetki satırları aynen kalır. Kurum adı elle değiştirmişse
--  (ad hâlâ "Belgeler" değilse) dokunulmaz. İdempotent.
-- =============================================================================

update public.yetki
   set ad = 'Başvuru Kartı'
 where kod = 'belge'
   and ad = 'Belgeler';
