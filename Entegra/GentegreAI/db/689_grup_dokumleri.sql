-- ============================================================================
--  Gentegre AI — HER MENÜ GRUBUNA DÖKÜM (689)
--  689_grup_dokumleri.sql
--
--  Kullanıcı: "menüleri ideal mockup gibi yap.. oradaki menü aralarındaki
--  dökümler kısmına da ilgili dökümleri ekle"
--
--  Menü yeniden düzenlendi (plan dokuman/11): her grubun sonunda **📊 Dökümler**
--  var ve o grubun kaynaklarına ait kayıtlı dökümleri gösteriyor. 688 sekiz
--  kaynağı kapsıyordu; altı grup BOŞ açılıyordu - boş açılan bir "Dökümler"
--  öğesi kullanıcıya yanlış söz vermektir.
--
--  Eklenen gruplar: Kurumlar & Sigorta · Cari & CRM · Alış · Üretim ·
--  Muhasebe · İK & Prim.
--
--  688 ile AYNI KURALLAR:
--   · Döküm kurum geneli (gorunurluk = 2) ve sahipsiz; kaynak yetkisi süzer.
--   · Modül kapalıysa dökümü de kaybolur (`modul` kolonu).
--   · Kod sabittir; yeniden çalıştırılınca AD/TANIM güncellenir, kullanıcının
--     kendi kopyası (farklı kod) dokunulmaz.
--   · Tarih parametreleri BOŞ aralık + `kural` ile gelir: döküm açılınca
--     "bu ay" / "bugün" kendiliğinden dolar, kullanıcı tarih yazmak zorunda
--     kalmaz.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

create temporary table _std689 (
    kod varchar(60), ad varchar(160), aciklama varchar(400), kaynak varchar(40),
    urun_modu smallint, modul varchar(40), tanim jsonb
) on commit drop;

insert into _std689 values

-- ------------------------------------------------ Kurumlar & Sigorta (HBYS)
('std-kurum-icmal-donem', 'Kurum icmalleri (dönem)',
 'Seçilen dönemdeki kurum icmalleri: kurum, dönem, satır sayısı, tutar ve durum.',
 'kurum-icmal', 2, '', $j${
  "kaynak":"kurum-icmal","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"donemBas","op":"arasinda","deger":["",""]}]},
  "kolonlar":["kurumAdi","donemBas","donemBit","satirSayisi","toplam","durumAdi"],
  "sirala":[{"alan":"donemBas","yon":"desc"}],
  "toplam":["toplam"],"grup":["kurumAdi"],
  "parametreler":{"donemBas":{"ad":"Dönem","kural":"buAy"}},
  "kiyas":"yok","esik":0}$j$),

-- ------------------------------------------------------- Cari & CRM (ERP)
('std-cari-liste', 'Cari listesi (kategoriye göre)',
 'Müşteri ve tedarikçiler; kategori kırılımında adet. İletişim bilgisi eksik olanlar görünür.',
 'cari', 1, '', $j${
  "kaynak":"cari","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"durum","op":"esit","deger":1}]},
  "kolonlar":["kod","unvan","vkno","telefon","eposta","il","kategori","temsilci"],
  "sirala":[{"alan":"unvan","yon":"asc"}],
  "toplam":[],"grup":["kategori"],
  "parametreler":{},
  "kiyas":"yok","esik":0}$j$),

-- ------------------------------------------------------------- Alış (ERP)
-- Alis faturasi = belge turu 10 (gelen fatura). Basvuru (19) ile ayni kaynak,
--   ayiran sey TUR filtresidir.
('std-alis-aylik', 'Aylık alış özeti',
 'Tedarikçi × ay: fatura adedi ve tutar; önceki yılla kıyaslı.',
 'belge', 1, 'erp_satis', $j${
  "kaynak":"belge","cikti":"ozet",
  "filtre":{"op":"and","kosullar":[
    {"alan":"tur","op":"esit","deger":10},
    {"alan":"belgeTarihi","op":"arasinda","deger":["",""]},
    {"alan":"durum","op":"esitDegil","deger":6}]},
  "boyut":{"satir":["cariUnvan"],"sutun":"belgeTarihi:ay"},
  "olcu":[{"alan":"id","fn":"adet","ad":"Fatura"},
          {"alan":"genelToplam","fn":"toplam","ad":"Tutar"}],
  "parametreler":{"belgeTarihi":{"ad":"Dönem","kural":"buYil"}},
  "kiyas":"gecenYil","esik":0}$j$),

