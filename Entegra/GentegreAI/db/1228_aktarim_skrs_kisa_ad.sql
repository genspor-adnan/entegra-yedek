-- =============================================================================
--  1228  SKRS EŞLEME - ESKİ AD KISA ADA
--
--  Kullanıcı 01.11.2026: "müşteri eski adlara çok alışık özellikle banko ekleme yaparken.. eski adları hizmet listesine
--  kısa ad kısmına eklesen". Uygula hizmetin adını SUT adıyla değiştirirken eski adı kısa ada yazar (kısa ad boşsa;
--  elle girilmiş kısa ad korunur). Kısa ad aramada önceliklidir (549); resmi ad fatura / e-Nabız için SUT adı kalır.
--  Önceden uygulanmış hizmetler: kısa adı boş ve eski kodu olanlara ilk (en çok kullanılan) eski ad yazılır.
-- =============================================================================

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
        update public.hizmet set kod = r.secilen_kod, ad = left(v_ad, 200),
               kisa_ad = coalesce(nullif(btrim(kisa_ad), ''), left(btrim(r.eski_ad), 60)), sut_kodu = r.secilen_kod, standart = 1,
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
        -- 1228: asıl hizmetin kısa adı boşsa birleşen eski adı alır (banko eski adla arar).
        update public.hizmet set kisa_ad = left(btrim(r.eski_ad), 60)
         where id = v_ana and coalesce(btrim(kisa_ad), '') = '' and coalesce(btrim(r.eski_ad), '') <> '';
        v_bir := v_bir + 1;
      end if;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (v_ana, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
    end if;
    update public.aktarim_esleme set uygulandi = 1, uygulama_tarihi = now(), hedef_hizmet_id = v_ana where id = r.id;
  end loop;
  return jsonb_build_object('sut', v_sut, 'birlesen', v_bir, 'ozel', v_ozel);
end $function$;

update public.hizmet h
   set kisa_ad = left(btrim(x.eski_ad), 60)
  from (select distinct on (e.hizmet_id) e.hizmet_id, e.eski_ad
          from public.hizmet_eski_kod e
          left join public.aktarim_esleme a on a.liste = 'hizmet' and a.eski_kod = e.eski_kod
         where coalesce(btrim(e.eski_ad), '') <> ''
         order by e.hizmet_id, coalesce(a.kullanim, 0) desc, e.id) x
 where x.hizmet_id = h.id and coalesce(btrim(h.kisa_ad), '') = ''
   and h.standart = 1 and btrim(x.eski_ad) is distinct from btrim(h.ad);
