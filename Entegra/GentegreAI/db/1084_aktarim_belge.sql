-- =============================================================================
--  1084  DELPHI AKTARIMI - DİLİM 3a: BELGE (FATBASLIK + FATURA + STOKIZLEME),
--        FATURANIN CARİ SATIRI, STOK BAKİYESİ (STOKDURUM)   (dokuman/18 §11)
--
--  KAPSAM (kullanıcı, 13.10.2026): hareketlerden YALNIZ BU YIL. Sınır
--  aktarim_ayar.hareket_baslangic (boş = sınır yok); daha eski tarihli belge
--  paketi sayılıp atlanır ('eski'). Ajanın ilk yüklemesi de aynı tarihle süzer.
--
--  TOPLAM: bir belge = FATBASLIK satırı + BÜTÜN FATURA satırları + BÜTÜN
--  STOKIZLEME satırları (BASLIKID). Pakette olmayan satır web'de silinir.
--  D.FATBASLIK = belge silinir (satır / izlem cascade, cari satırı önce).
--
--  KURALLAR - göç 014 + sonradan veriye uygulanan dönüşümler (aynen):
--   * 026 döviz: boş para birimi TL, kur 0 -> 1 (satırda belgenin kuru), döviz
--     tutarı 0 ise tutar / kur. 083/134: hepsi ISO (fn_doviz_iso), ekstre dövizi
--     = rapor dövizi, boş rapor dövizi = belge dövizi.
--   * 131: fatura türlerinde tipi 0 -> 1. 373: kdv_durum Dahil / Hariç / Muaf.
--   * 022: gönderici (unvan, VKN, alias) belgenin şubesinden.
--   * 023: iskonto2, otv_miktar, kdv_muafiyeti. 371/372: KDV'li birim fiyat ve
--     tutar (CHECK toleransı içinde).
--   * 115/116: izlem satırının deposu (transfer dönüşü giriş, çıkış türleri
--     çıkış, diğerleri giriş deposu; yoksa varsayılan depo).
--   * 334 tür takası UYGULANMAZ: Delphi 13 alış / 17 satış tahakkuku zaten web'in
--     bugünkü anlamı; 334 yalnız web'in yanlış ürettiği kayıtları taşımıştı.
--
--  FATURANIN CARİ SATIRI: Delphi faturaya KASA satırı YAZMAZ (BILIM 2021-2026:
--  0) - Delphi cari ekstresi FATBASLIK'ı doğrudan okur (fn_Cari_Ekstre UNION).
--  Web ekstresi yalnız mali_hareket okur -> aktarım cari satırını kendisi yazar,
--  web'in kaydetme kuralıyla AYNI (BelgeDeposu.MaliHareketYazAsync): katalog
--  cari_etkiler = 1, ekstre dövizi / kur, YÖN BelgeTuru.CikisMi(tur, tipi).
--  Delphi'den BİLEREK FARKLI: Delphi ekstresi iade faturasını (tipi 2) yön
--  çevirmeden yazıyor (15/2 borç); web'de iade ters yöndür (132). Delphi
--  DURUM 6 (iptal) cari satırı yazmaz (Delphi ekstresi de almaz).
--
--  STOK BAKİYESİ: web belge kaydı stok_durum'u artırır/azaltır; aktarım bunu
--  YAPMAZ - stok_durum Delphi STOKDURUM'un aynası (göç 013 ile aynı). Yalnız bu
--  yılın hareketi taşındığı için satırdan hesaplanan bakiye zaten yanlış olurdu.
--
--  KALEM KARŞILIĞI: satış satırı hizmet, alış satırı masraf ister. Delphi kalemi
--  (MASRAFGELIR) web'de yalnız öbür tarafta varsa karşılığı açılır (aynı kod,
--  ad, KDV, birim); kod web'in başka kaydına aitse açılmaz, satır kalemsiz kalır
--  ('kalemsiz' sayacı).
--  Kimlik eşlemesi 1080 (aktarim_*); Delphi kullanıcı / satıcı / servis /
--  aktivite kimlikleri web'de karşılıksız -> 0 / boş. Satır kaynağı (YERI/YERID)
--  yalnız Delphi satır dönüşümü (330 = FATURA) çözülürse kaynak_tur 30 olur.
--  İdempotent; içeriği aynı satıra yazılmaz.
-- =============================================================================

