-- =====================================================================
--  630_baslik_harf.sql
--  KOD LİSTELERİNİN GÖRÜNEN ADLARI BAŞLIK HARFİNE ÇEVRİLİR.
--
--  SKRS listeleri tamamı BÜYÜK HARF gelir ("ERKEK", "İÇ HASTALIKLARI").
--  Ekranda bağırıyor gibi duruyor; istenen her yerde "Erkek",
--  "İç Hastalıkları".
--
--  İKİ FARKLI METİN OLDUĞU KABUL EDİLİYOR:
--    * `kod_deger.ad`      -> EKRANDA görünen ad (başlık harfi)
--    * `kod_deger.skrs_ad` -> SKRS'nin KENDİ metni (e-Nabız `value` alanı)
--  613'te konan ilke: "gönderdiğimiz metin SKRS'nin kendi metni olmalı -
--  paketi okuyan insan bizim sözcüğümüzü değil kendi listesindeki adı
--  görmeli". `ad`ı güzelleştirip aynı kolonu pakete de koyarsak o ilke
--  kırılırdı; ham metin ayrı kolonda saklanıyor ve `fn_skrs_ad` /
--  `fn_skrs_hedef_ad` ONU döndürüyor.
--
--  DOKUNULMAYANLAR:
--    * Zaten küçük harf içeren adlar (elle yazılmış / müşterinin
--      düzenlediği kayıt). Koşul `ad = upper(ad)`: yalnız tamamı büyük
--      olan satır değişir, müşteri yazımı korunur.
--    * `icd` (15.799) ve `hizmet` (9.825) katalogları. Bunlar ICD-10 ve
--      SUT'un YAYIMLANMIŞ metinleri, uzun tıbbi cümleler; hekim resmî
--      yazımıyla arar ve karşılaştırır. Alan/açılır liste değiller.
--
--  BÜYÜK HARFTE "I" BELİRSİZDİR. "KIRMIZI" küçüğe "kırmızı", "GIZLI"
--  ise "gizli" iner - harf aynı, sesi farklı. SKRS metinlerinde noktalı
--  İ yerine düz I yazılmış YÜZLERCE kelime var ("BELIRTILMEMIŞ",
--  "RADYOLOJI", "MÜLTECI"). Büyük harfte göze batmıyordu, başlık
--  harfinde batar ("Radyolojı"). Türkçe kuralla (ünlü uyumu) ayırmak
--  işe yaramıyor: "acentası" uyuma uyar ama "cerrahi", "mimari",
--  "alerji" gibi alıntı kökler uymaz. Bu yüzden istisna LİSTEYLE
--  veriliyor; liste `taraf.meslek` DIŞINDAKİ bütün listelerin I içeren
--  kelimeleri tek tek gözden geçirilerek çıkarıldı. 5.461 satırlık ISCO
--  meslek listesinde gözden kaçan kelime kalmış olabilir - orada da
--  hatanın kaynağı SKRS'nin yazımı, düzeltmesi bu listeye eklemektir.
-- =====================================================================

