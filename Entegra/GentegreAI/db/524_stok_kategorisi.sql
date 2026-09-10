-- =====================================================================
--  524_stok_kategorisi.sql
--  Stok tarafında da kategori: SUT'un "Malzemeler" tipi kök kategori olur.
--
--  Kullanıcı: "stok için de aynı şekilde kategori oluştur."
--
--  522'de hizmet ağacı SUT TİPLERİNDEN kurulmuştu (Ameliyat ve Girişimler,
--  Tahlil İşlemleri…). Stok tarafında SUT tek tip veriyor - "Malzemeler" -
--  bu yüzden kök de tek. Kategori `tur = 1` (stok listesi) olarak açılır;
--  `stok.kategori` kategori id'sini taşır (kolon smallint, yabancı anahtarı
--  yok - şemanın bugünkü hâli, dokunulmuyor).
--
--  ALT KIRILIM ŞİMDİLİK YOK: SUT malzeme kodları önekli (OP…, KV…, GZ…,
--  UR…) ve bunlar SUT EK-3'ün branş listelerine denk geliyor, ama SKRS
--  kataloğunda bu öneklerin ADINI veren bir liste YOK (499 listenin hiçbiri).
--  Önek harflerine kendi tahminimle isim vermek ("OP = Ortopedi") kataloğa
--  doğrulanmamış bilgi yazmak olurdu; kırılım, adları elde edilince
--  `v_stok_onek_dagilim` üzerinden tek göçle açılır.
-- =====================================================================

do $$
declare
    v_sube integer;
    v_kat  integer;
    v_ad   text;
    v_adet integer;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    -- Kök adı SKRS'nin kendi tip adından gelir; kod hizmet tarafıyla aynı
    --   biçimde ("SUT.5" = Malzemeler tipinin IDUSTNO'su).
    select s.tip into v_ad
      from public.skrs_sut s
     where s.aktif = 1 and s.tip = 'Malzemeler' and coalesce(s.ust_no, 0) <> 0
     limit 1;

    if v_ad is null then
        raise notice '524: SKRS ambarında "Malzemeler" tipi yok - atlandı.';
        return;
    end if;

    select id into v_kat from public.kategori where kod = 'SUT.5' and tur = 1;
    if v_kat is null then
        insert into public.kategori (kod, ad, ust_id, aktif, sube_id, tur)
        values ('SUT.5', left(v_ad, 120), null, 1, v_sube, 1)
        returning id into v_kat;
    else
        update public.kategori set ad = left(v_ad, 120), aktif = 1 where id = v_kat;
    end if;

    update public.stok t
       set kategori = v_kat
     where coalesce(t.kategori, 0) = 0
       and exists (select 1 from public.skrs_sut s
                    where s.kod = t.kod and s.aktif = 1 and s.tip = 'Malzemeler');
    get diagnostics v_adet = row_count;
    raise notice '524 tamam: "%" kategorisi (#%) - % stok bağlandı.', v_ad, v_kat, v_adet;
end $$;

/**
 * SUT malzeme kodlarının ÖNEK dağılımı - alt kategori kırılımı istendiğinde
 * kaynak budur. Önek = SUT EK-3'ün branş listesi; adları SKRS'de olmadığı
 * için burada yalnız kodu, adedi ve bir örnek malzeme gösterilir.
 */
create or replace view public.v_stok_onek_dagilim as
select case when s.kod ~ '^[0-9]' then '(sayısal)'
            else substring(s.kod from '^[A-Z]+') end as onek,
       count(*)                                      as adet,
       min(s.kod)                                    as ilk_kod,
       min(s.ad)                                     as ornek_ad
  from public.skrs_sut s
 where s.aktif = 1 and s.tip = 'Malzemeler'
 group by 1;

comment on view public.v_stok_onek_dagilim is
    'SUT malzeme kodlarının önek dağılımı - stok alt kategorileri istendiğinde kaynak (524).';
