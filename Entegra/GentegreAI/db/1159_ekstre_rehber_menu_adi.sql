-- =============================================================================
--  1159  EKSTRE - yardım kataloğu: "Cari Ekstre" maddesi "Ekstre" oldu
--
--  Kullanıcı (23.10.2026): "menüde cari ekstre rename Ekstre". Menü maddesi eski
--  kaynak koduyla (cari-ekstre) kalır - GenProfil menü düzenleri ekranı bu kodla
--  tutuyor; adı ve hedefi tek ekstre ekranı (1158, /ekstre). 1158'in ayrı
--  'ekstre' rehber satırı bununla birleşir; hesap-ekstre satırı da tek ekrana
--  işaret eder. İdempotent.
-- =============================================================================

begin;

-- Önce 1158'in ayrı satırı: rota tekil (ux_ai_rehber_ekran), cari-ekstre /ekstre'yi alacak.
delete from public.ai_rehber_ekran where kaynak = 'ekstre';

update public.ai_rehber_ekran
   set rota = '/ekstre', baslik = 'Ekstre', yol = 'Finans › Ekstre', menu_grup = 'Finans', menu_ad = 'Ekstre',
       yetki_kodu = 'finans.ekstre',
       anahtar = 'ekstre hesap ekstresi cari ekstre kasa banka pos kredi hareket devir bakiye borç alacak giriş çıkış aylık vade',
       aciklama = 'Tek ekstre ekranı: cari (müşteri / tedarikçi), kasa, banka, POS, kredi hesaplarının hareketleri - '
               || 'dönem başı devir, yürüyen bakiye, para birimi grupları, aylık özet, belge kalemleri (cari), A4 çıktı. '
               || 'Liste ve kartlardaki "Ekstre" düğmesi bu ekranı ilgili hesapla açar.'
 where kaynak = 'cari-ekstre';

update public.ai_rehber_ekran
   set rota = '/ekstre?tur=hesap', yol = 'Finans › Ekstre', menu_grup = 'Finans', menu_ad = 'Ekstre',
       aciklama = 'Kasa / banka / POS / kredi hesabının hareketleri artık tek Ekstre ekranında (Finans › Ekstre, hesap türü seçici).'
 where kaynak = 'hesap-ekstre';

commit;
