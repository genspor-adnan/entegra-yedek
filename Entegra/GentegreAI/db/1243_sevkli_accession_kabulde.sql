-- =============================================================================
--  1243  SEVKLİ HASTADA ACCESSION KABULDE
--
--  Kullanıcı 01.11.2026: "evet, sevkli hastada boş bırakılırsa o zaman ver". 1242 sevkli hastanın isteminde de
--  kayıtta kurum accession'ı veriyordu; kabulde dış numara girilince verilen numara boşa gidiyordu (sırada atlama).
--    * accession_bekliyor = 1: istem accession'sız açılır (accession_no '').
--    * Kabul kartı kaydedilince (RadyolojiUclari PUT): dış numara girildiyse o, boşsa kurum numarası.
--    * Kart kaydedilmeden istem çekime giderse (durum >= 2, çekim zamanı ya da Study UID) tetik numarayı verir -
--      istem numarasız çekilmez.
--    * Numara verilince ücret satırının boş açıklamasına yazılır (kabul ekranıyla aynı).
--  Benzersizlik yalnız DOLU numarada (boş, bekleyen istemler arasında tekrar edebilir).
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_istem add column if not exists accession_bekliyor smallint not null default 0;
comment on column public.radyoloji_istem.accession_bekliyor is
  '1243: 1 = sevkli hasta - accession kabulde (dış numara ya da boş bırakılırsa kurum numarası).';

drop index if exists public.ux_radyoloji_istem_accession;
create unique index ux_radyoloji_istem_accession on public.radyoloji_istem (accession_no) where accession_no <> '';

-- 287 + 1243: bekleyen istemde boş accession doldurulmaz.
create or replace function public.tg_radyoloji_istem_hazirla()
returns trigger
language plpgsql as $$
begin
  if coalesce(new.accession_no, '') = '' and coalesce(new.accession_bekliyor, 0) = 0 then
    new.accession_no := public.fn_radyoloji_accession(
        coalesce(new.cekim_tarihi::date, current_date));
  end if;
  new.accession_no := coalesce(new.accession_no, '');

  if coalesce(new.modalite, 0) = 0 then
    select coalesce(h.modalite, 0) into new.modalite
      from public.hizmet h where h.id = new.hizmet_id;
  end if;

  if new.cekim_tarihi is not null and coalesce(new.durum, 1) = 1 then
    new.durum := 2;
  end if;

  return new;
end $$;

-- 287 + 1243: numara gelince bekleme biter; çekime giden bekleyen isteme kurum numarası.
create or replace function public.tg_radyoloji_istem_guncelle()
returns trigger
language plpgsql as $$
begin
  if new.cekim_tarihi is not null and old.cekim_tarihi is null
     and coalesce(new.durum, 1) = 1 then
    new.durum := 2;
  end if;
  if coalesce(new.accession_no, '') <> '' then
    new.accession_bekliyor := 0;
  elsif new.accession_bekliyor = 1
        and (coalesce(new.durum, 0) >= 2 or new.cekim_tarihi is not null or coalesce(new.study_uid, '') <> '') then
    new.accession_no := public.fn_radyoloji_accession_ver(new.sube_id, current_date);
    if coalesce(new.accession_no, '') = '' then
      new.accession_no := public.fn_radyoloji_accession(current_date);
    end if;
    new.accession_bekliyor := 0;
  end if;
  return new;
end $$;

create or replace function public.tg_radyoloji_istem_acc_satir()
returns trigger
language plpgsql as $$
begin
  if new.belge_satir_id is not null and coalesce(new.accession_no, '') <> '' then
    update public.belge_satir set aciklama = left(new.accession_no, 200)
     where id = new.belge_satir_id and coalesce(btrim(aciklama), '') = '';
  end if;
  return null;
end $$;

drop trigger if exists tg_radyoloji_istem_acc_satir on public.radyoloji_istem;
create trigger tg_radyoloji_istem_acc_satir
after update of accession_no on public.radyoloji_istem
for each row when (coalesce(old.accession_no, '') = '' and coalesce(new.accession_no, '') <> '')
execute function public.tg_radyoloji_istem_acc_satir();

create or replace function public.fn_basvuru_radyoloji_istem_esitle(p_belge integer, p_kullanici integer)
returns integer language plpgsql as $$
declare s record; v_istem integer; v_acilan integer := 0; v_sevk boolean;
begin
  -- Başvuru değilse ya da YATAN (basvuru_turu 3): yatan hastada istem order'dan açılır (kullanıcı: "yatan hasta
  --   değilse temel prensip önce başvuru aç, ücret satırı ekle, başvuru kaydet.. lab veya rad istemi oluşsun").
  if not exists (select 1 from public.belge_basvuru where id = p_belge and coalesce(basvuru_turu, 0) <> 3) then return 0; end if;

  -- 1243: DIŞ KURUM SEVKİ (gönderen dış hekim ya da geliş şekli Sevkli): accession VERİLMEZ, kabul kartında
  --   hastanın getirdiği numara girilir; boş bırakılırsa o zaman kurum numarası (sıra boşa gitmesin).
  select bb.gelis_sekli = 3 or coalesce(tp.dis_hekim, 0) = 1 into v_sevk
    from public.belge_basvuru bb left join public.taraf_personel tp on tp.id = bb.personel_id where bb.id = p_belge;
  v_sevk := coalesce(v_sevk, false);

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
            kontrast, ekleyen, serbest, accession_no, otomatik, accession_bekliyor)
    values (s.sube_id, p_belge, s.id, s.hasta_id, s.hizmet_id, s.modalite, 1, 1, s.personel_id,
            coalesce((select p.kontrast from public.radyoloji_protokol p where p.hizmet_id = s.hizmet_id and p.kontrast > 0),
                     case when s.ad ~ '\mKONTRASTLI\M' then 1 else 0 end),
            coalesce(p_kullanici, 0), 1,
            case when v_sevk then '' else public.fn_radyoloji_accession_ver(s.sube_id, current_date) end, 1,
            case when v_sevk then 1 else 0 end)
    returning id into v_istem;
    -- Kabul ekranıyla aynı: satırın açıklaması accession (boşsa).
    update public.belge_satir bs set aciklama = left(r.accession_no, 200)
      from public.radyoloji_istem r
     where r.id = v_istem and bs.id = s.id and s.aciklama = '' and coalesce(r.accession_no, '') <> '';
    v_acilan := v_acilan + 1;
  end loop;
  return v_acilan;
end $$;

commit;
