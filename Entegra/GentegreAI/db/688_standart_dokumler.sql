-- ============================================================================
--  Gentegre AI — STANDART DÖKÜMLER (688)
--  688_standart_dokumler.sql
--
--  Kullanıcı: "standart döküm listeleri kurum profiline göre mi çıkarılmalı"
--  → karar: ÜRETİLMEZ, SÜZÜLÜR (menüyle aynı kural). Standart dökümler tek
--  katalogdan (bu dosya) gelir; her satırın ürün modu ve modül etiketi var.
--  Listelenirken kurum profili (urun_modu + fn_kurum_modul_acik) ve kişinin
--  kaynak yetkisi süzer. Modül kapanınca döküm kendiliğinden kaybolur; tablo
--  değişmez.
--
--  KURALLAR
--   · sistem=1 satır SALT OKUNUR: kullanıcı kopyalar (Kopyala), kopya onun
--     olur (sistem=0). Böylece bu dosyanın yeniden çalışması (göç) kişisel
--     kopyaları ezmez, yalnız standart tanımı tazeler.
--   · sahip_id NULL = sistem. Görünürlük 2 (kurum geneli).
--   · SQL YOK: tanım jsonb, sorguyu SorguUretici üretir. Buradaki alan adları
--     KaynakKatalogu'ndaki kolon adlarıdır; katalogdan düşen alan çalıştırmada
--     400 verir (DokumDogrulayici) - sessiz yanlış sonuç yok.
--   · Kişiyi tanımlayan alanlar (hastaAdi vb.) istatistikte boyut değildir.
--
--  Kısaltma: p = parametreler ("çalıştırırken sorulur", tarih kuralı varsayılan).
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.dokum_tanimi add column if not exists sistem    smallint    not null default 0;
alter table public.dokum_tanimi add column if not exists urun_modu smallint    not null default 0;
alter table public.dokum_tanimi add column if not exists modul     varchar(40) not null default '';
alter table public.dokum_tanimi alter column sahip_id drop not null;

comment on column public.dokum_tanimi.sistem is
  '1 = standart dokum (688): salt okunur, kopyalanir; goc ile tazelenir. sahip_id NULL.';
comment on column public.dokum_tanimi.urun_modu is
  '0 her kurulum · 1 ERP · 2 HBYS (UrunModlari ile ayni dil). Yalniz sistem satirlarinda anlamli.';
comment on column public.dokum_tanimi.modul is
  'Kurum profili modulu (fn_kurum_modul_acik): bos = ortak. Kapali modulun dokumu listelenmez.';

-- ---------------------------------------------------------------- seed --
-- upsert: kod benzersiz; sistem satırı tazelenir, kullanıcı satırıyla (aynı
-- kod olamaz ama olursa) dokunulmaz.
create temporary table _std (
    kod varchar(60), ad varchar(160), aciklama varchar(400), kaynak varchar(40),
    urun_modu smallint, modul varchar(40), tanim jsonb
);

insert into _std values
-- ---------------------------------------------------------------- HBYS ----
('std-gunluk-basvuru', 'Günlük başvuru listesi',
 'Seçilen günün başvuruları; ödeyen kuruma göre gruplu, ciro ve tahsilat ara toplamlı.',
 'belge', 2, '', $j${
  "kaynak":"belge","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"tur","op":"esit","deger":19},
    {"alan":"belgeTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":6}]},
  "kolonlar":["belgeTarihi","belgeNo","hastaAdi","odeyenKurumAdi","poliklinik","doktor","genelToplam","tahsilat"],
  "sirala":[{"alan":"belgeTarihi","yon":"desc"}],
  "toplam":["genelToplam","tahsilat"],"grup":["odeyenKurumAdi"],
  "parametreler":{"belgeTarihi":{"ad":"Tarih","kural":"bugun"}},
  "kiyas":"yok","esik":0}$j$),

