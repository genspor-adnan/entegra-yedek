-- 1333 - Şablon bölme (1332) kod incelemesi düzeltmeleri
--
-- Kullanıcı 13.11.2026: "gentegreai tarafı bulguları düzelt" (/code-review, 1332).
--
--  1) fn_html_varlik_coz: geçersiz kod noktası (&#xD800;, &#55357; yarım emoji, &#x0;, &#xFFFFFF;) chr()'ı patlatıp
--     göçü / eski HBYS aktarımını bütünüyle geri aldırabiliyordu. Artık yalnız geçerli kod noktası (1..0x10FFFF,
--     vekil aralık 0xD800-0xDFFF hariç) çözülür; geçersiz varlık OLDUĞU GİBİ kalır.
--  2) fn_rad_sablon_bol - eski yer tutuculu üst bilgi kuralı DARALDI: önce başlık denetimi yapılır ("BULGULAR: @OLCUM"
--     başlıktır, kaybolmaz); ilk başlıktan önceki yer tutuculu düğüm YALNIZ başlık sözcüğü içermiyor ve yer tutucular
--     çıkınca en çok 300 karakterlik (künye boyu) ise atılır. Bütün metni saran tek Word tablosu artık atılmaz.
--     Aynı kural web/src/sayfalar/radyoloji/sablonBolme.ts'te (HTML yorum düğümü de iki yanda yok sayılır).
--     Boşluk sınıfı chr() ile kurulur (1332'de dosyaya ham Unicode karakter olarak yazılmıştı - anlamı aynı, okunmuyor).
--  3) 1332'nin geri alma kaydı aynı sürümde satır varsa sessizce atlanıyordu; uygulamanın kendi dondurmasıyla aynı
--     ("do update") olmalıydı. 1332 bu DB'de çalıştıysa ve o sürüm satırı 1332'nin değilse aşağıda raporlanır
--     (yedek tablo içeriği yine tutar).
--  4) Onarım: 1332'nin böldüğü ve SONRADAN DOKUNULMAMIŞ şablonlar (bölümleri hâlâ eski kuralın çıktısıyla birebir)
--     yeni kuralla yeniden bölünür - yalnız sonucu farklı olanlar; kaynak 1332'nin dondurduğu tek A4 sürümü.
--
-- Kapsam (1332'deki "her tek Rapor bölümlü şablon") değişmedi: kullanıcı kararı "bakanlığın istediği 4 parça esas".
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

-- ------------------------------------------------------------------ 1) varlık çözme ----
create or replace function public.fn_html_varlik_coz(p text)
returns text language plpgsql immutable as $f$
declare
  s text := coalesce(p, '');
  m text[];
  k bigint;
