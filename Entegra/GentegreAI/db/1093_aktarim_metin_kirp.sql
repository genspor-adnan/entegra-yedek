-- =============================================================================
--  1093  DELPHI AKTARIMI - METİN ALANLARI KOLON BOYUNA KIRPILIR   (dokuman/18 §11.5)
--
--  500 bin satırlık tam yükleme denemesi belge 54540'ta durdu: faturanın cari
--  satırı açıklamaya cari ünvanını yazıyor (belge.taraf_unvan 200) ama
--  mali_hareket.aciklama 100 (Delphi BASLIK 117 karakter). Kolonu genişletmek
--  v_mali_hareket_ek'i ve ona bağlı 101 nesneyi yeniden kurmayı gerektirirdi;
--  web'in kendi yazımı da (BelgeDeposu.MaliHareketYazAsync) aynı kırpmayı yapar.
--  Delphi'de web'den geniş tanımlı alanlar da (BILIM tarama: FATBASLIK ACIKLAMA
--  600 / VD, ILCE 100, KASA ACIKLAMA 200) web kolon boyuna kırpılır - bugün
--  sığıyorlar ama tanım izin veriyor. Kırpma yalnız fazlalığı atar, Delphi asıl kayıt.
--  Fonksiyonların geri kalanı 1088 / 1085 ile aynı.
-- =============================================================================

begin;

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
    select f.id, coalesce(f.tur, 0),
           case when coalesce(f.tipi, 0) = 0 and f.tur in (11, 12, 15, 16, 109, 119) then 1 else coalesce(f.tipi, 0) end,
           public.fn_aktarim_cari_id(f.rehberid),            -- 1085: 0 = Tanımsız Cari
           public.fn_aktarim_web_id('taraf_adres', 'REHBERILETISIM', f.rehberiletid),
           left(coalesce(f.baslik, ''), 200), coalesce(f.vno, ''), left(coalesce(f.vd, ''), 60),
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
           left(coalesce(f.aciklama, ''), 300), coalesce(f.ozelkod, ''), coalesce(f.ozelkod2, ''),
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
           case when c.cikis then x.genel_toplam else 0 end, case when c.cikis then 0 else x.genel_toplam end,
           d.cins, d.kur, left(x.taraf_unvan, 100), x.ekstrede_kullan, x.proje_id, x.merkez_id, x.sube_id
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
                              'izlem', v_ze + v_zg, 'izlem_silinen', v_zsil, 'izlem_atlanan', v_zatla, 'izlem_donus', v_zdon,
                              'cari', v_cari, 'cari_silinen', v_carisil);
end $$;

comment on function public.fn_aktar_belge(jsonb) is
    '1084/1085/1088/1093: Delphi FATBASLIK (+FATURA, +STOKIZLEME) -> belge / belge_satir / stok_izleme + faturanın cari satırı.';

