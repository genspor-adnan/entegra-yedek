-- =============================================================================
--  1188  AKTARIM: DELPHI BORÇ / ALACAK TAHAKKUKU - AÇIKLAMA, CARİ, SATIR
--
--  Kullanıcı (25.10.2026): "borç / alacak tahakkuklarda açıklama migrate edince gelmemiş".
--  Delphi tahakkuku (FATBASLIK TUR 13 / 17) yalnız BAŞLIKTIR: FATURA satırı yok, BASLIK (ünvan) boş, ne için
--  olduğu ACIKLAMA'da, tutar FATURA_TUTARI. fn_aktar_belge (1142) cari hareketin açıklamasına ünvanı yazıyordu
--  (boş) ve satır açmıyordu: ekstrede / son olaylarda açıklama boş, tahakkuk kartında cari, açıklama ve toplam
--  boş görünüyordu (UNIVERSE, FETA, BILIM; ZONE / MEDX aktarımı öncesi bulundu).
--
--  1) fn_aktar_belge: (a) başlık ünvanı boşsa cari adı; (b) tahakkukta cari hareket açıklaması = ACIKLAMA;
--     (c) satırsız tahakkuka tek serbest satır (açıklama + tutar, KDV 0; aktarim_tablo 'FATBASLIK_TK').
--  2) ONARIM (zaten aktarılmış veritabanı): YALNIZ aktarımla gelmiş (aktarim_kaynak 1, FATBASLIK) kayıtlar,
--     yalnız kanıtlanabilir boşluklar: ünvanı boş başlık, açıklaması boş tahakkuk cari hareketi, satırı hiç olmayan
--     tahakkuk. Web'de açılmış / değiştirilmiş kayda dokunulmaz. Öncesi rapor edilir. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_aktar_belge(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_bas date := (select nullif(btrim(a.deger), '')::date from public.aktarim_ayar a
                    where a.anahtar = 'hareket_baslangic');
    v_eski int := 0; v_be int := 0; v_bg int := 0; v_se int := 0; v_sg int := 0; v_ssil int := 0;
    v_ze int := 0; v_zg int := 0; v_zsil int := 0; v_zatla int := 0; v_zdon int := 0; v_karsi int := 0; v_kalemsiz int := 0;
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
    select f.id, tt.tur,
           case when coalesce(f.tipi, 0) = 0 and f.tur in (11, 12, 15, 16, 109, 119) then 1 else coalesce(f.tipi, 0) end,
           public.fn_aktarim_cari_id(f.rehberid),            -- 1085: 0 = Tanımsız Cari
           public.fn_aktarim_web_id('taraf_adres', 'REHBERILETISIM', f.rehberiletid),
           -- 1188: BAŞLIK boşsa (Delphi borç / alacak tahakkuku) cari adı - kart / liste "Cari" boş kalmasın.
           left(coalesce(nullif(btrim(f.baslik), ''),
                         (select public.fn_taraf_ad(ta.unvan, ta.ad, ta.soyad)::varchar from public.taraf ta
                           where ta.id = public.fn_aktarim_cari_id(f.rehberid)), ''), 200),
           coalesce(f.vno, ''), left(coalesce(f.vd, ''), 60),
           left(coalesce(f.adres, ''), 300), left(coalesce(f.ilce, ''), 60), left(coalesce(f.il, ''), 60),
           coalesce(f.faturaseri, ''),
           case when btrim(coalesce(f.faturano, '')) in ('', '0') then '' else btrim(f.faturano) end,
           coalesce(f.kocanno, 0),
           coalesce(public.fn_aktarim_zaman(f.faturatarih), public.fn_aktarim_zaman(f.eklemetarihi),
                    timestamptz '1901-01-01'),
           -- now() DEĞİL: her eşitlemede değişip belgeyi boşuna yeniden yazardı
           coalesce(public.fn_aktarim_zaman(f.eklemetarihi), public.fn_aktarim_zaman(f.faturatarih),
                    timestamptz '1901-01-01'),
           coalesce(f.irsaliyeno, ''), public.fn_aktarim_zaman(f.irsaliyetarih),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', case when tt.takas then f.cikisdepo else f.girisdepo end),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', case when tt.takas then f.girisdepo else f.cikisdepo end),
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
           d.kuru, d.rapor, d.ekstre, public.fn_doviz_iso(f.kur),
           coalesce(f.vade, 0), coalesce(f.acik_kapali, 0), coalesce(f.durum, 0), coalesce(f.fiyat_listesi, 0),
           public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', f.masrafid), coalesce(f.ekstredekullan, 1),
           coalesce(f.efaturadurum, 0), coalesce(f.efaturasonuc, 0), coalesce(f.senaryo, 0),
           coalesce(f.zarfid, 0), coalesce(f.yazdirildi, 0),
           left(coalesce(f.aciklama, ''), 300), coalesce(f.ozelkod, ''), coalesce(f.ozelkod2, ''),
           coalesce(f.detaybolumu, ''), coalesce(f.dil, 0), coalesce(f.sayfa, 0), coalesce(f.sayfasay, 0),
           coalesce(f.fatura_maliyeti_ort, 0), coalesce(f.giriskaynak, 0),
           coalesce(nullif(s.unvan, ''), s.ad, ''), coalesce(s.vkno, ''), coalesce(s.efatura_alias, '')
      from _fb f
      cross join lateral (select public.fn_doviz_iso(f.faturadovizi) as belge_dovizi,
                                 coalesce(nullif(f.dovizkur, 0), 1) as kuru,
                                 case when coalesce(btrim(f.rapordoviz), '') = '' then public.fn_doviz_iso(f.faturadovizi)
                                      else public.fn_doviz_iso(f.rapordoviz) end as rapor,
                                 -- 1142: cari bakiyesinin dövizi (Delphi sp_Prog_Cari_Liste / fn_Cari_Ekstre)
                                 case when f.ekstredekullan = 1 and coalesce(btrim(f.doviz_cinsi), '') <> ''
                                      then public.fn_aktarim_doviz(f.doviz_cinsi)
                                      else public.fn_aktarim_doviz(f.kur) end as ekstre) d
      -- 1142: İADE BELGESİ KARŞI TÜRE. Delphi'de yön TÜRDEN gelir, iadeyi malı geri
      --   gönderen keser (GİB): 15/2 = tedarikçiye iade (alış iadesi), 11/2 = müşteriden
      --   iade (satış iadesi). Web'de iade AYNI türde ters yöndür (BelgeTuru.CikisMi):
      --   alış iadesi 11/2, satış iadesi 15/2. Depolar da yer değiştirir (web depoyu
      --   türden seçer).
      cross join lateral (
          select coalesce(case when f.tipi = 2 then
                     case f.tur when 10 then 14 when 14 then 10 when 11 then 15 when 15 then 11
                                when 12 then 16 when 16 then 12 when 13 then 17 when 17 then 13
                                when 109 then 119 when 119 then 109 end end, f.tur, 0) as tur,
                 f.tipi = 2 and f.tur in (10, 14, 11, 15, 12, 16, 13, 17, 109, 119) as takas) tt
      left join public.sube s on s.id = public.fn_aktarim_sube(f.subeid);

    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('belge', 'FATBASLIK', '_bw', v_kb);

    -- 1085: alış belgesi gelen Delphi carisi tedarikçidir (göç 014); bayrak kaldırılmaz.
    update public.taraf t set tedarikci = 1
     where t.tedarikci = 0 and t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER'
       and t.id in (select w.taraf_id from _bw w where w.tur in (10, 11, 12, 109));

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

    -- 1188: DELPHI TAHAKKUKU SATIRSIZDIR (yalnız başlık: ACIKLAMA + FATURA_TUTARI). Web tahakkuk kartı kalemden
    --   okur - açıklama ve tutar görünsün diye tek serbest satır (KDV 0) yazılır; aktarim_tablo 'FATBASLIK_TK',
    --   aktarim_id = başlık. Delphi FATURA satırı olan tahakkukta yazılmaz; her pakette yeniden kurulur.
    delete from public.belge_satir x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK_TK' and x.belge_id in (select web from _bid);
    insert into public.belge_satir (belge_id, sira, tur, aciklama, miktar, adet, birim_fiyat, iskontolu_birim_fiyat,
                                    kdv, kdv_dahil_birim_fiyat, tutar, birim_fiyat_kdvli, tutar_kdvli,
                                    doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru,
                                    sube_id, merkez_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select b.web, 1, 0, left(coalesce(nullif(btrim(f.aciklama), ''), 'Tahakkuk'), 300), 1, 1,
           coalesce(f.fatura_tutari, 0), coalesce(f.fatura_tutari, 0), 0, coalesce(f.fatura_tutari, 0),
           coalesce(f.fatura_tutari, 0), coalesce(f.fatura_tutari, 0), coalesce(f.fatura_tutari, 0),
           b.cins, x.doviz_tutari, x.doviz_tutari, b.kur,
           b.sube, coalesce(b.merkez, 0), 1, 'FATBASLIK_TK', b.delphi
      from _bid b
      join _fb f on f.id = b.delphi
      join public.belge x on x.id = b.web
     where b.tur in (13, 17)
       and not exists (select 1 from public.belge_satir s where s.belge_id = b.web and s.aktarim_tablo = 'FATURA');

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

    -- 1088: dönüş izlemi (DONUSID) yukarıda YAZMADAN ÖNCE çözülüyor; hedefi aynı
    --   pakette yeni gelen satır ilk geçişte bulunamaz (0 yazılır). İkinci geçiş.
    update public.stok_izleme x set donus_id = w.id
      from _fz z
      join public.stok_izleme w on w.aktarim_kaynak = 1 and w.aktarim_tablo = 'STOKIZLEME' and w.aktarim_id = z.donusid
     where coalesce(z.donusid, 0) <> 0
       and x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKIZLEME' and x.aktarim_id = z.id
       and x.donus_id is distinct from w.id;
    get diagnostics v_zdon = row_count;

    -- 5) cari satırı (BelgeDeposu.MaliHareketYazAsync ile aynı kural)
    create temp table if not exists _cw on commit drop as
        select m.* from public.mali_hareket m with no data;
    truncate _cw;
    insert into _cw (aktarim_id, tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru, aciklama,
                     ekstrede_kullan, proje_id, merkez_id, sube_id)
    select w.aktarim_id, x.tur, 'C', x.taraf_id, x.id, x.belge_no, x.belge_tarihi,
           case when c.cikis then d.tutar else 0 end, case when c.cikis then 0 else d.tutar end,
           case when c.cikis then d.yerel else 0 end, case when c.cikis then 0 else d.yerel end,
           d.cins, case when d.tutar <> 0 then abs(round(d.yerel / d.tutar, 6)) else 1 end,
           -- 1188: borç / alacak TAHAKKUKUNDA açıklama Delphi ACIKLAMA (ekstrede ne için olduğu); diğerlerinde ünvan.
           case when x.tur in (13, 17) and btrim(coalesce(x.aciklama, '')) <> '' then left(x.aciklama, 100)
                else left(x.taraf_unvan, 100) end,
           x.ekstrede_kullan, x.proje_id, x.merkez_id, x.sube_id
      from _bw w
      join public.belge x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = w.aktarim_id
      join _fb f on f.id = w.aktarim_id
      join public.kasa_islem_turu t on t.kod = x.tur and t.cari_etkiler = 1
      cross join lateral (select public.fn_belge_cikis_mi(x.tur, x.tipi) as cikis) c
      -- 1142: Delphi cari bakiyesi (sp_Prog_Cari_Liste): EKSTREDEKULLAN=1 ise DOVIZ_TUTARI
      --   (DOVIZ_CINSI), değilse FATURA_TUTARI (KUR). Yerel (TL) karşılık: KUR TL ise
      --   FATURA_TUTARI, döviz faturada TL rapor tutarı (DOVIZ_TUTARI), yoksa kurla.
      cross join lateral (
          select x.ekstre_dovizi as cins,
                 case when f.ekstredekullan = 1 and coalesce(btrim(f.doviz_cinsi), '') <> ''
                      then coalesce(f.doviz_tutari, 0) else coalesce(f.fatura_tutari, 0) end as tutar,
                 case when public.fn_aktarim_doviz(f.kur) = 'TL' then coalesce(f.fatura_tutari, 0)
                      when public.fn_aktarim_doviz(f.doviz_cinsi) = 'TL' and coalesce(btrim(f.doviz_cinsi), '') <> ''
                           and coalesce(f.doviz_tutari, 0) <> 0 then f.doviz_tutari
                      else round(coalesce(f.fatura_tutari, 0) * coalesce(nullif(f.dovizkur, 0), 1), 4) end as yerel) d
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
                              'izlem', v_ze + v_zg, 'izlem_silinen', v_zsil, 'izlem_atlanan', v_zatla, 'izlem_donus', v_zdon,
                              'cari', v_cari, 'cari_silinen', v_carisil);