-- ---------------------------------------------------------------- kelime
--  Tek kelimeyi başlık harfine çevirir: küçült, ilk harfi büyüt, ayırıcı
--  sonrasını da büyüt. KESME İŞARETİ AYIRICI DEĞİL - Türkçe'de
--  "TÜRKİYE'DE" başlık harfiyle "Türkiye'de"dir, "Türkiye'De" değil.
--
--  Türkçe i/ı: `lower('IŞIK')` = 'ışık', `upper('ı')` = 'I' (veritabanı
--  ICU tr-TR). Bu yüzden önce KÜÇÜLTÜP sonra büyütmek şart - ilk harfi
--  olduğu gibi bırakıp gerisini küçültmek "IŞIK" için "Işık" veremezdi.
create or replace function public.fn_baslik_kelime(p_kelime text)
returns text
language plpgsql stable as $govde$
declare
    -- I'si NOKTALI okunan kelimeler; küçültmeden önce I -> İ yapılır.
    k_i_nokta constant text[] := array[
        'ACIL','ADLI','AILE','AKTIVITE','AKTIVITELER','ALERJI','ALGOLOJI',
        'ANATOMI',
        'ANESTEZIYOLOJI','ASKERI','ASKERLIĞE','BAHÇECİLIK','BELIRTILMEMIŞ',
        'BEYIN','BIYOKIMYA','BÜYÜKELÇİLIK','CEKKREDI','CERRAHI','CERRAHISI',
        'CINSIYET','ÇİFTÇİLIK','ÇİFTLIK','DEMIRBAS','DEMOKRATIK','DENİZCİLIK',
        'DERI','DIGER','DIĞER','DİŞÇİLIK','EKOLOJI','ELÇİLIK','ELVERIŞLI','EMEKLI',
        'EMBRIYOLOJI','ENDODONTI','ENDOKRINOLOJI','ENDOKRINOLOJISI',
        'ENFEKSIYON','EPIDEMIYOLOJI','ESTETIK','FARMAKOLOJI','FIZIKSEL',
        'FIZYOLOJI','GASTROENTEROLOJI','GASTROENTEROLOJISI','GAZETECİLIK',
        'GECMIS','GELIRAD','GELIŞIMSEL','GENETIK','GERI','GERIATRI','GIZLI',
        'GÜVENLIK','GÜZELLIK','HEKIMLIĞI','HEMATOLOJI','HEMATOLOJISI',
        'HEMŞİRELIK','HIDROKLIMATOLOJI','HIPERBARIK','HISTOLOJI','HIZMETLERI',
        'ILAHİYAT','IMAJ','INGİLTERE','INSAN','INŞAAT','ISPİRTO','ISTATİSTİK',
        'IŞ','IŞLETME','IZOLASYON','İLETIŞİM','İMMÜNOLOJI','İMMÜNOLOJISI',
        'JINEKOLOJIK','KARDIYOLOJI','KARDIYOLOJISI','KLINIK','KLINIĞI',
        'KREDILER','KREDIROTATIF','KÜTÜPHANECİLIK','MADENCİLIK','MAKİNESI',
        'MASRAFGELIR','MERKEZI','METABOLIZMA','MIKOLOJI','MIKROBIYOLOJI',
        'MİMARI','MÜFETTIŞ','MÜFETTIŞİ','MÜHENDİSLIK','MÜLTECI','NEFROLOJI',
        'NEFROLOJISI','NEONATOLOJI','NÖROFIZYOLOJI','NÖROLOJI','NÖROLOJISI',
        'ONKOLOJI','ONKOLOJISI','ORTODONTI','ORTOPEDI','ÖGRENCI','PALYATIF',
        'PARAZITOLOJI','PATOLOJI','PEDIATRI','PERIFERIK','PERINATOLOJI',
        'PERIODONTOLOJI','PERSONELI','PERSONELIZIN','PLANKREDI','PLASTIK',
        'POLIKLINIĞI','PROTETIK','PSIKIYATRI','RADYOLOJI','RADYOLOJISI',
        'REANIMASYON','REHABILITASYON','REKONSTRÜKTIF','RESTORATIF',
        'ROMATOLOJI','ROMATOLOJISI','SEBEBI','SEKRETERLIK','SERVIS',
        'SIGARAYI','SIPARISDETAY','SITOPATOLOJI','TALIMATLAR','TARIHI',
        'TEDAVISI',
        'TEFTIŞİ','TEKLIF','TEMINATMEKTUBU','TRAVMATOLOJI','URETIM',
        'ÜNITESI','ÜROLOJI','ÜROLOJISI','VETERİNERLIK','VIROLOJI',
        'YENIDOĞAN','YETIŞKİNLERE','YETIŞTİREN','YETIŞTİRİCİLİĞİ',
        'YETIŞTİRİCİSİ','YETIŞTİRME','YÖNELIK','ZÜHREVI',
        -- Yabancı kelime / firma adı: Türkçe küçültme I'yi ı yapar,
        --   "Industrıal" çıkardı.
        'ACNIS','AMSONIC','BRODOLINI','CHIMICA','COVID','EGMEDICAL','ETIGAM',
        'INC','INDUSTRIAL','INDUSTRIES','INDUSTRY','INTERNATIONAL','IONBOND',
        'JINGOIA','JINHU','KONFORMITATSBEWERTUNGSSTELLE','LABORATORIES',
        'LIMITED','MEDICAL','NIU','OBELIS','PACIFIC','RICERCA','SERINO',
        'SHAANXI','TECNOLOGIES','TITANIUM','TIVA','TRADING','VIA','VIDEOJET'];

    -- İçinde HEM ı HEM i geçen kelimeler - harf harf kural yetmez, tam
    --   karşılığı yazılır ("TIBBI" = tıbbi, ilk I ı, ikinci I i).
    k_tam_anahtar constant text[] := array[
        'TIBBI','MILLETLERARASI','IMALATI','KREDIKARTI','PLANKREDIKARTI',
        'HAZIRLANMİŞ'];
    k_tam_karsilik constant text[] := array[
        'tıbbi','milletlerarası','imalatı','kredikartı','plankredikartı',
        'hazırlanmış'];

    duz    text := '';
    kosu   text := '';
    sonuc  text := '';
    ch     text;
    i      integer;
    yer    integer;
    basla  boolean := true;

