-- =============================================================================
--  1080  AKTARIM KAYNAK KİMLİĞİ (dokuman/18 §11 adım 1)
--
--  Kullanıcı (13.10.2026): "tek yön delphi de web e migration olsun" - "başla".
--  Pilot: kaynak BILIM (MSSQL), hedef sunucudaki ERP (gentegre_erp).
--
--  SORUN. İlk kurulum göçü MSSQL kimliğini web'de AYNEN kullanıyordu
--  (taraf.id = REHBER.ID, belge.id = FATBASLIK.ID...). Sürekli aktarımda bu
--  çakışır: web de aynı tablolara yazıyor (HBYS hastaları ve kullanıcılar
--  `taraf`ta) ve hedef ERP'de zaten id 1-36 taraf, 1-332 stok var - BILIM'in
--  cari id'leri 1-5906. Delphi'de yeni açılan bir cari, web'deki bir kaydın
--  id'sini alabilir.
--
--  ÇÖZÜM. Web kendi id'sini HER ZAMAN kendisi üretir; Delphi'deki kimlik ayrı
--  kolonlarda tutulur ve aktarım eşlemeyi bunlarla yapar:
--      aktarim_kaynak  smallint     1 = Delphi ERP (NULL = web'de açıldı)
--      aktarim_tablo   varchar(30)  Delphi tablo adı (REHBER, KASALAR...)
--      aktarim_id      bigint       Delphi'deki ID
--  `aktarim_tablo` şart: `hesap` dört Delphi tablosundan gelir (KASALAR,
--  BANKAHESAPLAR, KREDIKARTI, POS) ve id'leri çakışabilir.
--  Ad öneki `aktarim_`: belge/mali_hareket/stok_izleme'de `kaynak_tur` /
--  `kaynak_id` zaten var ve İŞ anlamı taşıyor (belge hangi belgeden üretildi).
--
--  Bu betik yalnız KOLON + İNDEKS ekler - her ortamda güvenli, veri değiştirmez.
--  Var olan göç kayıtlarını işaretlemek AYRI ve ELLE çağrılan bir fonksiyondur
--  (fn_aktarim_kaynak_isaretle): hedef ERP'nin stg verisi BILIM'den gelmediği
--  için otomatik işaretleme yanlış damga vururdu. İdempotent.
-- =============================================================================

begin;

do $$
declare
    t text;
begin
    foreach t in array array[
        -- göçte id'si korunan tablolar
        'taraf', 'taraf_adres', 'depo', 'hizmet', 'masraf', 'stok', 'stok_seri_lot',
        'belge', 'belge_satir', 'mali_hareket', 'stok_izleme', 'kredi',
        -- id'si yeni üretilen, eşlemesi doğal anahtarla yapılacak tablolar
        'doviz_kur', 'hesap', 'proje', 'masraf_merkezi',
        'stok_barkod', 'stok_fiyat', 'hizmet_fiyat', 'masraf_fiyat']
    loop
        execute format('alter table public.%I add column if not exists aktarim_kaynak smallint', t);
        execute format('alter table public.%I add column if not exists aktarim_tablo varchar(30)', t);
        execute format('alter table public.%I add column if not exists aktarim_id bigint', t);
        execute format(
            'create unique index if not exists %I on public.%I (aktarim_kaynak, aktarim_tablo, aktarim_id) '
            'where aktarim_kaynak is not null', 'ux_' || t || '_aktarim', t);
    end loop;
end $$;

-- -----------------------------------------------------------------------------
-- VAR OLAN GÖÇ KAYITLARINI İŞARETLE (elle çağrılır)
--
--   select * from fn_aktarim_kaynak_isaretle();         -- yalnız RAPOR (varsayılan)
--   select * from fn_aktarim_kaynak_isaretle(true);     -- uygula
--
-- Bir satır ancak KANITLANABİLİR ise işaretlenir: stg'de aynı id'li satır VAR
-- ve ikinci bir alan da tutuyor (kod / bağlı kayıt). Yalnız id eşitliği yetmez -
-- stg başka bir kaynaktan doldurulmuş olabilir (hedef ERP'de öyle).
-- Zaten işaretli satıra dokunmaz. stg tablosu yoksa o satır atlanır.
-- -----------------------------------------------------------------------------
create or replace function public.fn_aktarim_kaynak_isaretle(p_uygula boolean default false)
returns table (tablo text, kaynak text, toplam bigint, eslesen bigint, isaretlenen bigint)
language plpgsql as $$
declare
    r record;
    v_toplam bigint;
    v_eslesen bigint;
    v_isaret bigint;
begin
    for r in
        select * from (values
            ('taraf',         'REHBER',         'rehber',         'coalesce(x.kod, '''') = coalesce(s.kod, '''')'),
            ('taraf_adres',   'REHBERILETISIM', 'rehberiletisim', 'x.taraf_id = s.rehberid'),
            ('depo',          'DEPOLAR',        'depolar',        'coalesce(x.ad, '''') = coalesce(s.depoadi, '''')'),
            ('hizmet',        'MASRAFGELIR',    'masrafgelir',    'coalesce(x.kod, '''') = coalesce(s.kod, '''')'),
            ('masraf',        'MASRAFGELIR',    'masrafgelir',    'coalesce(x.kod, '''') = coalesce(s.kod, '''')'),
            ('stok',          'STOKLAR',        'stoklar',        'coalesce(x.kod, '''') = coalesce(s.kod, '''')'),
            ('stok_seri_lot', 'STOKSERILOT',    'stokserilot',    'x.stok_id = s.stokid'),
            ('belge',         'FATBASLIK',      'fatbaslik',      'x.taraf_id is not distinct from s.rehberid'),
            ('belge_satir',   'FATURA',         'fatura',         'x.belge_id = s.fatbasid'),
            ('mali_hareket',  'KASA',           'kasa',           'x.taraf_id is not distinct from s.rehberid'),
            ('stok_izleme',   'STOKIZLEME',     'stokizleme',     'x.stok_id = s.stokid'),
            ('kredi',         'KREDILER',       'krediler',       'x.taraf_id is not distinct from s.rehberid')
        ) v(tablo, kaynak, stg, kosul)
    loop
        if to_regclass('stg.' || r.stg) is null then
            tablo := r.tablo; kaynak := r.kaynak; toplam := null; eslesen := null; isaretlenen := 0;
            return next;
            continue;
        end if;

        execute format('select count(*) from public.%I', r.tablo) into v_toplam;
        execute format(
            'select count(*) from public.%I x join stg.%I s on s.id = x.id and %s '
            'where x.aktarim_kaynak is null', r.tablo, r.stg, r.kosul) into v_eslesen;

        v_isaret := 0;
        if p_uygula and v_eslesen > 0 then
            execute format(
                'update public.%I x set aktarim_kaynak = 1, aktarim_tablo = %L, aktarim_id = x.id '
                '  from stg.%I s where s.id = x.id and %s and x.aktarim_kaynak is null',
                r.tablo, r.kaynak, r.stg, r.kosul);
            get diagnostics v_isaret = row_count;
        end if;

        tablo := r.tablo; kaynak := r.kaynak; toplam := v_toplam;
        eslesen := v_eslesen; isaretlenen := v_isaret;
        return next;
    end loop;
end $$;

comment on function public.fn_aktarim_kaynak_isaretle(boolean) is
    '1080: göçle gelmiş satırları Delphi kaynağı olarak işaretler (stg ile id + ikinci alan eşleşmesi). Varsayılan yalnız rapor.';

commit;
