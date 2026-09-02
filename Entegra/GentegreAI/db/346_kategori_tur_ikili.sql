-- 346: KATEGORİ TÜRÜ İKİLİ - "Ortak" kalktı (ya stok ya hizmet).
--
-- Kullanıcı: "tür de ortak yok, ya hizmet ya stok olsun."
--
-- 345'te üçüncü bir tür ("ortak") vardı ve o kategoriler iki listede birden
-- görünüyordu. Kullanıcı kararı: bir kategori tek tarafa aittir - iki listede
-- birden görünen kayıt, "hangisi benim listemde" sorusunu belirsiz bırakıyor.
--
-- MEVCUT "ORTAK" KAYITLAR BASKIN KULLANIMA GÖRE dağıtılır: kaç stok / kaç
-- hizmet o kategoriyi seçmişse çok olan taraf kazanır, hiç kullanılmayan
-- STOK sayılır (kurulumların ezici çoğunluğu stok tarafında başlıyor).
-- Kullanılan hiçbir kayıt SİLİNMEZ ya da boşaltılmaz: yalnız kategori
-- ağacının hangi listede görüneceği değişir - örneğin 42 stok + 1 hizmetin
-- kullandığı "Genel" stok tarafına geçer, o tek hizmetin kategori değeri
-- yerinde kalır ama hizmet listesinden yeni seçim yapılamaz.
\set ON_ERROR_STOP on

update public.kategori k
   set tur = case when h.adet > s.adet then 2 else 1 end
  from (select k2.id, (select count(*) from public.stok s2 where s2.kategori = k2.id) adet
          from public.kategori k2) s,
       (select k3.id, (select count(*) from public.hizmet h2 where h2.kategori = k3.id) adet
          from public.kategori k3) h
 where s.id = k.id and h.id = k.id and k.tur not in (1, 2);

alter table public.kategori
    alter column tur set default 1;

-- Uygulama tarafi da ikili (1/2) yaziyor; kisit yanlis degeri VERI GIRISINDE
--   durdurur - "ortak" kavrami geri sizmasin.
do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'kategori_tur_ck') then
        alter table public.kategori
            add constraint kategori_tur_ck check (tur in (1, 2));
    end if;
end $$;

comment on column public.kategori.tur is
  'Kategori turu (346): 1 stok, 2 hizmet. Ortak tur YOK - kategori tek listeye aittir.';

do $$
declare r record;
begin
    for r in select tur, count(*) adet from public.kategori group by tur order by tur loop
        raise notice '346: tur % -> % kategori', r.tur, r.adet;
    end loop;
    raise notice '346 tamam: kategori turu ikili (stok / hizmet).';
end $$;
