-- =============================================================================
--  1082  DELPHI AKTARIMI - DİLİM 2: DÖVİZ, MASRAF MERKEZİ, PROJE, KALEM (hizmet /
--        masraf + fiyat), STOK (barkod, fiyat, seri/lot), HESAP (kasa, banka, POS,
--        kredi kartı, kredi)  (dokuman/18 §11.4 adım 3)
--
--  Paket biçimi ve kurallar 1081 ile aynı: {"U": {TABLO: [satır]}, "D": {...}},
--  stg şekline çevrilir, göç SQL'i (013, 080) referanstır; içeriği aynı satıra
--  yazılmaz; web'in kaydı ezilmez; silinen kayıt pasifleşir.
--
--  BU DİLİMİN KURALLARI
--   * KOD / ANAHTAR ÇAKIŞMASI: web'de aynı benzersiz anahtarla açılmış kayıt varsa
--     (hesap tür+kod, masraf merkezi / proje kodu, stok barkodu - ilaç kataloğu,
--     döviz cins+tarih, fiyat doğal anahtarı) Delphi satırı ATLANIR ve sayılır
--     ('cakisma'); web kaydına dokunulmaz.
--   * DÖVİZ: Delphi DOVIZ'in ID'si yok, anahtar CINSI + TARIH -> doğal anahtarla
--     (doviz_cinsi, tarih) eşlenir; aynı gün birden çok satırda en geç saat kazanır.
--   * KALEM: MASRAFGELIR web'de HİZMET ve MASRAF olarak ikiye bölünür. Göç ayrımı
--     belge kullanımından yapıyordu; anlık aktarımda kalem geldiğinde kullanım
--     bilinmez -> GELIRMI = 1 hizmet, 0 masraf, başlık ikisine birden. Diğer tarafta
--     kullanan belge gelince karşılığı belge diliminde açılır. Var olan karşılık
--     her zaman güncellenir.
--   * BARKOD / VARSAYILAN: stok başına tek varsayılan barkod (indeks satır satır
--     denetlenir) -> önce aktarılan barkodların varsayılanlığı sıfırlanır, sonra yazılır.
--   * HESAP AÇILIŞ BAKİYESİ = Delphi bakiyesi (göç 080 ile aynı).
--   * PARA BİRİMİ ISO: Delphi '$' '€' '£' -> fn_doviz_iso (083) -> USD EUR GBP;
--     döviz kuru, hesap, proje bütçesi, BÜTÜN fiyat tabloları. (Eşdeğerlik testi:
--     çevrilmeyince aynı günün kuru hem USD hem $ satırı oldu, 30 hesap USD -> $.)
--   * TARİH KOLONU saat dilimine sokulmaz (fn_aktarim_tarih): timestamptz -> date
--     dönüşümü veritabanının UTC'sini kullanır, İstanbul gece yarısı önceki güne
--     düşüyordu (proje / kredi / seri-lot tarihleri bir gün geride).
--   * Delphi kimliği 0 = "yok" (fn_aktarim_web_id 1081'de 0'ı kimlik sanıyordu).
--   * ÇAKIŞMA DENETİMİ NULL'A DİKKAT: web kaydında aktarim_kaynak boş;
--     `not (aktarim_kaynak = 1 and ...)` NULL döner ve web kaydı "çakışan" sayılmaz
--     -> insert benzersiz indekste patlar. `not coalesce(..., false)` (test yakaladı).
--  İdempotent.
-- =============================================================================

begin;

-- ================================================================ yardımcılar ===
-- Delphi tarih kolonu -> date (saat dilimi YOK; 1901 öncesi = Delphi boş tarihi).
create or replace function public.fn_aktarim_tarih(p timestamp)
returns date language sql immutable as $$
    select case when p is null or p < timestamp '1901-01-01' then null else p::date end
$$;

-- 1081'in yeniden tanımı: Delphi'de 0 = "yok" (ilişki boş), kimlik değil.
create or replace function public.fn_aktarim_web_id(p_tablo text, p_kaynak_tablo text, p_delphi bigint)
returns integer language plpgsql stable as $$
declare v integer;
begin
    if p_delphi is null or p_delphi = 0 then return null; end if;
    execute format('select id from public.%I where aktarim_kaynak = 1 and aktarim_tablo = $1 and aktarim_id = $2',
                   p_tablo) into v using p_kaynak_tablo, p_delphi;
    return v;
end $$;

-- ===================================================== işaretleme (genişletme) ===
-- 1080'in fonksiyonu 080'in eski_tablo / eski_id eşlemesini ve doğal anahtarlı
-- tabloları da kapsayacak şekilde genişletilir. Kural aynı: kanıtlanabilir eşleşme.
-- İmza değişti (tablo süzgeci): eski tek parametreli sürüm kaldırılır.
drop function if exists public.fn_aktarim_kaynak_isaretle(boolean);

create or replace function public.fn_aktarim_kaynak_isaretle(p_uygula boolean default false,
                                                             p_tablo text default null)
returns table (tablo text, kaynak text, toplam bigint, eslesen bigint, isaretlenen bigint)
language plpgsql as $$
declare
    r record;
    v_toplam bigint; v_eslesen bigint; v_isaret bigint;
