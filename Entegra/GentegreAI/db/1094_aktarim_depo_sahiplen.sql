-- =============================================================================
--  1094  DELPHI AKTARIMI - DEPO SAHİPLENME (boş kurulum provası, dokuman/19)
--
--  Pilotun yerel provası (boş ERP kurulumu + ajan): ilk paket fn_aktar_depo'da
--  "duplicate key ux_depo_ad" ile durdu - boş kurulum tohumu "Anadepo" açıyor,
--  Delphi'nin 1 numaralı deposu da "Anadepo". Göçle kurulmuş kopyada görünmüyordu
--  (orada depolar zaten aktarım kimliğiyle işaretli). Aynı adlı, aktarım kimliği
--  olmayan web deposu artık Delphi deposu olarak işaretlenir ('depo_eslesen').
--  Fonksiyonun geri kalanı 1081 ile aynı.
-- =============================================================================

begin;

create or replace function public.fn_aktar_depo(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_sil int := 0; v_es int := 0;
begin
    -- 1094 SAHİPLENME: boş kurulumun tohum deposu ("Anadepo") Delphi deposuyla aynı
    --   adı taşıyor; ux_depo_ad ihlali aktarımı durduruyordu. Aynı adlı, aktarım
    --   kimliği OLMAYAN web deposu Delphi'nin sayılır (ayarları, bağlı kayıtları korunur).
    with r as (select * from jsonb_populate_recordset(null::stg.depolar, coalesce(p->'U'->'DEPOLAR', '[]')))
    update public.depo d set aktarim_kaynak = 1, aktarim_tablo = 'DEPOLAR', aktarim_id = r.id
      from r
     where d.aktarim_kaynak is null
       and d.ad = coalesce(nullif(btrim(r.depoadi), ''), '(adsız depo)')
       and not exists (select 1 from public.depo x
                        where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DEPOLAR' and x.aktarim_id = r.id);
    get diagnostics v_es = row_count;

    with r as (select * from jsonb_populate_recordset(null::stg.depolar, coalesce(p->'U'->'DEPOLAR', '[]')))
    insert into public.depo (ad, durum, varsayilan, maliyeti_etkilesin, son_sayim_tarihi, sube_id,
                             ekleme_tarihi, degistirme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select coalesce(nullif(btrim(r.depoadi), ''), '(adsız depo)'), coalesce(r.durum, 1),
           0, coalesce(r.maliyeti_etkilesin, 1),
           public.fn_aktarim_zaman(r.sonsayimtarihi), public.fn_aktarim_sube(r.subeid),
           coalesce(public.fn_aktarim_zaman(r.eklemetarihi), now()), public.fn_aktarim_zaman(r.degistirmetarihi),
           1, 'DEPOLAR', r.id
      from r
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set ad = excluded.ad, durum = excluded.durum,
                  maliyeti_etkilesin = excluded.maliyeti_etkilesin,
                  son_sayim_tarihi = excluded.son_sayim_tarihi, sube_id = excluded.sube_id,
                  degistirme_tarihi = excluded.degistirme_tarihi
     where (public.depo.ad, public.depo.durum, public.depo.maliyeti_etkilesin,
            public.depo.son_sayim_tarihi, public.depo.sube_id)
           is distinct from
           (excluded.ad, excluded.durum, excluded.maliyeti_etkilesin,
            excluded.son_sayim_tarihi, excluded.sube_id);
    get diagnostics v_yaz = row_count;

    -- VARSAYILAN AYRI ADIMDA (web: tek varsayılan, trg_depo_varsayilan_tek öbürlerini
    --   sıfırlar). Delphi'de birden çok varsayılan olabiliyor (BILIM: 1, 8, 9, 12) -
    --   aynı komutta yazınca tetik satırları ikinci kez değiştiriyor ("cannot affect
    --   row a second time"). En küçük Delphi kimliği kazanır (lokasyon kuralıyla aynı).
    update public.depo d set varsayilan = 1, durum = 1
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DEPOLAR' and d.varsayilan <> 1
       and d.aktarim_id = (select min(r.id) from jsonb_populate_recordset(null::stg.depolar,
                              coalesce(p->'U'->'DEPOLAR', '[]')) r where r.varsayilan = 1);

    -- Silinen depo: hareketlere bağlı olabilir -> silinmez, pasifleşir (varsayılan
    --   depo pasif olamaz: önce varsayılanlığı kalkar).
    update public.depo d set varsayilan = 0, durum = 0
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DEPOLAR'
       and d.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'DEPOLAR', '[]'))::bigint);
    get diagnostics v_sil = row_count;
    return jsonb_build_object('depo', v_yaz, 'depo_pasif', v_sil, 'depo_eslesen', v_es);
end $$;

-- ------------------------------------------------------------------ cari ---

comment on function public.fn_aktar_depo(jsonb) is
    '1081/1094: Delphi DEPOLAR -> depo; aynı adlı aktarım kimliksiz web deposu sahiplenilir.';

commit;
