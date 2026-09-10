-- =====================================================================
--  542 - ERP KURULUMUNDA TARIFE TIPI HEP 1 (OZEL)
--  (kullanici: "erp modunda tarife kolonu ve içerde tipi görünmesin ama
--   arka planda alanda hep 1 yalnız özel fiyat olsun ve combo görünmesin")
--
--  Tarife tipi (518) bir SAGLIK kavrami: 2 TTB/HUV ve 3 SUT yalnizca
--  hastane kurulumunda anlamli. ERP kurulumunda her liste "Özel
--  (Ücretli)" oluyor; kartta tek secenekli bir combo, listede her satiri
--  ayni olan bir kolon duruyordu. Ekran alanlari 542'de HBYS'e baglandi
--  (KartKatalogu / KaynakKatalogu `UrunModu`), degeri de burada DB yazar:
--  alan ekranda yoksa istemciden gelmez, gelmezse kolon varsayilani 0
--  ("Genel") kalirdi - `tg_fiyat_satir_tarife` 0'da hicbir kural
--  isletmiyor, yani liste kuralsiz kalirdi.
-- =====================================================================

create or replace function public.fn_fiyat_listesi_tarife_modu()
returns trigger language plpgsql as $$
begin
    -- ERP (fn_urun_modu = 1): tarife tipi kullanicinin sorusu degil, tek
    --   dogru cevabi var - Özel (Ücretli).
    if public.fn_urun_modu(coalesce(new.sube_id, 0)) = 1 then
        new.tarife_tipi := 1;
    -- Saglik kurulumunda da 0 ("Genel") bir tarife DEGIL: kural isletmeyen
    --   ara durum. Bos gelirse Özel sayilir.
    elsif coalesce(new.tarife_tipi, 0) = 0 then
        new.tarife_tipi := 1;
    end if;
    return new;
end $$;

comment on function public.fn_fiyat_listesi_tarife_modu() is
  'Fiyat listesi tarife tipi (542): ERP kurulumunda hep 1 (Özel); bos deger her modda 1.';

drop trigger if exists trg_fiyat_listesi_tarife_modu on public.fiyat_listesi;
create trigger trg_fiyat_listesi_tarife_modu
    before insert or update of tarife_tipi, sube_id on public.fiyat_listesi
    for each row execute function public.fn_fiyat_listesi_tarife_modu();
