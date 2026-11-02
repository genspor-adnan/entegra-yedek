-- =============================================================================
--  1233  SKRS YÖN AİLESİ - ÖNERİ SÜZGECİ
--
--  1232'nin aile önerisi KOSUYOLU masasında yanlış aileler de getirdi: "Skolyoz Tetkiki iki yön" -> "ÖNKOL İKİ YÖN",
--  "Üç Yönlü Grafi" -> "EKLEM GRAFİSİ (ÜÇ YÖN)", "Meme Biyopsi" -> "MRG KILAVUZLUĞUNDA BİYOPSİ, MEME".
--  Ek kurallar:
--    * "Karşılaştırmalı" / "kıyaslamalı" / "çift" eski ad zaten bilateraldir (tek koda eşlenir, aile değil).
--    * "Dikkat"li aday (girişimsel terim, terim farkı) aile tohumu olmaz.
--    * Ailenin kökündeki ilk kelime (modalite öneki dışında) eski adda kelime başı olarak geçmeli.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_aktarim_esleme_aile(p_id integer) returns jsonb language plpgsql stable as $$
declare e record; a record; v_onek text; v jsonb;
begin
  select x.*, coalesce(h.yon, 0) as h_yon into e
    from public.aktarim_esleme x join public.hizmet h on h.id = x.kayit_id where x.id = p_id and x.liste = 'hizmet';
  if e.id is null or e.tur <> 'RAD' or e.h_yon <> 0
     or upper(e.eski_ad) ~ '(\mSAĞ\M|\mSOL\M|B[İI]LATERAL|İK[İI]\s+TARAF|HER\s+[İI]K[İI]|MUKAYESEL[İI]|KARŞILAŞTIRMALI|KIYASLAMALI|ÇİFT)' then
    return null;
  end if;
  v_onek := case e.modalite when 1 then 'BT' when 2 then 'MRG' when 3 then 'USG' else '' end;
  for a in select x->>'kod' as kod from jsonb_array_elements(e.adaylar) x where x->>'dikkat' is null loop
    select jsonb_build_object('kok', min(f.kok), 'seed', a.kod,
             'varyant', jsonb_agg(jsonb_build_object('kod', f.kod, 'ad', f.ad, 'yon', f.yon, 'kontrastli', f.kontrastli)
                                  order by f.yon, f.kontrastli))
      into v from public.fn_skrs_yon_ailesi(a.kod) f
     having count(*) >= 2 and (v_onek = '' or public.fn_skrs_sade(min(f.kok)) like v_onek || ' %')
        and public.fn_skrs_sade(e.eski_ad) ~ ('\m' || left(split_part(btrim(regexp_replace(public.fn_skrs_sade(min(f.kok)),
                                                    '^(BT|MRG|USG) ', '')), ' ', 1), 4));
    if v is not null then return v; end if;
  end loop;
  return null;
end $$;

update public.aktarim_esleme e set aile = public.fn_aktarim_esleme_aile(e.id)
 where e.liste = 'hizmet' and e.uygulandi = 0;

commit;