('std-kurum-aylik-basvuru', 'Kurum bazlı aylık başvuru',
 'Ödeyen kurum × ay: başvuru adedi, ciro, tekil hasta, tahsilat oranı; önceki yılla kıyaslı.',
 'belge', 2, '', $j${
  "kaynak":"belge","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"tur","op":"esit","deger":19},
    {"alan":"belgeTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":6}]},
  "boyut":{"satir":["odeyenKurumAdi"],"sutun":"belgeTarihi:ay"},
  "olcu":[{"fn":"adet"},{"fn":"toplam","alan":"genelToplam"},{"fn":"tekil","alan":"hastaId"},
          {"fn":"oran","alan":"tahsilat","bolen":"genelToplam"}],
  "parametreler":{"belgeTarihi":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":0}$j$),

('std-randevu-gelmeyenler', 'Randevuya gelmeyenler',
 'Durumu "gelmedi" olan randevular; bölüme göre gruplu. Varsayılan geçen hafta.',
 'randevu', 2, '', $j${
  "kaynak":"randevu","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"durum","op":"esit","deger":3},
    {"alan":"tarih","op":"arasinda","deger":["",""]}]},
  "kolonlar":["tarih","saat","bolumAdi","hekim","hasta","hizmet","kaynakAdi"],
  "sirala":[{"alan":"tarih","yon":"desc"}],
  "toplam":[],"grup":["bolumAdi"],
  "parametreler":{"tarih":{"ad":"Tarih","kural":"gecenHafta"}},
  "kiyas":"yok","esik":0}$j$),