end $$;


-- --------------------------------------------------------------- onarım --
begin;
set local gentegre.aktarim = '1';     -- Delphi kaynaklı kayıt kilidi (fn_aktarim_salt_okunur) bu işlemde açılır

do $$
declare n1 int; n2 int; n3 int;
begin
  select count(*) into n1 from public.belge b
   where b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and btrim(coalesce(b.taraf_unvan, '')) = '' and coalesce(b.taraf_id, 0) > 0;
  select count(*) into n2 from public.mali_hareket m join public.belge b on b.id = m.belge_id
   where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK' and b.tur in (13, 17)
     and btrim(coalesce(m.aciklama, '')) = '' and btrim(coalesce(b.aciklama, '')) <> '';
  select count(*) into n3 from public.belge b
   where b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and b.tur in (13, 17)
     and not exists (select 1 from public.belge_satir s where s.belge_id = b.id);
  raise notice '1188 onarım: ünvanı boş belge %, açıklaması boş tahakkuk cari hareketi %, satırsız tahakkuk %', n1, n2, n3;
end $$;

update public.belge b
   set taraf_unvan = left(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar, 200)
  from public.taraf t
 where t.id = b.taraf_id and b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK'
   and btrim(coalesce(b.taraf_unvan, '')) = '' and coalesce(b.taraf_id, 0) > 0;

