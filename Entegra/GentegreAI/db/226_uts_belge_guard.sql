-- ============================================================================
--  Gentegre AI — ÜTS BELGE KORUMASI + KİLİT DÜZELTMESİ
--  226_uts_belge_guard.sql
--
--  Faz 3 (belge köprüsü) hazırlığı:
--  1) Başarılı ÜTS bildirimi olan belge SİLİNEMEZ (fn_belge_silinebilir):
--     bildirim resmi kayıttır; önce ÜTS'de iptal edilmelidir.
--  2) Çift gönderim kilidi SERİ/LOT bazına indirildi: bir belge satırında
--     BİRDEN ÇOK seri/lot olabilir (223'teki satır+tür kilidi ikinci lotu
--     yanlışlıkla engelliyordu).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------ çift gönderim kilidi ----
drop index if exists ux_uts_bildirim_satir;
create unique index if not exists ux_uts_bildirim_satir
    on public.uts_bildirim (belge_satir_id, tur, coalesce(seri_lot_id, 0))
 where belge_satir_id is not null and durum in (0, 1);

-- ---------------------------------------------------- fn_belge_silinebilir ---
create or replace function public.fn_belge_silinebilir(p_belge_id integer)
returns text
language plpgsql stable as $$
declare
    b       record;
    v_adet  integer;
begin
    select bl.durum, bl.efatura_durum, bl.belge_no, bl.kapanma_durum
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

    -- ÜTS (226): başarılı bildirim resmi kayıttır - Sağlık Bakanlığı'na
    --   bildirilmiş hareketin belgesi silinirse iz kopar. Delphi'deki
    --   STOKIZLEME.YER/YERID kilidinin temiz karşılığı.
    select count(*) into v_adet
      from public.uts_bildirim ub
     where ub.belge_id = p_belge_id and ub.durum = 1;
    if v_adet > 0 then
        return 'Belgenin başarılı ÜTS bildirimi var; önce ÜTS''de iptal edin.';
    end if;

    return '';                                   -- bos = silinebilir
end $$;

do $$ begin
    raise notice '226 tamam: UTS belge silme korumasi + seri/lot kilidi.';
end $$;
