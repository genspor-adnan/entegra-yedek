-- =============================================================================
--  1266  DELPHI AKTARIMI - e-BELGE XSLT ŞABLONLARI (DOKUMLER GRUBU='XSLT') SÜREKLİ ADIM  (dokuman/18 §11)
--
--  KULLANICI (05.11.2026): "xslt dosya/larını da aktar". Aktarılan e-belgenin görüntüsü (1265) kurumun kendi
--  XSLT'siyle çizilmeli; şablon Delphi'de DOKUMLER tablosunda (GRUBU 'XSLT', içerik SQL kolonu, RAPORID türü),
--  web'de merkezi dokuman deposunda (kaynak 'ebelge-xslt', kaynak_id e-belge türü, yon 1 gelen / 2 giden).
--
--  RAPORID (Delphi UOpsiyonFatura.XSLTComboYukle): giden 2 e-Fatura / 12 e-Arşiv / 32 e-SMM / 52 e-İrsaliye,
--  gelen 1 / 11 / 31 / 51 (eski kayıtlarda 1..4 = e-Fatura / e-Arşiv / e-SMM / e-İrsaliye giden). Web türü:
--  1 e-Fatura, 2 e-Arşiv, 7 e-İrsaliye, 8 e-SMM (EFaturaKodlari / DokumanDeposu.EBelgeTuruAdi).
--
--  VARSAYILAN: Delphi'de GENINI (-24076.. giden, -24107.. gelen) DOKUMLER.ID tutar; GENINI'nin birincil anahtarı
--  yok, ajanla taşınamaz. Kural: (tür, yön) için web'de varsayılan yoksa DOKUMLER.VARSAYILAN = 1 olan, yoksa en küçük
--  kimlikli şablon varsayılan olur; web'de seçilmiş varsayılan korunur. Kurumlarda türe bir şablon var (UNIVERSE,
--  FETA), kural gerçekte GENINI ile aynı sonucu verir.
--
--  İçerik dokuman_icerik'e (sha256 BÜYÜK hex, dedup); dokuman satırı aktarım kimliğiyle (DOKUMLER). Aynı şablon
--  değişince yeni içerik satırı açılır, dokuman hash'i güncellenir (eski içerik referanssız kalır, 059 dedup
--  kuralı). D: dokuman satırı silinir. Delphi'de GRUBU değişip XSLT olmaktan çıkan satır da D gibi silinir.
-- =============================================================================

begin;

drop table if exists stg.dokumler;
create table stg.dokumler (
    id integer, raporno smallint, raporadi varchar(250), grubu varchar(50), modul varchar(50), standart smallint,
    versiyon varchar(50), varsayilan smallint, aciklama varchar(500), sql text, sontarih timestamp,
    sayac smallint, raporid integer, ekleyen integer, eklemetarihi timestamp, degistiren integer,
    degistirmetarihi timestamp, sektor varchar(50), durum smallint);

-- Delphi RAPORID -> (web tür kodu, yön). Bilinmeyen: tür 0 (atlanır).
create or replace function public.fn_aktarim_xslt_turu(p_raporid integer)
returns table (tur smallint, yon smallint) language sql immutable as $$
    select case p_raporid
             when 2 then 1 when 12 then 2 when 32 then 8 when 52 then 7
             when 1 then 1 when 11 then 2 when 31 then 8 when 51 then 7
             when 3 then 8 when 4 then 7
             else 0 end::smallint,
           case when p_raporid in (1, 11, 31, 51) then 1 else 2 end::smallint
$$;