begin
    -- 1. GEÇİŞ: harf kümelerini istisnalara göre düzelt.
    for i in 1 .. length(p_kelime) + 1 loop
        ch := case when i <= length(p_kelime) then substr(p_kelime, i, 1) else '' end;
        if ch <> '' and ch ~ '[[:alpha:]]' then
            kosu := kosu || ch;
        else
            if kosu <> '' then
                yer := array_position(k_tam_anahtar, kosu);
                if yer is not null then
                    kosu := k_tam_karsilik[yer];
                elsif kosu = any(k_i_nokta) then
                    kosu := replace(kosu, 'I', 'İ');
                end if;
                duz  := duz || kosu;
                kosu := '';
            end if;
            duz := duz || ch;
        end if;
    end loop;

    -- 2. GEÇİŞ: küçült, ilk harfi ve ayırıcı sonrasını büyüt.
    duz := lower(duz);
    for i in 1 .. length(duz) loop
        ch := substr(duz, i, 1);
        if basla and ch ~ '[[:alpha:]]' then
            sonuc := sonuc || upper(ch);
            basla := false;
        else
            sonuc := sonuc || ch;
        end if;
        if ch in ('(', '[', '{', '/', '-', ',', '.', ':', ';', '&') then
            basla := true;
        end if;
    end loop;
    return sonuc;
end $govde$;

