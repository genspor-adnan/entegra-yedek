-- =====================================================================
--  555_stok_kategori_ek_dallar.sql
--  554'ün devamı: "Diğer Tıbbi Malzeme"de kalan dört kod bloğu çözüldü.
--
--  554, öneki bilinmeyen 1.254 kartı bilerek "Diğer Tıbbi Malzeme" dalında
--  bıraktı. Ardından bu blokların içeriğine bakıldı; dördü de tek bir işi
--  anlatıyor - ada bakarak TAHMİN değil, blok bütünüyle okunarak:
--
--    OR (401) → stapler kartuşu, klip, dren, iğne seti, arter valfi …
--               ameliyathanenin genel cerrahi sarfı.
--    TR (185) → diz distal femur ana gövde, teleskopik uzatma parçası,
--               proksimal femur bağlantı aparatı … tümör rezeksiyon protezi.
--    DO  (73) → BPAP, ev tipi ventilatör, işitme cihazı, diz altı çorap,
--               enürezis alarmı … evde bakım / destek cihazları.
--    10 (298) → servikal vida, lomber interbody kafes, disk protezi …
--               omurga cerrahisi. (Blokta birkaç protez parçası da var;
--               azınlık kalemler karttan elle taşınabilir.)
--
--  "Diğer Tıbbi Malzeme" dalı SİLİNMEZ: M2 (deneme/mülga) gibi tekil
--  kalemler orada kalır ve yeni gelen tanımsız önekler yine oraya düşer.
-- =====================================================================

do $$
declare
    v_ust integer;
    v_dal record;
    v_kalan integer;
begin
    select id into v_ust from public.kategori where kod = 'STK.TIBBI' and tur = 1 limit 1;
    if v_ust is null then
        raise notice '555: STK.TIBBI ust kategorisi yok - once 554 calismali.';
        return;
    end if;

    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select x.kod, x.ad, v_ust, 1, 1
      from (values
        ('STK.OR',     'Cerrahi Sarf / Genel Cerrahi'),
        ('STK.TR',     'Tümör Rezeksiyon Protezi'),
        ('STK.DO',     'Evde Bakım / Destek Cihazları'),
        ('STK.OMURGA', 'Omurga Cerrahisi')
      ) as x(kod, ad)
     where not exists (select 1 from public.kategori k where k.kod = x.kod and k.tur = 1);

    -- TASIMA: yalniz "Diger Tibbi Malzeme"de duranlar. Kullanici bir karti
    --   elle baska dala tasidiysa orada kalir.
    for v_dal in
        select * from (values
            ('OR', 'STK.OR'), ('TR', 'STK.TR'), ('DO', 'STK.DO'), ('10', 'STK.OMURGA')
        ) as t(onek, kat_kod)
    loop
        update public.stok s
           set kategori = (select k.id from public.kategori k
                            where k.kod = v_dal.kat_kod and k.tur = 1 limit 1)
         where s.kod like v_dal.onek || '%'
           and s.kategori = (select k.id from public.kategori k
                              where k.kod = 'STK.DIGER' and k.tur = 1 limit 1);
    end loop;

    select count(*) into v_kalan
      from public.stok s join public.kategori k on k.id = s.kategori
     where k.kod = 'STK.DIGER' and k.tur = 1;
    raise notice '555: "Diger Tibbi Malzeme" dalinda % kart kaldi.', v_kalan;
end $$;
