-- =====================================================================
--  551_hizmet_oto_pasif_durum.sql
--  550'in düzeltmesi: pasife alma `durum` alanını da çevirmeli.
--
--  550 yalnız `profil_pasif = 1` yazıyordu. 527'deki sözleşme ise İKİ alan:
--  profil bir kalemi kapattığında `durum = 0` (kalem gerçekten pasif) ve
--  `profil_pasif = 1` (iz: bunu profil kapattı, kullanıcı değil). Yalnız izi
--  yazmak hiçbir listeyi süzmüyordu - hizmet ekranda kalmaya devam ederdi.
--
--  Aynı sözleşmenin öteki yarısı: kullanım gelince yalnız PROFİLİN kapattığı
--  kalem geri açılır (`profil_pasif = 1` olan). Kullanıcının elle pasife
--  aldığı hizmet, birisi onu bir belgeye yazsa bile kapalı kalır - o bilinçli
--  bir karardır.
-- =====================================================================

-- Kullanim isleyicisi: pasife alinmisi ACARKEN durumu da geri ver.
create or replace function public.fn_hizmet_kullan(
    p_hizmet integer, p_bolum integer default 0, p_adet integer default 1)
returns void language plpgsql as $$
declare
    v_yarilanma numeric;
begin
    if p_hizmet is null then return; end if;

    select coalesce(nullif(deger, '')::numeric, 90) into v_yarilanma
      from public.referans where anahtar = 'hizmet.puan_yarilanma_gun';
    v_yarilanma := coalesce(v_yarilanma, 90);

    insert into public.hizmet_kullanim (bolum_id, hizmet_id, say, puan)
    values (coalesce(p_bolum, 0), p_hizmet, p_adet, p_adet)
    on conflict (bolum_id, hizmet_id) do update
       set say = public.hizmet_kullanim.say + excluded.say,
           -- Eski puan once SONUMLENIR, sonra yeni kullanim eklenir.
           puan = public.fn_hizmet_puan(public.hizmet_kullanim.puan,
                                        public.hizmet_kullanim.son_tarih, v_yarilanma)
                  + excluded.say,
           son_tarih = now()::timestamp;

    -- OTOMATIK KAPATILAN GERI ACILIR (527 sozlesmesi): yalniz profil_pasif
    --   isaretli olan. Kullanicinin elle kapattigi kalem kapali kalir.
    update public.hizmet
       set durum = 1, profil_pasif = 0
     where id = p_hizmet and profil_pasif = 1;
end $$;

comment on function public.fn_hizmet_kullan(integer, integer, integer) is
    'Bir hizmet kullanimini isler: sayac + sonumlenmis puan; profilin kapattigini acar (551).';

-- Otomatik pasife alma: durum = 0 + profil_pasif = 1 (527 ile ayni cift).
create or replace function public.fn_hizmet_kullanilmayan_pasife(
    p_gun integer default null, p_deneme boolean default false)
returns table (pasife_alinan integer, aciklama text)
language plpgsql as $$
declare
    v_gun       integer;
    v_baslangic date;
    v_sayi      integer := 0;
begin
    select coalesce(nullif(deger, '')::integer, 365) into v_gun
      from public.referans where anahtar = 'hizmet.oto_pasif_gun';
    v_gun := coalesce(p_gun, v_gun, 365);
    if v_gun <= 0 then
        return query select 0, 'Otomatik pasife alma kapali (hizmet.oto_pasif_gun = 0).'::text;
        return;
    end if;

    select coalesce(nullif(deger, '')::date, current_date) into v_baslangic
      from public.referans where anahtar = 'hizmet.kullanim_izleme_baslangic';
    v_baslangic := coalesce(v_baslangic, current_date);

    -- IZLEME SURESI DOLMADI: sayac heniz o kadar veri gormedi.
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_pasif_aday on commit drop as
    select h.id
      from public.hizmet h
     where h.baslik_mi = 0
       and h.durum = 1
       and h.profil_pasif = 0
       and not exists (
             select 1 from public.hizmet_kullanim k
              where k.hizmet_id = h.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       and not exists (
             select 1 from public.belge_satir bs
               join public.belge b on b.id = bs.belge_id
              where bs.hizmet_id = h.id
                and b.belge_tarihi >= now()::timestamp - make_interval(days => v_gun));

    select count(*) into v_sayi from zz_pasif_aday;

    if not p_deneme then
        update public.hizmet h
           set durum = 0, profil_pasif = 1
          from zz_pasif_aday a where a.id = h.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s hizmet %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

comment on function public.fn_hizmet_kullanilmayan_pasife(integer, boolean) is
    'Kullanilmayan hizmetleri pasife alir (durum 0 + profil_pasif 1); deneme kipinde sayar (551).';
