-- ============================================================================
--  593 - SGK KATILIM PAYI AYARLARI: yardim metinleri (kullanici)
--
--  "opsiyonda Katılım Payı Alınacak SUT Kodları altındaki açıklamayı help ?'e
--  ekle" - 357'deki GENEL KURALIN aynisi: aciklama alt paragrafta degil,
--  editin sagindaki "?" ikonunda durur.
-- ============================================================================
insert into public.help (anahtar, dil, baslik, metin) values
('ayar.basvuru.sgk_katilim_payi', 0, 'SGK Katılım Payı (TL)',
 'SUT muayenesinde SGK adına hastadan alınan SABİT tutar (TL).'
 || E'\n\n'
 || 'Bu tutar CİRO DIŞIDIR: hastanenin geliri değildir, SGK emaneti olarak '
 || 'tutulur ve SGK''ya aktarılır. Ücret satırının dağılımında ayrı bir pay '
 || 'olarak görünür ("ciro dışı · SGK emaneti").'
 || E'\n\n'
 || 'EMEKLİ hastadan alınmaz: emeklinin katılım payı maaşından kesildiği için '
 || 'kurumda ikinci kez tahsil edilmez. Başvuru sekmesindeki "Emekli" işareti '
 || 'bu payı sıfırlar. İşaret yalnız SGK''nın ödediği başvurularda sorulur '
 || '(SGK kurumu, TSS ve SGK katkısı açık karma poliçe).'
 || E'\n\n'
 || 'Katılım payı yalnız SGK''nın ödediği rotalarda doğar; özel hastada ve saf '
 || 'ÖSS (özel sağlık sigortası) başvurusunda alınmaz.'),
('ayar.basvuru.sgk_katilim_kodlari', 0, 'Katılım Payı Alınacak SUT Kodları',
 'Katılım payının HANGİ KALEMDE doğacağını belirler: hizmetin kodu (SUT kodu) '
 || 'bu listedeyse katılım payı alınır, değilse alınmaz.'
 || E'\n\n'
 || 'Kodlar VİRGÜLLE ayrılır, aradaki boşluklar önemsizdir: '
 || '520030,520031 ya da 520030, 520031.'
 || E'\n\n'
 || 'Kutu BOŞ bırakılırsa eski davranış sürer: MUAYENE kategorisindeki her '
 || 'kalem katılım payı üretir. Kod listesi kategoriden güvenlidir - kategori '
 || 'adı kurumun elindedir, SUT kodu değişmez.'
 || E'\n\n'
 || 'Tutar yandaki "SGK Katılım Payı (TL)" ayarındadır.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;
