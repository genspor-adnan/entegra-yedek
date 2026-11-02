-- =============================================================================
--  1236  SKRS YÖN AİLESİ - sut_kodu BOŞ METİN
--
--  hizmet.sut_kodu NOT NULL (varsayılan ''); 1232'nin aile uygulaması ve birleştirmesi NULL yazıyordu (kayıt reddedilirdi).
--  Yön ailesinde hizmet.sut_kodu '' kalır; kod fn_hizmet_sut_kodu ile istemin yön / kontrastından çözülür.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_hizmet_birlestir(p_eski integer, p_ana integer, p_sut varchar, p_kullanici integer, p_eski_ad varchar)
returns void language plpgsql as $$
begin
  perform set_config('gentegre.hizmet_birlestir', '1', true);
  update public.belge_satir set hizmet_id = p_ana where hizmet_id = p_eski;
  update public.radyoloji_istem set hizmet_id = p_ana where hizmet_id = p_eski;
  update public.radyoloji_sablon set hizmet_id = p_ana where hizmet_id = p_eski;
  update public.randevu set hizmet_id = p_ana where hizmet_id = p_eski;
  delete from public.fiyat_listesi_satir f where f.hizmet_id = p_eski
     and exists (select 1 from public.fiyat_listesi_satir g where g.liste_id = f.liste_id and g.hizmet_id = p_ana);
  update public.fiyat_listesi_satir set hizmet_id = p_ana where hizmet_id = p_eski;
  delete from public.radyoloji_sablon_hizmet x where x.hizmet_id = p_eski
     and exists (select 1 from public.radyoloji_sablon_hizmet y where y.sablon_id = x.sablon_id and y.hizmet_id = p_ana);
  update public.radyoloji_sablon_hizmet set hizmet_id = p_ana where hizmet_id = p_eski;
  update public.hizmet set durum = 0, standart = (select h.standart from public.hizmet h where h.id = p_ana),
         sut_kodu = coalesce(p_sut, ''),
         aciklama = left('Birleşti -> ' || coalesce(nullif(p_sut, ''), 'yön ailesi') || ' (#' || p_ana || '). ' || coalesce(aciklama, ''), 500),
         degistiren = p_kullanici, degistirme_tarihi = now() where id = p_eski;
  -- 1228: asıl hizmetin kısa adı boşsa birleşen eski adı alır (banko eski adla arar).
  update public.hizmet set kisa_ad = left(btrim(p_eski_ad), 60)
   where id = p_ana and coalesce(btrim(kisa_ad), '') = '' and coalesce(btrim(p_eski_ad), '') <> '';
end $$;

create or replace function public.fn_aktarim_esleme_uygula(p_kullanici integer) returns jsonb language plpgsql as $$
declare
  r record; v_ana integer; v_sut int := 0; v_bir int := 0; v_ozel int := 0; v_aile int := 0; v_ad varchar; v_kok varchar;
begin
  perform set_config('gentegre.hizmet_birlestir', '1', true);
  for r in select e.*, h.kod as h_kod, h.ad as h_ad from public.aktarim_esleme e join public.hizmet h on h.id = e.kayit_id
            where e.liste = 'hizmet' and e.uygulandi = 0 and e.durum in (1, 2, 4) order by e.kullanim desc, e.id
  loop
    v_ana := null;
    if r.durum = 2 then
      update public.hizmet set standart = 2, degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (r.kayit_id, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
      v_ozel := v_ozel + 1; v_ana := r.kayit_id;
    elsif r.durum = 4 then
      -- YÖN AİLESİ: hizmet tek kalem kalır, Bakanlık kodu istemin yön / kontrastından (hizmet_sut_varyant).
      select min(f.kok) into v_kok from public.fn_skrs_yon_ailesi(r.secilen_kod) f;
      if v_kok is null then raise exception 'SUT yön ailesi bulunamadı: %', r.secilen_kod; end if;
      select h.id into v_ana from public.hizmet h
       where h.standart = 3 and h.id <> r.kayit_id and coalesce(h.durum, 1) = 1
         and exists (select 1 from public.hizmet_sut_varyant v where v.hizmet_id = h.id
                        and v.sut_kodu in (select f.kod from public.fn_skrs_yon_ailesi(r.secilen_kod) f))
       order by h.id limit 1;
      if v_ana is null then
        update public.hizmet set ad = left(v_kok, 200),
               kisa_ad = coalesce(nullif(btrim(kisa_ad), ''), left(btrim(r.eski_ad), 60)),
               sut_kodu = '', standart = 3, yon = 0, yon_zorunlu = 1,
               degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
        insert into public.hizmet_sut_varyant (hizmet_id, yon, kontrastli, sut_kodu)
        select r.kayit_id, f.yon, f.kontrastli, f.kod from public.fn_skrs_yon_ailesi(r.secilen_kod) f
        on conflict (hizmet_id, yon, kontrastli) do update set sut_kodu = excluded.sut_kodu;
        v_ana := r.kayit_id; v_aile := v_aile + 1;
      else
        perform public.fn_hizmet_birlestir(r.kayit_id, v_ana, null, p_kullanici, r.eski_ad);
        v_bir := v_bir + 1;
      end if;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (v_ana, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
    else
      select ad into v_ad from public.skrs_sut where kod = r.secilen_kod;
      if v_ad is null then raise exception 'SUT kodu bulunamadı: %', r.secilen_kod; end if;
      select h.id into v_ana from public.hizmet h
       where h.standart = 1 and h.sut_kodu = r.secilen_kod and h.id <> r.kayit_id and coalesce(h.durum, 1) = 1
       order by h.id limit 1;
      if v_ana is null then
        update public.hizmet set kod = r.secilen_kod, ad = left(v_ad, 200),
               kisa_ad = coalesce(nullif(btrim(kisa_ad), ''), left(btrim(r.eski_ad), 60)), sut_kodu = r.secilen_kod, standart = 1,
               degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
        v_ana := r.kayit_id; v_sut := v_sut + 1;
      else
        perform public.fn_hizmet_birlestir(r.kayit_id, v_ana, r.secilen_kod, p_kullanici, r.eski_ad);
        v_bir := v_bir + 1;
      end if;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (v_ana, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
    end if;
    update public.aktarim_esleme set uygulandi = 1, uygulama_tarihi = now(), hedef_hizmet_id = v_ana where id = r.id;
  end loop;
  return jsonb_build_object('sut', v_sut, 'birlesen', v_bir, 'ozel', v_ozel, 'aile', v_aile);
end $$;

commit;
