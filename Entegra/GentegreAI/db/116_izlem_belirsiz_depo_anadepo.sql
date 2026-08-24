-- ============================================================================
--  Gentegre AI — DEPOSU BELIRSIZ IZLEM HAREKETLERI ANA DEPOYA
--  116_izlem_belirsiz_depo_anadepo.sql
--
--  115'te izlem hareketlerine depo eklendi ama gocmus 454.257 satirin deposu
--  turetilemedi (kaynak veride bu hareketler belgeye bagli degil). Kullanici
--  karari: bunlarin hepsi ANA DEPOYA (depo.varsayilan = 1) sayilsin.
--
--  Gerekce: gocmus mal fiilen ana depoda duruyor; "deposu belirsiz" ayri bir
--  yigin olarak durdukca cikis ekraninda ve stok kartinda ayri satir olarak
--  gorunuyordu.
--
--  GERI ALINABILIR: dokunulan satirlarin id'leri yedek tabloda. Geri almak:
--    update public.stok_izleme i set depo_id = null
--      from public.stok_izleme_depo_yedek_116 y where y.id = i.id;
--
--  Tekrar calistirilabilir: ikinci calismada depo_id'si null kalan satir yok.
--
--  UYARI (bu goc COZMEZ): lot kalanlari ile stok_durum miktarlari gocten beri
--  TUTMUYOR - 2.459 stokta lot kalanlari toplami depo miktarindan farkli
--  (or. stok 136: lot kalani 1.766, stok bakiyesi 84). Sebep, kaynak sistemden
--  gelen kalan degerlerinin oldugu gibi kopyalanmis olmasi. Bu goc yalnizca
--  DEPO etiketi yazar, kalan degerlerine DOKUNMAZ; mutabakat ayri bir istir ve
--  hangi eski belge turlerinin "stokta duran mal" sayildigina karar verilmesini
--  gerektirir.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.stok_izleme_depo_yedek_116 (
    id           integer primary key,
    yedek_tarihi timestamp not null default now()::timestamp
);

comment on table public.stok_izleme_depo_yedek_116 is
  'Deposu bos iken ana depoya alinan izlem satirlari (116). Geri alma icin saklanir.';

do $$
declare v_depo integer; v_satir integer;
begin
    select id into v_depo from public.depo
     where varsayilan = 1 and durum = 1 order by id limit 1;

    if v_depo is null then
        raise exception '116: varsayilan depo bulunamadi (depo.varsayilan = 1 olan kayit yok).';
    end if;

    insert into public.stok_izleme_depo_yedek_116 (id)
    select id from public.stok_izleme where depo_id is null
    on conflict (id) do nothing;

    update public.stok_izleme set depo_id = v_depo where depo_id is null;
    get diagnostics v_satir = row_count;

    raise notice '116 tamam: % izlem satiri ana depoya (%) alindi', v_satir, v_depo;
end $$;

do $$
declare v_kalan integer; v_fark integer;
begin
    select count(*) into v_kalan from public.stok_izleme where depo_id is null;

    -- Bilgi amacli: lot kalanlari ile depo bakiyesi tutmayan stok sayisi.
    select count(*) into v_fark from (
        select i.stok_id, sum(i.kalan) as lot_kalan,
               (select sum(d.kalan) from public.stok_durum d where d.stok_id = i.stok_id) as stok_kalan
          from public.stok_izleme i
         where i.kalan > 0
           and i.belge_tur not in (14, 15, 16, 119, 4, 29, 105, 133)
         group by i.stok_id) x
     where abs(coalesce(lot_kalan, 0) - coalesce(stok_kalan, 0)) > 0.001;

    raise notice '116: deposu bos kalan % satir; lot/stok bakiyesi tutmayan % stok (mutabakat AYRI is)',
                 v_kalan, v_fark;
end $$;
