-- =====================================================================
--  536_ozel_fiyat_turet.sql
--  Özel (ücretli) tarifeyi başka bir listeden türetir.
--
--  Kullanıcı: "Özel listeyi bir kuraldan üret" → "evet üret, SUT'un 3 katı
--  olsun."
--
--  521'de Özel liste BİLEREK fiyatsız kurulmuştu ("fiyat elle girilir") ama
--  10.066 satırı tek tek yazmak iş değil: başvuruda Özel liste seçiliyken
--  arama ekranında fiyat görünmüyor, satır 0,00 geliyordu.
--
--  KURAL LİSTEDE DEĞİL, ÜRETİMDE: hedef listeye `taban_liste_id`/`carpan`
--  yazıp kalıcı bir türetme zinciri kurmuyoruz - o zincir SUT fiyatı her
--  değiştiğinde Özel fiyatı da sessizce değiştirirdi. Kullanıcı Özel fiyatı
--  elle düzeltebilmeli; bu fonksiyon bir BAŞLANGIÇ doldurur, kilit koymaz.
--  Yeniden çalıştırmak isteyen `p_elle_yazilani_koru` ile kendi girdiklerini
--  koruyabilir.
-- =====================================================================

create or replace function public.fn_fiyat_liste_turet(
    p_hedef integer,
    p_kaynak integer,
    p_kat numeric,
    p_kategori integer default null,
    p_elle_yazilani_koru boolean default false,
    p_yuvarlama integer default 2)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    if p_hedef = p_kaynak then
        raise exception 'Hedef ve kaynak liste aynı olamaz.' using errcode = 'GK422';
    end if;
    if coalesce(p_kat, 0) <= 0 then
        raise exception 'Kat (çarpan) sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;

    -- Kaynak fiyatlar bir kez toplanır: satır başına alt sorgu, 10 bin
    --   satırlık listede dakikalara çıkıyordu (535'teki aynı ders).
    create temporary table zz_turet on commit drop as
    select s.id as satir_id, k.fiyat as kaynak_fiyat
      from public.fiyat_listesi_satir s
      join public.fiyat_listesi_satir k
        on k.liste_id = p_kaynak
       and coalesce(k.hizmet_id, 0) = coalesce(s.hizmet_id, 0)
       and coalesce(k.stok_id, 0)   = coalesce(s.stok_id, 0)
      left join public.hizmet h on h.id = s.hizmet_id
      left join public.stok   t on t.id = s.stok_id
     where s.liste_id = p_hedef
       and coalesce(k.fiyat, 0) > 0
       and (p_kategori is null
            or coalesce(h.kategori, t.kategori) in (
                 with recursive dal as (
                     select p_kategori::integer id
                     union all
                     select k2.id from public.kategori k2 join dal d on k2.ust_id = d.id)
                 select id from dal));

    update public.fiyat_listesi_satir s
       set fiyat = round(z.kaynak_fiyat * p_kat, p_yuvarlama),
           yazim = 2                      -- kuraldan (hesap) geldi
      from zz_turet z
     where s.id = z.satir_id
       and (not p_elle_yazilani_koru or coalesce(s.fiyat, 0) = 0)
       and s.fiyat is distinct from round(z.kaynak_fiyat * p_kat, p_yuvarlama);
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_fiyat_liste_turet(integer, integer, numeric, integer, boolean, integer) is
    'Hedef listenin fiyatını kaynak listeden × kat olarak doldurur - başlangıç değeri, kilit değil (536).';

-- ÖZEL 2026 = SUT 2026 × 3 (kullanıcı kararı).
do $$
declare
    v_ozel integer;
    v_sut  integer;
    v_sayi integer;
begin
    select id into v_ozel from public.fiyat_listesi where tarife_tipi = 1 order by id limit 1;
    select id into v_sut  from public.fiyat_listesi where tarife_tipi = 3 order by id limit 1;
    if v_ozel is null or v_sut is null then
        raise notice '536: Özel ya da SUT listesi yok - üretim atlandı.';
        return;
    end if;
    select public.fn_fiyat_liste_turet(v_ozel, v_sut, 3) into v_sayi;
    raise notice '536: Özel liste (#%) SUT (#%) x 3 ile dolduruldu - % satır.',
                 v_ozel, v_sut, v_sayi;
end $$;