-- ---------------------------------------------------------- Üretim (ERP)
('std-uretim-emir-durum', 'Üretim emirleri (durum)',
 'Açık ve kapanan emirler: mamul, adet, üretilen, ilerleme ve termin.',
 'uretim-emri', 1, 'uretim', $j${
  "kaynak":"uretim-emri","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"planBas","op":"arasinda","deger":["",""]}]},
  "kolonlar":["no","mamulAd","adet","uretilenAdet","ilerleme","planBas","termin","turAdi"],
  "sirala":[{"alan":"termin","yon":"asc"}],
  "toplam":["adet","uretilenAdet"],"grup":["turAdi"],
  "parametreler":{"planBas":{"ad":"Plan tarihi","kural":"buAy"}},
  "kiyas":"yok","esik":0}$j$),

-- ----------------------------------------------------------- Muhasebe
('std-muhasebe-fis-donem', 'Muhasebe fişleri (dönem)',
 'Dönemdeki fişler: fiş no, tarih, borç ve alacak toplamları; tür kırılımında ara toplam.',
 'muhasebe-fis', 0, 'muhasebe', $j${
  "kaynak":"muhasebe-fis","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"fisTarihi","op":"arasinda","deger":["",""]}]},
  "kolonlar":["fisNo","fisTarihi","toplamBorc","toplamAlacak"],
  "sirala":[{"alan":"fisTarihi","yon":"desc"}],
  "toplam":["toplamBorc","toplamAlacak"],"grup":[],
  "parametreler":{"fisTarihi":{"ad":"Dönem","kural":"buAy"}},
  "kiyas":"yok","esik":0}$j$),

-- ---------------------------------------------------------- İK & Prim
('std-hakedis-donem', 'Hakedişler (dönem)',
 'Dönem hakedişleri: kişi, dönem, satır sayısı, tutar ve durum.',
 'hakedis', 2, 'prim', $j${
  "kaynak":"hakedis","cikti":"liste",
  "filtre":{"op":"and","kosullar":[
    {"alan":"donemBaslangic","op":"arasinda","deger":["",""]}]},
  "kolonlar":["kisi","donemBaslangic","donemBitis","satirSayisi","toplam","durumAdi"],
  "sirala":[{"alan":"toplam","yon":"desc"}],
  "toplam":["toplam"],"grup":[],
  "parametreler":{"donemBaslangic":{"ad":"Dönem","kural":"buAy"}},
  "kiyas":"yok","esik":0}$j$);

insert into public.dokum_tanimi
    (kod, ad, aciklama, kaynak, tanim, surum, sahip_id, gorunurluk, roller, aktif,
     urun_modu, modul, calisma_sayisi, ekleyen)
select s.kod, s.ad, s.aciklama, s.kaynak, s.tanim, 1, null, 2, '{}', 1,
       s.urun_modu, s.modul, 0, 0
  from _std689 s
on conflict (kod) do update
   set ad = excluded.ad, aciklama = excluded.aciklama, kaynak = excluded.kaynak,
       tanim = excluded.tanim, urun_modu = excluded.urun_modu, modul = excluded.modul;

do $$
declare v_toplam integer; v_kaynak text;
begin
    select count(*) into v_toplam from public.dokum_tanimi where aktif = 1;
    select string_agg(distinct kaynak, ', ' order by kaynak) into v_kaynak
      from public.dokum_tanimi where aktif = 1;
    raise notice '689 tamam: % dokum · kaynaklar: %', v_toplam, v_kaynak;
end $$;

commit;
