-- =============================================================================
--  1013 - LABORATUVAR: YAPILAN TETKİK İSTATİSTİKLERİ (STANDART DÖKÜM)
--
--  Kullanıcı (10.10.2026): "laboratuvar menüsü altına ayarlardan önceye
--  Dökümler ekle ve içine yapılan tetkiklerle ilgili istatistik ekle".
--  Menüdeki yer web'de (Laboratuvar › Dökümler, Ayarlar'dan önce); burada
--  grubun Dökümler ekranında görünecek üç hazır döküm. Kaynak `lab-sonuc`
--  (tetkik başına bir sonuç satırı). "Yapılan" = sonuçlanmış: teknik onaylı
--  ya da onaylı (durum 2, 3); bekleyen ve iptal (düzeltildi) sayılmaz.
--
--  Standart döküm (sistem=1): salt okunur, kopyalanır; HBYS + lab modülü
--  açık kurumda görünür (688 süzgeci). İdempotent: kod varsa dokunulmaz.
-- =============================================================================

insert into public.dokum_tanimi
    (kod, ad, aciklama, kaynak, tanim, surum, sahip_id, gorunurluk, roller, aktif,
     sistem, urun_modu, modul, menu_grup, ekleyen, degistiren)
select s.kod, s.ad, s.aciklama, 'lab-sonuc', s.tanim::jsonb, 1, null, 2, '{}', 1,
       1, 2, 'lab', 'Laboratuvar', 0, 0
  from (values
('std-lab-tetkik-ay', 'Yapılan tetkikler (tetkik × ay)',
 'Sonuçlanan tetkik adedi ve tekil istem sayısı; tetkik × ay, geçen yılla kıyas.',
 $j${
  "kaynak":"lab-sonuc","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"olcumZamani","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"icinde","deger":[2,3]}]},
  "boyut":{"satir":["tetkikAd"],"sutun":"olcumZamani:ay"},
  "olcu":[{"fn":"adet"},{"fn":"tekil","alan":"istemNo"}],
  "parametreler":{"olcumZamani":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":0}$j$),
('std-lab-cihaz-ay', 'Cihaz bazında tetkik (cihaz × ay)',
 'Hangi cihazda (ya da elle) kaç tetkik sonuçlandı; cihaz × ay.',
 $j${
  "kaynak":"lab-sonuc","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"olcumZamani","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"icinde","deger":[2,3]}]},
  "boyut":{"satir":["cihazAdi"],"sutun":"olcumZamani:ay"},
  "olcu":[{"fn":"adet"}],
  "parametreler":{"olcumZamani":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":0}$j$),
('std-lab-panik-tetkik', 'Panik değer dağılımı (tetkik)',
 'Tetkik başına panik olan / olmayan sonuç adedi.',
 $j${
  "kaynak":"lab-sonuc","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"olcumZamani","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"icinde","deger":[2,3]}]},
  "boyut":{"satir":["tetkikAd"],"sutun":"panik"},
  "olcu":[{"fn":"adet"}],
  "parametreler":{"olcumZamani":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"yok","esik":0}$j$)
  ) as s(kod, ad, aciklama, tanim)
 where not exists (select 1 from public.dokum_tanimi d where d.kod = s.kod);
