-- 1334 - Teletıp ORU gövdesi HTML^BASE64: dört Bakanlık parçası biçimli metinden
--
-- Kullanıcı 13.11.2026: "teleradyoloji 64 bit html istiyormuş.. yani base 64" → "html base64'e geç, 1334 göçüyle uygula".
--
-- NEDEN: Kılavuz OBX-2/3 için iki biçim tanır - TX + HTML^BASE64 ya da TX + TXT^BASE64 (dokuman/14 §5.4) - ve kurulumda
--   hangisinin kullanıldığı Teleradyoloji birimine bildirilir (§5.6 "Desteklenen rapor biçimi: HTMLBASE64"). 1309'dan
--   beri TXT^BASE64 gidiyordu: parçalar radyoloji_rapor_bolum.metin'den (düz). Radyoloğun 1195'le verdiği biçim (punto,
--   renk, kalın, tablo) Bakanlık'ta ve e-Nabız'da kayboluyordu. Artık parça HTML: bölümün metin_html'i varsa o, yoksa düz
--   metin fn_rad_duzden_html ile paragraflanır (1332'nin eski şablonları sardığı kuralın aynısı).
--
-- DÜZ METİN KOLONU KALIR: Bulgular ≥ 50 karakter / boş parça denetimi (fn_rad_bakanlik_eksik, 809), e-Nabız 409
--   SONUC_ACIKLAMA, rapor listesi araması ve önizlemesi düz metni okur - HTML uzunluğuyla kural çalışmaz.
--
-- TEK KURAL: parçanın HTML'ini fn_rad_bakanlik_parca_html(rapor_id, parca) üretir; fn_teletip_oru_verisi (kendi
--   raporumuzun ORU'su, 1309) ve TeleradTeslimServisi sorgusu (telerad teslimi, 814) ikisi de bunu çağırır. Üretici
--   (OruUretici.BakanlikObx) OBX-3'ü HTML^BASE64 yazar; HTML'siz çağrıda aynı sarmayı C#'ta yapar (test / eski çağıran).
--
-- BOŞ BÖLÜM: 1332 dört parçayı "boşu boş" yazar - düz metni boş bölüm parçaya girmez (yoksa Karşılaştırma'sız rapor
--   "<p><br></p>" gövdeli ^2 parçası taşır, karşı taraf onu dolu sayar). Yalnız resimden oluşan bölüm (düz metni boş,
--   HTML'inde <img>) dolu sayılır - içerik sessizce düşmez.
--
-- Kurum HBYS profili (HL7 2.5, satır satır TX) DEĞİŞMEZ: düz metin gider.
--
-- Tekrar çalıştırılabilir (create or replace).
\set ON_ERROR_STOP on
begin;

-- Bölümün çıktı HTML'i: metin_html doluysa o, yoksa düz metin paragraflanır. Boş bölüm '' (yukarıdaki kural).
create or replace function public.fn_rad_bolum_html(p_metin text, p_html text)
returns text language sql immutable as $f$
  select case when btrim(coalesce(p_metin, '')) = '' and coalesce(p_html, '') not ilike '%<img%' then ''
              when btrim(coalesce(p_html, '')) <> '' then p_html
              else public.fn_rad_duzden_html(p_metin) end;
$f$;
comment on function public.fn_rad_bolum_html(text, text) is
  '1334: bölümün HTML''i - metin_html doluysa o, yoksa düz metin paragraflanır (fn_rad_duzden_html); düz metni boş ve '
  'resimsiz bölüm ''''.';

-- Bakanlık parçasının HTML'i (1 Teknik · 2 Karşılaştırma · 3 Bulgular · 4 Sonuç ve Öneriler): parçaya bağlı bölümler
-- sırayla art arda. Hem fn_teletip_oru_verisi hem TeleradTeslimServisi sorgusu bunu kullanır.
create or replace function public.fn_rad_bakanlik_parca_html(p_rapor_id integer, p_parca integer)
returns text language sql stable as $f$
  select coalesce(string_agg(public.fn_rad_bolum_html(b.metin, b.metin_html), '' order by b.sira), '')
    from public.radyoloji_rapor_bolum b
   where b.rapor_id = p_rapor_id and b.bakanlik_parca = p_parca;
$f$;
comment on function public.fn_rad_bakanlik_parca_html(integer, integer) is
  '1334: Bakanlık ORU parçasının HTML''i (OBX-5 HTML^BASE64) - parçanın bölümleri fn_rad_bolum_html ile sırayla.';

-- fn_teletip_oru_verisi (1309) + dört parçanın HTML'i. Düz anahtarlar (Teknik, Bulgular…) aynen kalır: denetim ve
-- kurum profili onları okur.
create or replace function public.fn_teletip_oru_verisi(p_rapor_id integer)
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'RaporId',            r.id,
    'IstemId',            r.istem_id,
    'Teknik',             coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 1), ''),
    'Karsilastirma',      coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 2), ''),
    'Bulgular',           coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 3), ''),
    'Sonuc',              coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 4), ''),
    'TeknikHtml',         public.fn_rad_bakanlik_parca_html(r.id, 1),
    'KarsilastirmaHtml',  public.fn_rad_bakanlik_parca_html(r.id, 2),
    'BulgularHtml',       public.fn_rad_bakanlik_parca_html(r.id, 3),
    'SonucHtml',          public.fn_rad_bakanlik_parca_html(r.id, 4),
    'OnayZamani',         to_char(r.onay_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'CekimZamani',        to_char(i.cekim_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'IstemNedeniPuan',    coalesce(r.istem_nedeni_puan, 0),
    'CekimKalitePuan',    coalesce(r.cekim_kalite_puan, 0),
    'RadyologTckn',       case when coalesce(rd.vkno, '') ~ '^[1-9][0-9]{10}$' then rd.vkno else '' end,
    'RadyologSoyad',      upper(coalesce(rd.soyad, '')),
    'RadyologAd',         upper(coalesce(nullif(rd.ad, ''), rd.unvan, '')),
    'KontrastObx17',      coalesce(public.fn_rad_kontrast_obx17(i.id), ''),
    'Duzeltme',           r.ust_rapor_id is not null,
    'RaporEksik',         coalesce(public.fn_rad_bakanlik_eksik(r.id), '')
  )
    from public.radyoloji_rapor r
    join public.radyoloji_istem i on i.id = r.istem_id
    left join public.taraf rd on rd.id = coalesce(r.onaylayan_id, r.yazan_id)
   where r.id = p_rapor_id
$$;
comment on function public.fn_teletip_oru_verisi(integer) is
  '1309/1334: Teletıp ORU rapor kısmı (jsonb): 4 Bakanlık parçası düz (denetim) + HTML (OBX-5 HTML^BASE64, 1334), '
  'onaylayan radyolog, onay / çekim zamanı, OBX-13 puanları, OBX-17 kontrast, ek rapor bayrağı, fn_rad_bakanlik_eksik. '
  'Hasta / istem / kurum kısmı fn_teletip_orm_verisi.';

commit;
