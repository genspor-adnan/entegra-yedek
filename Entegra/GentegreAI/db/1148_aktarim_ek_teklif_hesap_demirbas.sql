-- =============================================================================
--  1148  DELPHI AKTARIMI - TEKLİF, HESAP PLANI, DEMİRBAŞ  (bir kerelik, 1143)
--
--  TEKLIF / TEKLIFDETAY -> belge (tür 18 Satış Teklifi) / belge_satir
--    aktarim_tablo 'TEKLIF' / 'TEKLIFDETAY' (FATBASLIK kimlikleriyle çakışmaz).
--    Teklif cariyi ve stoğu etkilemez (tür 18: cari_etkiler = 0) - cari satırı yok.
--    DURUM (GENINI -2902) -> teklif_durum (218: 1 Hazırlanıyor, 2 Sunuldu, 3 Kabul,
--      4 Red, 5 İptal): 1 Oluşturma, 2 Onay bekleniyor, 5 Revize -> 1; 3 Onaylandı,
--      4 Beklemede -> 2; 7 Kabul edildi -> 3; 6 Reddedildi, 8 Onaylanmadı -> 4.
--    Satır: TUR 1 stok, diğerleri satış kalemi (MASRAFGELIR -> hizmet; yalnız masraf
--      olarak biliniyorsa masraf). ALTERNATIFNO > 1 alternatif satırlar da taşınır
--      (açıklamada "Alternatif n"); teklif toplamı Delphi'deki gibi başlıktan.
--  HESAPPLANI -> hesap_plani: web'in standart planı (TDHP) KORUNUR - aynı kodlu
--    hesabın adı değişmez; yalnız web'de olmayan kodlar eklenir (Delphi alt
--    hesapları). Üst hesap: kodun noktaya göre en uzun öneki, 3 haneli kodda ilk
--    iki hane (TDHP grubu), o yoksa ilk hane (sınıf). Alt hesabı olan hesap "çalışmaz" (grup) olur.
--  DEMIRBAS -> demirbas: FETA'da 6 araç (plaka); kategori 4 Araç, durum aktif
--    (Delphi DURUM 11 kod listesinde yok), REHBERID -> zimmet.
--  TAŞINMAYAN: TEKLIFHAREKET (durum geçmişi - web'de yok), MUHASEBEKOD (FETA'da
--    boş), AMORTISMAN_ORAN / DEMIRBAS_KATEGORI / DEMIRBAS_URUN (resmi listeler,
--    kayıt değil).
-- =============================================================================

begin;

