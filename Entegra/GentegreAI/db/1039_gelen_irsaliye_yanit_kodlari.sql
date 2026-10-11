-- =============================================================================
--  1039  GELEN e-İRSALİYE - kutu kaydı yanıt kodları
--
--  Kullanıcı (11.10.2026): "alış/satış irsaliyelerin izibiz entegrasyonu".
--  Gelen e-İrsaliye kutusu (izibiz /v2/edespatches/inbox) aynı e_belge tablosuna
--  belge_turu = 7 ile yazılır. İrsaliye yanıt durumlarından ikisi fatura
--  eşlemesinde yoktu:
--    PARTIAL_REJECTED       -> 102 (Red)
--    RESPONSE_TIME_EXPIRED  -> 103 (yanıt verilemez)
--  Fonksiyonun geri kalanı 187'dekiyle aynı.
-- =============================================================================

create or replace function public.fn_gelen_belge_kaydet(p_satir jsonb,
                                                        p_sube_id integer,
                                                        p_entegrator varchar,
                                                        p_kullanici integer)
returns table (e_belge_id bigint, yeni boolean)
language plpgsql as $$
declare
    v_uuid    varchar(50)  := nullif(btrim(p_satir->>'uuid'), '');
    v_vkno    varchar(20)  := coalesce(btrim(p_satir->>'gondericiVkno'), '');
    v_durum   smallint;
    v_yanit   varchar(100) := coalesce(btrim(p_satir->>'yanitKodu'), '');
    v_taraf   integer;
    v_id      bigint;
    v_yeni    boolean := false;
begin
    if v_uuid is null then
        raise exception 'Gelen belgede UUID yok; kayıt edilemez.';
    end if;

    -- Gonderici carimiz mi: VKN ile eslesir. Yoksa null kalir - liste yine
    --   gosterir (unvan JSON'dan gelir), kullanici isterse cari acar.
    select t.id into v_taraf
      from public.taraf t
     where coalesce(btrim(t.vkno), '') = v_vkno and v_vkno <> ''
     order by t.id limit 1;

    -- YANIT DURUMU: entegratorun kodu bizim durum kodumuza cevrilir.
    v_durum := case upper(v_yanit)
                 when 'ACCEPTED' then 101
                 when 'APPROVED' then 101
                 when 'REJECTED' then 102
                 when 'DECLINED' then 102
                 -- e-IRSALIYE (1039): kismi red de red; yanit suresi gecen
                 --   irsaliyeye artik yanit verilemez.
                 when 'PARTIAL_REJECTED' then 102
                 when 'RESPONSE_TIME_EXPIRED' then 103
                 else case when upper(coalesce(p_satir->>'profil', '')) = 'TEMELFATURA'
                             then 103 else 100 end
               end;

    insert into public.e_belge (
        belge_id, taraf_id, belge_turu, yon, uuid, belge_no,
        gonderici_alias, alici_alias, durum, api_json,
        gib_durum_kodu, gib_durum_aciklama, yanit_durum_kodu, yanit_durum_adi,
        sube_id, gonderici_vkno, entegrator,
        belge_tarihi, tutar, vergi_tutar, para_birimi, profil, senaryo_adi,
        gonderici_unvan, satir_sayisi, zarf_id, gib_zarf_kodu, entegrator_kayit,
        ekleyen)
    values (
        null, v_taraf,
        coalesce((p_satir->>'belgeTuru')::smallint, 1), 2, v_uuid,
        coalesce(btrim(p_satir->>'belgeNo'), ''),
        coalesce(btrim(p_satir->>'gondericiAlias'), ''),
        coalesce(btrim(p_satir->>'aliciAlias'), ''),
        v_durum, coalesce(p_satir->>'ham', ''),
        coalesce(btrim(p_satir->>'gibKod'), ''),
        coalesce(btrim(p_satir->>'gibAciklama'), ''),
        v_yanit, coalesce(btrim(p_satir->>'yanitAdi'), ''),
        p_sube_id, v_vkno, coalesce(p_entegrator, ''),
        nullif(btrim(p_satir->>'belgeTarihi'), '')::date,
        coalesce((p_satir->>'tutar')::numeric, 0),
        coalesce((p_satir->>'vergiTutar')::numeric, 0),
        coalesce(nullif(btrim(p_satir->>'paraBirimi'), ''), 'TRY'),
        coalesce(btrim(p_satir->>'profil'), ''),
        coalesce(btrim(p_satir->>'senaryoAdi'), ''),
        coalesce(btrim(p_satir->>'gondericiUnvan'), ''),
        coalesce((p_satir->>'satirSayisi')::integer, 0),
        coalesce(btrim(p_satir->>'zarfId'), ''),
        coalesce(btrim(p_satir->>'gibZarfKodu'), ''),
        coalesce(btrim(p_satir->>'entegratorKayit'), ''),
        p_kullanici)
    on conflict (uuid) where uuid is not null do update
       set durum              = excluded.durum,
           yanit_durum_kodu   = excluded.yanit_durum_kodu,
           yanit_durum_adi    = excluded.yanit_durum_adi,
           gib_durum_kodu     = excluded.gib_durum_kodu,
           gib_durum_aciklama = excluded.gib_durum_aciklama,
           api_json           = excluded.api_json,
           taraf_id           = coalesce(public.e_belge.taraf_id, excluded.taraf_id),
           entegrator_kayit   = case when excluded.entegrator_kayit <> ''
                                     then excluded.entegrator_kayit
                                     else public.e_belge.entegrator_kayit end,
           degistiren         = p_kullanici,
           degistirme_tarihi  = now()::timestamp
    returning public.e_belge.id, (xmax = 0) into v_id, v_yeni;

    return query select v_id, v_yeni;
end $$;