create or replace function public.fn_aktar_xslt(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_sube int := coalesce((select min(id) from public.sube where aktif = 1), 1);
    v_sil int := 0; v_e int := 0; v_g int := 0; v_atla int := 0; v_vars int := 0; v_icerik int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    create temp table if not exists _ax on commit drop as select * from stg.dokumler with no data;
    truncate _ax;
    insert into _ax select * from jsonb_populate_recordset(null::stg.dokumler, coalesce(p->'U'->'DOKUMLER', '[]'));

    -- 0) D + XSLT olmaktan çıkan / bilinmeyen türlü satırlar: web'deki aktarım kaydı silinir.
    create temp table if not exists _axd (id bigint primary key) on commit drop;
    truncate _axd;
    insert into _axd select distinct (x #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'DOKUMLER', '[]')) x
     where jsonb_typeof(x) = 'number' on conflict do nothing;
    insert into _axd select x.id from _ax x, public.fn_aktarim_xslt_turu(coalesce(x.raporid, 0)) t
     where upper(coalesce(x.grubu, '')) <> 'XSLT' or t.tur = 0 or coalesce(btrim(x.sql), '') = ''
    on conflict do nothing;
    v_atla := (select count(*) from _ax x where x.id in (select id from _axd));
    delete from public.dokuman d using _axd s
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DOKUMLER' and d.aktarim_id = s.id;
    get diagnostics v_sil = row_count;
    delete from _ax x where x.id in (select id from _axd);

    -- 1) içerik (sha256 BÜYÜK hex, DokumanDeposu.EkleAsync ile aynı).
    create temp table if not exists _axi (id bigint primary key, hash varchar(64), icerik bytea, boyut int) on commit drop;
    truncate _axi;
    insert into _axi
    select x.id, upper(encode(sha256(convert_to(x.sql, 'UTF8')), 'hex')), convert_to(x.sql, 'UTF8'), octet_length(convert_to(x.sql, 'UTF8'))
      from _ax x;
    insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
    select distinct on (i.hash) i.hash, i.icerik, 'application/xslt+xml', i.boyut, 1
      from _axi i order by i.hash, i.id
    on conflict (hash) do nothing;
    get diagnostics v_icerik = row_count;

    -- 2) dokuman satırı.
    create temp table if not exists _axw on commit drop as select d.* from public.dokuman d with no data;
    truncate _axw;
    insert into _axw (aktarim_id, kaynak, kaynak_id, ad, content_type, boyut, hash, varsayilan, sube_id, ekleyen,
                      ekleme_tarihi, degistiren, yon, belge_turu, durum)
    select x.id, 'ebelge-xslt', t.tur, left(coalesce(nullif(btrim(x.raporadi), ''), 'XSLT ' || x.id), 200),
           'application/xslt+xml', i.boyut, i.hash,
           0, v_sube, coalesce(public.fn_aktarim_kisi_id(x.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(x.eklemetarihi), public.fn_aktarim_zaman(x.degistirmetarihi), timestamptz '1901-01-01'),
           0, t.yon,
           case t.tur when 1 then 'e-Fatura' when 2 then 'e-Arşiv' when 7 then 'e-İrsaliye' when 8 then 'e-SMM' else '' end,
           case when coalesce(x.durum, 1) = 0 then 0 else 1 end
      from _ax x
      join _axi i on i.id = x.id
      cross join lateral public.fn_aktarim_xslt_turu(coalesce(x.raporid, 0)) t;

    -- Varsayılan web'de seçilmişse korunur (eşitlemede kolon yok); yalnız yeni satırda kural uygulanır.
    select eklenen, guncellenen into v_e, v_g from public.fn_aktarim_esitle('dokuman', 'DOKUMLER', '_axw',
        array['kaynak', 'kaynak_id', 'ad', 'content_type', 'boyut', 'hash', 'sube_id', 'ekleyen', 'ekleme_tarihi',
              'yon', 'belge_turu', 'durum']);

    -- 3) (tür, yön) için varsayılan yoksa: Delphi VARSAYILAN = 1, yoksa en küçük Delphi kimliği.
    with aday as (
        select d.id, d.kaynak_id, d.yon,
               row_number() over (partition by d.kaynak_id, d.yon
                                  order by coalesce(x.varsayilan, 0) desc, d.aktarim_id) rn
          from public.dokuman d
          join _ax x on x.id = d.aktarim_id
         where d.kaynak = 'ebelge-xslt' and d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DOKUMLER' and d.durum = 1
           and not exists (select 1 from public.dokuman v where v.kaynak = 'ebelge-xslt' and v.kaynak_id = d.kaynak_id
                                                             and v.yon = d.yon and v.varsayilan = 1))
    update public.dokuman d set varsayilan = 1 from aday a where a.rn = 1 and d.id = a.id;
    get diagnostics v_vars = row_count;

    return jsonb_build_object('xslt', v_e + v_g, 'eklenen', v_e, 'guncellenen', v_g, 'silinen', v_sil,
                              'atlanan', v_atla, 'icerik', v_icerik, 'varsayilan_atanan', v_vars);
