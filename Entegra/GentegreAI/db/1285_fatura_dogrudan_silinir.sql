-- =============================================================================
--  1285  ALIŞ / SATIŞ FATURASI SATIRLARIYLA SİLİNİR  (kullanıcı 10.11.2026: "alış/satış faturası listesinde ve kart
--        içinden faturayı silebilmeliyim. şu an satırları silin diyor")
--
--  1284'teki iç stok belgesi istisnası (3 / 4 / 20 / 105) alış faturası (11) ve satış faturasına (15) genişler:
--  listeden ya da karttan Sil, satırları aynı işlemde götürür (BelgeDeposu.SilAsync satirlarla), stok / lot ve cari
--  hareketi geri alınır (fn_belge_sil mali_hareket siler), silme logu (tablo 30) ile geri alınabilir.
--  KALAN KORUMALAR AYNEN: e-Belge hazırlanmış / gönderilmiş fatura silinmez (iade kesilir), iptal edilmiş belge
--  silinmez, bu faturadan dönüştürülmüş belge varsa silinmez, bağlı kasa işlemi (tahsilat / ödeme) varsa silinmez,
--  başarılı ÜTS bildirimi varsa silinmez. 1267'nin "önce satırları silin" kuralı irsaliye, sipariş, teklif, fiş,
--  tahakkuk ve konsinyede sürer.
-- =============================================================================

begin;

create or replace function public.fn_belge_silinebilir(p_belge_id integer)
returns text
language plpgsql stable as $$
declare
    b       record;
    v_adet  integer;
begin
    select bl.durum, bl.efatura_durum, bl.belge_no, bl.kapanma_durum, bl.tur
      into b from public.belge bl where bl.id = p_belge_id;
    if not found then
        return 'Belge bulunamadı.';
    end if;

    -- e-BELGE: hazirlanmis belgenin numarasi seri sayacindan alinmistir;
    --   silinirse numara bosa duser ve GIB'e giden/gidecek belge izi kaybolur.
    if coalesce(b.efatura_durum, 0) in (2, 12, 52) then
        return 'e-Belge gönderilmiş; belge silinemez. Düzeltme için iade faturası kesin.';
    end if;
    if coalesce(b.efatura_durum, 0) <> 0 then
        return 'e-Belge hazırlanmış; önce "Hazırı Geri Al" ile e-Belge kaydını kaldırın.';
    end if;

    -- IPTAL EDILMIS belge muhasebe izidir, silinmez.
    if coalesce(b.durum, 0) = 2 then
        return 'İptal edilmiş belge silinemez; iptal kaydı belgenin izidir.';
    end if;

    -- SATIRLI BELGE (1267, kullanıcı 05.11.2026): önce satırlar silinir.
    -- İSTİSNA (1284 iç stok belgeleri 3/4/20/105; 1285 alış / satış faturası 11/15): satırlarıyla silinir.
    if b.tur not in (3, 4, 20, 105, 11, 15) then
        select count(*) into v_adet from public.belge_satir s where s.belge_id = p_belge_id;
        if v_adet > 0 then
            return 'Satırları olan belge silinemez; önce satırları silin.';
        end if;
    end if;

    -- DONUSUM: bu belgeden uretilmis irsaliye/fatura varsa silme zinciri kirar.
    select count(*) into v_adet
      from public.belge_satir hs
      join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
      join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
     where ks.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Bu belgeden dönüştürülmüş belge var; önce onu kaldırın.';
    end if;

    -- KASA: tahsilat/odeme baglanmissa silme cari bakiyeyi bozar.
    select count(*) into v_adet from public.kasa_islem ki where ki.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Belgeye bağlı kasa işlemi var; önce tahsilatı/ödemeyi kaldırın.';
    end if;

    -- ÜTS (226): başarılı bildirim resmi kayıttır.
    select count(*) into v_adet
      from public.uts_bildirim ub
     where ub.belge_id = p_belge_id and ub.durum = 1;
    if v_adet > 0 then
        return 'Belgenin başarılı ÜTS bildirimi var; önce ÜTS''de iptal edin.';
    end if;

    return '';                                   -- bos = silinebilir
end $$;

comment on function public.fn_belge_silinebilir(integer) is
    '1267/1284/1285: silme ön koşulu (boş = silinebilir): e-belge hazır/gönderilmiş, iptal, SATIRLI BELGE (iç stok '
    'belgeleri 3/4/20/105 ve fatura 11/15 hariç - satırlarıyla silinir), dönüşüm, kasa, ÜTS.';

commit;