begin
    for r in
        select * from (values
            -- tablo, kaynak, stg (varlık denetimi), kaynak ifadesi (s), birleşme (x = web), aktarim_id
            ('taraf',         'REHBER',         'rehber',         'stg.rehber',         's.id = x.id and coalesce(x.kod, '''') = coalesce(s.kod, '''')', 'x.id'),
            ('taraf_adres',   'REHBERILETISIM', 'rehberiletisim', 'stg.rehberiletisim', 's.id = x.id and x.taraf_id = s.rehberid', 'x.id'),
            ('depo',          'DEPOLAR',        'depolar',        'stg.depolar',        's.id = x.id and coalesce(x.ad, '''') = coalesce(s.depoadi, '''')', 'x.id'),
            ('hizmet',        'MASRAFGELIR',    'masrafgelir',    'stg.masrafgelir',    's.id = x.id and coalesce(x.kod, '''') = coalesce(s.kod, '''')', 'x.id'),
            ('masraf',        'MASRAFGELIR',    'masrafgelir',    'stg.masrafgelir',    's.id = x.id and coalesce(x.kod, '''') = coalesce(s.kod, '''')', 'x.id'),
            ('stok',          'STOKLAR',        'stoklar',        'stg.stoklar',        's.id = x.id and coalesce(x.kod, '''') = coalesce(s.kod, '''')', 'x.id'),
            ('stok_seri_lot', 'STOKSERILOT',    'stokserilot',    'stg.stokserilot',    's.id = x.id and x.stok_id = s.stokid', 'x.id'),
            ('belge',         'FATBASLIK',      'fatbaslik',      'stg.fatbaslik',      's.id = x.id and x.taraf_id is not distinct from s.rehberid', 'x.id'),
            ('belge_satir',   'FATURA',         'fatura',         'stg.fatura',         's.id = x.id and x.belge_id = s.fatbasid', 'x.id'),
            ('mali_hareket',  'KASA',           'kasa',           'stg.kasa',           's.id = x.id and x.taraf_id is not distinct from s.rehberid', 'x.id'),
            ('stok_izleme',   'STOKIZLEME',     'stokizleme',     'stg.stokizleme',     's.id = x.id and x.stok_id = s.stokid', 'x.id'),
            -- 080: eski_tablo / eski_id
            ('hesap',          'KASALAR',       'kasalar',        'stg.kasalar',        'x.eski_tablo = ''KASALAR'' and s.id = x.eski_id', 'x.eski_id'),
            ('hesap',          'BANKAHESAPLAR', 'bankahesaplar',  'stg.bankahesaplar',  'x.eski_tablo = ''BANKAHESAPLAR'' and s.id = x.eski_id', 'x.eski_id'),
            ('hesap',          'POS',           'pos',            'stg.pos',            'x.eski_tablo = ''POS'' and s.id = x.eski_id', 'x.eski_id'),
            ('hesap',          'KREDIKARTI',    'kredikarti',     'stg.kredikarti',     'x.eski_tablo = ''KREDIKARTI'' and s.id = x.eski_id', 'x.eski_id'),
            ('hesap',          'KREDILER',      'krediler',       'stg.krediler',       'x.eski_tablo = ''KREDILER'' and s.id = x.eski_id', 'x.eski_id'),
            ('proje',          'PROJELER',      'projeler',       'stg.projeler',       's.id = x.eski_id', 'x.eski_id'),
            ('masraf_merkezi', 'SRMMERKEZI',    'srmmerkezi',     'stg.srmmerkezi',     's.id = x.eski_id', 'x.eski_id'),
            ('kredi',          'KREDILER',      'krediler',       'stg.krediler',
             'exists (select 1 from public.hesap h where h.id = x.id and h.eski_tablo = ''KREDILER'' and h.eski_id = s.id)', 's.id'),
            ('doviz_kur',      'DOVIZ',         'doviz',          'stg.doviz',
             'public.fn_doviz_iso(s.cinsi) = x.doviz_cinsi and s.tarih::date = x.tarih', 'null::bigint'),
            -- alt satırlar: doğal anahtar başına TEK kaynak satırı (pencere ile, bir kez -
            --   ilişkili alt sorgu 20 bin satırda karesel büyüyüp testi zaman aşımına düşürüyordu)
            ('stok_barkod',    'STOKBARKOD',    'stokbarkod',     'stg.stokbarkod',     's.barkod = x.barkod and s.stokid = x.stok_id', 's.id'),
            ('stok_fiyat',     'STOKFIYAT',     'stokfiyat',
             '(select * from (select z.*, row_number() over (partition by z.stokid, coalesce(z.fiyatadi, 0), '
             'coalesce(z.birim, 0), coalesce(z.satis, 1), public.fn_doviz_iso(z.kur) order by z.id desc) as sira '
             'from stg.stokfiyat z) q where q.sira = 1)',
             's.stokid = x.stok_id and coalesce(s.fiyatadi, 0) = x.fiyat_adi and coalesce(s.birim, 0) = x.birim '
             'and coalesce(s.satis, 1) = x.satis and public.fn_doviz_iso(s.kur) = x.doviz_cinsi', 's.id'),
            ('hizmet_fiyat',   'FIYATLAR',      'fiyatlar',
             '(select * from (select z.*, row_number() over (partition by z.hizmetid, coalesce(z.fiyatadi, 0), '
             'public.fn_doviz_iso(z.kur) order by z.id) as sira from stg.fiyatlar z) q where q.sira = 1)',
             's.hizmetid = x.hizmet_id and coalesce(s.fiyatadi, 0) = x.fiyat_adi and public.fn_doviz_iso(s.kur) = x.doviz_cinsi', 's.id'),
            ('masraf_fiyat',   'FIYATLAR',      'fiyatlar',
             '(select * from (select z.*, row_number() over (partition by z.hizmetid, coalesce(z.fiyatadi, 0), '
             'public.fn_doviz_iso(z.kur) order by z.id) as sira from stg.fiyatlar z) q where q.sira = 1)',
             's.hizmetid = x.masraf_id and coalesce(s.fiyatadi, 0) = x.fiyat_adi and public.fn_doviz_iso(s.kur) = x.doviz_cinsi', 's.id')
        ) v(tablo, kaynak, stg, kaynak_ifade, kosul, kimlik)
        where p_tablo is null or v.tablo = p_tablo
    loop
        if to_regclass('stg.' || r.stg) is null then
            tablo := r.tablo; kaynak := r.kaynak; toplam := null; eslesen := null; isaretlenen := 0;
            return next; continue;
        end if;
        execute format('select count(*) from public.%I', r.tablo) into v_toplam;
        execute format(
            'select count(distinct x.id) from public.%I x join %s s on %s where x.aktarim_kaynak is null',
            r.tablo, r.kaynak_ifade, r.kosul) into v_eslesen;
        v_isaret := 0;
        if p_uygula and v_eslesen > 0 then
            execute format(
                'update public.%I x set aktarim_kaynak = 1, aktarim_tablo = %L, aktarim_id = %s '
                '  from %s s where %s and x.aktarim_kaynak is null',
                r.tablo, r.kaynak, r.kimlik, r.kaynak_ifade, r.kosul);
            get diagnostics v_isaret = row_count;
        end if;
        tablo := r.tablo; kaynak := r.kaynak; toplam := v_toplam;
        eslesen := v_eslesen; isaretlenen := v_isaret;
        return next;
    end loop;
end $$;

comment on function public.fn_aktarim_kaynak_isaretle(boolean, text) is
    '1080/1082: göçle gelmiş satırları Delphi kaynağı olarak işaretler (id + ikinci alan / doğal anahtar). '
    'Varsayılan yalnız rapor; p_tablo verilirse yalnız o tablo.';