end $$;

comment on function public.fn_aktar_xslt(jsonb) is
    '1266: ajan paketi U/D DOKUMLER (GRUBU XSLT) -> dokuman (ebelge-xslt) + dokuman_icerik; varsayılan kuralı.';

-- ------------------------------------------------------- 15. adım (1086) ---
create or replace function public.fn_aktarim_adimlari()
returns table (sira int, fonksiyon text, tablolar text[]) language sql immutable as $$
    values (1,  'fn_aktar_depo',           array['DEPOLAR']),
           (2,  'fn_aktar_doviz',          array['DOVIZ']),
           (3,  'fn_aktar_masraf_merkezi', array['SRMMERKEZI']),
           (4,  'fn_aktar_cari',           array['REHBER', 'REHBERILETISIM', 'REHBERBILGI']),
           (5,  'fn_aktar_proje',          array['PROJELER']),
           (6,  'fn_aktar_kalem',          array['MASRAFGELIR', 'FIYATLAR']),
           (7,  'fn_aktar_stok',           array['STOKLAR', 'STOKBARKOD', 'STOKFIYAT', 'STOKSERILOT']),
           (8,  'fn_aktar_hesap',          array['KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER']),
           (9,  'fn_aktar_is_merkezi',     array['LOKASYON']),
           (10, 'fn_aktar_recete',         array['URETIMRECETE', 'URETIMRECETEDETAY', 'URETIMRECETEOPR']),
           (11, 'fn_aktar_stok_durum',     array['STOKDURUM']),
           (12, 'fn_aktar_belge',          array['FATBASLIK', 'FATURA', 'STOKIZLEME']),
           (13, 'fn_aktar_kasa',           array['KASA']),
           (14, 'fn_aktar_ebelge',         array['EBELGE', 'EBELGEMESAJ']),
           -- 1266: e-Belge XSLT şablonları (DOKUMLER GRUBU='XSLT'; ajan süzgeçle okur).
           (15, 'fn_aktar_xslt',           array['DOKUMLER'])
$$;

-- ---------------------------------------------- mutabakat kimlikleri (1091) ---
-- Yalnız DOKUMLER dalı eklendi; gövde 1265 ile aynı.
create or replace function public.fn_aktarim_web_kimlikleri(p_tablo text)
returns table (aktarim_id bigint, aktif boolean) language plpgsql stable as $$
begin
    case p_tablo
    when 'DEPOLAR' then
        return query select x.aktarim_id, x.durum <> 0 from public.depo x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'SRMMERKEZI' then
        return query select x.aktarim_id, false from public.masraf_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'REHBER' then
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
    when 'LOKASYON' then
        return query select x.aktarim_id, x.durum <> 1 from public.is_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'URETIMRECETE' then
        return query select x.aktarim_id, x.durum <> 1 from public.urun_agaci x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'FATBASLIK' then
        return query select x.aktarim_id, true from public.belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'KASA' then
        return query select x.aktarim_id, true from (
                         select m.aktarim_id from public.mali_hareket m where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA'
                         union
                         select k.aktarim_id from public.kasa_islem k where k.aktarim_kaynak = 1 and k.aktarim_tablo = 'KASA') x;
    when 'EBELGE' then
        return query select x.aktarim_id, true from public.e_belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'DOKUMLER' then       -- 1266: ajan yalnız GRUBU='XSLT' kimliklerini yollar; D şablonu siler
        return query select x.aktarim_id, true from public.dokuman x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    else
        raise exception using errcode = 'GK422', message = format('AKTARIM_TABLO: %s mutabakata girmez', p_tablo);
    end case;
end $$;

commit;
