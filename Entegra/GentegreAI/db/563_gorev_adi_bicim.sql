-- =====================================================================
--  563_gorev_adi_bicim.sql
--  GÖREV (branş) adları okunur biçime çevrilir: İLK HARFLER BÜYÜK.
--
--  Kullanıcı: "branşları küçük harfe çevir" → "ilk harfler büyük".
--
--  SKRS branş listesi TAMAMI BÜYÜK HARF geliyor ("ACIL TIP", "TIBBI
--  PATOLOJI") ve ekranda bağırıyor. İki yol birlikte kullanılır:
--
--  1) KLİNİK ADINDAN AL (77 görev). Klinik listesi zaten düzgün yazılmış
--     ("Tıbbi Biyokimya", "Kulak Burun Boğaz"); aynı işin iki listedeki
--     yazımı ayrışmasın diye eşleşen görev adı ORADAN kopyalanır.
--
--  2) KALANI DÖNÜŞTÜR. Türkçe küçültme (`lower`) veritabanının tr-TR
--     kolasyonunda doğru çalışır ama bir tuzağı var: SKRS bazı adlarda
--     NOKTALI İ yerine ASCII I yazmış. Türkçe kural I → ı olduğu için
--     "CERRAHISI" → "cerrahısı", "TIBBI" → "tıbbı" çıkıyor. Bu yüzden
--     küçültmenin ardından bilinen hecelerde ı → i düzeltmesi yapılır;
--     GERÇEKTEN ı olan kelimeler (kadın, hastalıkları, ağız, dış, bakım)
--     listede yok, onlara dokunulmaz.
--
--  TEKRAR ÇALIŞTIRILABİLİR: zaten düzgün yazılmış ad ikinci koşuda aynı
--  sonucu verir.
-- =====================================================================

-- Bir metni "İlk Harfler Büyük" biçimine çevirir (Türkçe duyarlı).
--   `initcap` ASCII düşünür: "ağız" -> "AğIz". Kelimeleri kendimiz gezeriz.
create or replace function public.fn_tr_baslik(p_metin text)
returns text language sql immutable as $$
    select string_agg(
             case when parca ~ '^[[:alpha:]]'
                  then upper(left(parca, 1)) || substr(parca, 2)
                  else parca end, '')
      from regexp_split_to_table(p_metin, '(?=[^[:alpha:]])|(?<=[^[:alpha:]])')
           as parca;
$$;

comment on function public.fn_tr_baslik(text) is
  'Turkce duyarli "Ilk Harfler Buyuk" bicimi (563).';

do $$
declare
    v_klinikten integer;
    v_donusen   integer;
begin
    -- 1) Klinik listesinde AYNI is varsa yazimi oradan al.
    update public.personel_gorev g
       set ad = d.ad
      from public.departman d
     where public.fn_ara_metin(d.ad) = public.fn_ara_metin(g.ad)
       and g.ad <> d.ad;
    get diagnostics v_klinikten = row_count;

    -- 2) Kalanlar: kucult + ilk harfleri buyut + I/İ duzeltmesi.
    update public.personel_gorev g
       set ad = public.fn_tr_baslik(
                  -- SKRS'nin ASCII I yazdigi heceler: kucultmede ı olur,
                  --   dogrusu i. Yalniz bu hece kaliplari duzeltilir.
                  regexp_replace(
                    regexp_replace(
                      regexp_replace(lower(g.ad), 'jı', 'ji', 'g'),
                      'hısı', 'hisi', 'g'),
                    'tıbbı', 'tıbbi', 'g'))
     where g.ad = upper(g.ad);           -- yalniz HALA tamami buyuk olanlar
    get diagnostics v_donusen = row_count;

    raise notice '563: % gorev adi klinik listesinden, % gorev adi bicimlendirildi.',
                 v_klinikten, v_donusen;
end $$;
