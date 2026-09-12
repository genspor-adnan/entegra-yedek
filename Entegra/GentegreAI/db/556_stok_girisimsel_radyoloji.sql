-- =====================================================================
--  556_stok_girisimsel_radyoloji.sql
--  555'in devamı: "GR" bloğu (296 kart) çözüldü.
--
--  "Diğer Tıbbi Malzeme" dalında kalan 297 kartın 296'sı `GR` önekli ve blok
--  bütünüyle tek işi anlatıyor: kılavuz tel, mikrokateter, anjiyografi
--  kateteri, vasküler stent, vena kava filtresi, opak madde bağlantı seti -
--  GİRİŞİMSEL RADYOLOJİ malzemesi.
--
--  Geriye yalnız `M2` (deneme/mülga) kalır; "Diğer Tıbbi Malzeme" dalı yeni
--  gelen tanımsız önekler için yerinde durur.
-- =====================================================================

do $$
declare
    v_ust   integer;
    v_kalan integer;
begin
    select id into v_ust from public.kategori where kod = 'STK.TIBBI' and tur = 1 limit 1;
    if v_ust is null then
        raise notice '556: STK.TIBBI ust kategorisi yok - once 554 calismali.';
        return;
    end if;

    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select 'STK.GR', 'Girişimsel Radyoloji', v_ust, 1, 1
     where not exists (select 1 from public.kategori where kod = 'STK.GR' and tur = 1);

    update public.stok s
       set kategori = (select k.id from public.kategori k
                        where k.kod = 'STK.GR' and k.tur = 1 limit 1)
     where s.kod like 'GR%'
       and s.kategori = (select k.id from public.kategori k
                          where k.kod = 'STK.DIGER' and k.tur = 1 limit 1);

    select count(*) into v_kalan
      from public.stok s join public.kategori k on k.id = s.kategori
     where k.kod = 'STK.DIGER' and k.tur = 1;
    raise notice '556: "Diger Tibbi Malzeme" dalinda % kart kaldi.', v_kalan;
end $$;
