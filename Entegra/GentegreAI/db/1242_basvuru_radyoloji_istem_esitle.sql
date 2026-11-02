-- =============================================================================
--  1242  BAŞVURU ÜCRET SATIRINDAN RADYOLOJİ İSTEMİ
--
--  Kullanıcı 01.11.2026: "ücret satırı girip başvuru kaydedince istem satırı oluşmalı değil mi" - test hastaya
--  başvurunun hizmet satırından "Diz MR" eklendi, istem (ve accession) açılmadı. Eski HBYS'de her radyoloji hizmet
--  satırının kendi accession'ı vardı. Yatan dışı başvuru her kaydedildiğinde (BelgeUclari, lab istemiyle aynı yer -
--  LabServisi.BasvurudanIstemTamamlaAsync; sessiz: istem açılamazsa başvuru kaydı düşmez) bu fonksiyon çalışır:
--    1. BAĞLA: istemi olmayan radyoloji satırı (hizmetin modalitesi var) aynı başvurunun bağsız, iptal olmayan aynı
--       hizmetli istemine bağlanır - kabul ekranı (istem önce, ücret sonra; accession = satır açıklaması) ve
--       muayeneden gelip bankoda ücretlendirilen istem ikinci kez açılmaz. Bağlanan istem serbest (çekim listesine).
--    2. AÇ: kalan satıra istem açılır - şube şablonundan accession (1229), başvurunun hekimi isteyen, kontrast çekim
--       protokolünden ya da SUT adındaki "KONTRASTLI"dan, yön hizmetten (1230 tetiği). otomatik = 1.
--  Satır silinince (BelgeDeposu) çekimi yapılmamış OTOMATİK istem iptal olur (durum 0, bağ kalkar); elle / kabulden
--  açılmış istemin satırı eskisi gibi korunur.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_istem add column if not exists otomatik smallint not null default 0;
comment on column public.radyoloji_istem.otomatik is
  '1242: 1 = başvurunun ücret satırından otomatik açıldı (satır silinince, çekim yoksa iptal olur).';

create or replace function public.fn_basvuru_radyoloji_istem_esitle(p_belge integer, p_kullanici integer)
returns integer language plpgsql as $$
declare s record; v_istem integer; v_acilan integer := 0;
begin
  -- Başvuru değilse ya da YATAN (basvuru_turu 3): yatan hastada istem order'dan açılır (kullanıcı: "yatan hasta
  --   değilse temel prensip önce başvuru aç, ücret satırı ekle, başvuru kaydet.. lab veya rad istemi oluşsun").
  if not exists (select 1 from public.belge_basvuru where id = p_belge and coalesce(basvuru_turu, 0) <> 3) then return 0; end if;

  for s in select bs.id, bs.hizmet_id, coalesce(btrim(bs.aciklama), '') as aciklama, h.modalite, upper(h.ad) as ad,
                  b.sube_id, coalesce(bb.hasta_id, b.taraf_id) as hasta_id, bb.personel_id, bb.basvuru_turu
             from public.belge_satir bs
             join public.belge b on b.id = bs.belge_id
             join public.belge_basvuru bb on bb.id = b.id
             join public.hizmet h on h.id = bs.hizmet_id
            where bs.belge_id = p_belge and coalesce(h.modalite, 0) > 0
              and not exists (select 1 from public.radyoloji_istem r where r.belge_satir_id = bs.id)
            order by bs.sira, bs.id
  loop
    -- 1. Bağla: önce accession'ı satır açıklamasında yazan (kabul), sonra en eski bağsız istem.
    select r.id into v_istem from public.radyoloji_istem r
     where r.belge_id = p_belge and r.hizmet_id = s.hizmet_id and r.belge_satir_id is null and r.durum > 0
     order by (r.accession_no = s.aciklama) desc, r.id limit 1;
    if v_istem is not null then
      update public.radyoloji_istem set belge_satir_id = s.id, serbest = 1 where id = v_istem;
      continue;
    end if;
    -- 2. Aç.
    insert into public.radyoloji_istem
           (sube_id, belge_id, belge_satir_id, hasta_id, hizmet_id, modalite, durum, oncelik, istek_hekim_id,
            kontrast, ekleyen, serbest, accession_no, otomatik)
    values (s.sube_id, p_belge, s.id, s.hasta_id, s.hizmet_id, s.modalite, 1, 1, s.personel_id,
            coalesce((select p.kontrast from public.radyoloji_protokol p where p.hizmet_id = s.hizmet_id and p.kontrast > 0),
                     case when s.ad ~ '\mKONTRASTLI\M' then 1 else 0 end),
            coalesce(p_kullanici, 0), 1, public.fn_radyoloji_accession_ver(s.sube_id, current_date), 1)
    returning id into v_istem;
    -- Kabul ekranıyla aynı: satırın açıklaması accession (boşsa).
    update public.belge_satir bs set aciklama = left(r.accession_no, 200)
      from public.radyoloji_istem r
     where r.id = v_istem and bs.id = s.id and s.aciklama = '' and coalesce(r.accession_no, '') <> '';
    v_acilan := v_acilan + 1;
  end loop;
  return v_acilan;
end $$;

-- Silinen satırların otomatik istemi (çekim / rapor yoksa) iptal: satır korumadan çıkar, silinebilir.
create or replace function public.fn_basvuru_radyoloji_istem_birak(p_belge integer, p_kalan integer[])
returns integer language plpgsql as $$
declare v_n integer;
begin
  update public.radyoloji_istem r
     set durum = 0, belge_satir_id = null,
         aciklama = left('Ücret satırı silindi - otomatik istem iptal. ' || coalesce(r.aciklama, ''), 300)
   where r.belge_id = p_belge and r.otomatik = 1 and r.durum = 1 and coalesce(r.study_uid, '') = ''
     and r.belge_satir_id is not null and not (r.belge_satir_id = any (coalesce(p_kalan, '{}'::int[])))
     and not exists (select 1 from public.radyoloji_rapor rp where rp.istem_id = r.id);
  get diagnostics v_n = row_count;
  return v_n;
end $$;

commit;