-- ----------------------------------------------------------------- metin
create or replace function public.fn_baslik_harf(p_metin text)
returns text
language plpgsql stable as $govde$
declare
    -- OLDUĞU GİBİ KALIR. Listeye ancak veride GERÇEKTEN geçen ve gerçek
    --   Türkçe kelimeyle çakışmayan kısaltma girer: "ADET" (adet), "ARK"
    --   (ark) gibi sözcükler bilerek DIŞARIDA - onları korumak "1 ADET"
    --   gibi sıradan metni bozardı. "TIP"/"TIBBİ" de kısaltma değil.
    k_kisaltma constant text[] := array[
        'AB','ADSL','AFAD','AMATEM','AŞ','BT','CHF','CNC','CRM','ÇEMATEM',
        'DDY','EEG','EKG','ERP','EUR','GBP','GN','GSS','İK','İNŞ','İŞL',
        'KDV','KGM','KVC','KWH','LTD','LTR','MHRS','MR','MTR','MÜH','ORG',
        'OSB','ÖSS','PC','POS','PVC','RH','SAN','SGK','SMS','SSK','SUT',
        'ŞTİ','TIR','TİC','TİKA','TL','TTB','TV','USD','USG','XL','XXL',
        'YRD',
        -- Ölçüm/işlem kısaltmaları ve unvanlar
        'ARGE','CD','CEO','DEXA','DVD','HUV','ICD','ICF','İV','SKT',
        -- Roma rakamı: "EVRE III", "TİP II". Tek harfliler (I, V, X, C,
        --   L, D, M) alınmadı - kelime olma ihtimalleri var.
        'II','III','IV','VI','VII','VIII','IX','XI','XII'];
    -- BAŞTA DEĞİLSE KÜÇÜK: Türkçe başlık yazımında bağlaç küçüktür -
    --   "Kadın Hastalıkları ve Doğum".
    k_kucuk constant text[] := array['VE','İLE','VEYA','VB','VS'];

    -- BAĞLAMA GÖRE OKUNAN KELİMELER. "DIŞ" kliniklerde DİŞ (ağızdaki),
    --   başka listede dış (haricî); "SINIR" beyin cerrahisinde SİNİR,
    --   meslek listesinde sınır (hudut). Kelime tek başına yetmiyor, o
    --   yüzden düzeltme İFADE düzeyinde - yalnız bu tamlamalarda.
    k_ifade_anahtar constant text[] := array[
        'AĞIZ, DIŞ VE ÇENE', 'DIŞ HEKIMLIĞI', 'GENEL DIŞ', 'DIŞ TEDAVISI',
        'VE SINIR CERRAHISI'];
    k_ifade_karsilik constant text[] := array[
        'AĞIZ, DİŞ VE ÇENE', 'DİŞ HEKIMLIĞI', 'GENEL DİŞ', 'DİŞ TEDAVISI',
        'VE SİNİR CERRAHISI'];

    kelimeler text[];
    kelime    text;
    cekirdek  text;
    sonuc     text := '';
    i         integer;
begin
    if p_metin is null or p_metin = '' then
        return p_metin;
    end if;
    -- Küçük harf varsa metne elle dokunulmuş demektir; olduğu gibi kalır.
    if p_metin <> upper(p_metin) then
        return p_metin;
    end if;

    for i in 1 .. coalesce(array_length(k_ifade_anahtar, 1), 0) loop
        p_metin := replace(p_metin, k_ifade_anahtar[i], k_ifade_karsilik[i]);
    end loop;

    kelimeler := regexp_split_to_array(p_metin, ' ');
    for i in 1 .. coalesce(array_length(kelimeler, 1), 0) loop
        kelime   := kelimeler[i];
        cekirdek := regexp_replace(kelime, '[^[:alpha:]]', '', 'g');
        if cekirdek = '' then
            null;                                   -- sayı / noktalama
        elsif cekirdek = any(k_kisaltma) then
            null;                                   -- kısaltma
        elsif i > 1 and cekirdek = any(k_kucuk) then
            kelime := lower(kelime);
        else
            kelime := public.fn_baslik_kelime(kelime);
        end if;
        sonuc := case when i = 1 then kelime else sonuc || ' ' || kelime end;
    end loop;
    return sonuc;
end $govde$;

comment on function public.fn_baslik_harf(text) is
  '630: BUYUK HARF metni Turkce baslik harfine cevirir (kisaltma, baglac '
  've noktali-I istisnalari korunur). Kucuk harf iceren metne dokunmaz.';

-- ------------------------------------------------------------ ham metin
alter table public.kod_deger
    add column if not exists skrs_ad varchar(200) not null default '';

comment on column public.kod_deger.skrs_ad is
  '630: SKRS listesindeki HAM ad (BUYUK HARF). e-Nabiz paketlerinde '
  '`value` olarak bu gider; `ad` ekranda gorunen baslik-harfli surumdur.';

-- SKRS'den birebir doldurulmuş listelerde bugünkü `ad` zaten SKRS'nin
--   metnidir - çevirmeden ÖNCE kopyalanır.
update public.kod_deger d
   set skrs_ad = d.ad
  from public.kod_liste l
 where l.id = d.liste_id
   and l.skrs_liste <> ''
   and d.skrs_ad = ''
   and d.ad <> '';

