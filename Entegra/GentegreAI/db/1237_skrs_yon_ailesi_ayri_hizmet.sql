-- =============================================================================
--  1237  SKRS YÖN AİLESİ - HER YÖN AYRI SUT HİZMETİ
--
--  Kullanıcı 01.11.2026: "olmadı şimdi o zaman biz ekrandan yön soramayız.. sut da nasılsa listeden seçelim".
--  SUT "Diz MR"ı yön + kontrastla dört AYRI kod olarak verir (R104040 sağ kontrastsız ... R104070 sol kontrastlı).
--  1232'nin "tek hizmet + istemde çözülen kod" modeli bırakılır: yön ailesi kararı (durum 4) eski yönsüz hizmeti
--  ailenin HER üyesi için ayrı SUT hizmetine AYIRIR - banko listeden doğru kodu seçer, kabulde yön sorulmaz.
--    * Üye hizmet zaten varsa (standart 1, aynı SUT kodu) o kullanılır; yoksa eski hizmetin kopyası açılır
--      (kod / ad / sut_kodu SUT'tan, sabit yön 1230 kuralıyla, kısa ad "Diz MR · Sağ · kontrastlı").
--    * Eski hizmetin tanımları üyelere KOPYALANIR: fiyat listesi satırları, hizmet fiyatı, çekim protokolü
--      (kontrastlı üyede varsayılan kontrast İV), rapor şablonu bağı. Eski kod her üyede "Eski kod" listesinde.
--    * Eski hizmet PASİF olur (standart 3 = yöne ayrıldı); geçmiş belge satırları / istemler onda kalır
--      (geçmiş tetkikin yönü belge satırından bilinmez - fatura geçmişi değişmez).
--  Kabulde "yön zorunlu" kalkar (1229 sezgisi yerine SUT kodu): bütün hizmetlerde yon_zorunlu = 0.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

comment on column public.hizmet.standart is
  '1222: 0 incelenmedi · 1 SUT (Bakanlık listesi) · 2 kuruma özel · 3 yöne ayrıldı - pasif, üyeleri ayrı SUT hizmeti (1237).';

update public.hizmet set yon_zorunlu = 0 where yon_zorunlu <> 0;

-- Bir hizmete bağlı tanım satırlarını başka hizmete kopyalar (hedefte o tabloda satır yoksa; kimlik kolonu hariç).
create or replace function public.fn_hizmet_tanim_kopyala(p_tablo text, p_eski integer, p_yeni integer)
returns integer language plpgsql as $$
declare v_kol text; v_sec text; v_n integer;
begin
  select string_agg(quote_ident(column_name), ',' order by ordinal_position),
         string_agg(case when column_name = 'hizmet_id' then '$2' else quote_ident(column_name) end, ',' order by ordinal_position)
    into v_kol, v_sec
    from information_schema.columns
   where table_schema = 'public' and table_name = p_tablo and is_identity = 'NO' and is_generated = 'NEVER';
  execute format('insert into public.%I (%s) select %s from public.%I where hizmet_id = $1
                   and not exists (select 1 from public.%I where hizmet_id = $2)', p_tablo, v_kol, v_sec, p_tablo, p_tablo)
    using p_eski, p_yeni;
  get diagnostics v_n = row_count;
  return v_n;
end $$;

-- Eski hizmetin kopyası olarak yeni hizmet (kimlik kolonu hariç bütün kolonlar). Dönen: yeni id.
create or replace function public.fn_hizmet_kopyala(p_eski integer) returns integer language plpgsql as $$
declare v_kol text; v_id integer;
begin
  select string_agg(quote_ident(column_name), ',' order by ordinal_position) into v_kol
    from information_schema.columns
   where table_schema = 'public' and table_name = 'hizmet' and is_identity = 'NO' and is_generated = 'NEVER';
  execute format('insert into public.hizmet (%s) select %s from public.hizmet where id = $1 returning id', v_kol, v_kol)
    into v_id using p_eski;
  return v_id;
end $$;

-- ------------------------------------------------------------------- uygula ----
-- 1236 gövdesi; durum 4 = yöne ayır. Dönen: {sut, birlesen, ozel, aile (ayrılan eski), uye (açılan / bağlanan üye)}.
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
        select h.id into v_uye from public.hizmet h
         where h.standart = 1 and h.sut_kodu = f.kod and coalesce(h.durum, 1) = 1 order by h.id limit 1;
        v_kisa := left(coalesce(nullif(btrim(r.h_kisa), ''), btrim(r.eski_ad)) || ' · '
                       || case f.yon when 1 then 'Sağ' when 2 then 'Sol' else 'Bilateral' end
                       || case f.kontrastli when 1 then ' · kontrastlı' when 0 then ' · kontrastsız' else '' end, 60);
        if v_uye is null then
          v_uye := public.fn_hizmet_kopyala(r.kayit_id);
          update public.hizmet set kod = f.kod, ad = left(f.ad, 200), sut_kodu = f.kod, standart = 1, kisa_ad = v_kisa,
                 yon = f.yon, yon_zorunlu = 0, durum = 1, aktarim_id = null,
                 aciklama = left('Yöne ayrıldı <- ' || r.eski_kod || ' ' || r.eski_ad || '. ' || coalesce(aciklama, ''), 500),
                 ekleyen = p_kullanici, ekleme_tarihi = now(), degistiren = 0, degistirme_tarihi = null
           where id = v_uye;
        else
          update public.hizmet set kisa_ad = v_kisa where id = v_uye and coalesce(btrim(kisa_ad), '') = '';
        end if;
        perform public.fn_hizmet_tanim_kopyala('fiyat_listesi_satir', r.kayit_id, v_uye);
        perform public.fn_hizmet_tanim_kopyala('hizmet_fiyat', r.kayit_id, v_uye);
        perform public.fn_hizmet_tanim_kopyala('radyoloji_sablon_hizmet', r.kayit_id, v_uye);
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
             aciklama = left('Yöne ayrıldı -> ' || v_kodlar || '. ' || coalesce(aciklama, ''), 500),
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
