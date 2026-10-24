-- =============================================================================
--  1172  DELPHI AKTARIMI - LOT DEFTERİ (stok_lot_durum) KURULUR
--
--  Kullanıcı (24.10.2026, UNIVERSE sayımı): "hiç bir satırda izlem bilgilerini
--  göremedim" / "sistemde 20 yazıyor saydım 18, 2 tane lotu çıkarmam lazım" ->
--  "kural olarak ekle".
--
--  Aktarım lot HAREKETLERİNİ (stok_izleme, Delphi STOKIZLEME) yazıyor ama lot
--  BAKİYESİNİ (stok_lot_durum) hiç kurmuyordu: web belgesi bakiyeyi kendisi
--  günceller (BelgeDeposu), aktarım güncellemez - 1084 stok_durum'u Delphi
--  STOKDURUM'un aynası yapar, lot için aynası yok. UNIVERSE'te 4.257 hareket,
--  defterde 3 satır kaldı: sayımda bütün izlemli stoklar "lotsuz" geldi, kart lot
--  dökümü boştu. (UNIVERSE elle kuruldu: 2.951 bakiye, 539 stok-depodan 519'u
--  stok bakiyesini tutuyor; tutmayanlar Delphi'de lotsuz giriş / lotu girilmeden
--  çıkış.)
--
--  1) fn_stok_lot_durum_kur(): defteri hareketlerden BAŞTAN kurar (118'in yön
--     kuralı). Hareketi olmayan mevcut satır korunur (web'de girilmiş). Ek
--     aktarımın (fn_aktar_ek, aktar_ek.ps1) son adımı; aktarımla kurulmuş başka
--     DB'de elle de çalıştırılır.
--  2) SÜREKLİ AKTARIM: stok_izleme'ye deyim düzeyinde tetik - yalnız aktarım
--     yazarken (gentegre.aktarim = 1) dokunulan stok-depo çiftlerinin defteri
--     yeniden hesaplanır. Aktarım fonksiyonları (fn_aktar_belge ...) değişmez;
--     onlar yeniden tanımlansa da kural sürer.
--  3) fn_belge_cikis_mi: stok fişleri (3 / 4) iadesiz - BelgeTuru.IadesizTurler
--     (C#, 24.10.2026) ile AYNI (1084: "Değişirse ikisi birlikte").
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- ---------------------------------------------------------------- yön kuralı --
-- Hareketin lot bakiyesine etkisi (118 ile aynı): çıkış türleri eksi, transferin
--   varış satırı artı / çıkış satırı eksi, sipariş / talep etkisiz, diğerleri artı.
create or replace function public.fn_stok_izleme_etki(p_belge_tur integer, p_donus_id bigint, p_adet numeric)
returns numeric language sql immutable as $$
    select case when p_belge_tur in (14, 15, 16, 119, 4, 29, 133) then -p_adet
                when p_belge_tur = 20 and coalesce(p_donus_id, 0) <> 0 then p_adet
                when p_belge_tur = 20 then -p_adet
                when p_belge_tur in (101, 105) then 0
                else p_adet end
$$;

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
    select i.stok_id, i.depo_id, i.seri_lot_id,
           sum(public.fn_stok_izleme_etki(i.belge_tur, i.donus_id, i.adet)) as kalan
      from public.stok_izleme i
     where i.depo_id is not null and i.seri_lot_id is not null
       and exists (select 1 from public.stok s where s.id = i.stok_id)
       and exists (select 1 from public.depo d where d.id = i.depo_id)
       and exists (select 1 from public.stok_seri_lot l where l.id = i.seri_lot_id)
     group by 1, 2, 3;

    -- Hareketi olmayan mevcut satır (web'de girilmiş lot) korunur.
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

    -- 118'in kontrol kaydı ileri alınır: aynı hareketler ikinci kez işlenmesin.
    insert into public.stok_lot_durum_islenen (tek_satir, son_izlem_id)
    values (true, coalesce((select max(id) from public.stok_izleme), 0))
    on conflict (tek_satir) do update set son_izlem_id = excluded.son_izlem_id, islem_tarihi = now()::timestamp;

    return jsonb_build_object('lot_bakiye', v_satir, 'eksi', v_eksi, 'hareketsiz_korunan', v_korunan);
end $$;

comment on function public.fn_stok_lot_durum_kur() is
  '1172: lot defterini (stok_lot_durum) stok_izleme hareketlerinden bastan kurar; hareketi olmayan satir korunur.';

-- Ek aktarım adımı (fn_aktar_ek 'fn_aktar_ek_%s' deseni).
create or replace function public.fn_aktar_ek_lot_durum()
returns jsonb language sql as $$ select public.fn_stok_lot_durum_kur() $$;

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
    select i.stok_id, i.depo_id, i.seri_lot_id, sum(public.fn_stok_izleme_etki(i.belge_tur, i.donus_id, i.adet))
      from public.stok_izleme i
      join (select distinct stok_id, depo_id from _lot_cift) c on c.stok_id = i.stok_id and c.depo_id = i.depo_id
     where i.seri_lot_id is not null
       and exists (select 1 from public.stok_seri_lot l where l.id = i.seri_lot_id)
     group by 1, 2, 3
    having sum(public.fn_stok_izleme_etki(i.belge_tur, i.donus_id, i.adet)) <> 0;
    return null;
end $$;

-- PG: geçiş tablolu deyim tetiği tek olaya bağlanır - üç ayrı tetik.
drop trigger if exists trg_stok_izleme_lot_aktarim_ekle on public.stok_izleme;
create trigger trg_stok_izleme_lot_aktarim_ekle after insert on public.stok_izleme
    referencing new table as yeni for each statement execute function public.tg_stok_izleme_lot_aktarim();
drop trigger if exists trg_stok_izleme_lot_aktarim_degis on public.stok_izleme;
create trigger trg_stok_izleme_lot_aktarim_degis after update on public.stok_izleme
    referencing old table as eski new table as yeni for each statement execute function public.tg_stok_izleme_lot_aktarim();
drop trigger if exists trg_stok_izleme_lot_aktarim_sil on public.stok_izleme;
create trigger trg_stok_izleme_lot_aktarim_sil after delete on public.stok_izleme
    referencing old table as eski for each statement execute function public.tg_stok_izleme_lot_aktarim();

-- ------------------------------------------------- fn_aktar_ek: son adım --
create or replace function public.fn_aktar_ek()
returns jsonb language plpgsql as $$
declare
    v_sonuc jsonb := '{}';
    v_m text;
    v_r jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);
    foreach v_m in array array['kategori', 'kisi', 'hesap_plani', 'demirbas', 'cek', 'teklif', 'gorev', 'dokuman', 'ebelge', 'lot_durum'] loop
        begin
            execute format('select public.fn_aktar_ek_%s()', v_m) into v_r;
            v_sonuc := v_sonuc || jsonb_build_object(v_m, v_r);
        exception when others then
            v_sonuc := v_sonuc || jsonb_build_object(v_m, jsonb_build_object('hata', sqlerrm));
        end;
    end loop;
    return v_sonuc;
end $$;

comment on function public.fn_aktar_ek() is
    '1149/1171/1172: Delphi ek modülleri (stg) sırayla aktarır - kategori, kişi, hesap planı, demirbaş, çek, teklif, görev, döküman, e-Belge; sonda lot defteri kurulur. Modül hatası diğerlerini durdurmaz.';

-- ------------------------------------------- yön: stok fişleri iadesiz --
create or replace function public.fn_belge_cikis_mi(p_tur integer, p_tipi integer)
returns boolean language sql immutable as $$
    select case when p_tipi = 2 and p_tur not in (9, 18, 19, 20, 105, 3, 4)
                then not (p_tur in (17, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123))
                else p_tur in (17, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123) end
$$;

commit;
