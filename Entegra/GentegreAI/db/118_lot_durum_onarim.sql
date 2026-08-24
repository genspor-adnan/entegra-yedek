-- ============================================================================
--  Gentegre AI — LOT BAKIYESI ONARIMI (117 oncesi girilen belgeler)
--  118_lot_durum_onarim.sql
--
--  117 lot bakiyesi tablosunu (stok_lot_durum) ESKI SISTEMDEN gelen devirle
--  tohumladi; belge kaydinin bu tabloyu guncellemesi de ayni surumle geldi.
--  Arada kalan belgeler ise lot HAREKETI yazdi (stok_izleme) ama BAKIYE
--  yazamadi - o kod henuz yoktu. Ornek: 000000001 no'lu alis irsaliyesi
--  (test008, 100 adet, 2 lot): stok_durum dogru (100 girdi), izlem satirlari
--  dogru, ama lot bakiyesi bos kaldi - stok kartinda lot dokumu gorunmuyordu.
--
--  Bu goc, DEVIRDEN SONRA olusmus izlem hareketlerini bakiyeye isler:
--    giris turleri (2/3/6/10/11/12/109 ve donus_id = 0 olan 20) -> +adet
--    cikis turleri (14/15/16/119/4/29/133)                      -> -adet
--    transferin varis satiri (belge_tur 20, donus_id <> 0)      -> +adet
--    101/105 (siparis/talep)                                    -> ISLENMEZ
--
--  TEK SEFER calisir: islenen id araligi kontrol tablosunda tutulur. Yeniden
--  calistirildiginda ayni satirlar IKINCI KEZ eklenmez - yoksa her calisma
--  bakiyeyi sisirirdi. Bu goctan SONRA yazilan hareketleri zaten uygulama
--  kendisi isliyor; onlar araligin disinda kalir.
--
--  Alt sinir 549534: gocmus izlem satirlarinin en buyuk id'si (kaynak sistemin
--  son kaydi). Ustundekiler bu urunde girilmis yeni hareketlerdir.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.stok_lot_durum_islenen (
    tek_satir    boolean primary key default true check (tek_satir),
    son_izlem_id bigint  not null,
    islem_tarihi timestamp not null default now()::timestamp
);

comment on table public.stok_lot_durum_islenen is
  'Lot bakiyesine islenmis son izlem id (118). Mukerrer islemeyi engeller.';

do $$
declare
    v_bas    bigint := 549534;   -- gocmus son izlem id'si
    v_son    bigint;
    v_onceki bigint;
    v_satir  integer;
begin
    select coalesce(max(son_izlem_id), v_bas) into v_onceki from public.stok_lot_durum_islenen;
    select coalesce(max(id), v_onceki) into v_son from public.stok_izleme;

    if v_son <= v_onceki then
        raise notice '118: islenecek yeni izlem hareketi yok (son id %)', v_onceki;
        return;
    end if;

    with hareket as (
        select i.stok_id, i.depo_id, i.seri_lot_id,
               sum(case
                     -- Cikis: mal depodan gider.
                     when i.belge_tur in (14, 15, 16, 119, 4, 29, 133) then -i.adet
                     -- Transferin VARIS satiri (kaynaktan turemis) mal getirir;
                     --   ayrilis satiri zaten kaynak depoda dusulmustu.
                     when i.belge_tur = 20 and i.donus_id <> 0 then i.adet
                     when i.belge_tur = 20 then -i.adet
                     -- Siparis/talep stok hareketi degildir.
                     when i.belge_tur in (101, 105) then 0
                     else i.adet
                   end) as degisim
          from public.stok_izleme i
         where i.id > v_onceki and i.id <= v_son
           and i.depo_id is not null
           and i.seri_lot_id is not null
         group by 1, 2, 3
    )
    insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan)
    select h.stok_id, h.depo_id, h.seri_lot_id, h.degisim
      from hareket h
     where h.degisim <> 0
       and exists (select 1 from public.stok s where s.id = h.stok_id)
       and exists (select 1 from public.depo d where d.id = h.depo_id)
       and exists (select 1 from public.stok_seri_lot l where l.id = h.seri_lot_id)
    on conflict (stok_id, depo_id, seri_lot_id) do update
       set kalan = stok_lot_durum.kalan + excluded.kalan;

    get diagnostics v_satir = row_count;

    insert into public.stok_lot_durum_islenen (tek_satir, son_izlem_id)
    values (true, v_son)
    on conflict (tek_satir) do update set son_izlem_id = excluded.son_izlem_id,
                                          islem_tarihi = now()::timestamp;

    raise notice '118 tamam: % lot bakiyesi satiri onarildi (izlem % - %)',
                 v_satir, v_onceki + 1, v_son;
end $$;
