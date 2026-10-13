-- =============================================================================
--  1091  DELPHI AKTARIMI - ADIM 7: MUTABAKAT   (dokuman/18 §11)
--
--  Sunucu Delphi'yi göremez; ajan gece (ya da --mutabakat ile) her KÖK tablonun
--  Delphi'deki kimlik listesini yollar, sunucu web'deki aktarım kimlikleriyle
--  karşılaştırır:
--    eksik = Delphi'de var, web'de HİÇ yok           -> ajan toplamı yeniden yollar
--    fazla = web'de AKTİF, Delphi listesinde yok      -> ajan Delphi'de yeniden
--            doğrular (liste alındıktan sonra eklenmiş olabilir), gerçekten
--            yoksa D yollar. Tam yükleme ve CT saklama süresini aşan kesinti
--            silinmişi göremiyordu; bu adım onu kapatır.
--  Ajan önce eksikleri yollar, sonra ikinci kez sorar: hâlâ eksik olan KURAL
--  gereği aktarılmayandır (tanımsız kasa türü, mamulü çözülmeyen reçete,
--  makine olmayan lokasyon...) - hata değil, bilgi ('atlanan').
--  Hareket tablolarında liste hareket_baslangic'tan; web tarafı süzülmez:
--  başlangıç ileri alınınca önceki hareketler web'de KALIR (Delphi'de var ->
--  fazla değil) - Veri Kaynağı sekmesindeki onay metniyle aynı kural.
--  Kapsam dışı: DOVIZ (bileşik anahtar, D yok), SRMMERKEZI (D yok - yalnız eksik),
--  STOKDURUM (her değişiklikte aynası yazılır).
-- =============================================================================

begin;

create table if not exists public.aktarim_mutabakat (
    id       bigserial primary key,
    zaman    timestamptz not null default now(),
    ajan_id  integer references public.aktarim_ajan (id),
    tablo    varchar(40) not null,
    delphi   integer not null,     -- Delphi'deki kimlik sayısı (süzgeçli)
    web      integer not null,     -- web'deki aktarım kimliği sayısı (pasif dahil)
    eksik    integer not null,     -- ilk karşılaştırma
    fazla    integer not null,
    giderilen integer not null default 0,  -- ajanın yeniden yolladığı / sildiği
    atlanan  integer not null default 0,   -- yeniden yollandıktan sonra hâlâ eksik (kural gereği)
    ornek    jsonb                 -- ilk birkaç eksik / fazla kimlik
);
create index if not exists ix_aktarim_mutabakat_zaman on public.aktarim_mutabakat (zaman desc);

-- Kök tablo -> web'deki aktarım kimlikleri (tum) ve D'nin geri alabileceği AKTİF olanlar.
create or replace function public.fn_aktarim_web_kimlikleri(p_tablo text)
returns table (aktarim_id bigint, aktif boolean) language plpgsql stable as $$
begin
    case p_tablo
    when 'DEPOLAR' then
        return query select x.aktarim_id, x.durum <> 0 from public.depo x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'SRMMERKEZI' then   -- D yok: fazla raporlanmaz
        return query select x.aktarim_id, false from public.masraf_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'REHBER' then       -- 0 = Tanımsız Cari (1085): Delphi'de REHBER satırı değil, web kartı
        return query select x.aktarim_id, x.durum <> 0 and x.aktarim_id <> 0 from public.taraf x
                      where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'PROJELER' then
        return query select x.aktarim_id, x.durum <> 0 from public.proje x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'MASRAFGELIR' then
        return query select x.aktarim_id, bool_or(x.aktif) from (
                         select h.aktarim_id, h.durum <> 0 aktif from public.hizmet h where h.aktarim_kaynak = 1 and h.aktarim_tablo = p_tablo
                         union all
                         select m.aktarim_id, m.durum <> 0 from public.masraf m where m.aktarim_kaynak = 1 and m.aktarim_tablo = p_tablo) x
                      group by x.aktarim_id;
    when 'STOKLAR' then
        return query select x.aktarim_id, x.durum <> 0 from public.stok x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER' then
        return query select x.aktarim_id, x.durum <> 0 from public.hesap x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'LOKASYON' then     -- iş merkezinde pasif = 1 (1083)
        return query select x.aktarim_id, x.durum <> 1 from public.is_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'URETIMRECETE' then -- ürün ağacında pasif = 1 (1083)
        return query select x.aktarim_id, x.durum <> 1 from public.urun_agaci x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'FATBASLIK' then    -- D belgeyi siler: her satır "aktif"
        return query select x.aktarim_id, true from public.belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'KASA' then         -- cari satırı mali_hareket, hesap satırı kasa_islem (1085)
        return query select x.aktarim_id, true from (
                         select m.aktarim_id from public.mali_hareket m where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA'
                         union
                         select k.aktarim_id from public.kasa_islem k where k.aktarim_kaynak = 1 and k.aktarim_tablo = 'KASA') x;
    else
        raise exception using errcode = 'GK422', message = format('AKTARIM_TABLO: %s mutabakata girmez', p_tablo);
    end case;
end $$;

-- Karşılaştırma (yazmaz). p_idler: Delphi'deki kimlikler.
create or replace function public.fn_aktarim_mutabakat(p_tablo text, p_idler bigint[])
returns jsonb language sql stable as $$
    with w as (select * from public.fn_aktarim_web_kimlikleri(p_tablo)),
         d as (select distinct unnest(coalesce(p_idler, '{}')) id)
    select jsonb_build_object(
        'tablo', p_tablo,
        'delphi', (select count(*) from d),
        'web', (select count(*) from w),
        'eksik', coalesce((select jsonb_agg(d.id order by d.id) from d where not exists (select 1 from w where w.aktarim_id = d.id)), '[]'),
        'fazla', coalesce((select jsonb_agg(w.aktarim_id order by w.aktarim_id) from w
                            where w.aktif and not exists (select 1 from d where d.id = w.aktarim_id)), '[]'))
$$;

comment on function public.fn_aktarim_mutabakat(text, bigint[]) is
    '1091: Delphi kök kimlik listesi <-> web aktarım kimlikleri; eksik (web''de yok) / fazla (web''de aktif, Delphi''de yok).';

commit;