create or replace function public.fn_aktar_kasa(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_bas date := (select nullif(btrim(a.deger), '')::date from public.aktarim_ayar a
                    where a.anahtar = 'hareket_baslangic');
    v_eski int := 0; v_tursuz int := 0; v_irs int := 0; v_kur112 int := 0;
    v_ce int := 0; v_cg int := 0; v_ie int := 0; v_ig int := 0; v_b1 int := 0; v_b2 int := 0;
    v_bicim int := 0; v_sil int := 0;
    v_kol text[] := array['tur', 'hesap_turu', 'hesap_id', 'taraf_id', 'belge_id', 'belge_no', 'islem_tarihi',
        'plan_tarihi', 'borc', 'alacak', 'yerel_borc', 'yerel_alacak', 'doviz_cinsi', 'doviz_kuru', 'durum',
        'masraf_id', 'hizmet_id', 'kredi_id', 'aciklama', 'ekstrede_kullan', 'sube_id', 'merkez_id',
        'giris_kaynak', 'proje_id', 'kasa_islem_id', 'sira'];
begin
    perform set_config('gentegre.aktarim', '1', true);
    -- Geçici tablo adları _kas* : aynı işlemde çağrılan başka fn_aktar_* fonksiyonlarının
    --   geçici tablolarıyla çakışmasın (1082 kalem '_k' kullanıyor).

    create temp table if not exists _kas on commit drop as select * from stg.kasa with no data;
    truncate _kas;
    insert into _kas select * from jsonb_populate_recordset(null::stg.kasa, coalesce(p->'U'->'KASA', '[]'));

    if v_bas is not null then
        delete from _kas k where coalesce(k.islemtarihi, k.eklemetarihi) < v_bas;
        get diagnostics v_eski = row_count;
    end if;
    delete from _kas k where not exists (select 1 from public.kasa_islem_turu t where t.kod = coalesce(k.tur, 0));
    get diagnostics v_tursuz = row_count;
    -- 136: irsaliye / konsinye cariyi etkilemez
    delete from _kas k where k.tur in (10, 14, 109, 119);
    get diagnostics v_irs = row_count;

    -- 1) Delphi satırı -> web değerleri (işaret Delphi'deki gibi)
    create temp table if not exists _kasr (delphi bigint primary key, cari boolean, tur int, hesap_turu varchar(1),
        hesap int, taraf int, belge int, belge_no varchar, islem_tarihi timestamptz, plan_tarihi timestamptz,
        borc numeric, alacak numeric, yerel_borc numeric, yerel_alacak numeric, doviz_cinsi varchar,
        doviz_kuru numeric, durum int, masraf int, hizmet int, kredi int, aciklama varchar,
        ekstrede_kullan int, sube int, merkez int, giris_kaynak int, proje int, kursuz boolean) on commit drop;
    truncate _kasr;
    insert into _kasr
    select k.id, h.cari, k.tur, case when h.cari then 'C' else h.ht end,
           case when not h.cari then public.fn_aktarim_web_id('hesap',
                case h.ht when 'K' then 'KASALAR' when 'H' then 'KASALAR' when 'B' then 'BANKAHESAPLAR'
                          when 'P' then 'POS' when 'V' then 'KREDIKARTI' when 'R' then 'KREDILER' end, k.hesapid) end,
           -- Tanımsız Cari (0) yalnız cari satırında; hesap hareketinde 0 = karşı taraf yok
           case when h.cari then public.fn_aktarim_cari_id(k.rehberid)
                else public.fn_aktarim_web_id('taraf', 'REHBER', k.rehberid) end,
           public.fn_aktarim_web_id('belge', 'FATBASLIK', k.faturaid), coalesce(k.belgeno, ''),
           coalesce(public.fn_aktarim_zaman(k.islemtarihi), public.fn_aktarim_zaman(k.eklemetarihi),
                    timestamptz '1901-01-01'),
           public.fn_aktarim_zaman(k.plantarihi),
           coalesce(k.borc, 0), coalesce(k.alacak, 0),
           case when d.cins = 'TL' or coalesce(k.doviz_tutari, 0) = 0 then coalesce(k.borc, 0)
                when coalesce(k.borc, 0) <> 0 then k.doviz_tutari else 0 end,
           case when d.cins = 'TL' or coalesce(k.doviz_tutari, 0) = 0 then coalesce(k.alacak, 0)
                when coalesce(k.alacak, 0) <> 0 then k.doviz_tutari else 0 end,
           d.cins,
           case when d.cins <> 'TL' and coalesce(k.borc, 0) + coalesce(k.alacak, 0) <> 0
                     and coalesce(k.doviz_tutari, 0) <> 0
                then abs(round(k.doviz_tutari / (coalesce(k.borc, 0) + coalesce(k.alacak, 0)), 6)) else 1 end,
           coalesce(k.durum, 0),
           km.masraf, case when km.masraf is null then km.hizmet end,
           public.fn_aktarim_web_id('kredi', 'KREDILER', k.krediid),
           coalesce(k.aciklama, ''), coalesce(k.ekstredekullan, 1), public.fn_aktarim_sube(k.subeid),
           public.fn_aktarim_web_id('masraf_merkezi', 'SRMMERKEZI', k.merkezid), coalesce(k.giriskaynak, 1),
           public.fn_aktarim_web_id('proje', 'PROJELER', k.projeid),
           -- 112 adayı: döviz devri, TL karşılığı tutarın kendisi (kur yazılmamış)
           k.tur = 2 and d.cins <> 'TL'
               and coalesce(k.doviz_tutari, 0) = coalesce(k.borc, 0) + coalesce(k.alacak, 0)
      from _kas k
      cross join lateral (select upper(btrim(coalesce(k.hesapturu, ''))) as ht) h0
      cross join lateral (select h0.ht, h0.ht in ('', '1', 'C') as cari) h
      cross join lateral (select public.fn_aktarim_doviz(k.kur) as cins) d
      cross join lateral (select public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', k.masrafid) as masraf,
                                 public.fn_aktarim_web_id('hizmet', 'MASRAFGELIR', k.masrafid) as hizmet) km;

    -- 112: kuru yazılmamış döviz devri, aynı gün / dövizdeki devirlerin EN SIK kuruyla
    with ref as (
        select x.doviz_cinsi, (x.islem_tarihi at time zone 'Europe/Istanbul')::date as gun,
               mode() within group (order by x.doviz_kuru) as kur
          from (select doviz_cinsi, islem_tarihi, doviz_kuru from _kasr where tur = 2 and not kursuz and doviz_kuru <> 1
                union all
                select m.doviz_cinsi, m.islem_tarihi, m.doviz_kuru from public.mali_hareket m
                 where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA' and m.tur = 2 and m.doviz_kuru <> 1
                   and m.aktarim_id not in (select delphi from _kasr)) x
         group by 1, 2)
    update _kasr r set doviz_kuru = ref.kur,
                     yerel_borc = round(r.borc * ref.kur, 4), yerel_alacak = round(r.alacak * ref.kur, 4)
      from ref
     where r.kursuz and ref.doviz_cinsi = r.doviz_cinsi
       and ref.gun = (r.islem_tarihi at time zone 'Europe/Istanbul')::date;
    get diagnostics v_kur112 = row_count;

    -- 2) biçim değiştiren satır (cari <-> hesap): eski gösterimi kaldır
    delete from public.kasa_islem x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'KASA'
       and x.aktarim_id in (select delphi from _kasr where cari);
    get diagnostics v_bicim = row_count;
    delete from public.mali_hareket m
     where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA' and m.kasa_islem_id is null
       and m.aktarim_id in (select delphi from _kasr where not cari);

    -- 3) cari satırları
    create temp table if not exists _kasw on commit drop as select m.* from public.mali_hareket m with no data;
    truncate _kasw;
    insert into _kasw (aktarim_id, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no, islem_tarihi, plan_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru, durum, masraf_id, hizmet_id,
                     kredi_id, aciklama, ekstrede_kullan, sube_id, merkez_id, giris_kaynak, proje_id,
                     kasa_islem_id, sira)
    select r.delphi, r.tur, 'C', null, r.taraf, r.belge, r.belge_no, r.islem_tarihi, r.plan_tarihi,
           r.borc, r.alacak, r.yerel_borc, r.yerel_alacak, r.doviz_cinsi, r.doviz_kuru, r.durum, r.masraf, r.hizmet,
           r.kredi, left(r.aciklama, 100), r.ekstrede_kullan, r.sube, r.merkez, r.giris_kaynak, r.proje, null, 1
      from _kasr r where r.cari;
    select eklenen, guncellenen into v_ce, v_cg from public.fn_aktarim_esitle('mali_hareket', 'KASA', '_kasw', v_kol);

    -- 4) hesap hareketi: başlık
    create temp table if not exists _kasi on commit drop as select i.* from public.kasa_islem i with no data;
    truncate _kasi;
    insert into _kasi (aktarim_id, tur, islem_tarihi, plan_tarihi, durum, taraf_id, taraf_unvan, hesap_id, doviz_cinsi,
                     tutar, doviz_kuru, yerel_tutar, masraf_id, hizmet_id, proje_id, merkez_id, belge_id,
                     aciklama, sube_id, giris_kaynak, kaynak_tur, kaynak_id)
    select r.delphi, r.tur, r.islem_tarihi, r.plan_tarihi, 2, r.taraf,
           coalesce((select t.unvan from public.taraf t where t.id = r.taraf), ''), r.hesap, r.doviz_cinsi,
           abs(r.borc - r.alacak), r.doviz_kuru, abs(r.yerel_borc - r.yerel_alacak),
           r.masraf, r.hizmet, r.proje, r.merkez, r.belge, r.aciklama, r.sube, r.giris_kaynak,
           43 /* eski TabNo_KASA - 081 ile aynı göç izi */, 0
      from _kasr r where not r.cari;
    select eklenen, guncellenen into v_ie, v_ig from public.fn_aktarim_esitle('kasa_islem', 'KASA', '_kasi',
        array['tur', 'islem_tarihi', 'plan_tarihi', 'durum', 'taraf_id', 'taraf_unvan', 'hesap_id', 'doviz_cinsi',
              'tutar', 'doviz_kuru', 'yerel_tutar', 'masraf_id', 'hizmet_id', 'proje_id', 'merkez_id', 'belge_id',
              'aciklama', 'sube_id', 'giris_kaynak', 'kaynak_tur', 'kaynak_id']);

    -- 5) bacaklar (081): 1. hesap (işaret ters), 2. karşı taraf (Delphi işareti)
    truncate _kasw;
    insert into _kasw (aktarim_id, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no, islem_tarihi, plan_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru, durum, masraf_id, hizmet_id,
                     kredi_id, aciklama, ekstrede_kullan, sube_id, merkez_id, giris_kaynak, proje_id,
                     kasa_islem_id, sira)
    select r.delphi, r.tur, r.hesap_turu, r.hesap, r.taraf, r.belge, r.belge_no, r.islem_tarihi, r.plan_tarihi,
           r.alacak, r.borc, r.yerel_alacak, r.yerel_borc, r.doviz_cinsi, r.doviz_kuru, r.durum,
           case when r.taraf is not null then r.masraf end, case when r.taraf is not null then r.hizmet end,
           r.kredi, left(r.aciklama, 100), r.ekstrede_kullan, r.sube, r.merkez, r.giris_kaynak, r.proje, i.id, 1
      from _kasr r
      join public.kasa_islem i on i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA' and i.aktarim_id = r.delphi
     where not r.cari;
    select eklenen + guncellenen into v_b1 from public.fn_aktarim_esitle('mali_hareket', 'KASA', '_kasw', v_kol);

    truncate _kasw;
    insert into _kasw (aktarim_id, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no, islem_tarihi, plan_tarihi,
                     borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru, durum, masraf_id, hizmet_id,
                     kredi_id, aciklama, ekstrede_kullan, sube_id, merkez_id, giris_kaynak, proje_id,
                     kasa_islem_id, sira)
    select r.delphi, r.tur,
           case when r.taraf is not null then 'C' when coalesce(r.masraf, r.hizmet) is not null then 'M' else '-' end,
           null, r.taraf, r.belge, r.belge_no, r.islem_tarihi, r.plan_tarihi,
           r.borc, r.alacak, r.yerel_borc, r.yerel_alacak, r.doviz_cinsi, r.doviz_kuru, r.durum,
           case when r.taraf is null then r.masraf end, case when r.taraf is null then r.hizmet end,
           null, left(r.aciklama, 100), r.ekstrede_kullan, r.sube, r.merkez, r.giris_kaynak, r.proje, i.id, 2
      from _kasr r
      join public.kasa_islem i on i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA' and i.aktarim_id = r.delphi
     where not r.cari;
    select eklenen + guncellenen into v_b2 from public.fn_aktarim_esitle('mali_hareket', 'KASA_KARSI', '_kasw', v_kol);

    v_ig := v_ig + v_ie;                        -- islem toplamı (v_ie aşağıda silinen başlık sayacı)
    -- 6) silinen Delphi satırı
    delete from public.mali_hareket m
     where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA' and m.kasa_islem_id is null
       and m.aktarim_id in (select (e #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'KASA', '[]')) e);
    get diagnostics v_sil = row_count;
    delete from public.kasa_islem x          -- bacaklar cascade
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'KASA'
       and x.aktarim_id in (select (e #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'KASA', '[]')) e);
    get diagnostics v_ie = row_count;           -- yeniden kullanılır: silinen başlık
    v_sil := v_sil + v_ie;

    return jsonb_build_object('cari', v_ce + v_cg, 'islem', v_ig,
                              'bacak1', v_b1, 'bacak2', v_b2, 'eski', v_eski, 'tursuz', v_tursuz,
                              'irsaliye', v_irs, 'kur112', v_kur112, 'bicim', v_bicim, 'silinen', v_sil);
end $$;

comment on function public.fn_aktar_kasa(jsonb) is
    '1085/1093: Delphi KASA -> cari satırı ya da kasa_islem + 2 bacak (081 modeli). Bkz. dosya başı.';

commit;