begin
  if strpos(s, '&') = 0 then return s; end if;
  for m in select distinct regexp_matches(s, '&#([0-9]{1,7});', 'g') loop
    k := m[1]::bigint;
    if k between 1 and 1114111 and k not between 55296 and 57343 then
      s := replace(s, '&#' || m[1] || ';', chr(k::int));
    end if;
  end loop;
  for m in select distinct regexp_matches(s, '&#[xX]([0-9a-fA-F]{1,6});', 'g') loop
    k := ('x' || lpad(m[1], 8, '0'))::bit(32)::bigint;
    if k between 1 and 1114111 and k not between 55296 and 57343 then
      s := regexp_replace(s, '&#[xX]' || m[1] || ';', chr(k::int), 'g');
    end if;
  end loop;
  s := replace(s, '&nbsp;', chr(160));
  s := replace(s, '&ensp;', chr(8194));
  s := replace(s, '&emsp;', chr(8195));
  s := replace(s, '&thinsp;', chr(8201));
  s := replace(s, '&quot;', '"');
  s := replace(s, '&apos;', '''');
  s := replace(s, '&lt;', '<');
  s := replace(s, '&gt;', '>');
  return replace(s, '&amp;', '&');
end $f$;

-- Unicode boşluk sınıfı (JS \s ile aynı küme) - tek yerde.
create or replace function public.fn_rad_bosluk_sinifi()
returns text language sql immutable as $f$
  select '[\s' || chr(160) || chr(5760) || chr(8192) || '-' || chr(8202) || chr(8232) || chr(8233) || chr(8239)
         || chr(8287) || chr(12288) || chr(65279) || ']+';
$f$;

create or replace function public.fn_rad_baslik_bul(p_metin text, out parca smallint, out kalan text)
language plpgsql immutable as $f$
declare
  t text := btrim(regexp_replace(coalesce(p_metin, ''), public.fn_rad_bosluk_sinifi(), ' ', 'g'));
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
    return;
  end loop;
end $f$;

-- ---------------------------------------------------------------------- 2) bölme ----
create or replace function public.fn_rad_sablon_bol(p_html text)
returns table (sira smallint, baslik varchar, html text, metin text, bakanlik_parca smallint, zorunlu smallint)
language plpgsql immutable as $f$
declare
  kova    text[] := array['', '', '', '', ''];
  etkin   int := 3;
  baslik_goruldu boolean := false;
  derinlik int := 0;
  dugum   text := '';
  ad      text := '';
  yazi    text := '';
  tok     record;
  etiket  text;
  e_ad    text;
  kapanis boolean;
  bos     constant text :=
    '<(p|div)(?:\s[^>]*)?>(?:\s|&nbsp;|<br\s*/?>|<(span|b|i|u)(?:\s[^>]*)?>(?:\s|&nbsp;|<br\s*/?>)*</\2>)*</\1>';
  bosluk  constant text := public.fn_rad_bosluk_sinifi();
  bos_etiket constant text[] := array['br', 'img', 'hr', 'wbr', 'col', 'input', 'meta', 'link', 'source'];
  dugumler text[] := '{}';
  adlar    text[] := '{}';
  i int;
  d text; da text; dm text; ds text;
  bb record;
  k int := 0;
  sonuc text;
begin
  -- 1) ÜST DÜZEY DÜĞÜMLER (DOMParser body.childNodes). HTML yorumu ('<!--...-->') düğüm sayılmaz.
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
    if e_ad is null then
      if derinlik > 0 then dugum := dugum || etiket; end if;      -- üst düzey yorum / bildirim atılır
      continue;
    end if;
    kapanis := etiket like '</%';
    if derinlik = 0 then
      if yazi <> '' then dugumler := dugumler || yazi; adlar := adlar || ''::text; yazi := ''; end if;
      if kapanis then continue; end if;
      if e_ad = any (bos_etiket) or etiket ~ '/\s*>$' then
        dugumler := dugumler || etiket; adlar := adlar || e_ad;
        continue;
      end if;
      dugum := etiket; ad := e_ad; derinlik := 1;
      continue;
    end if;
    dugum := dugum || etiket;
    if e_ad = any (bos_etiket) or etiket ~ '/\s*>$' then
      continue;
    end if;
    derinlik := derinlik + case when kapanis then -1 else 1 end;
    if derinlik <= 0 then
      dugumler := dugumler || dugum; adlar := adlar || ad;
      dugum := ''; ad := ''; derinlik := 0;
    end if;
  end loop;
  if dugum <> '' then dugumler := dugumler || dugum; adlar := adlar || ad; end if;
  if yazi <> '' then dugumler := dugumler || yazi; adlar := adlar || ''::text; end if;

  -- 2) KOVALAMA - sıra sablonBolme.ts ile aynı: imza → hitap → başlık → eski üst bilgi.
  for i in 1 .. coalesce(array_length(dugumler, 1), 0) loop
    d := dugumler[i]; da := adlar[i];
    dm := public.fn_html_varlik_coz(regexp_replace(d, '<[^>]*>', '', 'g'));
    ds := translate(upper(btrim(regexp_replace(dm, bosluk, ' ', 'g')) collate "tr-TR-x-icu"), 'ÇĞİÖŞÜ', 'CGIOSU');
    exit when ds like 'SAYGILARIM%';
    continue when ds ~ '^SAYIN MESLEKTASIM[,;:.!]?$';
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
    -- ilk başlıktan önce eski yer tutuculu KÜNYE (@ADSOYAD ...): başlık sözcüğü yok ve yer tutucular çıkınca kısa.
    continue when not baslik_goruldu
              and dm ~ '@[A-ZÇĞİÖŞÜ]{3,}'
              and ds !~ '(BULGU|SONUC|TEKNIK|KARSILASTIRMA|IZLENIM|KANAAT)[A-Z ]*:'
              and length(btrim(regexp_replace(regexp_replace(dm, '@[A-ZÇĞİÖŞÜ]{3,}', '', 'g'), bosluk, ' ', 'g'))) <= 300;
    if da = '' then
      d := replace(replace(replace(dm, '&', '&amp;'), '<', '&lt;'), '>', '&gt;');
    end if;
    if btrim(d) <> '' then kova[etkin + 1] := kova[etkin + 1] || d; end if;
  end loop;

  -- 3) ÇIKTI
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
  '1332/1333: tek A4 şablon HTML''i -> Klinik bilgi (varsa) + Bakanlık dört parçası. Kural web sablonBolme.ts ile aynı.';

-- ----------------------------------------------------------- 3) + 4) 1332 onarımı ----
-- Kaynak: 1332'nin dondurduğu sürüm (notu '...1332...'), içinde tek 'Rapor' bölümü. Şablon o günden beri
--   değişmediyse (bölümleri dondurmanın hemen sonrasındaki sürüme ait ve içerik 1332 çıktısıyla aynıysa) ve yeni
--   kural farklı sonuç veriyorsa yeniden yazılır. Kullanıcının düzelttiği şablona dokunulmaz.
create temp table zz_1333 on commit drop as
select s.id as sablon_id, v.surum as dondurulan,
       coalesce(nullif(x.varsayilan_html, ''), public.fn_rad_duzden_html(x.varsayilan_metin)) as kaynak
  from public.radyoloji_sablon s
  join public.radyoloji_sablon_surum v on v.sablon_id = s.id and v.notu like 'Tek A4 (1332%'
 cross join lateral jsonb_to_recordset(v.icerik -> 'bolumler')
         as x(baslik varchar, varsayilan_metin text, varsayilan_html text, bakanlik_parca smallint)
 where s.surum = v.surum + 1
   and jsonb_array_length(v.icerik -> 'bolumler') = 1
   and x.baslik = 'Rapor';

create temp table zz_1333_fark on commit drop as
select z.sablon_id
  from zz_1333 z
 where (select string_agg(b.baslik || '|' || b.bakanlik_parca || '|' || coalesce(b.varsayilan_html, ''), '§' order by b.sira)
          from public.radyoloji_sablon_bolum b where b.sablon_id = z.sablon_id)
       is distinct from
       (select string_agg(p.baslik || '|' || p.bakanlik_parca || '|' || p.html, '§' order by p.sira)
          from public.fn_rad_sablon_bol(z.kaynak) p);

-- Farklı çıkanların hangisi kullanıcının elinden geçti: bugünkü bölümler bir sonraki ad / parça kalıbında değilse
--   (Teknik / Karşılaştırma / Bulgular / Sonuç ve öneriler + isteğe bağlı Klinik bilgi, yazdir 1) dokunulmaz.
delete from zz_1333_fark f
 where exists (select 1 from public.radyoloji_sablon_bolum b
                where b.sablon_id = f.sablon_id
                  and (b.yazdir <> 1
                       or (b.baslik, b.bakanlik_parca) not in (('Klinik bilgi', 0), ('Teknik', 1), ('Karşılaştırma', 2),
                                                               ('Bulgular', 3), ('Sonuç ve öneriler', 4))))
    or exists (select 1 from public.radyoloji_sablon s where s.id = f.sablon_id and s.degistiren is not null);

-- 3) 1332 bölüp de sürüm kaydını yazamadığı (aynı sürümde başka satır vardı) şablonlar: "Geri yükle" eski tek A4'ü
--   getirmez, kaynak yalnız yedek tablo. Onarılmaz, listelenir.
do $$
declare r record;
begin
  if to_regclass('public.yedek_1332_radyoloji_sablon_bolum') is null then return; end if;
  for r in select distinct s.kod, s.ad
             from public.yedek_1332_radyoloji_sablon_bolum y
             join public.radyoloji_sablon s on s.id = y.sablon_id
            where y.baslik = 'Rapor'
              and not exists (select 1 from public.radyoloji_sablon_surum v
                               where v.sablon_id = s.id and v.notu like 'Tek A4 (1332%')
            order by s.ad
  loop
    raise notice '1333 UYARI: % (%) - 1332 öncesi tek A4 sürüm olarak dondurulamamış; eski metin yalnız '
                 'yedek_1332_radyoloji_sablon_bolum tablosunda', r.ad, r.kod;
  end loop;
end $$;

do $$
declare n int; nf int;
begin
  select count(*) into n from zz_1333;
  select count(*) into nf from zz_1333_fark;
  raise notice '1333: 1332 ile bölünmüş dokunulmamış % şablon; yeni kuralla farklı çıkan (yeniden bölünecek) %', n, nf;
end $$;

insert into public.yedek_1332_radyoloji_sablon_bolum
select b.*, now() from public.radyoloji_sablon_bolum b
  join zz_1333_fark f on f.sablon_id = b.sablon_id
 where not exists (select 1 from public.yedek_1332_radyoloji_sablon_bolum y where y.id = b.id);

delete from public.radyoloji_sablon_bolum b using zz_1333_fark f where b.sablon_id = f.sablon_id;

insert into public.radyoloji_sablon_bolum (sablon_id, sira, baslik, varsayilan_metin, varsayilan_html, bakanlik_parca,
                                           zorunlu, yazdir)
select z.sablon_id, p.sira, p.baslik, p.metin, nullif(p.html, ''), p.bakanlik_parca, p.zorunlu, 1
  from zz_1333 z
  join zz_1333_fark f on f.sablon_id = z.sablon_id
 cross join lateral public.fn_rad_sablon_bol(z.kaynak) p;

do $$
declare r record;
begin
  for r in select s.kod, s.ad from zz_1333_fark f join public.radyoloji_sablon s on s.id = f.sablon_id order by s.ad loop
    raise notice '1333 yeniden bölündü: % (%)', r.ad, r.kod;
  end loop;
end $$;

commit;
