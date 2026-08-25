-- ============================================================================
--  Gentegre AI — FATURA TIPI VARSAYILANI
--  131_fatura_tipi_varsayilan.sql
--
--  Fatura tipi (130) kart uzerinde secilebilir oldu; varsayilani "1 Alış/Satış"
--  (kullanici). Yeni kayitlarda kolon varsayilani da 1 olur, boylece API'yi
--  dogrudan cagiran istemci tip gondermese bile fatura "tipsiz" (0) kalmaz.
--
--  ESKI KAYITLAR: yalniz FATURA turlerinde (11/12/15/16 + konsinye 109/119)
--  tipi = 0 olan satirlar 1 yapilir - bunlar tip kavrami eklenmeden once
--  girilmis birkac belge. Diger tipler (2 iade, 22 tevkifatli, 24 KDV istisna,
--  26 ihracat, 17 gibi gocten gelen degerler) OLDUGU GIBI birakilir.
--
--  Irsaliye / siparis / transfer / talep turlerine DOKUNULMAZ: onlarda belge.tipi
--  kullanilmiyor (stok fisinde ise fisin sebebi anlamina gelir).
-- ============================================================================
\set ON_ERROR_STOP on

-- Once yedek: hangi satirlar degistiyse geri alinabilsin.
create table if not exists public.belge_tipi_yedek_131 (
    belge_id  integer primary key,
    eski_tipi smallint not null,
    tarih     timestamp not null default now()::timestamp
);

insert into public.belge_tipi_yedek_131 (belge_id, eski_tipi)
select id, tipi from public.belge
 where tur in (11, 12, 15, 16, 109, 119) and tipi = 0
on conflict (belge_id) do nothing;

update public.belge set tipi = 1
 where tur in (11, 12, 15, 16, 109, 119) and tipi = 0;

-- Yeni kayitlarda kolon varsayilani (stok fisi kendi tipini acikca gonderir).
alter table public.belge alter column tipi set default 1;

do $$
declare v_yedek integer; v_sifir integer;
begin
    select count(*) into v_yedek from public.belge_tipi_yedek_131;
    select count(*) into v_sifir from public.belge
     where tur in (11, 12, 15, 16, 109, 119) and tipi = 0;
    raise notice '131 tamam: % fatura tipi 1 yapildi, kalan tipsiz %', v_yedek, v_sifir;
end $$;
