-- =============================================================================
--  1014 - KAYIT KABUL: GÜNLÜK KASA DÖKÜMLERİ (STANDART)
--
--  Kullanıcı (10.10.2026): "kayıt kabul altındaki dökümlere günlük kasa
--  dökümleri ekle". Finans'taki "Günlük kasa dökümü" (std-gunluk-kasa) bütün
--  kasa hareketlerini gösterir; bankonun gün sonu sorusu farklı: "hangi banko,
--  hangi görevli, ne kadar nakit / POS aldı, sayımda fark var mı".
--
--  Tahsilat dökümleri `belge-tahsilat` (başvuru tahsilatları) üzerinden ve
--  YALNIZ BANKODA ALINANLAR (banko dolu = oturum damgalı, 997): alış faturası
--  ödemeleri ve muhasebeden girilen kayıtlar karışmasın. İptal (durum 0) hariç.
--  Banko kolonu bunun için süzülebilir yapıldı (KaynakKatalogu.Kasa).
--
--  Standart döküm (sistem=1), HBYS; dönem varsayılanı BUGÜN. İdempotent.
-- =============================================================================

insert into public.dokum_tanimi
    (kod, ad, aciklama, kaynak, tanim, surum, sahip_id, gorunurluk, roller, aktif,
     sistem, urun_modu, modul, menu_grup, ekleyen, degistiren)
select s.kod, s.ad, s.aciklama, s.kaynak, s.tanim::jsonb, 1, null, 2, '{}', 1,
       1, 2, '', 'Kayıt Kabul', 0, 0
  from (values
('std-kk-banko-gun-sonu', 'Banko gün sonu (oturumlar)',
 'Banko ve görevli bazında devir, nakit, POS, sayım, fark ve teslim edilen tutar.',
 'bankoOturum', $j${
  "kaynak":"bankoOturum","cikti":"liste",
  "filtre":{"op":"and","kosullar":[{"alan":"acilisTs","op":"arasinda","deger":["",""]}]},
  "kolonlar":["acilisTs","bankoAd","gorevli","vardiya","devirTutar","nakitTahsilat","posTutar",
              "kapanisSayim","kapanisFark","teslimEdilen","durumAdi"],
  "sirala":[{"alan":"acilisTs","yon":"asc"}],
  "toplam":["nakitTahsilat","posTutar","kapanisFark","teslimEdilen"],
  "parametreler":{"acilisTs":{"ad":"Tarih","kural":"bugun"}},
  "kiyas":"yok","esik":0}$j$),
('std-kk-gunluk-tahsilat-ozet', 'Günlük tahsilat özeti (banko × ödeme türü)',
 'Bankolarda alınan tahsilatın ödeme türüne göre toplamı ve adedi.',
 'belge-tahsilat', $j${
  "kaynak":"belge-tahsilat","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"islemTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":0},
    {"alan":"banko","op":"bosDegil"}]},
  "boyut":{"satir":["banko"],"sutun":"turAdi"},
  "olcu":[{"fn":"toplam","alan":"yerelTutar"},{"fn":"adet"}],
  "parametreler":{"islemTarihi":{"ad":"Tarih","kural":"bugun"}},
  "kiyas":"yok","esik":0}$j$),
('std-kk-gunluk-tahsilat-liste', 'Günlük tahsilat listesi (banko)',
 'Bankolarda alınan tahsilatlar makbuz makbuz; bankoya göre gruplu, toplamlı.',
 'belge-tahsilat', $j${
  "kaynak":"belge-tahsilat","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"islemTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":0},
    {"alan":"banko","op":"bosDegil"}]},
  "kolonlar":["islemTarihi","islemNo","banko","turAdi","hesapAdi","tutar","dovizCinsi","yerelTutar"],
  "sirala":[{"alan":"islemTarihi","yon":"asc"}],
  "grup":["banko"],"toplam":["yerelTutar"],
  "parametreler":{"islemTarihi":{"ad":"Tarih","kural":"bugun"}},
  "kiyas":"yok","esik":0}$j$)
  ) as s(kod, ad, aciklama, kaynak, tanim)
 where not exists (select 1 from public.dokum_tanimi d where d.kod = s.kod);