('std-randevu-bolum-istatistik', 'Randevu istatistiği (bölüm × ay)',
 'Bölüm × ay randevu adedi; gelmeme oranı için "gelmedi" satırı ayrı dökümde.',
 'randevu', 2, '', $j${
  "kaynak":"randevu","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"tarih","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":4}]},
  "boyut":{"satir":["bolumAdi"],"sutun":"tarih:ay"},
  "olcu":[{"fn":"adet"},{"fn":"tekil","alan":"hastaId"},{"fn":"ortalama","alan":"sureDk"}],
  "parametreler":{"tarih":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":0}$j$),

('std-lab-bekleyen-istemler', 'Bekleyen laboratuvar istemleri',
 'Sonuçlanmamış istemler (istendi · numune alındı · çalışılıyor); bölüm koduna göre gruplu.',
 'lab-istem', 2, 'lab', $j${
  "kaynak":"lab-istem","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"durum","op":"icinde","deger":[1,2,3]},
    {"alan":"istemTarihi","op":"arasinda","deger":["",""]}]},
  "kolonlar":["istemTarihi","istemNo","protokolNo","hastaAdi","bolumAdi","hekimAdi","oncelikAdi","testSayisi","sonuclanan","durumAdi"],
  "sirala":[{"alan":"istemTarihi","yon":"asc"}],
  "toplam":["testSayisi","sonuclanan"],"grup":["bolum"],
  "parametreler":{"istemTarihi":{"ad":"İstem tarihi","kural":"son7"}},
  "kiyas":"yok","esik":0}$j$),

('std-radyoloji-modalite', 'Radyoloji modalite istatistiği',
 'Modalite × ay tetkik adedi ve ortalama bekleme (dk).',
 'radyoloji-istem', 2, 'radyoloji', $j${
  "kaynak":"radyoloji-istem","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"saat","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":9}]},
  "boyut":{"satir":["modalite"],"sutun":"saat:ay"},
  "olcu":[{"fn":"adet"},{"fn":"ortalama","alan":"beklemeDk"},{"fn":"p90","alan":"beklemeDk"}],
  "parametreler":{"saat":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":5}$j$),

('std-muayene-bolum', 'Muayene istatistiği (bölüm × ay)',
 'Bölüm × ay muayene adedi, tekil hasta, ortalama tanı sayısı.',
 'muayene', 2, 'muayene', $j${
  "kaynak":"muayene","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"muayeneTarihi","op":"arasinda","deger":["",""]}]},
  "boyut":{"satir":["bolumAdi"],"sutun":"muayeneTarihi:ay"},
  "olcu":[{"fn":"adet"},{"fn":"tekil","alan":"tarafId"},{"fn":"ortalama","alan":"taniSayisi"}],
  "parametreler":{"muayeneTarihi":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":5}$j$),

-- --------------------------------------------------------------- ORTAK ----
('std-gunluk-kasa', 'Günlük kasa dökümü',
 'Seçilen günün tahsilatları; hesaba (kasa/banka/POS) göre gruplu, yerel tutar toplamlı.',
 'kasa-islem', 0, '', $j${
  "kaynak":"kasa-islem","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"turGrup","op":"esit","deger":"tahsilat"},
    {"alan":"islemTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":0}]},
  "kolonlar":["islemTarihi","islemNo","turAdi","tarafUnvan","hesapAdi","tutar","dovizCinsi","yerelTutar","aciklama"],
  "sirala":[{"alan":"islemTarihi","yon":"asc"}],
  "toplam":["yerelTutar"],"grup":["hesapAdi"],
  "parametreler":{"islemTarihi":{"ad":"Tarih","kural":"bugun"}},
  "kiyas":"yok","esik":0}$j$),

('std-stok-durumu', 'Stok durumu (kategoriye göre)',
 'Satılan aktif stoklar kalan miktarıyla; kategoriye göre gruplu, kalan toplamlı. "kalan" hesaplanan alan - süzülmez, sıralanır.',
 'stok', 0, '', $j${
  "kaynak":"stok","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"satilan","op":"esit","deger":1},
    {"alan":"durum","op":"esit","deger":1}]},
  "kolonlar":["kod","ad","kategori","marka","kalan","minStok","fiyat","anaBirim"],
  "sirala":[{"alan":"kategori","yon":"asc"}],
  "toplam":["kalan"],"grup":["kategori"],
  "parametreler":{},
  "kiyas":"yok","esik":0}$j$),

-- ----------------------------------------------------------------- ERP ----
('std-satis-aylik', 'Aylık satış özeti',
 'Satış faturaları: şube × ay adet, ciro (KDV hariç matrah), KDV, genel toplam; önceki yılla kıyaslı.',
 'belge', 1, '', $j${
  "kaynak":"belge","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"tur","op":"esit","deger":15},
    {"alan":"belgeTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":6}]},
  "boyut":{"satir":["subeAdi"],"sutun":"belgeTarihi:ay"},
  "olcu":[{"fn":"adet"},{"fn":"toplam","alan":"matrah"},{"fn":"toplam","alan":"kdvTutari"},{"fn":"toplam","alan":"genelToplam"}],
  "parametreler":{"belgeTarihi":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"oncekiYil","esik":0}$j$),

('std-acik-siparis-satirlari', 'Açık sipariş satırları',
 'Kalan miktarı olan sipariş satırları; belge türüne göre gruplu, kalan toplamlı.',
 'belge-acik-satir', 1, '', $j${
  "kaynak":"belge-acik-satir","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"kalanMiktar","op":"buyuk","deger":0},
    {"alan":"belgeTarihi","op":"arasinda","deger":["",""]}]},
  "kolonlar":["belgeTarihi","belgeTurAdi","belgeNo","tarafUnvan","stokKodu","stokAdi","miktar","kapatilanMiktar","kalanMiktar","birimFiyat"],
  "sirala":[{"alan":"belgeTarihi","yon":"asc"}],
  "toplam":["miktar","kapatilanMiktar","kalanMiktar"],"grup":["belgeTurAdi"],
  "parametreler":{"belgeTarihi":{"ad":"Sipariş tarihi","kural":"buYil"}},
  "kiyas":"yok","esik":0}$j$);

insert into public.dokum_tanimi
    (kod, ad, aciklama, kaynak, tanim, surum, sahip_id, gorunurluk, roller, aktif,
     sistem, urun_modu, modul, ekleyen, degistiren)
select s.kod, s.ad, s.aciklama, s.kaynak, s.tanim, 1, null, 2, '{}', 1, 1, s.urun_modu, s.modul, 0, 0
  from _std s
on conflict (kod) do update
   set ad = excluded.ad, aciklama = excluded.aciklama, kaynak = excluded.kaynak,
       tanim = excluded.tanim, urun_modu = excluded.urun_modu, modul = excluded.modul,
       aktif = 1, surum = public.dokum_tanimi.surum + 1, degistirme_tarihi = now()
 where public.dokum_tanimi.sistem = 1;

drop table _std;

do $$
begin
    raise notice '688 tamam: % standart dokum.', (select count(*) from public.dokum_tanimi where sistem = 1);
end $$;