begin;

insert into public.aktarim_ayar (anahtar, deger, aciklama) values
    ('hareket_baslangic', '2026-01-01',
     'Delphi hareketleri (belge, kasa, stok izleme) bu tarihten itibaren aktarılır; boş = hepsi')
on conflict (anahtar) do nothing;

-- ================================================================ yardımcılar ===
-- Geçici tablodaki satırları (kolon adları hedefle aynı + aktarim_id) aktarım
-- kimliğiyle hedefe eşitler: içeriği farklı olanı günceller, olmayanı ekler.
create or replace function public.fn_aktarim_esitle(p_tablo text, p_kaynak text, p_gecici text,
                                                    p_kolonlar text[], out eklenen int, out guncellenen int)
language plpgsql as $$
declare
    v_kol text := array_to_string(p_kolonlar, ', ');
    v_w   text := (select string_agg('w.' || k, ', ') from unnest(p_kolonlar) k);
    v_x   text := (select string_agg('x.' || k, ', ') from unnest(p_kolonlar) k);
begin
    execute format(
        'update public.%1$I x set (%2$s) = row(%3$s) from %4$I w '
        ' where x.aktarim_kaynak = 1 and x.aktarim_tablo = %5$L and x.aktarim_id = w.aktarim_id '
        '   and row(%6$s) is distinct from row(%3$s)',
        p_tablo, v_kol, v_w, p_gecici, p_kaynak, v_x);
    get diagnostics guncellenen = row_count;
    execute format(
        'insert into public.%1$I (%2$s, aktarim_kaynak, aktarim_tablo, aktarim_id) '
        'select %3$s, 1, %4$L, w.aktarim_id from %5$I w '
        ' where not exists (select 1 from public.%1$I x where x.aktarim_kaynak = 1 '
        '                      and x.aktarim_tablo = %4$L and x.aktarim_id = w.aktarim_id)',
        p_tablo, v_kol, v_w, p_kaynak, p_gecici);
    get diagnostics eklenen = row_count;
end $$;

-- BelgeTuru.CikisMi(tur, tipi) - Gentegre.Cekirdek/Katalog/BelgeTuru.cs ile AYNI
-- (stok çıkışı / cari borçlanır). Değişirse ikisi birlikte.
create or replace function public.fn_belge_cikis_mi(p_tur integer, p_tipi integer)
returns boolean language sql immutable as $$
    select case when p_tipi = 2 and p_tur not in (9, 18, 19, 20, 105)
                then not (p_tur in (17, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123))
                else p_tur in (17, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123) end
$$;

