-- ============================================================================
--  414 - TURKCE METIN KARSILASTIRMA (fn_metin_sadelestir)
--
--  ALERJI KONTROLU SESSIZCE CALISMIYORDU ve sebebi collation'di:
--
--    veritabani ICU tr-TR ile kurulu -> lower('AMOKSISILIN') = 'amoksısılın'
--    (noktasiz i!), katalogdaki 'amoksisilin' ile ESLESMIYOR.
--
--  Hasta "Augmentin alerjisi" kayitli iken ayni etken maddeli baska marka
--  uyarisiz yazilabiliyordu. Bu, hata vermeyen ve ancak zarar olusunca
--  fark edilen turden bir sessizlik - bu yuzden karsilastirma metni ASCII'ye
--  indirgeyen tek bir fonksiyondan gecer.
--
--  Turkce'ye ozgu dort tuzak birden cozulur:
--    * I / ı / İ / i    - noktali-noktasiz i
--    * Ş Ğ Ü Ö Ç        - aksanli harfler
--    * buyuk/kucuk harf
--    * bas-son bosluk ve coklu bosluk
-- ============================================================================

create or replace function public.fn_metin_sadelestir(p_metin text)
returns text language sql immutable as $$
    select regexp_replace(
             btrim(
               translate(p_metin,
                         'IİıiŞşĞğÜüÖöÇç',
                         'iiiissggUUooCC')
             ), '\s+', ' ', 'g')
$$;

-- translate() harf harf esler; ustteki cift ASCII harfler kucuk/buyuk
--   ayrimini da siler. Sonucu tamamen kucuk harfe indirmek icin lower()
--   YETMEZ (ayni tuzak) - bu yuzden ASCII'ye indikten SONRA lower guvenli.
create or replace function public.fn_metin_anahtar(p_metin text)
returns text language sql immutable as $$
    select lower(public.fn_metin_sadelestir(coalesce(p_metin, '')) collate "C")
$$;

comment on function public.fn_metin_anahtar(text) is
    'Turkce metni karsilastirilabilir ASCII anahtara cevirir (414). lower() TEK BASINA YETMEZ: ICU tr-TR lower(I)=ı.';

-- ---------------------------------------------------------------------------
--  ALERJI KONTROLU - anahtar uzerinden
-- ---------------------------------------------------------------------------
create or replace function public.fn_ilac_alerji_kontrol(p_hasta_id integer,
                                                         p_barkod varchar)
returns table (alerji_id integer, etken varchar, siddet smallint, reaksiyon varchar)
language sql stable as $$
    select a.id, a.etken, a.siddet, a.reaksiyon
      from public.hasta_alerji a
      join public.ilac i on i.barkod = p_barkod
     where a.hasta_id = p_hasta_id
       and a.aktif = 1
       and a.tur = 1
       and (
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
                   like '%' || public.fn_metin_anahtar(a.etken) || '%')
       );
$$;
