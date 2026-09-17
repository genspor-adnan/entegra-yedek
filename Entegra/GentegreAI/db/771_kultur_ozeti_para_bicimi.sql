-- ============================================================================
--  Gentegre AI — KÜLTÜR ÖZETİ SAYI BİÇİMİ ORTAK YARDIMCIYA BAĞLANIYOR
--  771_kultur_ozeti_para_bicimi.sql
--
--  Kullanıcı: "436'yı da fn_para_tr'ye bağla".
--
--  ============ BAĞLARKEN BİR KUSUR ÇIKTI ==============================
--  436 grup ayıracını `translate(..., ',', '.')` ile düzeltiyordu ama
--  YALNIZ virgülü çeviriyordu. `lc_numeric = C` altında `G` virgül, `D`
--  NOKTA üretir; küsuratlı bir koloni sayısında sonuç şuydu:
--
--      1234.5  ->  to_char "1,234.5"  ->  translate  ->  "1.234.5"
--
--  Yani ondalık ayıracı grup ayıracıyla AYNI işarete dönüyordu - rapor
--  metninde "1.234.5" ne bin iki yüz otuz dört buçuk okunur ne başka bir
--  şey; hangi noktanın ne olduğu belirsizdir. Tam sayı dalı (asıl
--  kullanılan dal) doğruydu, bu yüzden gözden kaçmış.
--
--  `fn_para_tr` (769) iki ayıracı birlikte çevirdiği için hem bağlanma hem
--  düzeltme aynı değişiklik: artık "1.234,50".
--
--  ============ DEĞİŞEN DAVRANIŞ =======================================
--  Küsuratlı sayıda basamak sayısı SABİT 2 oldu ("2,50"); eskiden `FM`
--  sondaki sıfırı atıyordu ("2.5"). Rapor metninde ondalık basamağın
--  sabit olması okumayı kolaylaştırır ve zaten dev/canlı veride küsuratlı
--  koloni sayısı yok (sorgulandı: 0 satır). Tam sayı biçimi DEĞİŞMEDİ -
--  `MikroTestleri` "100.000 CFU/mL" beklentisini aynen sürdürüyor.
--
--  436 bir göçtür, düzenlenmez: yeniden tanımlama burada. Gövde 436'dan
--  aynen alındı (770'teki gibi betikle kopyalandı); tek fark bu ifade.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_lab_kultur_ozet(p_kultur_id integer)
returns text language sql stable as $$
    select coalesce(
        nullif(string_agg(
            o.ad
            -- SAYI BİÇİMİ TEK YERDEN (771): `fn_para_tr`. 100000 -> "100.000";
            --   tam sayıda ondalık basamak yazılmaz ("100.000." kuyruğu),
            --   küsuratlı sayıda iki basamak yazılır.
            || case when u.koloni_sayisi is null then ''
                    else ' — ' || public.fn_para_tr(u.koloni_sayisi,
                             case when u.koloni_sayisi = trunc(u.koloni_sayisi)
                                  then 0 else 2 end)
                         || ' ' || u.koloni_birim end
            || case when u.esbl = 2 then ' · ESBL pozitif' else '' end
            || case when u.karbapenemaz = 2 then ' · karbapenemaz pozitif' else '' end
            || case when u.mrsa = 2 then ' · MRSA' else '' end
            || case when u.vre = 2 then ' · VRE' else '' end,
            ' + ' order by u.izolat_no), ''),
        'Üreme yok')
      from public.lab_kultur_ureme u
      join public.lab_organizma o on o.id = u.organizma_id
     where u.kultur_id = p_kultur_id and u.durum = 1;
$$;

comment on function public.fn_lab_kultur_ozet(integer) is
  '436/771: kultur ureme ozeti (ekran, cikti ve e-Nabiz ayni cumleyi gorsun). '
  'Sayi bicimi fn_para_tr''den (769) - 436''daki translate yalniz virgulu '
  'ceviriyordu ve kusuratli sayida ondalik ayiraci grup ayiraciyla ayni '
  'isarete dusuyordu.';

do $$
begin
    raise notice '771 tamam: kultur ozeti bicimi % · %',
        public.fn_para_tr(100000, 0), public.fn_para_tr(1234.5, 2);
end $$;
