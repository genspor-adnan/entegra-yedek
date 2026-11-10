-- =============================================================================
--  1284  İÇ STOK BELGESİ SATIRLARIYLA SİLİNİR  (kullanıcı 10.11.2026: "Stoktan Talep – Stok Transferleri – Giriş –
--        Çıkış Fişinde silmek isteyince içeriden satırları silmemizi istiyor. direkt silebilsin.. gerekirse logdan
--        geri alırız")
--
--  1267 "satırları olan belge silinemez; önce satırları silin" kuralı TÜM türlere konmuştu. Carisiz, parasız,
--  e-Belgesiz iç stok belgelerinde (3 giriş fişi · 4 çıkış fişi · 20 depolar arası transfer · 105 stoktan talep) bu
--  kural yalnız tıklama yükü: listeden Sil, satırları aynı işlemde götürür (BelgeDeposu.SilAsync satirlarla - stok /
--  lot geri alma ve "dönüştürülmüş belge var" denetimi aynen çalışır), silme logu (tablo 30) ile geri alınabilir.
--  Ticari belgelerde (fatura, irsaliye, sipariş, teklif...) 1267 kuralı değişmedi.
--
--  fn_belge_silinebilir'de satır kuralı bu dört tür için atlanır ki uç ve arayüz AYNI cevabı alsın (181 ilkesi).
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

    -- SATIRLI BELGE (1267, kullanıcı 05.11.2026, tüm türler): önce satırlar silinir.
    -- İÇ STOK BELGESİ İSTİSNASI (1284): giriş / çıkış fişi, transfer, stoktan talep satırlarıyla silinir.
    if b.tur not in (3, 4, 20, 105) then
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
    '1267/1284: silme ön koşulu (boş = silinebilir): e-belge hazır/gönderilmiş, iptal, SATIRLI BELGE (iç stok belgeleri '
    '3/4/20/105 hariç - satırlarıyla silinir), dönüşüm, kasa, ÜTS.';

commit;
