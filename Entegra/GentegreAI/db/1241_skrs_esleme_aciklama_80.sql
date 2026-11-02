-- =============================================================================
--  1241  SKRS EŞLEME - hizmet.aciklama 80 KARAKTER
--
--  hizmet.aciklama varchar(80); yönlere ayırma ve birleştirme notu left(..., 500) ile yazılıyordu - uzun eski
--  açıklamalı hizmette (KOSUYOLU "Eski HBYS: ...") kayıt reddedildi. Not 80 karaktere kırpılır; bağlantının kendisi
--  hizmet_eski_kod'da (eski kod her üyede) ve masa satırında (hedef_hizmet_id) durur.
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
         aciklama = left('Birleşti -> ' || coalesce(nullif(p_sut, ''), 'yön ailesi') || ' (#' || p_ana || '). ' || coalesce(aciklama, ''), 80),
         degistiren = p_kullanici, degistirme_tarihi = now() where id = p_eski;
  -- 1228: asıl hizmetin kısa adı boşsa birleşen eski adı alır (banko eski adla arar).
  update public.hizmet set kisa_ad = left(btrim(p_eski_ad), 60)
   where id = p_ana and coalesce(btrim(kisa_ad), '') = '' and coalesce(btrim(p_eski_ad), '') <> '';
end $$;

create or replace function public.fn_aktarim_esleme_uygula(p_kullanici integer) returns jsonb language plpgsql as $$
declare
  r record; f record; v_ana integer; v_uye integer; v_sut int := 0; v_bir int := 0; v_ozel int := 0; v_aile int := 0;
  v_uye_n int := 0; v_ad varchar; v_kisa varchar; v_kodlar text;
begin
  perform set_config('gentegre.hizmet_birlestir', '1', true);
  for r in select e.*, h.kod as h_kod, h.ad as h_ad, h.kisa_ad as h_kisa from public.aktarim_esleme e
             join public.hizmet h on h.id = e.kayit_id
            where e.liste = 'hizmet' and e.uygulandi = 0 and e.durum in (1, 2, 4) order by e.kullanim desc, e.id
  loop
    v_ana := null;
    if r.durum = 2 then
      update public.hizmet set standart = 2, degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (r.kayit_id, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
      v_ozel := v_ozel + 1; v_ana := r.kayit_id;
    elsif r.durum = 4 then
      -- YÖNE AYIR: ailenin her üyesi ayrı SUT hizmeti; eski hizmet pasif, tanımları üyelere kopyalanır.
      v_kodlar := '';
      for f in select * from public.fn_skrs_yon_ailesi(r.secilen_kod) loop
        -- 1238: kurulumda zaten olan SUT hizmeti (masadan gelmemiş, standart 0 olsa da) tekrar açılmaz.
        select h.id into v_uye from public.hizmet h
         where h.id <> r.kayit_id and coalesce(h.durum, 1) = 1 and (h.sut_kodu = f.kod or h.kod = f.kod)
         order by (h.standart = 1) desc, (h.sut_kodu = f.kod) desc, h.id limit 1;
        v_kisa := left(coalesce(nullif(btrim(r.h_kisa), ''), btrim(r.eski_ad)) || ' · '
                       || case f.yon when 1 then 'Sağ' when 2 then 'Sol' else 'Bilateral' end
                       || case f.kontrastli when 1 then ' · kontrastlı' when 0 then ' · kontrastsız' else '' end, 60);
        if v_uye is null then
          v_uye := public.fn_hizmet_kopyala(r.kayit_id);
          update public.hizmet set kod = f.kod, ad = left(f.ad, 200), sut_kodu = f.kod, standart = 1, kisa_ad = v_kisa,
                 yon = f.yon, yon_zorunlu = 0, durum = 1, aktarim_id = null,
                 aciklama = left('Yöne ayrıldı <- ' || r.eski_kod || ' ' || r.eski_ad || '. ' || coalesce(aciklama, ''), 80),
                 ekleyen = p_kullanici, ekleme_tarihi = now(), degistiren = 0, degistirme_tarihi = null
           where id = v_uye;
        else
          update public.hizmet set kisa_ad = case when coalesce(btrim(kisa_ad), '') = '' then v_kisa else kisa_ad end,
                 sut_kodu = case when coalesce(btrim(sut_kodu), '') = '' then f.kod else sut_kodu end,
                 yon = case when yon = 0 then f.yon else yon end
           where id = v_uye;
        end if;
        perform public.fn_hizmet_tanim_kopyala('fiyat_listesi_satir', r.kayit_id, v_uye, 'liste_id');
        perform public.fn_hizmet_tanim_kopyala('hizmet_fiyat', r.kayit_id, v_uye);
        perform public.fn_hizmet_tanim_kopyala('radyoloji_sablon_hizmet', r.kayit_id, v_uye, 'sablon_id');
        if public.fn_hizmet_tanim_kopyala('radyoloji_protokol', r.kayit_id, v_uye) > 0 and f.kontrastli = 1 then
          update public.radyoloji_protokol set kontrast = 1 where hizmet_id = v_uye and kontrast = 0;
        end if;
        insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
        values (v_uye, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
        v_kodlar := v_kodlar || case when v_kodlar = '' then '' else ', ' end || f.kod;
        v_uye_n := v_uye_n + 1;
      end loop;
      if v_kodlar = '' then raise exception 'SUT yön ailesi bulunamadı: %', r.secilen_kod; end if;
      update public.hizmet set durum = 0, standart = 3, yon_zorunlu = 0,
             aciklama = left('Yöne ayrıldı -> ' || v_kodlar || '. ' || coalesce(aciklama, ''), 80),
             degistiren = p_kullanici, degistirme_tarihi = now() where id = r.kayit_id;
      insert into public.hizmet_eski_kod (hizmet_id, eski_kod, eski_ad, kaynak)
      values (r.kayit_id, r.eski_kod, r.eski_ad, 'Eski HBYS') on conflict do nothing;
      v_aile := v_aile + 1; v_ana := r.kayit_id;
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
  return jsonb_build_object('sut', v_sut, 'birlesen', v_bir, 'ozel', v_ozel, 'aile', v_aile, 'uye', v_uye_n);
end $$;

commit;
