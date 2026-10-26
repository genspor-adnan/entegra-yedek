-- =============================================================================
--  1192  DELPHI AKTARIMI - SİPARİŞ  (bir kerelik, 1143 deseni; aktar_ek.ps1)
--
--  Kullanıcı 26.10.2026 (ZONE / MEDX): "siparişler de aktarılsın" - aktarım SIPARIS'i hiç
--  taşımıyordu; numara sayaçları Delphi'den devam ediyordu ama eski siparişler web'de yoktu.
--
--  SIPARIS / SIPARISDETAY -> belge (tür 19 Satış Siparişi / 9 Alış Siparişi, tipi 1) / belge_satir
--    aktarim_tablo 'SIPARIS' / 'SIPARISDETAY' (FATBASLIK / TEKLIF kimlikleriyle çakışmaz).
--    Sipariş cariyi ve stoğu etkilemez (mali_hareket / izlem yok). Tutarlar Delphi başlığından
--    (SIPARIS_MATRAHI / KDV_TUTARI / SIPARIS_TUTARI) - teklif (1148) gibi.
--    Delphi TUR 101 / 105 (stok / satınalma talebi, SIPARIS tablosunda) TAŞINMAZ.
--  TESLİM BAĞI: Delphi FATURA.YERI in (406, 407, 409, 410, 473) -> YERID = SIPARISDETAY.ID
--    (UFaturalar "Sipariş No" sütunu). Aktarılmış irsaliye / fatura satırına web dönüşüm bağı
--    yazılır (kaynak_tur 30, kaynak_id = sipariş satırı) - bağı boş (0) olan satıra; başlıkta da
--    boşsa ilk sipariş. Sipariş satırının "dönüşen" miktarı fn_belge_satir_kapatma_tazele ile
--    (web'in dönüşüm kuralı, Σ hedef miktar).
--    stg.fatura doluysa çalışır (aktar_ek.ps1 FATURA'yı da alır); boşsa bağ adımı atlanır.
--  DURUM (GENINI -24020 / -24021): 0 Yapılmadı, 1 Kısmi -> açık kalır (kalan bağdan);
--    9 Tamamlandı, 6 İptal, -1 (listede yok - eski "kapalı") -> kalan miktar "kalanı kapat"
--    kaydıyla kapanır (siparis_satir_kapanis, neden "Delphi: ..."). Sipariş belgesi değişmez.
--  NOT: çekirdek fn_aktar_belge (1188) yeniden çalışırsa irsaliye / fatura satırlarının
--    kaynak bağını yalnız 330'a göre yazar - bu bağı siler. Bu fonksiyon tekrar çalıştırılınca
--    bağ geri gelir (idempotent).
-- =============================================================================
\set ON_ERROR_STOP on

begin;

drop table if exists stg.siparis;
create table stg.siparis (
    id integer, tarih timestamp, tur smallint, tipi smallint, rehberid integer, projeid integer,
    siparistarih timestamp, kocanno integer, siparisno varchar(20), girisdepo smallint, cikisdepo smallint,
    baslik varchar(200), adres varchar(300), ilce varchar(100), il varchar(100), vd varchar(100), vno varchar(100),
    kdvdurum varchar(10), acik_kapali smallint, siparis_gon_tarihi timestamp, siparis_matrahi numeric(19,4),
    kdv_tutari numeric(19,4), siparis_tutari numeric(19,4), kur varchar(10), doviz_tutari numeric(19,4),
    doviz_cinsi varchar(12), aciklama varchar(200), durum smallint, ozelkod varchar(40), ekvergi numeric(19,4),
    siparisseri varchar(10), eklemetarihi timestamp, ekleyen integer, detaybolumu varchar(40),
    dovizkur numeric(19,6), vade smallint, rehberiletid integer, subeid smallint, yazdirildi smallint,
    giriskaynak smallint, rapordoviz varchar(10), ozelkod2 varchar(40));
drop table if exists stg.siparisdetay;
create table stg.siparisdetay (
    id integer, siparisid integer, rehberid integer, tur smallint, urunid integer, aciklama varchar(1000),
    adet numeric(19,4), birim smallint, miktar numeric(19,4), birimfiyat numeric(19,6), tutar numeric(19,4),
    iskonto float8, kdv smallint, masrafid integer, ozelkod varchar(40), muhkodu varchar(50), kur varchar(10),
    doviz_tutari numeric(19,4), doviz_kuru varchar(10), iskonto2 float8, doviz_birimfiyat numeric(19,6),
    dovizkurdegeri numeric(19,6), projeid integer, teslimtarihi timestamp, subeid smallint, merkezid integer,
    giriskaynak smallint, otvyuzde smallint, otvmiktar numeric(19,4), iskontolubrmfiyat float8,
    kdvdahilbrmfiyat numeric(19,6), ozelkod2 varchar(40));

create or replace function public.fn_aktar_ek_siparis()
returns jsonb language plpgsql as $$
declare
    v_be int := 0; v_bg int := 0; v_se int := 0; v_sg int := 0; v_ssil int := 0; v_atla int := 0;
    v_bag int := 0; v_bas int := 0; v_kapa int := 0; v_tazele int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    -- 1) başlık
    create temp table if not exists _sp on commit drop as select b.* from public.belge b with no data;
    truncate _sp;
    insert into _sp (aktarim_id, tur, tipi, taraf_id, taraf_adres_id, taraf_unvan, taraf_vkno, taraf_vd,
                     taraf_adres, taraf_ilce, taraf_il, belge_seri, belge_no, kocan_no, belge_tarihi, kayit_tarihi,
                     giris_depo_id, cikis_depo_id, sube_id, proje_id, matrah, kdv_tutari, ek_vergi, genel_toplam,
                     kdv_durum, belge_dovizi, doviz_cinsi, doviz_tutari, doviz_kuru, rapor_dovizi, ekstre_dovizi,
                     kur, vade_gun, durum, aciklama, ozel_kod, ozel_kod2, detay_bolumu, yazdirildi, giris_kaynak,
                     ekleyen)
    select p.id, p.tur, 1, ci.id,
           public.fn_aktarim_web_id('taraf_adres', 'REHBERILETISIM', p.rehberiletid),
           left(coalesce(nullif(btrim(p.baslik), ''),
                         (select public.fn_taraf_ad(ta.unvan, ta.ad, ta.soyad)::varchar from public.taraf ta
                           where ta.id = ci.id), ''), 200),
           coalesce(p.vno, ''), left(coalesce(p.vd, ''), 60),
           left(coalesce(p.adres, ''), 300), left(coalesce(p.ilce, ''), 60), left(coalesce(p.il, ''), 60),
           left(coalesce(p.siparisseri, ''), 5),
           case when btrim(coalesce(p.siparisno, '')) in ('', '0') then '' else btrim(p.siparisno) end,
           coalesce(p.kocanno, 0),
           coalesce(public.fn_aktarim_zaman(p.siparistarih), public.fn_aktarim_zaman(p.eklemetarihi),
                    timestamptz '1901-01-01'),
           coalesce(public.fn_aktarim_zaman(p.eklemetarihi), public.fn_aktarim_zaman(p.siparistarih),
                    timestamptz '1901-01-01'),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', p.girisdepo),
           public.fn_aktarim_web_id('depo', 'DEPOLAR', p.cikisdepo),
           public.fn_aktarim_sube(p.subeid),
           public.fn_aktarim_web_id('proje', 'PROJELER', p.projeid),
           coalesce(p.siparis_matrahi, 0), coalesce(p.kdv_tutari, 0), coalesce(p.ekvergi, 0),
           coalesce(p.siparis_tutari, 0),
           case when lower(btrim(coalesce(p.kdvdurum, ''))) like 'dah%' then 'Dahil'
                when lower(btrim(coalesce(p.kdvdurum, ''))) like 'muaf%' then 'Muaf' else 'Hariç' end,
           d.belge_dovizi, public.fn_doviz_iso(p.doviz_cinsi),
           case when coalesce(p.doviz_tutari, 0) = 0
                then round(coalesce(p.siparis_tutari, 0) / d.kuru, 4) else p.doviz_tutari end,
           d.kuru, d.rapor, d.belge_dovizi, public.fn_doviz_iso(p.kur),
           coalesce(p.vade, 0), 0,
           left(coalesce(p.aciklama, ''), 300), coalesce(p.ozelkod, ''), coalesce(p.ozelkod2, ''),
           coalesce(p.detaybolumu, ''), coalesce(p.yazdirildi, 0), coalesce(p.giriskaynak, 0),
           coalesce(public.fn_aktarim_kisi_id(p.ekleyen), 0)
      from stg.siparis p
      cross join lateral (select public.fn_aktarim_cari_id(p.rehberid) as id) ci
      cross join lateral (select public.fn_doviz_iso(p.kur) as belge_dovizi,
                                 coalesce(nullif(p.dovizkur, 0), 1) as kuru,
                                 case when coalesce(btrim(p.rapordoviz), '') = '' then public.fn_doviz_iso(p.kur)
                                      else public.fn_doviz_iso(p.rapordoviz) end as rapor) d
     where p.tur in (9, 19);
    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('belge', 'SIPARIS', '_sp',
        array['tur', 'tipi', 'taraf_id', 'taraf_adres_id', 'taraf_unvan', 'taraf_vkno', 'taraf_vd', 'taraf_adres',
              'taraf_ilce', 'taraf_il', 'belge_seri', 'belge_no', 'kocan_no', 'belge_tarihi', 'kayit_tarihi',
              'giris_depo_id', 'cikis_depo_id', 'sube_id', 'proje_id', 'matrah', 'kdv_tutari', 'ek_vergi',
              'genel_toplam', 'kdv_durum', 'belge_dovizi', 'doviz_cinsi', 'doviz_tutari', 'doviz_kuru',
              'rapor_dovizi', 'ekstre_dovizi', 'kur', 'vade_gun', 'durum', 'aciklama', 'ozel_kod', 'ozel_kod2',
              'detay_bolumu', 'yazdirildi', 'giris_kaynak', 'ekleyen']);

    -- 2) satırlar (kalem: satışta hizmet, alışta masraf - fatura aktarımıyla aynı)
    create temp table if not exists _sps on commit drop as select s.* from public.belge_satir s with no data;
    truncate _sps;
    insert into _sps (aktarim_id, belge_id, sira, tur, stok_id, hizmet_id, masraf_id, aciklama, miktar, adet, birim,
                      birim_fiyat, iskonto, iskonto2, iskontolu_birim_fiyat, kdv, kdv_dahil_birim_fiyat, otv_yuzde,
                      otv_miktar, tutar, doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru, giris_depo_id,
                      cikis_depo_id, stok_durum_degis, proje_id, taraf_id, ozel_kod, ozel_kod2, muh_kodu, sube_id,
                      merkez_id, giris_kaynak, teslim_tarihi, birim_fiyat_kdvli, tutar_kdvli)
    select s.id, b.id, row_number() over (partition by s.siparisid order by s.id)::int,
           case when coalesce(s.tur, 0) = 1 then 1 when k.hizmet is not null then 2 when k.masraf is not null then 3 else 0 end,
           case when coalesce(s.tur, 0) = 1 then public.fn_aktarim_web_id('stok', 'STOKLAR', s.urunid) end,
           k.hizmet, k.masraf,
           left(coalesce(s.aciklama, ''), 1000), coalesce(s.miktar, 0), coalesce(s.adet, 0), coalesce(s.birim, 0),
           coalesce(s.birimfiyat, 0), coalesce(s.iskonto, 0)::numeric, coalesce(s.iskonto2, 0)::numeric,
           coalesce(s.iskontolubrmfiyat, 0)::numeric, coalesce(s.kdv, 0), coalesce(s.kdvdahilbrmfiyat, 0),
           coalesce(s.otvyuzde, 0), coalesce(s.otvmiktar, 0), coalesce(s.tutar, 0),
           d.cins,
           case when coalesce(s.doviz_birimfiyat, 0) = 0 then round(coalesce(s.birimfiyat, 0) / d.kur, 6) else s.doviz_birimfiyat end,
           case when coalesce(s.doviz_tutari, 0) = 0 then round(coalesce(s.tutar, 0) / d.kur, 4) else s.doviz_tutari end,
           d.kur, b.giris_depo_id, b.cikis_depo_id, 1,
           coalesce(public.fn_aktarim_web_id('proje', 'PROJELER', s.projeid), b.proje_id),
           public.fn_aktarim_web_id('taraf', 'REHBER', s.rehberid),
           coalesce(s.ozelkod, ''), coalesce(s.ozelkod2, ''), coalesce(s.muhkodu, ''),
           coalesce(public.fn_aktarim_sube(s.subeid), b.sube_id),
           coalesce(public.fn_aktarim_web_id('masraf_merkezi', 'SRMMERKEZI', s.merkezid), 0),
           coalesce(s.giriskaynak, 0), public.fn_aktarim_zaman(s.teslimtarihi),
           case when coalesce(s.birimfiyat, 0) <> 0
                then round(s.birimfiyat * (1 + coalesce(s.kdv, 0)::int / 100.0), 4) else 0 end,
           case when coalesce(s.tutar, 0) <> 0
                then round(s.tutar * (1 + coalesce(s.kdv, 0)::int / 100.0), 4) else 0 end
      from stg.siparisdetay s
      join public.belge b on b.aktarim_kaynak = 1 and b.aktarim_tablo = 'SIPARIS' and b.aktarim_id = s.siparisid
      cross join lateral (
          select case when coalesce(s.tur, 0) = 1 or coalesce(s.urunid, 0) = 0 then null::int
                      when public.fn_belge_cikis_mi(b.tur, 1)
                      then public.fn_aktarim_web_id('hizmet', 'MASRAFGELIR', s.urunid) end as hizmet,
                 case when coalesce(s.tur, 0) = 1 or coalesce(s.urunid, 0) = 0 then null::int
                      when not public.fn_belge_cikis_mi(b.tur, 1)
                      then public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', s.urunid) end as masraf) k
      cross join lateral (
          select case when coalesce(btrim(s.doviz_kuru), '') = '' then b.doviz_cinsi
                      else public.fn_doviz_iso(s.doviz_kuru) end as cins,
                 coalesce(nullif(s.dovizkurdegeri, 0), nullif(b.doviz_kuru, 0), 1) as kur) d;
    select count(*) - (select count(*) from _sps) into v_atla
      from stg.siparisdetay s join stg.siparis p on p.id = s.siparisid where p.tur in (9, 19);
    delete from public.belge_satir x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'SIPARISDETAY'
       and not exists (select 1 from _sps w where w.aktarim_id = x.aktarim_id);
    get diagnostics v_ssil = row_count;
    select eklenen, guncellenen into v_se, v_sg from public.fn_aktarim_esitle('belge_satir', 'SIPARISDETAY', '_sps',
        array['belge_id', 'sira', 'tur', 'stok_id', 'hizmet_id', 'masraf_id', 'aciklama', 'miktar', 'adet', 'birim',
              'birim_fiyat', 'iskonto', 'iskonto2', 'iskontolu_birim_fiyat', 'kdv', 'kdv_dahil_birim_fiyat',
              'otv_yuzde', 'otv_miktar', 'tutar', 'doviz_cinsi', 'doviz_birim_fiyat', 'doviz_tutari', 'doviz_kuru',
              'giris_depo_id', 'cikis_depo_id', 'stok_durum_degis', 'proje_id', 'taraf_id', 'ozel_kod', 'ozel_kod2',
              'muh_kodu', 'sube_id', 'merkez_id', 'giris_kaynak', 'teslim_tarihi', 'birim_fiyat_kdvli',
              'tutar_kdvli']);

    -- 3) teslim bağı: Delphi FATURA satırı (YERI 406/407/409/410/473, YERID = SIPARISDETAY.ID)
    update public.belge_satir h
       set kaynak_tur = 30, kaynak_id = ss.id
      from stg.fatura f
      join public.belge_satir ss on ss.aktarim_kaynak = 1 and ss.aktarim_tablo = 'SIPARISDETAY' and ss.aktarim_id = f.yerid
     where f.yeri in (406, 407, 409, 410, 473)
       and h.aktarim_kaynak = 1 and h.aktarim_tablo = 'FATURA' and h.aktarim_id = f.id
       and (coalesce(h.kaynak_tur, 0) = 0 or h.kaynak_tur = 30 and h.kaynak_id <> ss.id
            and exists (select 1 from public.belge_satir o where o.id = h.kaynak_id and o.aktarim_tablo = 'SIPARISDETAY'));
    get diagnostics v_bag = row_count;
    -- başlık: kaynak boşsa ilk bağlı sipariş
    update public.belge hb
       set kaynak_tur = 30, kaynak_id = x.siparis
      from (select h.belge_id, min(ss.belge_id) as siparis
              from public.belge_satir h
              join public.belge_satir ss on ss.id = h.kaynak_id and ss.aktarim_tablo = 'SIPARISDETAY'
             where h.kaynak_tur = 30 and h.aktarim_tablo = 'FATURA'
             group by h.belge_id) x
     where hb.id = x.belge_id and coalesce(hb.kaynak_tur, 0) = 0;
    get diagnostics v_bas = row_count;

    -- 4) dönüşen miktar (web kuralı) - aktarılan bütün sipariş satırları
    perform public.fn_belge_satir_kapatma_tazele(s.id)
       from public.belge_satir s
      where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'SIPARISDETAY';
    get diagnostics v_tazele = row_count;

    -- 5) Delphi'de bitmiş sipariş: kalan kapanır (9 Tamamlandı, 6 İptal, -1 eski kapalı)
    insert into public.siparis_satir_kapanis (belge_id, belge_satir_id, miktar, teslim, neden, sube_id, ekleyen)
    select s.belge_id, s.id, s.kalan_miktar, s.kapatilan_miktar,
           'Delphi aktarımı: sipariş ' || case p.durum when 9 then 'Tamamlandı' when 6 then 'İptal' else 'kapalı' end,
           coalesce(b.sube_id, 0), 0
      from public.belge_satir s
      join public.belge b on b.id = s.belge_id and b.aktarim_kaynak = 1 and b.aktarim_tablo = 'SIPARIS'
      join stg.siparis p on p.id = b.aktarim_id
     where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'SIPARISDETAY'
       and p.durum in (9, 6, -1) and s.kalan_miktar > 0
    on conflict (belge_satir_id) do nothing;
    get diagnostics v_kapa = row_count;

    return jsonb_build_object('siparis_eklenen', v_be, 'siparis_guncellenen', v_bg, 'satir_eklenen', v_se,
                              'satir_guncellenen', v_sg, 'satir_silinen', v_ssil, 'satir_atlanan', v_atla,
                              'teslim_bagi', v_bag, 'teslim_baslik', v_bas, 'kalan_kapatilan', v_kapa);
end $$;

comment on function public.fn_aktar_ek_siparis() is
    '1192: Delphi SIPARIS / SIPARISDETAY (stg, tür 9 / 19) -> belge / belge_satir; FATURA.YERI 406/407/409/410/473 '
    'teslim bağı (kaynak_tur 30), dönüşen miktar, Delphi Tamamlandı / İptal kalanı kapanır. İdempotent.';

-- fn_aktar_ek (1172) + 'siparis' (teklif'ten sonra; irsaliye / fatura çekirdek aktarımda gelmiş olur)
create or replace function public.fn_aktar_ek()
returns jsonb language plpgsql as $$
declare
    v_sonuc jsonb := '{}';
    v_m text;
    v_r jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);
    foreach v_m in array array['kategori', 'kisi', 'hesap_plani', 'demirbas', 'cek', 'teklif', 'siparis', 'gorev', 'dokuman', 'ebelge', 'lot_durum'] loop
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
    '1149/1171/1172/1192: Delphi ek modülleri (stg) sırayla aktarır - kategori, kişi, hesap planı, demirbaş, çek, teklif, sipariş, görev, döküman, e-Belge; sonda lot defteri kurulur. Modül hatası diğerlerini durdurmaz.';

commit;