-- ============================================================== stok bakiyesi ===
create or replace function public.fn_aktar_stok_durum(p jsonb)
returns jsonb language plpgsql as $$
declare v_n int := 0; v_atla int := 0; v_sil int := 0;
begin
    create temp table if not exists _sd on commit drop as select * from stg.stokdurum with no data;
    truncate _sd;
    insert into _sd select * from jsonb_populate_recordset(null::stg.stokdurum, coalesce(p->'U'->'STOKDURUM', '[]'));

    create temp table if not exists _sdw (stok int, depo int, giren numeric, cikan numeric, kalan numeric)
        on commit drop;
    truncate _sdw;
    insert into _sdw
    select public.fn_aktarim_web_id('stok', 'STOKLAR', d.stokid), public.fn_aktarim_web_id('depo', 'DEPOLAR', d.depoid),
           round(coalesce(d.giren, 0)::numeric, 4), round(coalesce(d.cikan, 0)::numeric, 4),
           round(coalesce(d.kalan, 0)::numeric, 4)
      from _sd d;
    delete from _sdw where stok is null or depo is null;
    get diagnostics v_atla = row_count;

    insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan)
    select stok, depo, giren, cikan, kalan from _sdw
    on conflict (stok_id, depo_id) do update
       set giren = excluded.giren, cikan = excluded.cikan, kalan = excluded.kalan
     where (public.stok_durum.giren, public.stok_durum.cikan, public.stok_durum.kalan)
           is distinct from (excluded.giren, excluded.cikan, excluded.kalan);
    get diagnostics v_n = row_count;

    -- Silinen bakiye satırı sıfırlanır (min / max / rezerve web'in).
    update public.stok_durum x set giren = 0, cikan = 0, kalan = 0
      from (select public.fn_aktarim_web_id('stok', 'STOKLAR', (e->>'stokid')::bigint) s,
                   public.fn_aktarim_web_id('depo', 'DEPOLAR', (e->>'depoid')::bigint) d
              from jsonb_array_elements(coalesce(p->'D'->'STOKDURUM', '[]')) e) k
     where x.stok_id = k.s and x.depo_id = k.d and (x.giren, x.cikan, x.kalan) is distinct from (0, 0, 0);
    get diagnostics v_sil = row_count;

    return jsonb_build_object('stok_durum', v_n, 'eslesmeyen', v_atla, 'sifirlanan', v_sil);
end $$;

-- ===================================================================== belge ===
create or replace function public.fn_aktar_belge(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_bas date := (select nullif(btrim(a.deger), '')::date from public.aktarim_ayar a
                    where a.anahtar = 'hareket_baslangic');
    v_eski int := 0; v_be int := 0; v_bg int := 0; v_se int := 0; v_sg int := 0; v_ssil int := 0;
    v_ze int := 0; v_zg int := 0; v_zsil int := 0; v_zatla int := 0; v_karsi int := 0; v_kalemsiz int := 0;
    v_cari int := 0; v_carisil int := 0; v_sil int := 0;
    v_kb text[] := array['tur', 'tipi', 'taraf_id', 'taraf_adres_id', 'taraf_unvan', 'taraf_vkno', 'taraf_vd',
        'taraf_adres', 'taraf_ilce', 'taraf_il', 'belge_seri', 'belge_no', 'kocan_no', 'belge_tarihi',
        'kayit_tarihi', 'irsaliye_no', 'irsaliye_tarihi', 'giris_depo_id', 'cikis_depo_id', 'sube_id',
        'merkez_id', 'proje_id', 'matrah', 'kdv_tutari', 'ek_vergi', 'genel_toplam', 'stok_iskonto',
        'kdv_durum', 'belge_dovizi', 'doviz_cinsi', 'doviz_tutari', 'doviz_kuru', 'rapor_dovizi',
        'ekstre_dovizi', 'kur', 'vade_gun', 'acik_kapali', 'durum', 'eski_fiyat_adi', 'masraf_id',
        'ekstrede_kullan', 'efatura_durum', 'efatura_sonuc', 'senaryo', 'zarf_id', 'yazdirildi',
        'aciklama', 'ozel_kod', 'ozel_kod2', 'detay_bolumu', 'dil', 'sayfa', 'sayfa_sayisi', 'maliyet_ort',
        'giris_kaynak', 'gonderici_unvan', 'gonderici_vkno', 'gonderici_alias'];
    v_ks text[] := array['belge_id', 'sira', 'tur', 'stok_id', 'hizmet_id', 'masraf_id', 'aciklama', 'miktar',
        'adet', 'birim', 'birim_fiyat', 'iskonto', 'iskontolu_birim_fiyat', 'kdv', 'kdv_dahil_birim_fiyat',
        'otv_yuzde', 'tutar', 'ek_maliyet', 'doviz_cinsi', 'doviz_birim_fiyat', 'doviz_tutari', 'doviz_kuru',
        'giris_depo_id', 'cikis_depo_id', 'izleme', 'izleme_kodu', 'stok_durum_degis', 'ekipman_id',
        'kaynak_tur', 'kaynak_id', 'proje_id', 'taraf_id', 'vade_gun', 'ozel_kod', 'ozel_kod2', 'muh_kodu',
        'sube_id', 'merkez_id', 'giris_kaynak', 'iskonto2', 'otv_miktar', 'kdv_muafiyeti',
        'birim_fiyat_kdvli', 'tutar_kdvli', 'uygunluk_notu'];
    v_kz text[] := array['stok_id', 'seri_lot_id', 'izlem_tur', 'belge_tur', 'belge_id', 'belge_satir_id',
        'adet', 'kalan', 'donus_id', 'depo_id'];
begin
    create temp table if not exists _fb on commit drop as select * from stg.fatbaslik  with no data;
    create temp table if not exists _fs on commit drop as select * from stg.fatura     with no data;
    create temp table if not exists _fz on commit drop as select * from stg.stokizleme with no data;
    truncate _fb, _fs, _fz;
    insert into _fb select * from jsonb_populate_recordset(null::stg.fatbaslik,  coalesce(p->'U'->'FATBASLIK', '[]'));
    insert into _fs select * from jsonb_populate_recordset(null::stg.fatura,     coalesce(p->'U'->'FATURA', '[]'));
    insert into _fz select * from jsonb_populate_recordset(null::stg.stokizleme, coalesce(p->'U'->'STOKIZLEME', '[]'));

    -- 0) yıl sınırı: belge tarihi sınırdan önceyse paketin o belgesi atlanır
    if v_bas is not null then
        delete from _fb f where coalesce(f.faturatarih, f.eklemetarihi) < v_bas;
        get diagnostics v_eski = row_count;
    end if;
    delete from _fs s where not exists (select 1 from _fb f where f.id = s.fatbasid);
    delete from _fz z where not exists (select 1 from _fb f where f.id = z.baslikid);

    -- 1) başlık
    create temp table if not exists _bw on commit drop as
        select b.* from public.belge b with no data;
    truncate _bw;
    insert into _bw (aktarim_id, tur, tipi, taraf_id, taraf_adres_id, taraf_unvan, taraf_vkno, taraf_vd,
                     taraf_adres, taraf_ilce, taraf_il, belge_seri, belge_no, kocan_no, belge_tarihi, kayit_tarihi,
                     irsaliye_no, irsaliye_tarihi, giris_depo_id, cikis_depo_id, sube_id, merkez_id, proje_id,
                     matrah, kdv_tutari, ek_vergi, genel_toplam, stok_iskonto, kdv_durum,
                     belge_dovizi, doviz_cinsi, doviz_tutari, doviz_kuru, rapor_dovizi, ekstre_dovizi, kur,
                     vade_gun, acik_kapali, durum, eski_fiyat_adi, masraf_id, ekstrede_kullan,
                     efatura_durum, efatura_sonuc, senaryo, zarf_id, yazdirildi,
                     aciklama, ozel_kod, ozel_kod2, detay_bolumu, dil, sayfa, sayfa_sayisi, maliyet_ort,
                     giris_kaynak, gonderici_unvan, gonderici_vkno, gonderici_alias)
    select f.id, coalesce(f.tur, 0),
           case when coalesce(f.tipi, 0) = 0 and f.tur in (11, 12, 15, 16, 109, 119) then 1 else coalesce(f.tipi, 0) end,
           public.fn_aktarim_web_id('taraf', 'REHBER', f.rehberid),
           public.fn_aktarim_web_id('taraf_adres', 'REHBERILETISIM', f.rehberiletid),
           coalesce(f.baslik, ''), coalesce(f.vno, ''), coalesce(f.vd, ''),
           coalesce(f.adres, ''), coalesce(f.ilce, ''), coalesce(f.il, ''),
           coalesce(f.faturaseri, ''),
           case when btrim(coalesce(f.faturano, '')) in ('', '0') then '' else btrim(f.faturano) end,
           coalesce(f.kocanno, 0),
           coalesce(public.fn_aktarim_zaman(f.faturatarih), public.fn_aktarim_zaman(f.eklemetarihi),
                    timestamptz '1901-01-01'),
           -- now() DEĞİL: her eşitlemede değişip belgeyi boşuna yeniden yazardı
           coalesce(public.fn_aktarim_zaman(f.eklemetarihi), public.fn_aktarim_zaman(f.faturatarih),
                    timestamptz '1901-01-01'),
           coalesce(f.irsaliyeno, ''), public.fn_aktarim_zaman(f.irsaliyetarih),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', f.girisdepo),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', f.cikisdepo),
           public.fn_aktarim_sube(f.subeid),
           public.fn_aktarim_web_id('masraf_merkezi', 'SRMMERKEZI', f.merkezid),
           public.fn_aktarim_web_id('proje', 'PROJELER', f.projeid),
           coalesce(f.fatura_matrahi, 0), coalesce(f.kdv_tutari, 0), coalesce(f.ekvergi, 0),
           coalesce(f.fatura_tutari, 0), coalesce(f.stokisk, 0),
           case when lower(btrim(coalesce(f.kdvdurum, ''))) like 'dah%' then 'Dahil'
                when lower(btrim(coalesce(f.kdvdurum, ''))) like 'muaf%' then 'Muaf' else 'Hariç' end,
           d.belge_dovizi, public.fn_doviz_iso(f.doviz_cinsi),
           case when coalesce(f.doviz_tutari, 0) = 0
                then round(coalesce(f.fatura_tutari, 0) / d.kuru, 4) else f.doviz_tutari end,
           d.kuru, d.rapor, d.rapor, public.fn_doviz_iso(f.kur),
           coalesce(f.vade, 0), coalesce(f.acik_kapali, 0), coalesce(f.durum, 0), coalesce(f.fiyat_listesi, 0),
           public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', f.masrafid), coalesce(f.ekstredekullan, 1),
           coalesce(f.efaturadurum, 0), coalesce(f.efaturasonuc, 0), coalesce(f.senaryo, 0),
           coalesce(f.zarfid, 0), coalesce(f.yazdirildi, 0),
           coalesce(f.aciklama, ''), coalesce(f.ozelkod, ''), coalesce(f.ozelkod2, ''),
           coalesce(f.detaybolumu, ''), coalesce(f.dil, 0), coalesce(f.sayfa, 0), coalesce(f.sayfasay, 0),
           coalesce(f.fatura_maliyeti_ort, 0), coalesce(f.giriskaynak, 0),
           coalesce(nullif(s.unvan, ''), s.ad, ''), coalesce(s.vkno, ''), coalesce(s.efatura_alias, '')
      from _fb f
      cross join lateral (select public.fn_doviz_iso(f.faturadovizi) as belge_dovizi,
                                 coalesce(nullif(f.dovizkur, 0), 1) as kuru,
                                 case when coalesce(btrim(f.rapordoviz), '') = '' then public.fn_doviz_iso(f.faturadovizi)
                                      else public.fn_doviz_iso(f.rapordoviz) end as rapor) d
      left join public.sube s on s.id = public.fn_aktarim_sube(f.subeid);

    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('belge', 'FATBASLIK', '_bw', v_kb);

    create temp table if not exists _bid (delphi bigint primary key, web int, tur int, tipi int,
                                          giris int, cikis int, sube int, merkez int, kur numeric, cins varchar)
        on commit drop;
    truncate _bid;
    insert into _bid
    select w.aktarim_id, x.id, x.tur, x.tipi, x.giris_depo_id, x.cikis_depo_id, x.sube_id, x.merkez_id,
           x.doviz_kuru, x.belge_dovizi
      from _bw w join public.belge x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = w.aktarim_id;

    -- 2) kalem karşılığı: satışta hizmet, alışta masraf; yalnız öbür tarafta varsa açılır
    create temp table if not exists _kk (kalem bigint, hizmet boolean) on commit drop;
    truncate _kk;
    insert into _kk
    select distinct s.urunid, public.fn_belge_cikis_mi(b.tur, 1)
      from _fs s join _bid b on b.delphi = s.fatbasid
     where coalesce(s.tur, 0) <> 1 and coalesce(s.urunid, 0) > 0;

    insert into public.hizmet (kod, ad, kdv, birim, muh_kodu, ozel_kod, aciklama, durum, sube_id,
                               aktarim_kaynak, aktarim_tablo, aktarim_id)
    select m.kod, m.ad, m.kdv, m.birim, m.muh_kodu, m.ozel_kod, m.aciklama, m.durum, m.sube_id, 1, 'MASRAFGELIR', k.kalem
      from _kk k join public.masraf m on m.aktarim_kaynak = 1 and m.aktarim_tablo = 'MASRAFGELIR' and m.aktarim_id = k.kalem
     where k.hizmet
       and public.fn_aktarim_web_id('hizmet', 'MASRAFGELIR', k.kalem) is null
       and not exists (select 1 from public.hizmet h where h.kod = m.kod);
    get diagnostics v_karsi = row_count;
    insert into public.masraf (kod, ad, kdv, birim, muh_kodu, ozel_kod, aciklama, durum, sube_id,
                               aktarim_kaynak, aktarim_tablo, aktarim_id)
    select h.kod, h.ad, h.kdv, h.birim, h.muh_kodu, h.ozel_kod, h.aciklama, h.durum, h.sube_id, 1, 'MASRAFGELIR', k.kalem
      from _kk k join public.hizmet h on h.aktarim_kaynak = 1 and h.aktarim_tablo = 'MASRAFGELIR' and h.aktarim_id = k.kalem
     where not k.hizmet
       and public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', k.kalem) is null
       and not exists (select 1 from public.masraf x where x.kod = h.kod);
    get diagnostics v_kalemsiz = row_count;          -- geçici: masraf karşılığı sayısı
    v_karsi := v_karsi + v_kalemsiz;

    -- 3) satırlar. Kaynak (330 = Delphi FATURA) satırı önce gelmiş olmalı; çözülmezse 0.
    create temp table if not exists _sw on commit drop as
        select s.* from public.belge_satir s with no data;
    truncate _sw;
    insert into _sw (aktarim_id, belge_id, sira, tur, stok_id, hizmet_id, masraf_id, aciklama, miktar, adet, birim,
                     birim_fiyat, iskonto, iskontolu_birim_fiyat, kdv, kdv_dahil_birim_fiyat, otv_yuzde, tutar,
                     ek_maliyet, doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru, giris_depo_id,
                     cikis_depo_id, izleme, izleme_kodu, stok_durum_degis, ekipman_id, kaynak_tur, kaynak_id,
                     proje_id, taraf_id, vade_gun, ozel_kod, ozel_kod2, muh_kodu, sube_id, merkez_id, giris_kaynak,
                     iskonto2, otv_miktar, kdv_muafiyeti, birim_fiyat_kdvli, tutar_kdvli, uygunluk_notu)
    select s.id, b.web,
           coalesce(s.sira, row_number() over (partition by s.fatbasid order by s.id))::int,
           case when coalesce(s.tur, 0) = 1 then 1 when k.hizmet is not null then 2 when k.masraf is not null then 3 else 0 end,
           case when coalesce(s.tur, 0) = 1 then public.fn_aktarim_web_id('stok', 'STOKLAR', s.urunid) end,
           k.hizmet, k.masraf,
           coalesce(s.aciklama, ''), coalesce(s.miktar, 0), coalesce(s.adet, 0), coalesce(s.birim, 0),
           coalesce(s.birimfiyat, 0), coalesce(s.iskonto, 0), coalesce(s.iskontolubrmfiyat, 0),
           coalesce(s.kdv, 0), coalesce(s.kdvdahilbrmfiyat, 0), coalesce(s.otvyuzde, 0),
           coalesce(s.tutar, 0), coalesce(s.ekmaliyet, 0),
           d.cins,
           case when coalesce(s.doviz_birimfiyat, 0) = 0 then round(coalesce(s.birimfiyat, 0) / d.kur, 6) else s.doviz_birimfiyat end,
           case when coalesce(s.doviz_tutari, 0) = 0 then round(coalesce(s.tutar, 0) / d.kur, 4) else s.doviz_tutari end,
           d.kur,
           public.fn_aktarim_web_id('depo', 'DEPOLAR', s.girdepo), public.fn_aktarim_web_id('depo', 'DEPOLAR', s.cikdepo),
           coalesce(s.izleme, 0), coalesce(s.izlemekodu, ''), coalesce(s.stokdurumdegis, 1), coalesce(s.ekipmanid, 0),
           case when s.yeri = 330 and kay.id is not null then 30 else 0 end,
           case when s.yeri = 330 and kay.id is not null then kay.id else 0 end,
           public.fn_aktarim_web_id('proje', 'PROJELER', s.projeid),
           public.fn_aktarim_web_id('taraf', 'REHBER', s.rehberid),
           coalesce(s.vade, 0), coalesce(s.ozelkod, ''), coalesce(s.ozelkod2, ''), coalesce(s.muhkodu, ''),
           coalesce(public.fn_aktarim_sube(s.subeid), b.sube),
           coalesce(public.fn_aktarim_web_id('masraf_merkezi', 'SRMMERKEZI', s.merkezid), b.merkez, 0),  -- satırda NOT NULL, 0 = yok
           coalesce(s.giriskaynak, 0),
           coalesce(s.iskonto2, 0), coalesce(s.otvmiktar, 0), coalesce(s.kdvmuhafiyeti, 0),
           case when coalesce(s.birimfiyat, 0) <> 0
                then round(s.birimfiyat * (1 + coalesce(s.kdv, 0)::int / 100.0), 4) else 0 end,
           case when coalesce(s.tutar, 0) <> 0
                then round(s.tutar * (1 + coalesce(s.kdv, 0)::int / 100.0), 4) else 0 end,
           -- uygunluk kuralı (cinsiyet / yaş) Delphi'de yoktu: kayıt olduğu gibi gelir
           case when k.hizmet is not null then 'Delphi aktarımı' else '' end
      from _fs s
      join _bid b on b.delphi = s.fatbasid
      cross join lateral (
          select case when coalesce(s.tur, 0) = 1 or coalesce(s.urunid, 0) = 0 then null::int
                      when public.fn_belge_cikis_mi(b.tur, 1)
                      then public.fn_aktarim_web_id('hizmet', 'MASRAFGELIR', s.urunid) end as hizmet,
                 case when coalesce(s.tur, 0) = 1 or coalesce(s.urunid, 0) = 0 then null::int
                      when not public.fn_belge_cikis_mi(b.tur, 1)
                      then public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', s.urunid) end as masraf) k
      cross join lateral (
          select case when coalesce(btrim(s.doviz_kuru), '') = '' then b.cins
                      else public.fn_doviz_iso(s.doviz_kuru) end as cins,
                 coalesce(nullif(s.dovizkurdegeri, 0), nullif(b.kur, 0), 1) as kur) d
      left join public.belge_satir kay
             on s.yeri = 330 and kay.aktarim_kaynak = 1 and kay.aktarim_tablo = 'FATURA' and kay.aktarim_id = s.yerid;

    -- kalemi olan ama web'de çözülemeyen satır (kartsız serbest satır - URUNID 0 - sayılmaz)
    select count(*) into v_kalemsiz from _sw w join _fs s on s.id = w.aktarim_id
     where w.stok_id is null and w.hizmet_id is null and w.masraf_id is null and coalesce(s.urunid, 0) > 0;

    -- pakette olmayan Delphi satırı (önce: izlem cascade'le gider)
    delete from public.belge_satir x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATURA'
       and x.belge_id in (select web from _bid)
       and not exists (select 1 from _sw w where w.aktarim_id = x.aktarim_id);
    get diagnostics v_ssil = row_count;

    select eklenen, guncellenen into v_se, v_sg from public.fn_aktarim_esitle('belge_satir', 'FATURA', '_sw', v_ks);

    -- 4) stok izlem (seri / lot). Stok ya da seri-lot çözülmezse atlanır (göç 014 de alıyordu).
    create temp table if not exists _zw on commit drop as
        select z.* from public.stok_izleme z with no data;
    truncate _zw;
    insert into _zw (aktarim_id, stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id,
                     adet, kalan, donus_id, depo_id)
    select z.id, public.fn_aktarim_web_id('stok', 'STOKLAR', z.stokid),
           public.fn_aktarim_web_id('stok_seri_lot', 'STOKSERILOT', z.serilotid),
           coalesce(z.izlemtur, 0), coalesce(z.belgetur, 0), b.web, st.id,
           coalesce(z.adet, 0), coalesce(z.kalan, 0),
           coalesce(public.fn_aktarim_web_id('stok_izleme', 'STOKIZLEME', z.donusid), 0),
           coalesce(case when z.belgetur = 20 and coalesce(z.donusid, 0) <> 0 then coalesce(st.giris_depo_id, b.giris)
                         when z.belgetur in (14, 15, 16, 119, 4, 29, 105, 133, 20) then coalesce(st.cikis_depo_id, b.cikis)
                         else coalesce(st.giris_depo_id, b.giris) end,
                    (select min(d.id) from public.depo d where d.varsayilan = 1 and d.durum = 1))
      from _fz z
      join _bid b on b.delphi = z.baslikid
      left join public.belge_satir st on st.aktarim_kaynak = 1 and st.aktarim_tablo = 'FATURA' and st.aktarim_id = z.satirid;
    delete from _zw where stok_id is null or seri_lot_id is null;
    get diagnostics v_zatla = row_count;

    delete from public.stok_izleme x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKIZLEME'
       and x.belge_id in (select web from _bid)
       and not exists (select 1 from _zw w where w.aktarim_id = x.aktarim_id);
    get diagnostics v_zsil = row_count;

    select eklenen, guncellenen into v_ze, v_zg from public.fn_aktarim_esitle('stok_izleme', 'STOKIZLEME', '_zw', v_kz);

    -- 5) cari satırı (BelgeDeposu.MaliHareketYazAsync ile aynı kural)
    create temp table if not exists _cw on commit drop as
        select m.* from public.mali_hareket m with no data;
    truncate _cw;
    insert into _cw (aktarim_id, tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru, aciklama,
                     ekstrede_kullan, proje_id, merkez_id, sube_id)
    select w.aktarim_id, x.tur, 'C', x.taraf_id, x.id, x.belge_no, x.belge_tarihi,
           case when c.cikis then d.tutar else 0 end, case when c.cikis then 0 else d.tutar end,
           case when c.cikis then x.genel_toplam else 0 end, case when c.cikis then 0 else x.genel_toplam end,
           d.cins, d.kur, x.taraf_unvan, x.ekstrede_kullan, x.proje_id, x.merkez_id, x.sube_id
      from _bw w
      join public.belge x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = w.aktarim_id
      join public.kasa_islem_turu t on t.kod = x.tur and t.cari_etkiler = 1
      cross join lateral (select public.fn_belge_cikis_mi(x.tur, x.tipi) as cikis) c
      cross join lateral (
          select e.cins,
                 case when e.cins = r.cins and coalesce(x.doviz_tutari, 0) > 0 then x.doviz_tutari else x.genel_toplam end as tutar,
                 case when e.cins = r.cins and coalesce(x.doviz_kuru, 0) > 0 then x.doviz_kuru else 1 end as kur
            from (select coalesce(nullif(btrim(x.ekstre_dovizi), ''), nullif(btrim(x.rapor_dovizi), ''),
                                  nullif(btrim(x.belge_dovizi), ''), 'TL') as cins) e,
                 (select coalesce(nullif(btrim(x.rapor_dovizi), ''), nullif(btrim(x.belge_dovizi), ''), 'TL') as cins) r) d
     where x.taraf_id is not null and x.durum <> 6;

    delete from public.mali_hareket m
     where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK'
       and m.aktarim_id in (select delphi from _bid)
       and not exists (select 1 from _cw c where c.aktarim_id = m.aktarim_id);
    get diagnostics v_carisil = row_count;

    select eklenen + guncellenen into v_cari from public.fn_aktarim_esitle('mali_hareket', 'FATBASLIK', '_cw',
        array['tur', 'hesap_turu', 'taraf_id', 'belge_id', 'belge_no', 'islem_tarihi', 'borc', 'alacak',
              'yerel_borc', 'yerel_alacak', 'doviz_cinsi', 'doviz_kuru', 'aciklama', 'ekstrede_kullan',
              'proje_id', 'merkez_id', 'sube_id']);

    -- 6) silinen belge
    create temp table if not exists _bsil (web int) on commit drop;
    truncate _bsil;
    insert into _bsil select x.id from public.belge x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK'
       and x.aktarim_id in (select (e #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'FATBASLIK', '[]')) e);
    delete from public.mali_hareket m where m.belge_id in (select web from _bsil)
       and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK';
    delete from public.belge x where x.id in (select web from _bsil);
    get diagnostics v_sil = row_count;

    return jsonb_build_object('belge', v_be + v_bg, 'belge_yeni', v_be, 'eski', v_eski, 'silinen', v_sil,
                              'satir', v_se + v_sg, 'satir_silinen', v_ssil, 'kalemsiz', v_kalemsiz,
                              'kalem_karsilik', v_karsi,
                              'izlem', v_ze + v_zg, 'izlem_silinen', v_zsil, 'izlem_atlanan', v_zatla,
                              'cari', v_cari, 'cari_silinen', v_carisil);
end $$;

comment on function public.fn_aktar_belge(jsonb) is
    '1084: Delphi FATBASLIK (+FATURA, +STOKIZLEME) -> belge / belge_satir / stok_izleme + faturanın cari satırı. Bkz. dosya başı.';

commit;