-- =================================================================== döviz ===
create or replace function public.fn_aktar_doviz(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_web int := 0;
begin
    create temp table if not exists _dv on commit drop as
        select * from stg.doviz with no data;
    truncate _dv;
    insert into _dv
    select x.cinsi, x.tarih, x.alis, x.satis, x.efalis, x.efsatis, x.ekleyen, x.eklemetarihi,
           x.degistiren, x.degistirmetarihi from (
        select d.*, row_number() over (partition by public.fn_doviz_iso(d.cinsi), d.tarih::date order by d.tarih desc) sn
          from jsonb_populate_recordset(null::stg.doviz, coalesce(p->'U'->'DOVIZ', '[]')) d
         where coalesce(btrim(d.cinsi), '') <> '' and d.tarih is not null) x
     where x.sn = 1;

    -- web'in kendi kuru (TCMB vb.) ezilmez
    select count(*) into v_web from _dv d
      join public.doviz_kur k on k.doviz_cinsi = public.fn_doviz_iso(d.cinsi) and k.tarih = d.tarih::date
     where k.aktarim_kaynak is null;

    insert into public.doviz_kur (doviz_cinsi, tarih, alis, satis, efektif_alis, efektif_satis,
                                  ekleme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select public.fn_doviz_iso(d.cinsi), d.tarih::date, coalesce(d.alis, 0), coalesce(d.satis, 0),
           coalesce(d.efalis, 0), coalesce(d.efsatis, 0),
           coalesce(public.fn_aktarim_zaman(d.eklemetarihi), now()), 1, 'DOVIZ', null
      from _dv d
    on conflict (doviz_cinsi, tarih)
    do update set alis = excluded.alis, satis = excluded.satis,
                  efektif_alis = excluded.efektif_alis, efektif_satis = excluded.efektif_satis
     where public.doviz_kur.aktarim_kaynak = 1
       and (public.doviz_kur.alis, public.doviz_kur.satis, public.doviz_kur.efektif_alis,
            public.doviz_kur.efektif_satis)
           is distinct from (excluded.alis, excluded.satis, excluded.efektif_alis, excluded.efektif_satis);
    get diagnostics v_yaz = row_count;
    return jsonb_build_object('doviz', v_yaz, 'web_sahipli', v_web);
end $$;

-- ======================================================== masraf merkezi ===
create or replace function public.fn_aktar_masraf_merkezi(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_cak int := 0;
begin
    create temp table if not exists _mm on commit drop as
        select *, ''::varchar(60) as kod2 from stg.srmmerkezi with no data;
    truncate _mm;
    insert into _mm
    select s.*, left(coalesce(nullif(btrim(s.merkezkodu), ''), 'MM' || s.id), 60)
      from jsonb_populate_recordset(null::stg.srmmerkezi, coalesce(p->'U'->'SRMMERKEZI', '[]')) s;

    -- kod başka bir kayıtta (web ya da başka Delphi satırı) -> atla
    delete from _mm i
     where exists (select 1 from public.masraf_merkezi m
                    where m.kod = i.kod2
                      and not coalesce(m.aktarim_kaynak = 1 and m.aktarim_tablo = 'SRMMERKEZI' and m.aktarim_id = i.id, false));
    get diagnostics v_cak = row_count;

    insert into public.masraf_merkezi (kod, ad, durum, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select i.kod2, coalesce(nullif(btrim(i.merkezadi), ''), 'Merkez ' || i.id), 1, 1, 'SRMMERKEZI', i.id
      from _mm i
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad
     where (public.masraf_merkezi.kod, public.masraf_merkezi.ad) is distinct from (excluded.kod, excluded.ad);
    get diagnostics v_yaz = row_count;
    return jsonb_build_object('masraf_merkezi', v_yaz, 'cakisma', v_cak);
end $$;

-- ================================================================= proje ===
create or replace function public.fn_aktar_proje(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_cak int := 0; v_sil int := 0;
begin
    create temp table if not exists _pr on commit drop as
        select *, ''::varchar(60) as kod2 from stg.projeler with no data;
    truncate _pr;
    insert into _pr
    select s.*, left(coalesce(nullif(btrim(s.projekodu), ''), 'PRJ' || s.id), 60)
      from jsonb_populate_recordset(null::stg.projeler, coalesce(p->'U'->'PROJELER', '[]')) s;

    delete from _pr i
     where exists (select 1 from public.proje m
                    where m.kod = i.kod2
                      and not coalesce(m.aktarim_kaynak = 1 and m.aktarim_tablo = 'PROJELER' and m.aktarim_id = i.id, false));
    get diagnostics v_cak = row_count;

    insert into public.proje (kod, ad, taraf_id, sorumlu_id, baslangic, bitis, butce_tutar, butce_dovizi,
                              durum, aciklama, sube_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select i.kod2,
           coalesce(nullif(btrim(i.projeadi), ''), nullif(btrim(i.konusu), ''), 'Proje ' || i.id),
           public.fn_aktarim_web_id('taraf', 'REHBER', i.rehberid),
           public.fn_aktarim_web_id('taraf', 'REHBER', i.prj_sorumlusu_id),
           public.fn_aktarim_tarih(i.baslamatarihi), public.fn_aktarim_tarih(i.bitistarihi),
           coalesce(i.satisfiyati, 0), public.fn_doviz_iso(i.satiskur),
           case when coalesce(i.durum, 1) = 0 then 0 else 1 end,
           coalesce(nullif(btrim(i.konusu), ''), ''), public.fn_aktarim_sube(i.subeid),
           1, 'PROJELER', i.id
      from _pr i
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, taraf_id = excluded.taraf_id,
                  sorumlu_id = excluded.sorumlu_id, baslangic = excluded.baslangic, bitis = excluded.bitis,
                  butce_tutar = excluded.butce_tutar, butce_dovizi = excluded.butce_dovizi,
                  durum = excluded.durum, aciklama = excluded.aciklama, sube_id = excluded.sube_id
     where (public.proje.kod, public.proje.ad, public.proje.taraf_id, public.proje.sorumlu_id,
            public.proje.baslangic, public.proje.bitis, public.proje.butce_tutar, public.proje.butce_dovizi,
            public.proje.durum, public.proje.aciklama, public.proje.sube_id)
           is distinct from
           (excluded.kod, excluded.ad, excluded.taraf_id, excluded.sorumlu_id, excluded.baslangic,
            excluded.bitis, excluded.butce_tutar, excluded.butce_dovizi, excluded.durum,
            excluded.aciklama, excluded.sube_id);
    get diagnostics v_yaz = row_count;

    update public.proje x set durum = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'PROJELER' and x.durum <> 0
       and x.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'PROJELER', '[]'))::bigint);
    get diagnostics v_sil = row_count;
    return jsonb_build_object('proje', v_yaz, 'cakisma', v_cak, 'proje_pasif', v_sil);
end $$;

-- ===================================================== kalem (hizmet/masraf) ===
create or replace function public.fn_aktar_kalem(p jsonb)
returns jsonb language plpgsql as $$
declare v_h int := 0; v_m int := 0; v_hf int := 0; v_mf int := 0; v_sil int := 0;
begin
    create temp table if not exists _k on commit drop as select * from stg.masrafgelir with no data;
    create temp table if not exists _kf on commit drop as select * from stg.fiyatlar with no data;
    truncate _k, _kf;
    insert into _k  select * from jsonb_populate_recordset(null::stg.masrafgelir, coalesce(p->'U'->'MASRAFGELIR', '[]'));
    insert into _kf select * from jsonb_populate_recordset(null::stg.fiyatlar,    coalesce(p->'U'->'FIYATLAR', '[]'));

    -- HİZMET: var olan karşılık + GELIRMI=1 + başlık
    insert into public.hizmet (kod, ad, baslik_mi, grubu, tur, kdv, birim, barkod, muh_kodu, ozel_kod,
                               yetki_kodu, aciklama, varsayilan, durum, resim, sube_id, ekleme_tarihi,
                               aktarim_kaynak, aktarim_tablo, aktarim_id)
    select coalesce(k.kod, ''), coalesce(nullif(btrim(k.ad), ''), '(adsiz kalem)'),
           coalesce(k.baslik, 0), coalesce(k.grubu, 0), coalesce(k.tur, 0), coalesce(k.kdv, 0),
           coalesce(k.birim, 0), coalesce(k.barkod, ''), coalesce(k.muhkodu, ''), coalesce(k.ozelkod, ''),
           coalesce(k.yetkikodu, ''), coalesce(k.aciklama, ''), coalesce(k.varsayilan, 0), coalesce(k.durum, 0),
           k.resim, public.fn_aktarim_sube(k.subeid), coalesce(public.fn_aktarim_zaman(k.eklemetarihi), now()),
           1, 'MASRAFGELIR', k.id
      from _k k
     where coalesce(k.gelirmi, 0) = 1 or coalesce(k.baslik, 0) = 1
        or exists (select 1 from public.hizmet h where h.aktarim_kaynak = 1
                     and h.aktarim_tablo = 'MASRAFGELIR' and h.aktarim_id = k.id)
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, baslik_mi = excluded.baslik_mi, grubu = excluded.grubu,
                  tur = excluded.tur, kdv = excluded.kdv, birim = excluded.birim, barkod = excluded.barkod,
                  muh_kodu = excluded.muh_kodu, ozel_kod = excluded.ozel_kod, yetki_kodu = excluded.yetki_kodu,
                  aciklama = excluded.aciklama, varsayilan = excluded.varsayilan, durum = excluded.durum,
                  resim = excluded.resim, sube_id = excluded.sube_id
     where (public.hizmet.kod, public.hizmet.ad, public.hizmet.baslik_mi, public.hizmet.grubu, public.hizmet.tur,
            public.hizmet.kdv, public.hizmet.birim, public.hizmet.barkod, public.hizmet.muh_kodu,
            public.hizmet.ozel_kod, public.hizmet.yetki_kodu, public.hizmet.aciklama, public.hizmet.varsayilan,
            public.hizmet.durum, md5(coalesce(public.hizmet.resim, '')), public.hizmet.sube_id)
           is distinct from
           (excluded.kod, excluded.ad, excluded.baslik_mi, excluded.grubu, excluded.tur, excluded.kdv,
            excluded.birim, excluded.barkod, excluded.muh_kodu, excluded.ozel_kod, excluded.yetki_kodu,
            excluded.aciklama, excluded.varsayilan, excluded.durum, md5(coalesce(excluded.resim, '')),
            excluded.sube_id);
    get diagnostics v_h = row_count;

    -- MASRAF: var olan karşılık + GELIRMI=0 + başlık
    insert into public.masraf (kod, ad, baslik_mi, grubu, tur, kdv, birim, muh_kodu, ozel_kod, yetki_kodu,
                               aciklama, varsayilan, durum, sube_id, ekleme_tarihi,
                               aktarim_kaynak, aktarim_tablo, aktarim_id)
    select coalesce(k.kod, ''), coalesce(nullif(btrim(k.ad), ''), '(adsiz kalem)'),
           coalesce(k.baslik, 0), coalesce(k.grubu, 0), coalesce(k.tur, 0), coalesce(k.kdv, 0),
           coalesce(k.birim, 0), coalesce(k.muhkodu, ''), coalesce(k.ozelkod, ''), coalesce(k.yetkikodu, ''),
           coalesce(k.aciklama, ''), coalesce(k.varsayilan, 0), coalesce(k.durum, 0),
           public.fn_aktarim_sube(k.subeid), coalesce(public.fn_aktarim_zaman(k.eklemetarihi), now()),
           1, 'MASRAFGELIR', k.id
      from _k k
     where coalesce(k.gelirmi, 0) = 0 or coalesce(k.baslik, 0) = 1
        or exists (select 1 from public.masraf m where m.aktarim_kaynak = 1
                     and m.aktarim_tablo = 'MASRAFGELIR' and m.aktarim_id = k.id)
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, baslik_mi = excluded.baslik_mi, grubu = excluded.grubu,
                  tur = excluded.tur, kdv = excluded.kdv, birim = excluded.birim, muh_kodu = excluded.muh_kodu,
                  ozel_kod = excluded.ozel_kod, yetki_kodu = excluded.yetki_kodu, aciklama = excluded.aciklama,
                  varsayilan = excluded.varsayilan, durum = excluded.durum, sube_id = excluded.sube_id
     where (public.masraf.kod, public.masraf.ad, public.masraf.baslik_mi, public.masraf.grubu, public.masraf.tur,
            public.masraf.kdv, public.masraf.birim, public.masraf.muh_kodu, public.masraf.ozel_kod,
            public.masraf.yetki_kodu, public.masraf.aciklama, public.masraf.varsayilan, public.masraf.durum,
            public.masraf.sube_id)
           is distinct from
           (excluded.kod, excluded.ad, excluded.baslik_mi, excluded.grubu, excluded.tur, excluded.kdv,
            excluded.birim, excluded.muh_kodu, excluded.ozel_kod, excluded.yetki_kodu, excluded.aciklama,
            excluded.varsayilan, excluded.durum, excluded.sube_id);
    get diagnostics v_m = row_count;

    -- FİYATLAR: göç gibi (kalem, fiyat adı, kur) başına tek satır; kalem hangi taraftaysa oraya
    create temp table if not exists _kfg (hizmetid int, fiyatadi int, kur text, fiyat numeric,
                                          kdvdurum int, ilk_id int) on commit drop;
    truncate _kfg;
    insert into _kfg
    select f.hizmetid, coalesce(f.fiyatadi, 0), public.fn_doviz_iso(f.kur), coalesce(max(f.fiyat), 0),
           coalesce(max(f.kdvdurum), 0), min(f.id)
      from _kf f join _k k on k.id = f.hizmetid
     group by f.hizmetid, coalesce(f.fiyatadi, 0), public.fn_doviz_iso(f.kur);

    insert into public.hizmet_fiyat (hizmet_id, fiyat_adi, fiyat, doviz_cinsi, kdv_durum,
                                     aktarim_kaynak, aktarim_tablo, aktarim_id)
    select h.id, g.fiyatadi, g.fiyat, g.kur, g.kdvdurum, 1, 'FIYATLAR', g.ilk_id
      from _kfg g
      join public.hizmet h on h.aktarim_kaynak = 1 and h.aktarim_tablo = 'MASRAFGELIR' and h.aktarim_id = g.hizmetid
    on conflict (hizmet_id, fiyat_adi, doviz_cinsi)
    do update set fiyat = excluded.fiyat, kdv_durum = excluded.kdv_durum,
                  aktarim_kaynak = 1, aktarim_tablo = 'FIYATLAR', aktarim_id = excluded.aktarim_id
     where (public.hizmet_fiyat.aktarim_kaynak = 1 or public.hizmet_fiyat.aktarim_kaynak is null)
       and (public.hizmet_fiyat.fiyat, public.hizmet_fiyat.kdv_durum, public.hizmet_fiyat.aktarim_id)
           is distinct from (excluded.fiyat, excluded.kdv_durum, excluded.aktarim_id);
    get diagnostics v_hf = row_count;

    insert into public.masraf_fiyat (masraf_id, fiyat_adi, fiyat, doviz_cinsi, kdv_durum,
                                     aktarim_kaynak, aktarim_tablo, aktarim_id)
    select m.id, g.fiyatadi, g.fiyat, g.kur, g.kdvdurum, 1, 'FIYATLAR', g.ilk_id
      from _kfg g
      join public.masraf m on m.aktarim_kaynak = 1 and m.aktarim_tablo = 'MASRAFGELIR' and m.aktarim_id = g.hizmetid
    on conflict (masraf_id, fiyat_adi, doviz_cinsi)
    do update set fiyat = excluded.fiyat, kdv_durum = excluded.kdv_durum,
                  aktarim_kaynak = 1, aktarim_tablo = 'FIYATLAR', aktarim_id = excluded.aktarim_id
     where (public.masraf_fiyat.aktarim_kaynak = 1 or public.masraf_fiyat.aktarim_kaynak is null)
       and (public.masraf_fiyat.fiyat, public.masraf_fiyat.kdv_durum, public.masraf_fiyat.aktarim_id)
           is distinct from (excluded.fiyat, excluded.kdv_durum, excluded.aktarim_id);
    get diagnostics v_mf = row_count;

    -- Delphi'de silinen fiyat (pakette olmayan): fiyat satırı başka yerden bağlanmaz -> silinir.
    delete from public.hizmet_fiyat x using public.hizmet h, _k k
     where x.hizmet_id = h.id and h.aktarim_kaynak = 1 and h.aktarim_tablo = 'MASRAFGELIR' and h.aktarim_id = k.id
       and x.aktarim_kaynak = 1
       and not exists (select 1 from _kfg g where g.hizmetid = k.id and g.fiyatadi = x.fiyat_adi and g.kur = x.doviz_cinsi);
    delete from public.masraf_fiyat x using public.masraf m, _k k
     where x.masraf_id = m.id and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'MASRAFGELIR' and m.aktarim_id = k.id
       and x.aktarim_kaynak = 1
       and not exists (select 1 from _kfg g where g.hizmetid = k.id and g.fiyatadi = x.fiyat_adi and g.kur = x.doviz_cinsi);

    -- Delphi'de silinen kalem -> pasif (belgede kullanılmış olabilir)
    update public.hizmet x set durum = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'MASRAFGELIR' and x.durum <> 0
       and x.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'MASRAFGELIR', '[]'))::bigint);
    get diagnostics v_sil = row_count;
    update public.masraf x set durum = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'MASRAFGELIR' and x.durum <> 0
       and x.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'MASRAFGELIR', '[]'))::bigint);

    return jsonb_build_object('hizmet', v_h, 'masraf', v_m, 'hizmet_fiyat', v_hf, 'masraf_fiyat', v_mf,
                              'kalem_pasif', v_sil);
