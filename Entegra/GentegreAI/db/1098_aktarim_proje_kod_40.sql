-- =============================================================================
--  1098  DELPHI AKTARIMI - PROJE KODU 40 KARAKTER (FETA geçişi)
--
--  fn_aktar_proje kodu 60 karaktere kırpıyordu ama proje.kod varchar(40) -
--  FETA'da 46 karakterlik PROJEKODU aktarımı durdurdu ("value too long for type
--  character varying(40)"). BILIM'de kodlar 40'ı geçmediği için görünmemişti.
--  Kırpma ve '-<id>' eki 40'a göre. Geri kalanı 1095 ile aynı.
-- =============================================================================

begin;

create or replace function public.fn_aktar_proje(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_cak int := 0; v_sil int := 0;
begin
    create temp table if not exists _pr on commit drop as
        select *, ''::varchar(40) as kod2 from stg.projeler with no data;
    truncate _pr;
    insert into _pr
    select s.*, left(coalesce(nullif(btrim(s.projekodu), ''), 'PRJ' || s.id), 40)
      from jsonb_populate_recordset(null::stg.projeler, coalesce(p->'U'->'PROJELER', '[]')) s;

    -- 1095: Delphi'de AYNI KODLU iki proje olabiliyor (BILIM: 6/12, 4/11). İkisi de
    --   gerçek kayıt: en küçük kimlik kodu korur, sonrakiler '-<id>' ekiyle gelir
    --   (reçete kuralı, 1083). Web'deki başka bir kayıtla çakışma aşağıda (atlanır).
    update _pr i set kod2 = left(i.kod2, 40 - length('-' || i.id)) || '-' || i.id
     where exists (select 1 from _pr o where o.kod2 = i.kod2 and o.id < i.id)
        or exists (select 1 from public.proje m
                    where m.kod = i.kod2 and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'PROJELER'
                      and m.aktarim_id < i.id);

    delete from _pr i
     where exists (select 1 from public.proje m
                    where m.kod = i.kod2
                      and not coalesce(m.aktarim_kaynak = 1 and m.aktarim_tablo = 'PROJELER' and m.aktarim_id = i.id, false));
    get diagnostics v_cak = row_count;

    insert into public.proje (kod, ad, taraf_id, sorumlu_id, baslangic, bitis, butce_tutar, butce_dovizi,
                              durum, aciklama, sube_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select i.kod2,
           coalesce(nullif(btrim(i.projeadi), ''), nullif(btrim(i.konusu), ''), 'Proje ' || i.id),
           public.fn_aktarim_web_id('taraf', 'REHBER', i.rehberid),
           public.fn_aktarim_web_id('taraf', 'REHBER', i.prj_sorumlusu_id),
           public.fn_aktarim_tarih(i.baslamatarihi), public.fn_aktarim_tarih(i.bitistarihi),
           coalesce(i.satisfiyati, 0), public.fn_doviz_iso(i.satiskur),
           case when coalesce(i.durum, 1) = 0 then 0 else 1 end,
           coalesce(nullif(btrim(i.konusu), ''), ''), public.fn_aktarim_sube(i.subeid),
           1, 'PROJELER', i.id
      from _pr i
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, taraf_id = excluded.taraf_id,
                  sorumlu_id = excluded.sorumlu_id, baslangic = excluded.baslangic, bitis = excluded.bitis,
                  butce_tutar = excluded.butce_tutar, butce_dovizi = excluded.butce_dovizi,
                  durum = excluded.durum, aciklama = excluded.aciklama, sube_id = excluded.sube_id
     where (public.proje.kod, public.proje.ad, public.proje.taraf_id, public.proje.sorumlu_id,
            public.proje.baslangic, public.proje.bitis, public.proje.butce_tutar, public.proje.butce_dovizi,
            public.proje.durum, public.proje.aciklama, public.proje.sube_id)
           is distinct from
           (excluded.kod, excluded.ad, excluded.taraf_id, excluded.sorumlu_id, excluded.baslangic,
            excluded.bitis, excluded.butce_tutar, excluded.butce_dovizi, excluded.durum,
            excluded.aciklama, excluded.sube_id);
    get diagnostics v_yaz = row_count;

    update public.proje x set durum = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'PROJELER' and x.durum <> 0
       and x.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'PROJELER', '[]'))::bigint);
    get diagnostics v_sil = row_count;
    return jsonb_build_object('proje', v_yaz, 'cakisma', v_cak, 'proje_pasif', v_sil);
end $$;

commit;
