-- =============================================================================
--  1175  SATIŞ / ALIŞ / İRSALİYE-FATURA EŞLEŞME / TAHSİLAT-ÖDEME / ÇEK-SENET /
--        NAKİT AKIŞ (VADE) İCMALLERİ
--
--  Kullanıcı (25.10.2026): mockup'ları (Ekranlar/İcmal/satis_icmali.html, alis_icmali.html,
--  irsaliye_fatura_eslesme_icmali.html, tahsilat_odeme_icmali.html, cek_senet_icmali.html,
--  nakit_akis_icmali.html) onaylanan kararlarla kodla. Uçlar TicariIcmalUclari,
--  EslesmeIcmalUclari, FinansIcmalUclari (+ .CekSenet).
--
--  1) Ekran kodları (1003 ilkesi: bir kod bir menü ekranı) - hakları ilgili listenin
--     kodundan KOPYALANIR (o listeyi gören rol icmali de görür; kimse yetki kazanmaz /
--     kaybetmez), yalnız Gör; var olan rol_yetki satırına dokunulmaz:
--       satis.icmali               <- belge.satis.fatura (Satış Faturası Listesi)
--       alis.icmali                <- belge.alis_fatura  (Alış Faturası Listesi)
--       irsaliye_fatura_eslesme    <- efatura.icmal      (Fatura / e-Belge İcmali kitlesi)
--       finans.tahsilat_odeme_icmali, finans.nakit_akis_icmali <- kasa.finans (Cari İcmali 1154 ile aynı kaynak)
--       finans.cek_senet_icmali    <- cek_senet.liste    (Çek Listesi)
--     Eşleşme ekranındaki "Bağla" ayrı kod istemez: belge Değiştir + tür izni (PUT /api/belge ile aynı).
--  2) Asistan ekran kataloğu (ai_rehber_ekran). Ekranın "ne yapılır" metni
--     dokuman/yardim/icmal-*.md belgelerindedir.
--  3) Finans icmallerinin yolu menüdeki yeni "İcmaller" alt başlığına uydurulur
--     (yalnız eski metin hâlâ duruyorsa).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40))
  on commit drop;