-- ---------------------------------------------------------------- yedek
drop table if exists public._yedek_kod_deger_ad_630;
create table public._yedek_kod_deger_ad_630 as
select liste_id, deger, dil, ad from public.kod_deger;

-- --------------------------------------------------------------- çevrim
--  `liste_NNNN` DIŞARIDA. Onlar eski Delphi kurulumundan göçen MÜŞTERİ
--  listeleri: firma unvanları, markalar, kendi kod tablolarındaki
--  yazımları. Müşterinin girdiği metni güzelleştirmek bizim işimiz
--  değil ("asla müşterinin bilerek yapılandırdığı bir kolonu topluca
--  ezme"). Çevrilen, programın/SKRS'nin sahibi olduğu adlandırılmış
--  listeler.
update public.kod_deger d
   set ad = public.fn_baslik_harf(d.ad)
  from public.kod_liste l
 where l.id = d.liste_id
   and l.kod not like 'liste\_%'
   -- KOD LİSTESİ, KELİME LİSTESİ DEĞİL: ana birim UN/ECE ölçü
   --   kodları (AD, CS, PK, ZZ), marka ise tescilli ad.
   and l.kod not in ('stok.ana_birim', 'stok.marka')
   and d.ad = upper(d.ad)
   and d.ad ~ '[[:alpha:]]'
   and d.ad <> public.fn_baslik_harf(d.ad);

-- ------------------------------------------------------- paket metinleri
--  `value` alanı SKRS'nin ham metnini taşımaya devam eder; ham metin
--  yoksa (yerelden ÇEVRİLEN listeler) eskisi gibi yerel ada düşülür.
create or replace function public.fn_skrs_ad(p_liste text, p_deger integer)
returns varchar
language sql stable as $govde$
    select coalesce(nullif(d.skrs_ad, ''), d.ad, '')
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = p_liste and d.deger = p_deger and d.dil = 0
$govde$;

create or replace function public.fn_skrs_hedef_ad(p_liste text, p_deger integer)
returns varchar
language sql stable as $govde$
    with kaynak as (
        select d.skrs_kod, coalesce(nullif(d.skrs_ad, ''), d.ad) as yerel_ad,
               l.skrs_liste
          from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = p_liste and d.deger = p_deger and d.dil = 0
    )
    select coalesce(
        (select coalesce(nullif(hd.skrs_ad, ''), hd.ad)
           from kaynak k
           join public.kod_liste hl on hl.skrs_liste = k.skrs_liste
           join public.kod_deger hd on hd.liste_id = hl.id and hd.dil = 0
                                   and hd.skrs_kod = k.skrs_kod
                                   and hd.deger::varchar = hd.skrs_kod
          limit 1),
        (select k.yerel_ad from kaynak k),
        '')
$govde$;

comment on function public.fn_skrs_ad(text, integer) is
  '630: yerel kod degerinin SKRS metni (skrs_ad), yoksa listedeki adi.';
comment on function public.fn_skrs_hedef_ad(text, integer) is
  '630: degerin SKRS kod sistemindeki HAM adi (value alani).';

do $kontrol$
declare
    v_degisen integer;
begin
    select count(*) into v_degisen
      from public._yedek_kod_deger_ad_630 y
      join public.kod_deger d on d.liste_id = y.liste_id
                             and d.deger = y.deger and d.dil = y.dil
     where d.ad <> y.ad;
    raise notice '630: % ad baslik harfine cevrildi', v_degisen;
    raise notice '630 ornek: cinsiyet 1 -> % (pakete giden: %)',
        (select d.ad from public.kod_deger d
           join public.kod_liste l on l.id = d.liste_id
          where l.kod = 'hasta.cinsiyet' and d.deger = 1 and d.dil = 0),
        public.fn_skrs_ad('hasta.cinsiyet', 1);
end $kontrol$;