end $$;

-- ================================================================== stok ===
create or replace function public.fn_aktar_stok(p jsonb)
returns jsonb language plpgsql as $$
declare v_s int := 0; v_b int := 0; v_bc int := 0; v_f int := 0; v_fc int := 0; v_l int := 0; v_lc int := 0;
        v_sil int := 0;
begin
    create temp table if not exists _s  on commit drop as select * from stg.stoklar     with no data;
    create temp table if not exists _sb on commit drop as select * from stg.stokbarkod  with no data;
    create temp table if not exists _sf on commit drop as select * from stg.stokfiyat   with no data;
    create temp table if not exists _sl on commit drop as select * from stg.stokserilot with no data;
    truncate _s, _sb, _sf, _sl;
    insert into _s  select * from jsonb_populate_recordset(null::stg.stoklar,     coalesce(p->'U'->'STOKLAR', '[]'));
    insert into _sb select * from jsonb_populate_recordset(null::stg.stokbarkod,  coalesce(p->'U'->'STOKBARKOD', '[]'));
    insert into _sf select * from jsonb_populate_recordset(null::stg.stokfiyat,   coalesce(p->'U'->'STOKFIYAT', '[]'));
    insert into _sl select * from jsonb_populate_recordset(null::stg.stokserilot, coalesce(p->'U'->'STOKSERILOT', '[]'));

    -- 1) kart (göç 013 + 033 raf ömrü + 034 GTİP)
    -- 'kullanim' YOK: 545'te kaldırıldı (hiç doldurulmamış alan).
    insert into public.stok (kod, ad, kategori, tipi, marka, model, grubu, ozellik, icerik, ana_birim,
                             birim2, birim2_miktar, min_stok, kdv, otv_yuzde, izleme, raf_omru_sure,
                             raf_omru_birim, durum, urun_no, hucre, ozel_kod, ozel_kod2, muh_kodu, detay_bolumu,
                             internet_satis, bildirim, fatura_stok_adi, gtip_kodu, resim, sube_id, giris_kaynak,
                             ekleme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select coalesce(s.kod, ''), coalesce(nullif(btrim(s.stokadi), ''), '(adsiz stok)'),
           coalesce(s.kategori, 0), coalesce(s.tipi, 0), coalesce(s.marka, 0), coalesce(s.model, 0),
           coalesce(s.grubu, 0), coalesce(s.ozellik, 0), coalesce(s.icerik, 0),
           coalesce(s.anabirim, 0), coalesce(s.birim2, 0), coalesce(s.birim2miktar, 0), coalesce(s.minstok, 0),
           coalesce(s.kdv, 0), coalesce(s.otvyuzde, 0), coalesce(s.izleme, 0),
           coalesce(s.rafomru_sure, 0), coalesce(s.rafomru_birim, 0), coalesce(s.durum, 0),
           coalesce(s.urunno, ''), coalesce(s.hucre, ''), coalesce(s.ozelkod, ''), coalesce(s.ozelkod2, ''),
           coalesce(s.muhkodu, ''), coalesce(s.detaybolumu, ''), coalesce(s.internet_satis, 0),
           coalesce(s.bildirim, 0), coalesce(s.teditfatura_stok_adi, ''), coalesce(s.gtip, ''), s.resim,
           public.fn_aktarim_sube(s.subeid), coalesce(s.giriskaynak, 0),
           coalesce(public.fn_aktarim_zaman(s.eklemetarihi), now()), 1, 'STOKLAR', s.id
      from _s s
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, kategori = excluded.kategori, tipi = excluded.tipi,
                  marka = excluded.marka, model = excluded.model, grubu = excluded.grubu,
                  ozellik = excluded.ozellik, icerik = excluded.icerik,
                  ana_birim = excluded.ana_birim, birim2 = excluded.birim2, birim2_miktar = excluded.birim2_miktar,
                  min_stok = excluded.min_stok, kdv = excluded.kdv, otv_yuzde = excluded.otv_yuzde,
                  izleme = excluded.izleme, raf_omru_sure = excluded.raf_omru_sure,
                  raf_omru_birim = excluded.raf_omru_birim, durum = excluded.durum, urun_no = excluded.urun_no,
                  hucre = excluded.hucre, ozel_kod = excluded.ozel_kod, ozel_kod2 = excluded.ozel_kod2,
                  muh_kodu = excluded.muh_kodu, detay_bolumu = excluded.detay_bolumu,
                  internet_satis = excluded.internet_satis, bildirim = excluded.bildirim,
                  fatura_stok_adi = excluded.fatura_stok_adi, gtip_kodu = excluded.gtip_kodu,
                  resim = excluded.resim, sube_id = excluded.sube_id, giris_kaynak = excluded.giris_kaynak
     where (public.stok.kod, public.stok.ad, public.stok.kategori, public.stok.tipi, public.stok.marka,
            public.stok.model, public.stok.grubu, public.stok.ozellik, public.stok.icerik,
            public.stok.ana_birim, public.stok.birim2, public.stok.birim2_miktar, public.stok.min_stok,
            public.stok.kdv, public.stok.otv_yuzde, public.stok.izleme, public.stok.raf_omru_sure,
            public.stok.raf_omru_birim, public.stok.durum, public.stok.urun_no, public.stok.hucre,
            public.stok.ozel_kod, public.stok.ozel_kod2, public.stok.muh_kodu, public.stok.detay_bolumu,
            public.stok.internet_satis, public.stok.bildirim, public.stok.fatura_stok_adi, public.stok.gtip_kodu,
            md5(coalesce(public.stok.resim, '')), public.stok.sube_id, public.stok.giris_kaynak)
           is distinct from
           (excluded.kod, excluded.ad, excluded.kategori, excluded.tipi, excluded.marka, excluded.model,
            excluded.grubu, excluded.ozellik, excluded.icerik, excluded.ana_birim,
            excluded.birim2, excluded.birim2_miktar, excluded.min_stok, excluded.kdv, excluded.otv_yuzde,
            excluded.izleme, excluded.raf_omru_sure, excluded.raf_omru_birim, excluded.durum, excluded.urun_no,
            excluded.hucre, excluded.ozel_kod, excluded.ozel_kod2, excluded.muh_kodu, excluded.detay_bolumu,
            excluded.internet_satis, excluded.bildirim, excluded.fatura_stok_adi, excluded.gtip_kodu,
            md5(coalesce(excluded.resim, '')), excluded.sube_id, excluded.giris_kaynak);
    get diagnostics v_s = row_count;

    -- web stok id'leri bu pakette
    create temp table if not exists _sid (delphi int primary key, web int) on commit drop;
    truncate _sid;
    insert into _sid select s.id, w.id from _s s
      join public.stok w on w.aktarim_kaynak = 1 and w.aktarim_tablo = 'STOKLAR' and w.aktarim_id = s.id;

    -- 2) barkod: boş atlanır; aynı barkod pakette tekrarlıyorsa ilki; başka stokta
    --    (web - ilaç kataloğu - ya da başka Delphi stoğu) kullanılan barkod atlanır.
    create temp table if not exists _sb2 (id int, web_stok int, barkod varchar, tip int, birim int, vars int)
        on commit drop;
    truncate _sb2;
    insert into _sb2
    select b.id, i.web, b.barkod, coalesce(b.barkodtipi, 0), coalesce(b.barkodbirimi, 0),
           case when row_number() over (partition by b.stokid order by coalesce(b.varsayilan, 0) desc, b.id) = 1
                 and coalesce(b.varsayilan, 0) = 1 then 1 else 0 end
      from (select x.*, row_number() over (partition by x.barkod order by x.id) sn from _sb x
             where coalesce(btrim(x.barkod), '') <> '') b
      join _sid i on i.delphi = b.stokid
     where b.sn = 1;
    delete from _sb2 b
     where exists (select 1 from public.stok_barkod x
                    where x.barkod = b.barkod
                      and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKBARKOD' and x.aktarim_id = b.id, false));
    get diagnostics v_bc = row_count;

    -- varsayılan tekliği satır satır denetlenir: önce aktarılan barkodların varsayılanlığı sıfırlanır
    update public.stok_barkod x set varsayilan = 0
      from _sid i
     where x.stok_id = i.web and x.aktarim_kaynak = 1 and x.varsayilan = 1
       and not exists (select 1 from _sb2 b where b.id = x.aktarim_id and b.vars = 1);

    insert into public.stok_barkod (stok_id, barkod, barkod_tipi, barkod_birimi, varsayilan,
                                    aktarim_kaynak, aktarim_tablo, aktarim_id)
    select b.web_stok, b.barkod, b.tip, b.birim, b.vars, 1, 'STOKBARKOD', b.id from _sb2 b
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set stok_id = excluded.stok_id, barkod = excluded.barkod, barkod_tipi = excluded.barkod_tipi,
                  barkod_birimi = excluded.barkod_birimi, varsayilan = excluded.varsayilan
     where (public.stok_barkod.stok_id, public.stok_barkod.barkod, public.stok_barkod.barkod_tipi,
            public.stok_barkod.barkod_birimi, public.stok_barkod.varsayilan)
           is distinct from (excluded.stok_id, excluded.barkod, excluded.barkod_tipi,
                             excluded.barkod_birimi, excluded.varsayilan);
    get diagnostics v_b = row_count;

    delete from public.stok_barkod x using _sid i
     where x.stok_id = i.web and x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKBARKOD'
       and not exists (select 1 from _sb2 b where b.id = x.aktarim_id);

    -- 3) fiyat: doğal anahtar başına en son satır (göç gibi); web'in kendi fiyatı ezilmez
    create temp table if not exists _sf2 (id int, web_stok int, fiyatadi int, birim int, fiyat numeric,
                                          kur varchar, satis int) on commit drop;
    truncate _sf2;
    insert into _sf2
    select f.id, i.web, coalesce(f.fiyatadi, 0), coalesce(f.birim, 0), coalesce(f.fiyat, 0),
           public.fn_doviz_iso(f.kur), coalesce(f.satis, 1)
      from (select x.*, row_number() over (partition by x.stokid, coalesce(x.fiyatadi, 0), coalesce(x.birim, 0),
                                                        coalesce(x.satis, 1), public.fn_doviz_iso(x.kur)
                                           order by x.id desc) sn from _sf x) f
      join _sid i on i.delphi = f.stokid
     where f.sn = 1;
    select count(*) into v_fc from _sf2 f
      join public.stok_fiyat x on x.stok_id = f.web_stok and x.fiyat_adi = f.fiyatadi and x.birim = f.birim
                              and x.satis = f.satis and x.doviz_cinsi = f.kur
     where x.aktarim_kaynak is null;

    insert into public.stok_fiyat (stok_id, fiyat_adi, birim, fiyat, doviz_cinsi, satis,
                                   aktarim_kaynak, aktarim_tablo, aktarim_id)
    select f.web_stok, f.fiyatadi, f.birim, f.fiyat, f.kur, f.satis, 1, 'STOKFIYAT', f.id from _sf2 f
    on conflict (stok_id, fiyat_adi, birim, satis, doviz_cinsi)
    do update set fiyat = excluded.fiyat, aktarim_id = excluded.aktarim_id
     where public.stok_fiyat.aktarim_kaynak = 1
       and (public.stok_fiyat.fiyat, public.stok_fiyat.aktarim_id) is distinct from (excluded.fiyat, excluded.aktarim_id);
    get diagnostics v_f = row_count;

    delete from public.stok_fiyat x using _sid i
     where x.stok_id = i.web and x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKFIYAT'
       and not exists (select 1 from _sf2 f where f.web_stok = x.stok_id and f.fiyatadi = x.fiyat_adi
                         and f.birim = x.birim and f.satis = x.satis and f.kur = x.doviz_cinsi);

    -- 4) seri / lot (stok hareketleri bağlanır -> silinmez)
    create temp table if not exists _sl2 (id int, web_stok int, lot varchar, lot_ex varchar, seri varchar,
                                          urt date, skt date) on commit drop;
    truncate _sl2;
    insert into _sl2
    select l.id, i.web, coalesce(l.lotno, ''), coalesce(l.lotno_ex, ''), coalesce(l.serino, ''),
           public.fn_aktarim_tarih(l.urt), public.fn_aktarim_tarih(l.skt)
      from (select x.*, row_number() over (partition by x.stokid, coalesce(x.lotno, ''), coalesce(x.serino, '')
                                           order by x.id) sn from _sl x) l
      join _sid i on i.delphi = l.stokid
     where l.sn = 1;
    delete from _sl2 l
     where exists (select 1 from public.stok_seri_lot x
                    where x.stok_id = l.web_stok and x.lot_no = l.lot and x.seri_no = l.seri
                      and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKSERILOT' and x.aktarim_id = l.id, false));
    get diagnostics v_lc = row_count;

    insert into public.stok_seri_lot (stok_id, lot_no, lot_no_ex, seri_no, uretim_tarihi, son_kullanma_tarihi,
                                      aktarim_kaynak, aktarim_tablo, aktarim_id)
    select l.web_stok, l.lot, l.lot_ex, l.seri, l.urt, l.skt, 1, 'STOKSERILOT', l.id from _sl2 l
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set stok_id = excluded.stok_id, lot_no = excluded.lot_no, lot_no_ex = excluded.lot_no_ex,
                  seri_no = excluded.seri_no, uretim_tarihi = excluded.uretim_tarihi,
                  son_kullanma_tarihi = excluded.son_kullanma_tarihi
     where (public.stok_seri_lot.stok_id, public.stok_seri_lot.lot_no, public.stok_seri_lot.lot_no_ex,
            public.stok_seri_lot.seri_no, public.stok_seri_lot.uretim_tarihi, public.stok_seri_lot.son_kullanma_tarihi)
           is distinct from (excluded.stok_id, excluded.lot_no, excluded.lot_no_ex, excluded.seri_no,
                             excluded.uretim_tarihi, excluded.son_kullanma_tarihi);
    get diagnostics v_l = row_count;

    -- 5) Delphi'de silinen stok -> pasif
    update public.stok x set durum = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKLAR' and x.durum <> 0
       and x.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'STOKLAR', '[]'))::bigint);
    get diagnostics v_sil = row_count;

    return jsonb_build_object('stok', v_s, 'barkod', v_b, 'barkod_cakisma', v_bc, 'fiyat', v_f,
                              'fiyat_web_sahipli', v_fc, 'seri_lot', v_l, 'seri_lot_cakisma', v_lc,
                              'stok_pasif', v_sil);