create or replace function public.fn_aktar_ek_teklif()
returns jsonb language plpgsql as $$
declare
    v_be int := 0; v_bg int := 0; v_se int := 0; v_sg int := 0; v_ssil int := 0; v_atla int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    create temp table if not exists _tk on commit drop as select b.* from public.belge b with no data;
    truncate _tk;
    insert into _tk (aktarim_id, tur, tipi, taraf_id, taraf_adres_id, taraf_unvan, belge_seri, belge_no, kocan_no,
                     belge_tarihi, kayit_tarihi, sube_id, proje_id, matrah, kdv_tutari, genel_toplam, kdv_durum,
                     belge_dovizi, doviz_cinsi, doviz_tutari, doviz_kuru, rapor_dovizi, ekstre_dovizi, kur, vade_gun,
                     durum, teklif_durum, revize_no, teklif_konusu, teklif_teslim, aciklama, ekleyen)
    select t.id, 18, 1, tr.id,
           public.fn_aktarim_web_id('taraf_adres', 'REHBERILETISIM', t.rehberiletid),
           left(coalesce(tr.unvan, ''), 200),
           left(coalesce(t.teklifseri, ''), 5), left(coalesce(t.teklifno, ''), 20), coalesce(t.kocanno, 0),
           coalesce(public.fn_aktarim_zaman(t.tarih), public.fn_aktarim_zaman(t.eklemetarihi), timestamptz '1901-01-01'),
           coalesce(public.fn_aktarim_zaman(t.eklemetarihi), public.fn_aktarim_zaman(t.tarih), timestamptz '1901-01-01'),
           public.fn_aktarim_sube(t.subeid), public.fn_aktarim_web_id('proje', 'PROJELER', t.projeid),
           coalesce(t.teklif_matrahi, 0), coalesce(t.kdv_tutari, 0), coalesce(t.teklif_tutari, 0),
           case when lower(btrim(coalesce(t.kdvdurum, ''))) like 'dah%' then 'Dahil'
                when lower(btrim(coalesce(t.kdvdurum, ''))) like 'muaf%' then 'Muaf' else 'Hariç' end,
           d.cins, d.cins,
           case when coalesce(t.doviz_tutari, 0) <> 0 then t.doviz_tutari
                else round(coalesce(t.teklif_tutari, 0) / d.kur, 4) end,
           d.kur, d.cins, d.cins, d.cins, coalesce(t.vade, 0), 0,
           case t.durum when 3 then 2 when 4 then 2 when 7 then 3 when 6 then 4 when 8 then 4 else 1 end,
           case when coalesce(t.revizeid, 0) > 0 then t.revizeid::text else '' end,
           left(coalesce(t.konusu, ''), 100),
           case when coalesce(t.teslim_suresi, 0) > 0 then t.teslim_suresi || ' gün' else '' end,
           left(coalesce(t.aciklama, ''), 300),
           coalesce(public.fn_aktarim_kisi_id(t.ekleyen), 0)
      from stg.teklif t
      cross join lateral (select public.fn_aktarim_cari_id(t.rehberid) as id) ci
      left join public.taraf tr on tr.id = ci.id
      cross join lateral (select public.fn_aktarim_doviz(t.kur) as cins,
                                 coalesce(nullif(t.dovizkur, 0), 1) as kur) d;
    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('belge', 'TEKLIF', '_tk',
        array['tur', 'tipi', 'taraf_id', 'taraf_adres_id', 'taraf_unvan', 'belge_seri', 'belge_no', 'kocan_no',
              'belge_tarihi', 'kayit_tarihi', 'sube_id', 'proje_id', 'matrah', 'kdv_tutari', 'genel_toplam',
              'kdv_durum', 'belge_dovizi', 'doviz_cinsi', 'doviz_tutari', 'doviz_kuru', 'rapor_dovizi',
              'ekstre_dovizi', 'kur', 'vade_gun', 'durum', 'teklif_durum', 'revize_no', 'teklif_konusu',
              'teklif_teslim', 'aciklama', 'ekleyen']);

    create temp table if not exists _tks on commit drop as select s.* from public.belge_satir s with no data;
    truncate _tks;
    insert into _tks (aktarim_id, belge_id, sira, tur, stok_id, hizmet_id, masraf_id, aciklama, miktar, adet, birim,
                      birim_fiyat, iskonto, iskonto2, iskontolu_birim_fiyat, kdv, tutar, doviz_cinsi,
                      doviz_birim_fiyat, doviz_tutari, doviz_kuru, sube_id, birim_fiyat_kdvli, tutar_kdvli)
    select s.id, b.id, coalesce(nullif(s.siralama, 0), row_number() over (partition by s.teklifid order by s.id)),
           case when coalesce(s.tur, 0) = 1 then 1 when k.hizmet is not null then 2 when k.masraf is not null then 3 else 0 end,
           case when coalesce(s.tur, 0) = 1 then public.fn_aktarim_web_id('stok', 'STOKLAR', s.urunid) end,
           k.hizmet, case when k.hizmet is null then k.masraf end,
           left(case when coalesce(s.alternatifno, 0) > 1 then 'Alternatif ' || s.alternatifno || ': ' else '' end
                || coalesce(s.aciklama, ''), 200),
           coalesce(nullif(s.miktar, 0), s.adet, 0), coalesce(s.adet, 0), case when btrim(coalesce(s.birim, '')) ~ '^[0-9]{1,4}$' then btrim(s.birim)::smallint else 0 end,
           coalesce(s.birimfiyat, 0), coalesce(s.iskonto, 0)::numeric, coalesce(s.iskonto2, 0)::numeric,
           round(coalesce(s.birimfiyat, 0) * (1 - coalesce(s.iskonto, 0)::numeric / 100.0) * (1 - coalesce(s.iskonto2, 0)::numeric / 100.0), 6),
           coalesce(s.kdv, 0), coalesce(s.tutar, 0), d.cins,
           case when coalesce(s.doviz_birimfiyat, 0) = 0 then round(coalesce(s.birimfiyat, 0) / d.kur, 6) else s.doviz_birimfiyat end,
           case when coalesce(s.doviz_tutari, 0) = 0 then round(coalesce(s.tutar, 0) / d.kur, 4) else s.doviz_tutari end,
           d.kur, b.sube_id,
           round(coalesce(s.birimfiyat, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 6),
           round(coalesce(s.tutar, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 4)
      from stg.teklifdetay s
      join public.belge b on b.aktarim_kaynak = 1 and b.aktarim_tablo = 'TEKLIF' and b.aktarim_id = s.teklifid
      cross join lateral (
          select case when coalesce(s.tur, 0) = 1 then null
                      else public.fn_aktarim_web_id('hizmet', 'MASRAFGELIR', coalesce(nullif(s.urunid, 0), s.masrafid)) end as hizmet,
                 case when coalesce(s.tur, 0) = 1 then null
                      else public.fn_aktarim_web_id('masraf', 'MASRAFGELIR', coalesce(nullif(s.urunid, 0), s.masrafid)) end as masraf) k
      cross join lateral (
          select case when coalesce(btrim(s.doviz_kuru), '') = '' then b.doviz_cinsi
                      else public.fn_aktarim_doviz(s.doviz_kuru) end as cins,
                 coalesce(nullif(s.dovizkurdegeri, 0), nullif(b.doviz_kuru, 0), 1) as kur) d;
    select count(*) - (select count(*) from _tks) into v_atla from stg.teklifdetay;
    delete from public.belge_satir x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'TEKLIFDETAY'
       and not exists (select 1 from _tks w where w.aktarim_id = x.aktarim_id);
    get diagnostics v_ssil = row_count;
    select eklenen, guncellenen into v_se, v_sg from public.fn_aktarim_esitle('belge_satir', 'TEKLIFDETAY', '_tks',
        array['belge_id', 'sira', 'tur', 'stok_id', 'hizmet_id', 'masraf_id', 'aciklama', 'miktar', 'adet', 'birim',
              'birim_fiyat', 'iskonto', 'iskonto2', 'iskontolu_birim_fiyat', 'kdv', 'tutar', 'doviz_cinsi',
              'doviz_birim_fiyat', 'doviz_tutari', 'doviz_kuru', 'sube_id', 'birim_fiyat_kdvli', 'tutar_kdvli']);

    return jsonb_build_object('teklif_eklenen', v_be, 'teklif_guncellenen', v_bg, 'satir_eklenen', v_se,
                              'satir_guncellenen', v_sg, 'satir_silinen', v_ssil, 'satir_atlanan', v_atla);
end $$;

comment on function public.fn_aktar_ek_teklif() is
    '1148: Delphi TEKLIF / TEKLIFDETAY (stg) -> belge tür 18 / belge_satir. Cari ve stok etkisi yok. İdempotent.';

create or replace function public.fn_aktar_ek_hesap_plani()
returns jsonb language plpgsql as $$
declare v_e int := 0; v_g int := 0; v_ust int := 0; v_grup int := 0; v_web int := 0; v_n int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);
    -- web'de aynı kod varsa web satırı kalır (TDHP adı korunur)
    select count(*) into v_web from stg.hesapplani s
     where exists (select 1 from public.hesap_plani h where h.kod = btrim(s.hesapkodu)
                     and h.aktarim_kaynak is distinct from 1);

    create temp table if not exists _hp on commit drop as select h.* from public.hesap_plani h with no data;
    truncate _hp;
    insert into _hp (aktarim_id, kod, ad, sinif, doviz_cinsi, calisir_mi, durum)
    select s.id, btrim(s.hesapkodu), left(coalesce(nullif(btrim(s.hesapadi), ''), btrim(s.hesapkodu)), 150),
           case when left(btrim(s.hesapkodu), 1) ~ '^[0-9]$' then left(btrim(s.hesapkodu), 1)::int else 0 end,
           public.fn_aktarim_doviz(s.kur),
           -- Delphi planında alt hesabı olan grup hesaptır (çalışmaz)
           case when exists (select 1 from stg.hesapplani c where btrim(c.hesapkodu) like btrim(s.hesapkodu) || '.%')
                then 0 else 1 end,
           case when coalesce(s.durum, 1) = 0 then 0 else 1 end
      from stg.hesapplani s
     where coalesce(btrim(s.hesapkodu), '') <> ''
       and not exists (select 1 from public.hesap_plani h where h.kod = btrim(s.hesapkodu)
                         and h.aktarim_kaynak is distinct from 1);
    select eklenen, guncellenen into v_e, v_g from public.fn_aktarim_esitle('hesap_plani', 'HESAPPLANI', '_hp',
        array['kod', 'ad', 'sinif', 'doviz_cinsi', 'calisir_mi', 'durum']);

    -- üst hesap ve seviye: koddaki en uzun önek. Zincir (üstü de bu çalıştırmada
    --   eklenen hesap) için değişiklik kalmayana kadar tekrarlanır.
    for i in 1..10 loop
        update public.hesap_plani h set ust_id = u.id, seviye = coalesce(u.seviye, 0) + 1
          from (select h2.id hid,
                       (select p.id from public.hesap_plani p
                         where p.id <> h2.id
                           and (h2.kod like p.kod || '.%' or (h2.kod !~ '\.' and length(h2.kod) = 3 and p.kod in (left(h2.kod, 2), left(h2.kod, 1))))
                         order by length(p.kod) desc limit 1) uid
                  from public.hesap_plani h2 where h2.aktarim_kaynak = 1 and h2.aktarim_tablo = 'HESAPPLANI') x
          join public.hesap_plani u on u.id = x.uid
         where h.id = x.hid and (h.ust_id is distinct from u.id or h.seviye is distinct from coalesce(u.seviye, 0) + 1);
        get diagnostics v_n = row_count;
        v_ust := v_ust + v_n;
        exit when v_n = 0;
    end loop;

    -- Delphi alt hesabı eklenen WEB hesabı grup olur (çalışmaz)
    update public.hesap_plani h set calisir_mi = 0
     where h.calisir_mi <> 0 and h.aktarim_kaynak is distinct from 1
       and exists (select 1 from public.hesap_plani c where c.ust_id = h.id);
    get diagnostics v_grup = row_count;

    return jsonb_build_object('eklenen', v_e, 'guncellenen', v_g, 'web_kodu_korunan', v_web,
                              'ust_baglanan', v_ust, 'gruba_donen', v_grup);
end $$;

comment on function public.fn_aktar_ek_hesap_plani() is
    '1148: Delphi HESAPPLANI (stg) -> hesap_plani; web''de olan kod korunur, yalnız eksik kodlar eklenir, üst hesap koddan.';

create or replace function public.fn_aktar_ek_demirbas()
returns jsonb language plpgsql as $$
declare v_e int := 0; v_g int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);
    create temp table if not exists _dmb on commit drop as select d.* from public.demirbas d with no data;
    truncate _dmb;
    insert into _dmb (aktarim_id, kod, ad, kategori, durum, seri_no, barkod, zimmet_taraf_id, sube_id, aciklama,
                      ekleme_tarihi)
    select s.id,
           case when coalesce(btrim(s.demirbasno), '') <> ''
                 and not exists (select 1 from public.demirbas x where x.kod = btrim(s.demirbasno)
                                   and not (x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DEMIRBAS' and x.aktarim_id = s.id))
                then left(btrim(s.demirbasno), 40) else '' end,
           left(coalesce(nullif(btrim(s.demirbasadi), ''), nullif(btrim(s.stokkodu), ''), 'Demirbaş ' || s.id), 200),
           4, 1, left(coalesce(s.serino, ''), 60), left(coalesce(s.barkod, ''), 40),
           public.fn_aktarim_kisi_id(s.rehberid), coalesce(public.fn_aktarim_sube(s.subeid), 1),
           left(coalesce(s.notlar, ''), 400),
           coalesce(s.eklemetarihi, timestamp '1901-01-01')
      from stg.demirbas s;
    select eklenen, guncellenen into v_e, v_g from public.fn_aktarim_esitle('demirbas', 'DEMIRBAS', '_dmb',
        array['kod', 'ad', 'kategori', 'durum', 'seri_no', 'barkod', 'zimmet_taraf_id', 'sube_id', 'aciklama',
              'ekleme_tarihi']);
    return jsonb_build_object('eklenen', v_e, 'guncellenen', v_g);
end $$;

comment on function public.fn_aktar_ek_demirbas() is
    '1148: Delphi DEMIRBAS (stg) -> demirbas (FETA: araçlar, kategori 4). İdempotent.';

commit;
