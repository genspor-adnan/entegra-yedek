-- 1341 - Yapay Zekâya Sor: radyoloji rapor ekranının kendi katalog satırı.
--
-- Kullanıcı 14.11.2026: "bu bilgileri rapor ekranda iken yapay zekaya sor kısmında başlıklara koy.. tıklandığında bu
--   bilgiler ekranda görünsün". Rapor rotası /radyoloji/rapor/{istemId} bugüne kadar köke (/radyoloji = istem listesi)
--   çözülüyordu; panel "Radyoloji İstem Listesi" diyor, rapor belgesi listeye karışıyordu. EkranBaglamiCozucu artık iki
--   kademeli kart rotasını ("/radyoloji/rapor/2573" → "/radyoloji/rapor") tanır; bu satır onun hedefi.
--   Yardım belgesi radyoloji-rapor-yazma-onay.md ekran: radyoloji-rapor'a bağlandı; "## Ekran kılavuzu" bölümündeki
--   "### Başlık" konuları panelde tıklanır başlık olarak gelir (model çağrısı / kontör yok).
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, modul,
                                    yetki_kodu, kart_yolu, urun_modu, anahtar, aciklama)
select 'radyoloji-rapor', '/radyoloji/rapor', 'Radyoloji Raporu', 'Radyoloji › Rapor Yazma',
       'Radyoloji', 'Rapor Yazma', 'radyoloji', 'radyoloji', '/radyoloji', 2,
       'radyoloji rapor yazma şablon makro yapılandırılmış alan bakanlık değerlendirmesi onay e-imza kritik bulgu',
       'Radyoloğun rapor ekranı: şablon seçimi (modal), makrolar, yapılandırılmış alanlar, Bakanlık Değerlendirmesi, '
       'taslak / uzmana gönder / onayla ve imzala, kritik bulgu, konsültasyon, ek rapor.'
 where not exists (select 1 from public.ai_rehber_ekran where kaynak = 'radyoloji-rapor');

commit;