end $$;

-- ================================================================= hesap ===
create or replace function public.fn_aktar_hesap(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_cak int := 0; v_kredi int := 0; v_n int;
begin
    create temp table if not exists _h (
        kaynak text, delphi int, tur char(1), kod varchar, ad varchar, doviz varchar, alt_tur int,
        delphi_sube int, sorumlu_delphi int, bakiye numeric, durum int, aciklama varchar,
        banka_adi varchar, hesap_no varchar, iban varchar, komisyon_zamani int, kesim int, son_odeme int,
        limit_tutar numeric, bagli_tablo text, bagli_delphi int, komisyon_masraf_delphi int) on commit drop;
    truncate _h;

    -- Her kaynak AYRI insert: tek UNION'da ilk kolların tipsiz NULL'ları metin sayılıp
    --   sonraki kolların sayılarıyla çakışıyordu ("UNION types text and integer").
    insert into _h (kaynak, delphi, tur, kod, ad, doviz, alt_tur, delphi_sube, sorumlu_delphi, bakiye, durum, aciklama)
    select 'KASALAR', s.id, case when coalesce(s.kasatur, 0) = 200 then 'H' else 'K' end,
           coalesce(nullif(btrim(s.kasakodu), ''), 'K' || s.id), coalesce(nullif(btrim(s.kasaadi), ''), 'Kasa ' || s.id),
           public.fn_doviz_iso(s.kur), coalesce(s.kasatur, 0), s.subeid, s.rehberid,
           coalesce(s.bakiye, 0), coalesce(s.durum, 1), coalesce(nullif(btrim(s.hesapaciklama), ''), '')
      from jsonb_populate_recordset(null::stg.kasalar, coalesce(p->'U'->'KASALAR', '[]')) s;

    insert into _h (kaynak, delphi, tur, kod, ad, doviz, delphi_sube, bakiye, durum, aciklama,
                    banka_adi, hesap_no, iban)
    select 'BANKAHESAPLAR', s.id, 'B', coalesce(nullif(btrim(s.hesapkodu), ''), 'B' || s.id),
           coalesce(nullif(btrim(s.hesapadi), ''), 'Banka Hesabi ' || s.id), public.fn_doviz_iso(s.kur),
           s.subeid, coalesce(s.bakiye, 0), coalesce(s.durum, 1), coalesce(nullif(btrim(s.hesapaciklama), ''), ''),
           '', coalesce(nullif(btrim(s.hesapno), ''), ''), coalesce(nullif(btrim(s.iban), ''), '')
      from jsonb_populate_recordset(null::stg.bankahesaplar, coalesce(p->'U'->'BANKAHESAPLAR', '[]')) s;

    insert into _h (kaynak, delphi, tur, kod, ad, doviz, delphi_sube, durum, komisyon_zamani, kesim, son_odeme,
                    limit_tutar, bagli_tablo, bagli_delphi, komisyon_masraf_delphi)
    select 'POS', s.id, 'P', coalesce(nullif(btrim(s.kodu), ''), 'P' || s.id), coalesce(nullif(btrim(s.adi), ''), 'POS ' || s.id),
           public.fn_doviz_iso(s.kur), s.subeid, coalesce(s.durum, 1),
           case when coalesce(s.masrafcikis, 1) = 2 then 2 else 1 end,
           coalesce(s.hesap_kesim_tarihi, 0), coalesce(s.odeme_gun_sayisi, 0), coalesce(s.genellimit, 0),
           'BANKAHESAPLAR', s.bankahesapid, s.komisyonmasrafmerkezi
      from jsonb_populate_recordset(null::stg.pos, coalesce(p->'U'->'POS', '[]')) s;

    insert into _h (kaynak, delphi, tur, kod, ad, doviz, delphi_sube, durum, kesim, son_odeme, limit_tutar,
                    bagli_tablo, bagli_delphi)
    select 'KREDIKARTI', s.id, 'V', coalesce(nullif(btrim(s.kodu), ''), 'V' || s.id),
           coalesce(nullif(btrim(s.adi), ''), 'Kredi Karti ' || s.id), public.fn_doviz_iso(s.kur),
           s.subeid, case when coalesce(s.durum, 1) = 0 then 0 else 1 end,
           coalesce(s.hesap_kesim_tarihi, 0), coalesce(s.odeme_gun_sayisi, 0), coalesce(s.genellimit, 0),
           'BANKAHESAPLAR', coalesce(nullif(s.odeme_bankahesapid, 0), s.bankahesapid)
      from jsonb_populate_recordset(null::stg.kredikarti, coalesce(p->'U'->'KREDIKARTI', '[]')) s;

    insert into _h (kaynak, delphi, tur, kod, ad, doviz, alt_tur, delphi_sube, durum, bagli_tablo, bagli_delphi)
    select 'KREDILER', s.id, 'R', coalesce(nullif(btrim(s.kredikodu), ''), 'R' || s.id),
           coalesce(nullif(btrim(s.adi), ''), 'Kredi ' || s.id), public.fn_doviz_iso(s.kur),
           coalesce(s.genelkreditipi, 0), s.subeid, coalesce(s.durum, 1), 'BANKAHESAPLAR', s.bankaticarihesapid
      from jsonb_populate_recordset(null::stg.krediler, coalesce(p->'U'->'KREDILER', '[]')) s;

    -- tür + kod başka kayıtta -> atla
    delete from _h h
     where exists (select 1 from public.hesap x
                    where x.tur = h.tur and x.kod = h.kod and h.kod <> ''
                      and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = h.kaynak and x.aktarim_id = h.delphi, false));
    get diagnostics v_cak = row_count;

    insert into public.hesap (tur, kod, ad, doviz_cinsi, alt_tur, sube_id, sorumlu_id, acilis_bakiye, durum,
                              aciklama, banka_adi, hesap_no, iban, komisyon_zamani, hesap_kesim_gunu,
                              son_odeme_gunu, limit_tutar, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select h.tur, h.kod, h.ad, h.doviz, coalesce(h.alt_tur, 0), public.fn_aktarim_sube(h.delphi_sube),
           public.fn_aktarim_web_id('taraf', 'REHBER', h.sorumlu_delphi), coalesce(h.bakiye, 0), h.durum,
           coalesce(h.aciklama, ''), coalesce(h.banka_adi, ''), coalesce(h.hesap_no, ''), coalesce(h.iban, ''),
           coalesce(h.komisyon_zamani, 1), coalesce(h.kesim, 0), coalesce(h.son_odeme, 0),
           coalesce(h.limit_tutar, 0), 1, h.kaynak, h.delphi
      from _h h
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set tur = excluded.tur, kod = excluded.kod, ad = excluded.ad, doviz_cinsi = excluded.doviz_cinsi,
                  alt_tur = excluded.alt_tur, sube_id = excluded.sube_id, sorumlu_id = excluded.sorumlu_id,
                  acilis_bakiye = excluded.acilis_bakiye, durum = excluded.durum, aciklama = excluded.aciklama,
                  banka_adi = excluded.banka_adi, hesap_no = excluded.hesap_no, iban = excluded.iban,
                  komisyon_zamani = excluded.komisyon_zamani, hesap_kesim_gunu = excluded.hesap_kesim_gunu,
                  son_odeme_gunu = excluded.son_odeme_gunu, limit_tutar = excluded.limit_tutar
     where (public.hesap.tur, public.hesap.kod, public.hesap.ad, public.hesap.doviz_cinsi, public.hesap.alt_tur,
            public.hesap.sube_id, public.hesap.sorumlu_id, public.hesap.acilis_bakiye, public.hesap.durum,
            public.hesap.aciklama, public.hesap.banka_adi, public.hesap.hesap_no, public.hesap.iban,
            public.hesap.komisyon_zamani, public.hesap.hesap_kesim_gunu, public.hesap.son_odeme_gunu,
            public.hesap.limit_tutar)
           is distinct from
           (excluded.tur, excluded.kod, excluded.ad, excluded.doviz_cinsi, excluded.alt_tur, excluded.sube_id,
            excluded.sorumlu_id, excluded.acilis_bakiye, excluded.durum, excluded.aciklama, excluded.banka_adi,
            excluded.hesap_no, excluded.iban, excluded.komisyon_zamani, excluded.hesap_kesim_gunu,
            excluded.son_odeme_gunu, excluded.limit_tutar);
    get diagnostics v_yaz = row_count;

    -- bağlı banka hesabı / POS komisyon masrafı (banka hesabı aynı ya da önceki pakette gelmiş olmalı)
    update public.hesap x
       set bagli_hesap_id = public.fn_aktarim_web_id('hesap', h.bagli_tablo, h.bagli_delphi)
      from _h h
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = h.kaynak and x.aktarim_id = h.delphi
       and h.bagli_tablo is not null
       and x.bagli_hesap_id is distinct from public.fn_aktarim_web_id('hesap', h.bagli_tablo, h.bagli_delphi);
    update public.hesap x
       set komisyon_masraf_id = public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', h.komisyon_masraf_delphi)
      from _h h
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'POS' and h.kaynak = 'POS' and x.aktarim_id = h.delphi
       and x.komisyon_masraf_id is distinct from public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', h.komisyon_masraf_delphi);

    -- kredi detayı (id = hesap.id)
    insert into public.kredi (id, taraf_id, proje_id, anapara, faiz_orani, kkdf_orani, bsmv_orani, vade_ay,
                              kullanim_tarihi, faiz_masraf_id, durum, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select x.id, public.fn_aktarim_web_id('taraf', 'REHBER', s.rehberid),
           public.fn_aktarim_web_id('proje', 'PROJELER', s.projeid),
           coalesce(s.tutari, 0), coalesce(s.faizorani, 0)::numeric(9,4), coalesce(s.kkdf, 0)::numeric(9,4),
           coalesce(s.bsmv, 0)::numeric(9,4), coalesce(s.kreditaksit, 0), public.fn_aktarim_tarih(s.alinistarihi),
           public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', coalesce(nullif(s.faizmasrafid, 0), s.masrafid)),
           coalesce(s.durum, 1), 1, 'KREDILER', s.id
      from jsonb_populate_recordset(null::stg.krediler, coalesce(p->'U'->'KREDILER', '[]')) s
      join public.hesap x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'KREDILER' and x.aktarim_id = s.id
    on conflict (id)
    do update set taraf_id = excluded.taraf_id, proje_id = excluded.proje_id, anapara = excluded.anapara,
                  faiz_orani = excluded.faiz_orani, kkdf_orani = excluded.kkdf_orani, bsmv_orani = excluded.bsmv_orani,
                  vade_ay = excluded.vade_ay, kullanim_tarihi = excluded.kullanim_tarihi,
                  faiz_masraf_id = excluded.faiz_masraf_id, durum = excluded.durum,
                  aktarim_kaynak = 1, aktarim_tablo = 'KREDILER', aktarim_id = excluded.aktarim_id
     where (public.kredi.taraf_id, public.kredi.proje_id, public.kredi.anapara, public.kredi.faiz_orani,
            public.kredi.kkdf_orani, public.kredi.bsmv_orani, public.kredi.vade_ay, public.kredi.kullanim_tarihi,
            public.kredi.faiz_masraf_id, public.kredi.durum, public.kredi.aktarim_id)
           is distinct from
           (excluded.taraf_id, excluded.proje_id, excluded.anapara, excluded.faiz_orani, excluded.kkdf_orani,
            excluded.bsmv_orani, excluded.vade_ay, excluded.kullanim_tarihi, excluded.faiz_masraf_id,
            excluded.durum, excluded.aktarim_id);
    get diagnostics v_kredi = row_count;

    -- silinen hesap -> pasif
    update public.hesap x set durum = 0
      from (select key as kaynak, jsonb_array_elements_text(value)::bigint as delphi
              from jsonb_each(coalesce(p->'D', '{}'))
             where key in ('KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER')) d
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = d.kaynak and x.aktarim_id = d.delphi and x.durum <> 0;
    get diagnostics v_n = row_count;

    return jsonb_build_object('hesap', v_yaz, 'cakisma', v_cak, 'kredi', v_kredi, 'hesap_pasif', v_n);
end $$;

commit;
