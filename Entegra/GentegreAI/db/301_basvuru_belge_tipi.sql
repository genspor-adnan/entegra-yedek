-- 301: HBYS basvurusu belge TIPI ile ayrilsin (kullanici: "hbys de tip
-- degisik olsun").
--
-- Basvuru ile satis siparisi AYNI TURDUR (belge.tur = 19) - ayri bir tur
-- numarasi yok, ayni kayit ERP'de "Satış Siparişi", HBYS'de "Başvuru"
-- ekraninda aciliyor. Ikisi bugune kadar `tipi = 1` ile ayni gorunuyordu:
-- veriye bakan biri (rapor, SQL, dis entegrasyon) hangisinin hasta basvurusu
-- oldugunu ancak belge_basvuru uzantisina JOIN atarak anlayabiliyordu.
--
-- Artik basvuru `tipi = 30`. 30 secildi cunku 1-26 arasi degerler
-- belge.fatura_tipi kod listesinde DOLU (1 Alış/Satış, 2 İade, 22 Tevkifatlı,
-- 26 İhracat...); 30 bos ve eski kodda basvuru icin ayrilmis numaraydi.

-- ------------------------------------------------------------ kod degeri --
-- belge.tipi'nin kod uzayi fatura_tipi listesidir (belge tek kolonu paylasir).
insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, 30, 'Hasta Başvurusu', 30, 1
  from public.kod_liste l
 where l.kod = 'belge.fatura_tipi'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = 30);

-- ---------------------------------------------------------- veri onarimi --
-- YALNIZ gercek basvurular: belge_basvuru uzantisi olanlar. ERP'de acilmis
-- tur 19 siparisler (uzantisiz) DOKUNULMAZ - onlar `tipi = 1` kalir.
create table if not exists public.belge_tipi_yedek_301 as
select b.id, b.tur, b.tipi, now() as yedek_zaman
  from public.belge b
 where b.tur = 19 and b.tipi <> 30
   and exists (select 1 from public.belge_basvuru bb where bb.id = b.id);

do $$
declare n integer;
begin
  update public.belge b
     set tipi = 30
   where b.tur = 19 and b.tipi <> 30
     and exists (select 1 from public.belge_basvuru bb where bb.id = b.id);
  get diagnostics n = row_count;
  raise notice '301: % basvuru tipi 30 yapildi (yedek: belge_tipi_yedek_301)', n;
end $$;

-- HBYS KURULUMUNDA (genel.urun_modu = 2) uzantisi olmayan tur 19 kayitlar da
-- basvurudur: o kurulumda ERP siparis ekrani hic acilmaz, "Satış Siparişleri"
-- listesi gorunmez. Uzanti satiri yalniz bolum/hekim/kurum alanlarinin HEPSI
-- bosken yazilmaz - eski kayitlarin cogu bu yuzden uzantisiz. Onlari disarida
-- birakmak, tipi filtresi devreye girince Basvurular listesinden dusururdu.
-- ERP kurulumunda (urun_modu 1) bu blok CALISMAZ: orada tur 19 gercekten
-- satis siparisidir.
do $$
declare n integer; mod_deger text;
begin
  select deger into mod_deger from public.referans where anahtar = 'genel.urun_modu';
  if coalesce(mod_deger, '1') <> '2' then
    raise notice '301: ERP kurulumu - uzantisiz tur 19 kayitlara dokunulmadi.';
    return;
  end if;

  insert into public.belge_tipi_yedek_301 (id, tur, tipi, yedek_zaman)
  select b.id, b.tur, b.tipi, now()
    from public.belge b
   where b.tur = 19 and b.tipi <> 30
     and not exists (select 1 from public.belge_tipi_yedek_301 y where y.id = b.id);

  update public.belge b set tipi = 30 where b.tur = 19 and b.tipi <> 30;
  get diagnostics n = row_count;
  raise notice '301: HBYS - uzantisiz % kayit da tipi 30 yapildi', n;
end $$;