update public.mali_hareket m
   set aciklama = left(b.aciklama, 100)
  from public.belge b
 where b.id = m.belge_id and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK' and b.tur in (13, 17)
   and btrim(coalesce(m.aciklama, '')) = '' and btrim(coalesce(b.aciklama, '')) <> '';

insert into public.belge_satir (belge_id, sira, tur, aciklama, miktar, adet, birim_fiyat, iskontolu_birim_fiyat,
                                kdv, kdv_dahil_birim_fiyat, tutar, birim_fiyat_kdvli, tutar_kdvli,
                                doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru,
                                sube_id, merkez_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
select b.id, 1, 0, left(coalesce(nullif(btrim(b.aciklama), ''), 'Tahakkuk'), 300), 1, 1,
       b.genel_toplam, b.genel_toplam, 0, b.genel_toplam, b.genel_toplam, b.genel_toplam, b.genel_toplam,
       b.belge_dovizi, b.doviz_tutari, b.doviz_tutari, b.doviz_kuru,
       b.sube_id, coalesce(b.merkez_id, 0), 1, 'FATBASLIK_TK', b.aktarim_id
  from public.belge b
 where b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and b.tur in (13, 17)
   and not exists (select 1 from public.belge_satir s where s.belge_id = b.id);

commit;
