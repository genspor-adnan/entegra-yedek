-- =============================================================================
--  1249  LOT DEFTERİNİ HAREKETLERDEN KURMA - TRANSFER VE İRSALİYEDEN TÜREYEN FATURA
--
--  Kullanıcı 02.11.2026: "lot defterini kurma fonksiyonunu da düzelt".
--
--  1172 fn_stok_lot_durum_kur() / tg_stok_izleme_lot_aktarim her izlem satırının etkisini YALNIZ kendi deposuna
--  yazıyordu (fn_stok_izleme_etki). İki durumda yanlış:
--   1) WEB TRANSFERİ stok_izleme'ye tek satır yazar: deposu GİRİŞ deposu, lot bakiyesi iki depoya doğrudan
--      (BelgeDeposu.LottanDusAsync). Çıkış tarafı hareket olarak yoktur -> baştan kurulumda çıkış deposu hiç
--      düşmüyordu. Zincir kaynağı bulunamayan web transferinde donus_id 0 kalır ve satır ÇIKIŞ sayılıyordu.
--   2) İRSALİYEDEN TÜREYEN FATURA satırı (belge_satir.stok_durum_degis = 0) stoğu oynatmaz; Delphi'deki izlemi
--      yalnız referanstır ama çıkış sayılıyordu (UNIVERSE: SUPRAMİD 211105).
--
--  YENİ KURAL - fn_stok_lot_hareketleri(): her izlem satırı (stok, depo, lot, etki) üretir.
--   - Transfer (20), belge satırının giriş deposu biliniyorsa: satır GİRİŞ deposundaysa +adet, değilse -adet
--     (aktarım: çıkış satırı -, 1248 varış satırı +; Delphi'nin kendi varış satırı da giriş deposunda +).
--   - Web transferi (aktarim_kaynak boş) giriş deposundaki satır için çıkış deposuna AYRICA -adet.
--   - stok_durum_degis = 0 satır: 0.
--   - Diğerleri 1172 fn_stok_izleme_etki.
--  UNIVERSE'te doğrulandı: yeni kural mevcut (Delphi ile karşılaştırılıp onarılmış) defteri birebir üretir -
--  2.962 satır aynı, 0 fark.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_stok_lot_hareketleri()
returns table (stok_id integer, depo_id integer, seri_lot_id integer, etki numeric)
language sql stable as $$
    select i.stok_id, i.depo_id, i.seri_lot_id,
           case when i.belge_tur = 20 and g.giris is not null
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
       and i.depo_id = g.giris and g.cikis is not null and g.cikis <> g.giris
$$;

comment on function public.fn_stok_lot_hareketleri() is
  '1249: lot hareketlerinin depo bazında etkisi (transfer iki taraflı, irsaliyeden türeyen fatura etkisiz) - defter kurulumu ve aktarım tetiği.';

-- ------------------------------------------------------------ tam kurulum --
create or replace function public.fn_stok_lot_durum_kur()
returns jsonb language plpgsql as $$
declare
    v_satir integer;
    v_korunan integer;
    v_eksi integer;
begin
    perform set_config('gentegre.aktarim', '1', true);

    drop table if exists _lot_yeni;
    create temp table _lot_yeni on commit drop as
    select h.stok_id, h.depo_id, h.seri_lot_id, sum(h.etki) as kalan
      from public.fn_stok_lot_hareketleri() h
     where exists (select 1 from public.stok s where s.id = h.stok_id)
       and exists (select 1 from public.depo d where d.id = h.depo_id)
       and exists (select 1 from public.stok_seri_lot l where l.id = h.seri_lot_id)
     group by 1, 2, 3;

    -- Hareketi olmayan mevcut satır (web'de elle girilmiş lot) korunur.
    insert into _lot_yeni
    select m.stok_id, m.depo_id, m.seri_lot_id, m.kalan
      from public.stok_lot_durum m
     where not exists (select 1 from _lot_yeni y
                        where (y.stok_id, y.depo_id, y.seri_lot_id) = (m.stok_id, m.depo_id, m.seri_lot_id));
    get diagnostics v_korunan = row_count;

    delete from public.stok_lot_durum;
    insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan)
    select stok_id, depo_id, seri_lot_id, kalan from _lot_yeni where kalan <> 0;
    get diagnostics v_satir = row_count;
    select count(*) into v_eksi from public.stok_lot_durum where kalan < 0;

    insert into public.stok_lot_durum_islenen (tek_satir, son_izlem_id)
    values (true, coalesce((select max(id) from public.stok_izleme), 0))
    on conflict (tek_satir) do update set son_izlem_id = excluded.son_izlem_id, islem_tarihi = now()::timestamp;

    return jsonb_build_object('lot_bakiye', v_satir, 'eksi', v_eksi, 'hareketsiz_korunan', v_korunan);
end $$;

comment on function public.fn_stok_lot_durum_kur() is
  '1172/1249: lot defterini (stok_lot_durum) fn_stok_lot_hareketleri''nden baştan kurar; hareketi olmayan satır korunur.';

-- ------------------------------------------------- sürekli aktarım tetiği --
create or replace function public.tg_stok_izleme_lot_aktarim()
returns trigger language plpgsql as $$
begin
    -- Yalnız AKTARIM: web belgesi defteri kendisi günceller (çift sayılmasın).
    if coalesce(current_setting('gentegre.aktarim', true), '') <> '1' then
        return null;
    end if;

    create temp table if not exists _lot_cift (stok_id integer, depo_id integer) on commit drop;
    truncate _lot_cift;
    if tg_op in ('INSERT', 'UPDATE') then
        insert into _lot_cift select distinct stok_id, depo_id from yeni where depo_id is not null and seri_lot_id is not null;
    end if;
    if tg_op in ('DELETE', 'UPDATE') then
        insert into _lot_cift select distinct stok_id, depo_id from eski where depo_id is not null and seri_lot_id is not null;
    end if;
    if not exists (select 1 from _lot_cift) then return null; end if;

    delete from public.stok_lot_durum d
     using (select distinct stok_id, depo_id from _lot_cift) c
     where d.stok_id = c.stok_id and d.depo_id = c.depo_id;

    insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan)
    select h.stok_id, h.depo_id, h.seri_lot_id, sum(h.etki)
      from public.fn_stok_lot_hareketleri() h
      join (select distinct stok_id, depo_id from _lot_cift) c on c.stok_id = h.stok_id and c.depo_id = h.depo_id
     where exists (select 1 from public.stok_seri_lot l where l.id = h.seri_lot_id)
     group by 1, 2, 3
    having sum(h.etki) <> 0;
    return null;
end $$;

commit;
