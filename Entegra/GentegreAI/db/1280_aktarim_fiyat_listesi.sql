-- =============================================================================
--  1280 - DELPHİ STOK FİYATLARI -> FİYAT LİSTESİ (fn_aktar_fiyat_listesi)  (09.11.2026)
--
--  Kullanıcı (UNIVERSE): "universe DB den fiyat listesi ve fiyatlar migrate olmadı mı.. yoksa migrate et".
--  Aktarım STOKFIYAT'ı `stok_fiyat`a birebir taşıyor (5.324 satır) ama web'in satış / alış fiyatı
--  `fiyat_listesi` + `fiyat_listesi_satir` üzerinden gelir (204 fn_belge_kalem_fiyati: cari listesi >
--  yönün varsayılan listesi > kart fiyatı). Liste hiç kurulmayınca "Fiyat Listeleri" ekranı boş, cari
--  listesi seçilemiyor, fiyat yalnız kart fiyatı düşüşüyle (128) geliyordu.
--
--  DÖNÜŞÜM: Delphi'nin her FİYAT ADI bir listedir -
--    · satış adları (GENINI -1007: UNIVERSE'te 36 Satış, 37 Bayi) -> yön 2 (satış)
--    · alış adları  (GENINI -1008: 10 Alış)                       -> yön 1 (alış)
--    · maliyet adları (-1 Son Maliyet, -2 Ort.Maliyet) liste DEĞİL - atlanır (maliyet stok hareketinden).
--  Ad: 1180'in kurduğu kod listesi (kod_liste.eski_bolum -1007 / -1008) > stg.genini > "Fiyat <kod>".
--  Satır: fiyat > 0 olan stok_fiyat / hizmet_fiyat kayıtları, yazım 3 (İmport), döviz ve birim satırdan;
--  KDV hariç (Delphi KDVDURUM aktarımda 0). Yönün varsayılan listesi yoksa sırası en küçük ad varsayılan olur.
--
--  İDEMPOTENT: liste `aciklama` damgasıyla ('Delphi fiyat adı N') bulunur, satır çakışmada (liste+kalem+
--  birim+döviz) dokunulmaz - kullanıcının web'de düzelttiği fiyat ezilmez. stok_fiyat boş kurulumda (HBYS,
--  temiz ERP) hiçbir şey yapmaz. Göç sonunda bir kez çağrılır; aktar_ek.ps1 de yeni müşteride çağırır.
-- =============================================================================

create or replace function public.fn_aktar_fiyat_listesi()
returns jsonb
language plpgsql
as $$
declare
  r record;
  v_liste int; v_sube int; v_n int;
  v_liste_yeni int := 0; v_liste_mevcut int := 0; v_satir int := 0; v_atlanan int := 0;