insert into _bolme values
  ('satis.icmali',                  'belge.satis.fatura', 'Satış İcmali (Satış)',                     'Satış'),
  ('alis.icmali',                   'belge.alis_fatura',  'Alış İcmali (Alış)',                       'Alış'),
  ('irsaliye_fatura_eslesme',       'efatura.icmal',      'İrsaliye-Fatura Eşleşme İcmali (Satış)',   'Satış'),
  ('finans.tahsilat_odeme_icmali',  'kasa.finans',        'Tahsilat / Ödeme İcmali (Finans)',         'Finans'),
  ('finans.nakit_akis_icmali',      'kasa.finans',        'Nakit Akış (Vade) İcmali (Finans)',        'Finans'),
  ('finans.cek_senet_icmali',       'cek_senet.liste',    'Çek / Senet İcmali (Finans)',              'Finans');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1175: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, 0, 0, 0, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.grup, v.baslik, v.yetki_kodu, v.urun_modu, v.anahtar, v.aciklama, ''
  from (values
    ('satis-icmali', '/satis-icmali', 'Satış İcmali', 'Satış › İcmaller › Satış İcmali', 'Satış', 'satis.icmali', 1::smallint,
     'satış icmal ciro net satış müşteri bazında ürün bazında brüt kâr marj iskonto iade geçen yıl karşılaştırma trend temsilci kategori döviz kur farkı maliyet altı zararına satış kayıp müşteri faturası kesilmemiş irsaliye e-fatura gönderilmemiş',
     'Dönemde müşteri ve ürün bazında net satış, iskonto, iade, brüt kâr ve geçen yılla karşılaştırma; 12 aylık trend, temsilci / kategori / şube / belge türü / para birimi kırılımları ve '
     || 'maliyet altı satış, düşen müşteri, faturası kesilmemiş irsaliye, gönderilmemiş e-Belge uyarıları.'),
    ('alis-icmali', '/alis-icmali', 'Alış İcmali', 'Alış › İcmaller › Alış İcmali', 'Alış', 'alis.icmali', 1::smallint,
     'alış icmal satınalma tedarikçi bazında ürün bazında net alış fiyat gelişimi fiyat artışı teslim süresi açık borç vadesi gelen hizmet alımı döviz kur farkı sözleşme fiyatı ucuz tedarikçi faturası gelmemiş irsaliye geciken sipariş gelen e-fatura kutusu',
     'Dönemde tedarikçi ve ürün bazında net alış, iade, geçen yılla karşılaştırma, teslim süresi ve açık borç; aynı kalemin fiyat gelişimi, aylık alış / satılan malın maliyeti ve '
     || 'sözleşme üstü alış, daha ucuz tedarikçi, faturası gelmemiş irsaliye, geciken sipariş, gelen kutusunda bekleyen fatura uyarıları.'),
    ('irsaliye-fatura-eslesme', '/irsaliye-fatura-eslesme', 'İrsaliye-Fatura Eşleşme İcmali', 'Satış › İcmaller › İrsaliye-Fatura Eşleşme İcmali', 'Satış', 'irsaliye_fatura_eslesme', 1::smallint,
     'irsaliye fatura eşleşme icmal faturalanmamış irsaliye faturasız kısmi fazla faturalanan fiyat farkı irsaliyesiz fatura mükerrer stok çıkışı bağla faturala dönüştür vuk 7 gün süre aşımı konsinye e-irsaliye yanıt ay sonu kapanış',
     'Satış ve alış irsaliyelerinin satır bazında faturalanma durumu: faturası kesilmemiş (VUK 7 gün, konsinye muaf, e-İrsaliye yanıtı), kısmi / fazla / fiyatı farklı faturalanan, '
     || 'stoğu iki kez düşürmüş olabilecek irsaliyesiz faturalar; seçilenleri faturaya dönüştürme, irsaliyesiz faturayı açık irsaliyeye bağlama, cari bazında özet.'),
    ('tahsilat-odeme-icmali', '/tahsilat-odeme-icmali', 'Tahsilat / Ödeme İcmali', 'Finans › İcmaller › Tahsilat / Ödeme İcmali', 'Finans', 'finans.tahsilat_odeme_icmali', 0::smallint,
     'tahsilat ödeme icmal ödeme aracı havale eft pos kredi kartı çek senet nakit dağıtılmamış tahsil süresi tahsil eden temsilci komisyon virman iade iptal',
     'Dönemde kimden ne tahsil edildi, kime ne ödendi: ödeme aracına, cariye, kasa / banka hesabına ve tahsil edene göre; '
     || 'tahsilat / satış oranı, ortalama tahsil ve ödeme süresi, faturaya dağıtılmamış tahsilat, iade / iptal, vadesi geçmiş ödemeler.'),
    ('cek-senet-icmali', '/cek-senet-icmali', 'Çek / Senet İcmali', 'Finans › İcmaller › Çek / Senet İcmali', 'Finans', 'finans.cek_senet_icmali', 0::smallint,
     'çek senet icmal portföy bankada tahsilde teminat ciro rücu karşılıksız protesto vade takvimi keşideci muhatap banka verilen çek hesap bakiyesi karşılık döviz kur farkı',
     'Alınan ve verilen çek / senetlerin durumu (portföy, bankada tahsilde, teminatta, ciro edilmiş, karşılıksız), vade takvimi, keşideci ve banka yoğunlaşması, '
     || 'dövizli evrakın bugünkü kurla TL değeri ve kur farkı, verilen çeklerin vade günündeki banka hesabı karşılığı.'),
    ('nakit-akis-icmali', '/nakit-akis-icmali', 'Nakit Akış (Vade) İcmali', 'Finans › İcmaller › Nakit Akış (Vade) İcmali', 'Finans', 'finans.nakit_akis_icmali', 0::smallint,
     'nakit akış vade tahmin haftalık aylık bakiye eksi en düşük nokta beklenen tahsilat ödeme çek senet kredi taksit maaş döviz pozisyonu senaryo kmh',
     'Bugünkü kasa + banka bakiyesinden önümüzdeki 30 / 90 / 180 gün ya da 12 ayın haftalık / aylık beklenen giriş, çıkış ve kapanışı; '
     || 'en düşük nokta, döviz pozisyonu, planlı gider tanımı ve görünüm amaçlı senaryolar (gecikme, gerçekleşme oranı, erteleme).'))
    as v(kaynak, rota, baslik, yol, grup, yetki_kodu, urun_modu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

-- Finans icmalleri menüde "İcmaller" alt başlığında (25.10.2026).
update public.ai_rehber_ekran e
   set yol = 'Finans › İcmaller › ' || substr(e.yol, length('Finans › ') + 1)
 where e.kaynak in ('cari-icmali', 'alacak-yaslandirma', 'kasa-gun-sonu', 'maliyet-icmali', 'efatura-icmal')
   and e.yol like 'Finans › %' and e.yol not like 'Finans › İcmaller › %';

commit;
