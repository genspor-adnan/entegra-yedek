-- =====================================================================
--  935_ilac_alerji_sinif.sql
--  REÇETE ALERJİ KONTROLÜ İLAÇ SINIFINA GÖRE DE (kullanıcı: "reçete
--  kontrolünü sınıfa göre de yap").
--
--  Sorun: alerji kartında katalogdan ilaç seçilince etken madde o ilacın
--  TAM maddesi olur ("prokain penisilin g/potasyum penisilin g"). Madde
--  eşleşmesi iki yönlü "içerir" olduğu için başka bir penisilin
--  ("amoksisilin", "benzatin benzilpenisilin") uyarı VERMİYORDU - hasta
--  penisiline alerjik olduğu halde.
--
--  Çözüm: madde eşleşmesine EK olarak ATC 3. düzey (ilk 4 karakter,
--  "farmakolojik alt grup": J01C penisilinler, J01D diğer beta-laktamlar,
--  M01A NSAİİ...) eşleşmesi. Alerjinin sınıfı ayrıca saklanmaz; katalogda
--  alerjinin maddesini (ya da markasını) taşıyan ilaçların ATC'sinden
--  türetilir - katalog güncellenince kendiliğinden doğru kalır.
--
--  Dönüş tipi değiştiği için (eslesme, sinif kolonları) fonksiyon DROP +
--  CREATE edilir. Tek çağıran: ReceteUclari.UyarilariTopla.
--  Yanlış pozitif yanlış negatife yeğdir: sınıf uyarısı ayrı metinle
--  döner, hekim okuyup geçer.
-- =====================================================================
\set ON_ERROR_STOP on

drop function if exists public.fn_ilac_alerji_kontrol(integer, varchar);

create function public.fn_ilac_alerji_kontrol(p_hasta_id integer,
                                              p_barkod varchar)
returns table (alerji_id integer, etken varchar, siddet smallint, reaksiyon varchar,
               eslesme varchar, sinif varchar)
language sql stable as $$
    select a.id, a.etken, a.siddet, a.reaksiyon,
           (case when m.madde then 'madde' else 'sinif' end)::varchar,
           left(i.atc_kod, 4)::varchar
      from public.hasta_alerji a
      join public.ilac i on i.barkod = p_barkod
      cross join lateral (select
            -- Etken madde iki yonlu icerir: kayit "amoksisilin", katalog
            --   "amoksisilin ve klavulanik asit" olabilir ya da tersi.
            (a.etken_madde <> '' and i.etken_madde <> ''
             and (public.fn_metin_anahtar(i.etken_madde)
                    like '%' || public.fn_metin_anahtar(a.etken_madde) || '%'
               or public.fn_metin_anahtar(a.etken_madde)
                    like '%' || public.fn_metin_anahtar(i.etken_madde) || '%'))
            -- Etken madde girilmemisse marka adindan yakalamayi dene.
         or (a.etken <> ''
             and public.fn_metin_anahtar(i.ad)
                   like '%' || public.fn_metin_anahtar(a.etken) || '%') as madde) m
     where a.hasta_id = p_hasta_id
       and a.aktif = 1
       and a.tur = 1
       and (m.madde
            -- SINIF: yazilan ilacin ATC 3. duzeyini tasiyan bir katalog
            --   ilaci alerjinin maddesini (ya da markasini) iceriyorsa.
            or (length(i.atc_kod) >= 4
                and exists (
                    select 1 from public.ilac k
                     where left(k.atc_kod, 4) = left(i.atc_kod, 4)
                       and ((a.etken_madde <> '' and k.etken_madde <> ''
                             and (public.fn_metin_anahtar(k.etken_madde)
                                    like '%' || public.fn_metin_anahtar(a.etken_madde) || '%'
                               or public.fn_metin_anahtar(a.etken_madde)
                                    like '%' || public.fn_metin_anahtar(k.etken_madde) || '%'))
                         or (a.etken <> ''
                             and public.fn_metin_anahtar(k.ad)
                                   like '%' || public.fn_metin_anahtar(a.etken) || '%')))));
$$;
