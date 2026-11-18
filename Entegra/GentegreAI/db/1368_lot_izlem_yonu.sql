-- =============================================================================
--  1368  LOT İZLEMİNDE YÖN (stok/belge incelemesi 18.11.2026, bulgu 1-3)
--
--  Lot yolu yönü belge TÜRÜNDEN alıyordu (iade tipini bilmeden), stok ise tür + tipten: satış iadesinde stok girerken
--  lot düşüyor, alış iadesinde stok çıkarken lot ekleniyordu. Geri alma (düzenleme / silme) de yönü belgeden
--  türettiği için satırın gerçekte yazdığı etkiyle uyuşmuyordu. Taslak belge lot bakiyesini değiştiriyordu.
--
--  stok_izleme.yon: web yazıcısının satıra yazdığı etki - +1 giriş, -1 çıkış, 0 taslak (bakiyeye etkisiz).
--  Boş = aktarım (Delphi) ya da transfer satırı: eski kurallar (fn_stok_izleme_etki, transfer iki depo).
--  Geri alma ve defter kurulumu (fn_stok_lot_hareketleri) yönü satırdan okur.
--
--  GEÇMİŞ WEB SATIRLARI: eski yazıcının fiilen yaptığı yön yazılır (tür çıkış türüyse -1, değilse +1) - defter
--  kurulumu ve sonraki geri alma, bakiyeye ne yazıldıysa onu bulur. İadelerin stok / lot ayrışması (eski kural)
--  bu dosyayla düzelmez, ayrıca ölçülür. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.stok_izleme add column if not exists yon smallint;
comment on column public.stok_izleme.yon is
  '1368: web izlem satırının lot bakiyesine yazdığı yön: +1 giriş, -1 çıkış, 0 taslak (etkisiz). Boş = aktarım / transfer (eski kural).';

do $$
declare v_sayi integer;
begin
    update public.stok_izleme
       set yon = case when belge_tur in (17, 128, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123) then -1 else 1 end
     where yon is null and aktarim_kaynak is null and belge_tur <> 20 and seri_lot_id is not null;
    get diagnostics v_sayi = row_count;
    raise notice '1368: yönü yazılan geçmiş web izlem satırı = %', v_sayi;
end $$;

create or replace function public.fn_stok_lot_hareketleri()
returns table (stok_id integer, depo_id integer, seri_lot_id integer, etki numeric)
language sql stable as $$
    select i.stok_id, i.depo_id, i.seri_lot_id,
           -- 1368: web satırı YÖNÜNÜ kendisi taşır (+1 giriş, -1 çıkış, 0 taslak); yazılan etki aynen.
           case when i.yon is not null then i.yon * i.adet
                when i.belge_tur = 20 and g.giris is not null
                     then case when i.depo_id = g.giris then i.adet else -i.adet end
                when coalesce(s.stok_durum_degis, 1) = 0 then 0
                else public.fn_stok_izleme_etki(i.belge_tur, i.donus_id, i.adet) end
      from public.stok_izleme i
      left join public.belge_satir s on s.id = i.belge_satir_id
      left join public.belge b on b.id = i.belge_id
      cross join lateral (select coalesce(s.giris_depo_id, b.giris_depo_id) as giris) g
     where i.depo_id is not null and i.seri_lot_id is not null
    union all
    -- Web transferinin yazılmayan ÇIKIŞ tarafı.
    select i.stok_id, g.cikis, i.seri_lot_id, -i.adet
      from public.stok_izleme i
      left join public.belge_satir s on s.id = i.belge_satir_id
      left join public.belge b on b.id = i.belge_id
      cross join lateral (select coalesce(s.giris_depo_id, b.giris_depo_id) as giris,
                                 coalesce(s.cikis_depo_id, b.cikis_depo_id) as cikis) g
     where i.belge_tur = 20 and i.aktarim_kaynak is null and i.seri_lot_id is not null
       and coalesce(i.yon, 1) <> 0                       -- 1368: taslak transfer satırı etkisiz
       and i.depo_id = g.giris and g.cikis is not null and g.cikis <> g.giris
$$;

comment on function public.fn_stok_lot_hareketleri() is
  '1249/1368: lot hareketlerinin depo bazında etkisi - web satırı kendi yönüyle (yon), transfer iki taraflı, irsaliyeden türeyen fatura etkisiz.';

commit;
