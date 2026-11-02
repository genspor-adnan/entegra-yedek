-- =============================================================================
--  1225  SKRS EŞLEME UYGULA - İSKONTO KİLİDİ
--
--  Uygula, birleşen eski hizmetin belge satırlarını asıl hizmete taşırken onaylı iskontolu satırın kilidine
--  (681 tg_belge_satir_iskonto_kilit) takılıyordu (KOSUYOLU: "Bu satırın iskontosu onaylanmıştır").
--  Kilit yalnız uygula işleminin açtığı oturum bayrağıyla ve yalnız hizmet_id değişikliği için gevşer.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.tg_belge_satir_iskonto_kilit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    -- 1225: SKRS eşleme birleştirmesi (fn_aktarim_esleme_uygula) yalnız hizmet_id'yi asıl hizmete çevirebilir;
    -- tutarı belirleyen öteki alanlar kilitli kalır.
    if current_setting('gentegre.hizmet_birlestir', true) = '1'
       and coalesce(old.iskonto_kilit, 0) = 1 and coalesce(new.iskonto_kilit, 0) = 1
       and coalesce(new.hizmet_id, 0) is distinct from coalesce(old.hizmet_id, 0)
       and coalesce(new.iskonto, 0) = coalesce(old.iskonto, 0) and coalesce(new.iskonto2, 0) = coalesce(old.iskonto2, 0)
       and coalesce(new.birim_fiyat, 0) = coalesce(old.birim_fiyat, 0) and coalesce(new.adet, 0) = coalesce(old.adet, 0)
       and coalesce(new.miktar, 0) = coalesce(old.miktar, 0) and coalesce(new.kdv, 0) = coalesce(old.kdv, 0)
       and coalesce(new.stok_id, 0) = coalesce(old.stok_id, 0)
    then
        return new;
    end if;
    if coalesce(old.iskonto_kilit, 0) = 1
       and coalesce(new.iskonto_kilit, 0) = 1
       and (coalesce(new.iskonto, 0)     is distinct from coalesce(old.iskonto, 0)
         or coalesce(new.iskonto2, 0)    is distinct from coalesce(old.iskonto2, 0)
         or coalesce(new.birim_fiyat, 0) is distinct from coalesce(old.birim_fiyat, 0)
         -- 681: tutarı belirleyen öteki alanlar da kilitli.
         or coalesce(new.adet, 0)        is distinct from coalesce(old.adet, 0)
         or coalesce(new.miktar, 0)      is distinct from coalesce(old.miktar, 0)
         or coalesce(new.kdv, 0)         is distinct from coalesce(old.kdv, 0)
         or coalesce(new.hizmet_id, 0)   is distinct from coalesce(old.hizmet_id, 0)
         or coalesce(new.stok_id, 0)     is distinct from coalesce(old.stok_id, 0))
    then
        raise exception 'Bu satırın iskontosu onaylanmıştır, değiştirilemez. '
                        'Değişiklik için yeni bir iskonto onayı alın.'
              using errcode = 'GK422';
    end if;
    return new;
end $function$;

CREATE OR REPLACE FUNCTION public.fn_aktarim_esleme_uygula(p_kullanici integer)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  r record; v_ana integer; v_sut int := 0; v_bir int := 0; v_ozel int := 0; v_ad varchar;
begin
  -- 1225: birleşen hizmetin belge satırları asıl hizmete taşınırken iskonto kilidi yalnız hizmet_id için açılır.
  perform set_config('gentegre.hizmet_birlestir', '1', true);
  for r in select e.*, h.kod as h_kod, h.ad as h_ad from public.aktarim_esleme e join public.hizmet h on h.id = e.kayit_id
            where e.liste = 'hizmet' and e.uygulandi = 0 and e.durum in (1, 2) order by e.kullanim desc, e.id
  loop
    if r.durum = 2 then
      update public.hizmet set standart = 2, degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (r.kayit_id, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
      v_ozel := v_ozel + 1; v_ana := r.kayit_id;
    else
      select ad into v_ad from public.skrs_sut where kod = r.secilen_kod;
      if v_ad is null then raise exception 'SUT kodu bulunamadı: %', r.secilen_kod; end if;
      select h.id into v_ana from public.hizmet h
       where h.standart = 1 and h.sut_kodu = r.secilen_kod and h.id <> r.kayit_id and coalesce(h.durum, 1) = 1
       order by h.id limit 1;
      if v_ana is null then
        -- Hizmet YERİNDE SUT'a çevrilir.
        update public.hizmet set kod = r.secilen_kod, ad = left(v_ad, 200), sut_kodu = r.secilen_kod, standart = 1,
               degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
        v_ana := r.kayit_id; v_sut := v_sut + 1;
      else
        -- Aynı SUT hizmeti var: bu eski hizmet ona BİRLEŞİR - ana hareketler yönlenir, kendisi pasif kalır.
        update public.belge_satir set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        update public.radyoloji_istem set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        update public.radyoloji_sablon set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        update public.randevu set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        delete from public.fiyat_listesi_satir f where f.hizmet_id = r.kayit_id
           and exists (select 1 from public.fiyat_listesi_satir g where g.liste_id = f.liste_id and g.hizmet_id = v_ana);
        update public.fiyat_listesi_satir set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        delete from public.radyoloji_sablon_hizmet x where x.hizmet_id = r.kayit_id
           and exists (select 1 from public.radyoloji_sablon_hizmet y where y.sablon_id = x.sablon_id and y.hizmet_id = v_ana);
        update public.radyoloji_sablon_hizmet set hizmet_id = v_ana where hizmet_id = r.kayit_id;
        update public.hizmet set durum = 0, standart = 1, sut_kodu = r.secilen_kod,
               aciklama = left('Birleşti -> ' || r.secilen_kod || ' (#' || v_ana || '). ' || coalesce(aciklama, ''), 500),
               degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
        v_bir := v_bir + 1;
      end if;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (v_ana, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
    end if;
    update public.aktarim_esleme set uygulandi = 1, uygulama_tarihi = now(), hedef_hizmet_id = v_ana where id = r.id;
  end loop;
  return jsonb_build_object('sut', v_sut, 'birlesen', v_bir, 'ozel', v_ozel);
end $function$;