begin
  -- Liste şubeye bağlı (KartKatalogu.FiyatListesi SubeKolonu); aktarımda tek şube olağan - ilk etkin şube.
  select coalesce((select min(id) from public.sube where coalesce(aktif, 1) = 1 and coalesce(varsayilan, 0) = 1),
                  (select min(id) from public.sube where coalesce(aktif, 1) = 1)) into v_sube;

  -- FİYAT ADLARI: hangi ad hangi yön (satış 2 / alış 1), sırası ve görünen adı.
  create temp table _fa (kod int primary key, yon smallint, sira int, ad varchar(100)) on commit drop;
  -- 1) 1180 kod listeleri (eski_bolum -1007 satış, -1008 alış)
  insert into _fa
  select kd.deger, case kl.eski_bolum when -1007 then 2 else 1 end::smallint,
         min(coalesce(kd.sira, 0)), min(kd.ad)
    from public.kod_liste kl join public.kod_deger kd on kd.liste_id = kl.id
   where kl.eski_bolum in (-1007, -1008)
   group by kd.deger, kl.eski_bolum
  on conflict do nothing;
  -- 2) stg.genini (aktarım makinesinde hâlâ duruyorsa) - tablo yoksa statik SQL derlenemez, dinamik.
  if to_regclass('stg.genini') is not null then
    execute $g$
      insert into _fa
      select g.deger::text::int, case g.bolum when -1007 then 2 else 1 end::smallint,
             min(coalesce(g.sira, 0)), min(g.anahtar)
        from stg.genini g
       where g.bolum in (-1007, -1008) and g.deger::text ~ '^-?[0-9]+$'
       group by g.deger::text::int, g.bolum
      on conflict do nothing $g$;
  end if;

  for r in
    select f.fiyat_adi as kod, f.satis,
           coalesce(a.yon, case when f.satis = 1 then 2 else 1 end::smallint) as yon,
           coalesce(a.sira, 999) as sira,
           coalesce(a.ad, 'Fiyat ' || f.fiyat_adi) as ad,
           count(*) as n
      from (select stok_id as kalem, fiyat_adi, satis from public.stok_fiyat where fiyat > 0
            union all
            select hizmet_id, fiyat_adi, 1::smallint from public.hizmet_fiyat where fiyat > 0) f
      left join _fa a on a.kod = f.fiyat_adi
     group by f.fiyat_adi, f.satis, a.yon, a.sira, a.ad
     order by coalesce(a.sira, 999), f.fiyat_adi
  loop
    -- Maliyet adları liste değil.
    if r.kod < 0 then v_atlanan := v_atlanan + r.n; continue; end if;

    select id into v_liste from public.fiyat_listesi
     where aciklama like 'Delphi fiyat adı ' || r.kod || ' %' and yon = r.yon
     order by id limit 1;
    if v_liste is null then
      -- Geçerlilik: eski belgeler de bu listeyle fiyatlansın diye 2000'den açık uçlu (web listeleri 2099-12-31).
      insert into public.fiyat_listesi (ad, yon, durum, kdv_dahil, tarife_tipi, sube_id, baslangic, bitis,
                                        aciklama, varsayilan, ekleyen)
      values (left(r.ad, 100), r.yon, 1, 0, 0, v_sube, date '2000-01-01', date '2099-12-31',
              'Delphi fiyat adı ' || r.kod || ' (aktarım 1280)',
              case when not exists (select 1 from public.fiyat_listesi where yon = r.yon and varsayilan = 1 and durum = 1)
                   then 1 else 0 end,
              0)
      returning id into v_liste;
      v_liste_yeni := v_liste_yeni + 1;
    else
      v_liste_mevcut := v_liste_mevcut + 1;
    end if;

    -- Stok satırları (çakışma: liste + stok + birim + döviz - dokunulmaz).
    insert into public.fiyat_listesi_satir
        (liste_id, stok_id, fiyat, doviz_cinsi, kdv_dahil, birim, durum, yazim, ekleyen)
    select v_liste, f.stok_id, f.fiyat, coalesce(nullif(f.doviz_cinsi, ''), 'TL'), 0,
           coalesce(f.birim, 0), 1, 3, 0
      from public.stok_fiyat f
      join public.stok s on s.id = f.stok_id
     where f.fiyat_adi = r.kod and f.satis = r.satis and f.fiyat > 0
    on conflict do nothing;
    get diagnostics v_n = row_count; v_satir := v_satir + v_n;

    -- Hizmet satırları (hizmet_fiyat'ta yön yok: satış sayılır).
    if r.satis = 1 then
      insert into public.fiyat_listesi_satir
          (liste_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, durum, yazim, ekleyen)
      select v_liste, f.hizmet_id, f.fiyat, coalesce(nullif(f.doviz_cinsi, ''), 'TL'), 0, 1, 3, 0
        from public.hizmet_fiyat f
        join public.hizmet h on h.id = f.hizmet_id
       where f.fiyat_adi = r.kod and f.fiyat > 0
      on conflict do nothing;
      get diagnostics v_n = row_count; v_satir := v_satir + v_n;
    end if;
  end loop;

  return jsonb_build_object('liste_yeni', v_liste_yeni, 'liste_mevcut', v_liste_mevcut,
                            'satir_eklenen', v_satir, 'maliyet_atlanan', v_atlanan);
end $$;

comment on function public.fn_aktar_fiyat_listesi() is
  '1280: Delphi fiyat adları (stok_fiyat / hizmet_fiyat) -> fiyat_listesi + satırları (idempotent; aktar_ek.ps1 ve göç).';

-- Göç sırasında bir kez: aktarımlı kurulumda listeler kurulur, boş kurulumda hiçbir şey olmaz.
do $kontrol$
declare v jsonb;
begin
    v := public.fn_aktar_fiyat_listesi();
    raise notice '1280 tamam: fiyat listeleri %', v;
end $kontrol$;
