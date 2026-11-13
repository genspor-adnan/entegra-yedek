-- 1332 - Tek A4 radyoloji şablonları Bakanlık dört parçasına bölünür
--
-- Kullanıcı 13.11.2026: "şablon göçünü yaz.. eski yazılmış raporları göndermeyeceğiz.. tek parça olarak kalabilir
-- bundan sonrakileri göndereceğiz.. bakanlığın istediği 4 parça esas olmalı".
--
-- NEDEN: Bakanlık TeleRadyoloji ORU'su gövdeyi dört parça ister (809; OBX-5 ^1 Teknik · ^2 Karşılaştırma · ^3 Bulgular
--   ≥ 50 karakter · ^4 Sonuç ve Öneriler; ^3 / ^4 yoksa ret). Eski HBYS'den aktarılan şablonlar (esle.sql, HAZOLE) TEK
--   bölüm "Rapor" (parça 0) idi - bu şablonla yazılan rapor Bakanlık'a hiç gidemezdi. Ölçüm (KOSUYOLU, 338 şablon):
--   325'inde "Sonuç:", 262'sinde "Bulgular:", 195'inde "Teknik:" başlığı var.
--
-- KURAL TEK: web'deki "☰ Başlıklardan böl" (web/src/sayfalar/radyoloji/sablonBolme.ts · bakanligaBol) ile AYNI -
--   üst düzey paragraf "BAŞLIK" ya da "Başlık: devamı" ise yeni bölüm başlar; başlıktan önceki ve başlığı tanınmayan
--   metin Bulgular'a; Klinik bilgi ayrı bölüm (parça değil). Dört parça HER ZAMAN yazılır (boşu boş).
--   Eski Word baskısından kalanlar atılır (sablonBolme.ts ile aynı üç kural):
--     * ilk başlıktan ÖNCE eski yer tutuculu blok (@ADSOYAD, @TETKIK ... - web'de hiçbir yerde dolmaz; hasta üst
--       bilgisi rapor çıktısının kendi başlığında),
--     * yalnız "Sayın Meslektaşım," olan paragraf,
--     * "Saygılarımızla / Saygılarımla" ile başlayan paragraf ve sonrası (şablona gömülü hekim adı = yanlış imza).
--   İki uygulama (TS + bu dosya) sözlüğü ve kuralları ortak tutar; değişiklik ikisine birden yapılır
--   (test: SablonBakanlikBolmeTestleri ↔ sablonBolme.test.ts aynı örnekler).
--
-- KAPSAM: yalnız TEK bölümü olan ve o bölüm "Rapor" + parça 0 olan şablonlar (aktarımın yazdığı biçim; web'de "Teke
--   birleştir"in ürettiği de bu). Çok bölümlü / elle parçalanmış şablona dokunulmaz.
--   Yazılmış RAPORLARA dokunulmaz (kullanıcı: eskiler gönderilmeyecek, tek parça kalır).
--
-- GERİ ALMA: her şablonun bugünkü içeriği önce `radyoloji_sablon_surum`a dondurulur (kartta Sürümler → Geri yükle
--   eski tek A4'ü getirir), satırlar ayrıca `yedek_1332_radyoloji_sablon_bolum`da. Şablon `degistirme_tarihi`
--   damgalanır: eski HBYS aktarımı yeniden çalışınca bölünmüş şablonu ezmez.
--
-- Tekrar çalıştırılabilir (ikinci çalışmada tek "Rapor" bölümlü şablon kalmaz).
\set ON_ERROR_STOP on
begin;

-- --------------------------------------------------------------- HTML yardımcıları ----
-- HTML karakter varlıklarını çözer (WebUtility.HtmlDecode'un rapor HTML'inde geçen alt kümesi).
create or replace function public.fn_html_varlik_coz(p text)
returns text language plpgsql immutable as $f$
declare
  s text := coalesce(p, '');
  m text[];
begin
  if strpos(s, '&') = 0 then return s; end if;
  for m in select distinct regexp_matches(s, '&#([0-9]{1,7});', 'g') loop
    if m[1]::int between 1 and 1114111 then
      s := replace(s, '&#' || m[1] || ';', chr(m[1]::int));
    end if;
  end loop;
  for m in select distinct regexp_matches(s, '&#[xX]([0-9a-fA-F]{1,6});', 'g') loop
    s := regexp_replace(s, '&#[xX]' || m[1] || ';', chr(('x' || lpad(m[1], 8, '0'))::bit(32)::int), 'g');
  end loop;
  s := replace(s, '&nbsp;', chr(160));
  s := replace(s, '&ensp;', chr(8194));
  s := replace(s, '&emsp;', chr(8195));
  s := replace(s, '&thinsp;', chr(8201));
  s := replace(s, '&quot;', '"');
  s := replace(s, '&apos;', '''');
  s := replace(s, '&lt;', '<');
  s := replace(s, '&gt;', '>');
  return replace(s, '&amp;', '&');                      -- en son: "&amp;lt;" -> "&lt;" kalmalı
end $f$;

-- Rapor HTML'inden düz metin: RaporHtml.DuzMetin (api/.../Servisler/RaporHtml.cs) ile aynı.
create or replace function public.fn_rad_html_duz(p_html text)
returns text language sql immutable as $f$
  select btrim(public.fn_html_varlik_coz(
           regexp_replace(
             regexp_replace(
               regexp_replace(coalesce(p_html, ''), '</t[dh]>', E'\t', 'gi'),
               E'\\t*(<br\\s*/?>|</(p|div|li|h1|h2|h3|tr)>)', E'\n', 'gi'),
             '<[^>]+>', '', 'g')),
         E' \t\n\r');
$f$;

-- Düz metinden HTML (web duzdenHtml gibi: her satır bir paragraf).
create or replace function public.fn_rad_duzden_html(p_metin text)
returns text language sql immutable as $f$
  select coalesce(string_agg(case when btrim(x) = '' then '<p><br></p>'
                                  else '<p>' || replace(replace(replace(x, '&', '&amp;'), '<', '&lt;'), '>', '&gt;') || '</p>'
                             end, '' order by n), '')
    from regexp_split_to_table(replace(coalesce(p_metin, ''), E'\r', ''), E'\n') with ordinality as t(x, n);
$f$;

-- -------------------------------------------------------------------- başlık sözlüğü ----
-- sablonBolme.ts · baslikBul ile AYNI: sadeleştirilmiş BÜYÜK harf, uzun olan önce. Önek eşleşip ardından ne iki nokta
--   ne satır sonu geliyorsa ("Bulgular ile uyumlu...") başlık DEĞİL ve başka sözcük denenmez.
create or replace function public.fn_rad_baslik_bul(p_metin text, out parca smallint, out kalan text)
language plpgsql immutable as $f$
declare
  t text := btrim(regexp_replace(coalesce(p_metin, ''),
                  '[\s   -     　﻿]+', ' ', 'g'));
  s text;
  b record;
  geri text;
  m text;
begin
  s := translate(upper(t collate "tr-TR-x-icu"), 'ÇĞİÖŞÜ', 'CGIOSU');
  for b in select * from (values
      (1, 'SONUC VE ONERILER', 4), (2, 'SONUC VE ONERI', 4), (3, 'INCELEME TEKNIGI', 1), (4, 'ONCEKI TETKIK', 2),
      (5, 'KLINIK BILGI', 0), (6, 'ENDIKASYON', 0), (7, 'KLINIK', 0),
      (8, 'KARSILASTIRMA', 2), (9, 'TEKNIK', 1), (10, 'BULGULAR', 3), (11, 'BULGU', 3),
      (12, 'SONUC', 4), (13, 'KANAAT', 4), (14, 'IZLENIM', 4), (15, 'ONERILER', 4), (16, 'ONERI', 4), (17, 'YORUM', 4)
    ) v(sira, baslik, parca) order by sira
  loop
    continue when left(s, length(b.baslik)) <> b.baslik;
    geri := substr(t, length(b.baslik) + 1);
    m := substring(geri from '^\s*[:：]\s*(.*)$');
    if m is not null then
      parca := b.parca; kalan := m; return;
    end if;
    if btrim(geri) = '' then
      parca := b.parca; kalan := ''; return;
    end if;
    return;                                              -- önek tuttu ama başlık değil: null
  end loop;
end $f$;

-- -------------------------------------------------------------------------- bölme ----
-- Tek A4 HTML -> bölümler (sablonBolme.ts · bakanligaBol). Klinik bilgi doluysa başta, ardından DÖRT parça her zaman.
create or replace function public.fn_rad_sablon_bol(p_html text)
returns table (sira smallint, baslik varchar, html text, metin text, bakanlik_parca smallint, zorunlu smallint)
language plpgsql immutable as $f$
declare
  kova    text[] := array['', '', '', '', ''];          -- parça 0..4 -> indis 1..5
  etkin   int := 3;                                    -- başlıktan önceki kısım Bulgular'a
  baslik_goruldu boolean := false;
  derinlik int := 0;
  dugum   text := '';                                  -- birikmekte olan üst düzey eleman
  ad      text := '';                                  -- onun etiket adı
  yazi    text := '';                                  -- üst düzey düz metin
  tok     record;
  etiket  text;
  e_ad    text;
  kapanis boolean;
  bos     constant text :=
    '<(p|div)(?:\s[^>]*)?>(?:\s|&nbsp;|<br\s*/?>|<(span|b|i|u)(?:\s[^>]*)?>(?:\s|&nbsp;|<br\s*/?>)*</\2>)*</\1>';
  dugumler text[] := '{}';
  adlar    text[] := '{}';
  i int;
  d text; da text; dm text; ds text;
  bb record;
  k int := 0;
  sonuc text;
begin
  -- 1) ÜST DÜZEY DÜĞÜMLER (DOMParser body.childNodes): metin + etiket belirteçleri sırayla, derinlik sayılarak.
  for tok in select m[1] as metin, m[2] as etiket
               from regexp_matches(coalesce(p_html, ''), '([^<]*)(<[^>]*>)?', 'g') with ordinality as r(m, n)
              order by n
  loop
    if tok.metin <> '' then
      if derinlik = 0 then yazi := yazi || tok.metin; else dugum := dugum || tok.metin; end if;
    end if;
    etiket := tok.etiket;
    continue when etiket is null;
    e_ad := lower(substring(etiket from '^</?([A-Za-z][A-Za-z0-9]*)'));
    if e_ad is null then                               -- <!-- --> vb.: bulunduğu yere yapışır
      if derinlik = 0 then yazi := yazi || etiket; else dugum := dugum || etiket; end if;
      continue;
    end if;
    kapanis := etiket like '</%';
    if derinlik = 0 then
      if yazi <> '' then dugumler := dugumler || yazi; adlar := adlar || ''::text; yazi := ''; end if;
      if kapanis then continue; end if;                -- sahipsiz kapanış: DOM da atar
      if e_ad in ('br', 'img', 'hr', 'wbr', 'col', 'input', 'meta', 'link', 'source') or etiket ~ '/\s*>$' then
        dugumler := dugumler || etiket; adlar := adlar || e_ad;
        continue;
      end if;
      dugum := etiket; ad := e_ad; derinlik := 1;
      continue;
    end if;
    dugum := dugum || etiket;
    if e_ad in ('br', 'img', 'hr', 'wbr', 'col', 'input', 'meta', 'link', 'source') or etiket ~ '/\s*>$' then
      continue;
    end if;
    derinlik := derinlik + case when kapanis then -1 else 1 end;
    if derinlik <= 0 then
      dugumler := dugumler || dugum; adlar := adlar || ad;
      dugum := ''; ad := ''; derinlik := 0;
    end if;
  end loop;
  if dugum <> '' then dugumler := dugumler || dugum; adlar := adlar || ad; end if;   -- kapanmamış: olduğu gibi
  if yazi <> '' then dugumler := dugumler || yazi; adlar := adlar || ''::text; end if;

  -- 2) KOVALAMA
  for i in 1 .. coalesce(array_length(dugumler, 1), 0) loop
    d := dugumler[i]; da := adlar[i];
    dm := public.fn_html_varlik_coz(regexp_replace(d, '<[^>]*>', '', 'g'));          -- textContent
    ds := translate(upper(btrim(regexp_replace(dm,
            '[\s   -     　﻿]+', ' ', 'g')) collate "tr-TR-x-icu"),
            'ÇĞİÖŞÜ', 'CGIOSU');
    -- eski Word baskısı: imza ve sonrası atılır
    exit when ds like 'SAYGILARIM%';
    -- yalnız hitap paragrafı
    continue when ds ~ '^SAYIN MESLEKTASIM[,;:.!]?$';
    -- ilk başlıktan önce eski yer tutuculu üst bilgi (@ADSOYAD ...)
    continue when not baslik_goruldu and dm ~ '@[A-ZÇĞİÖŞÜ]{3,}';
    if da ~ '^(p|div|h[1-6]|li)$' then
      select * into bb from public.fn_rad_baslik_bul(dm);
      if bb.parca is not null then
        etkin := bb.parca; baslik_goruldu := true;
        if btrim(bb.kalan) <> '' then
          kova[etkin + 1] := kova[etkin + 1] || '<p>'
            || replace(replace(replace(btrim(bb.kalan), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') || '</p>';
        end if;
        continue;
      end if;
    end if;
    if da = '' then                                    -- metin düğümü: kaçışlı
      d := replace(replace(replace(dm, '&', '&amp;'), '<', '&lt;'), '>', '&gt;');
    end if;
    if btrim(d) <> '' then kova[etkin + 1] := kova[etkin + 1] || d; end if;
  end loop;

  -- 3) ÇIKTI: baştaki / sondaki boş paragraflar atılır.
  for bb in select * from (values (0, 'Klinik bilgi', 0), (1, 'Teknik', 0), (2, 'Karşılaştırma', 0),
                                  (3, 'Bulgular', 1), (4, 'Sonuç ve öneriler', 1)) v(parca, ad, zor) order by parca
  loop
    sonuc := regexp_replace(kova[bb.parca + 1], '^(?:' || bos || '|\s)+', '');
    sonuc := regexp_replace(sonuc, '(?:' || bos || '|\s)+$', '');
    continue when bb.parca = 0 and sonuc = '';
    k := k + 1;
    sira := k; baslik := bb.ad; html := sonuc; metin := public.fn_rad_html_duz(sonuc);
    bakanlik_parca := bb.parca; zorunlu := bb.zor;
    return next;
  end loop;
end $f$;

comment on function public.fn_rad_sablon_bol(text) is
  '1332: tek A4 şablon HTML''i -> Klinik bilgi (varsa) + Bakanlık dört parçası. Kural web sablonBolme.ts ile aynı.';

-- --------------------------------------------------------------------- uygulama ----
create temp table zz_1332 on commit drop as
select s.id as sablon_id, s.surum, b.id as bolum_id,
       coalesce(nullif(b.varsayilan_html, ''), public.fn_rad_duzden_html(b.varsayilan_metin)) as kaynak
  from public.radyoloji_sablon s
  join public.radyoloji_sablon_bolum b on b.sablon_id = s.id
 where b.baslik = 'Rapor' and coalesce(b.bakanlik_parca, 0) = 0
   and (select count(*) from public.radyoloji_sablon_bolum x where x.sablon_id = s.id) = 1;

create temp table zz_1332_yeni on commit drop as
select z.sablon_id, p.*
  from zz_1332 z cross join lateral public.fn_rad_sablon_bol(z.kaynak) p;

do $$
declare n int; nb int; ns int; nt int; nk int; nbos int;
begin
  select count(*) into n from zz_1332;
  select count(*) filter (where bakanlik_parca = 3 and html <> ''),
         count(*) filter (where bakanlik_parca = 4 and html <> ''),
         count(*) filter (where bakanlik_parca = 1 and html <> ''),
         count(*) filter (where bakanlik_parca = 0)
    into nb, ns, nt, nk from zz_1332_yeni;
  select count(*) into nbos from (select sablon_id from zz_1332_yeni group by sablon_id
                                  having bool_and(html = '')) x;
  raise notice '1332: % tek A4 şablon bölünecek - Bulgular dolu %, Sonuç dolu %, Teknik dolu %, Klinik bilgi %, tamamen boş %',
               n, nb, ns, nt, nk, nbos;
  raise notice '1332: Bulgular ya da Sonuç BOŞ kalan şablonlar radyoloğun elle tamamlaması için (liste aşağıda)';
end $$;

-- yedek
create table if not exists public.yedek_1332_radyoloji_sablon_bolum as
select b.*, now() as yedek_zamani from public.radyoloji_sablon_bolum b where false;
insert into public.yedek_1332_radyoloji_sablon_bolum
select b.*, now() from public.radyoloji_sablon_bolum b
  join zz_1332 z on z.bolum_id = b.id
 where not exists (select 1 from public.yedek_1332_radyoloji_sablon_bolum y where y.id = b.id);

-- bugünkü içerik sürüm olarak dondurulur (RadyolojiUclari.Tanim.cs IcerikSql ile aynı biçim)
insert into public.radyoloji_sablon_surum (sablon_id, surum, notu, icerik)
select z.sablon_id, z.surum, 'Tek A4 (1332 Bakanlık parçalarına bölmeden önce)',
       jsonb_build_object(
         'bolumler', coalesce((select jsonb_agg(to_jsonb(b) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by b.sira, b.id)
                                 from public.radyoloji_sablon_bolum b where b.sablon_id = z.sablon_id), '[]'::jsonb),
         'alanlar',  coalesce((select jsonb_agg(to_jsonb(a) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by a.sira, a.id)
                                 from public.radyoloji_sablon_alan a where a.sablon_id = z.sablon_id), '[]'::jsonb),
         'makrolar', coalesce((select jsonb_agg(to_jsonb(m) - 'id' - 'sablon_id' - 'ekleyen' - 'ekleme_tarihi' - 'degistiren' - 'degistirme_tarihi' order by m.id)
                                 from public.radyoloji_sablon_makro m where m.sablon_id = z.sablon_id), '[]'::jsonb))
  from zz_1332 z
on conflict (sablon_id, surum) do nothing;

delete from public.radyoloji_sablon_bolum b using zz_1332 z where b.id = z.bolum_id;

insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, varsayilan_html, bakanlik_parca,
                                           zorunlu, yazdir)
select y.sablon_id, y.sira, y.baslik, y.metin, nullif(y.html, ''), y.bakanlik_parca, y.zorunlu, 1
  from zz_1332_yeni y;

update public.radyoloji_sablon s set surum = s.surum + 1, degistirme_tarihi = now()
  from zz_1332 z where z.sablon_id = s.id;

-- elle tamamlanacaklar
do $$
declare r record;
begin
  for r in select s.kod, s.ad,
                  string_agg(case y.bakanlik_parca when 3 then 'Bulgular' else 'Sonuç' end, ', ' order by y.bakanlik_parca) as eksik
             from zz_1332_yeni y join public.radyoloji_sablon s on s.id = y.sablon_id
            where y.bakanlik_parca in (3, 4) and y.html = ''
            group by s.kod, s.ad order by s.ad
  loop
    raise notice '1332 eksik: % (%) - boş: %', r.ad, r.kod, r.eksik;
  end loop;
end $$;

commit;
