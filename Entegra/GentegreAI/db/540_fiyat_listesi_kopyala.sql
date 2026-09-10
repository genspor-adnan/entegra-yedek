-- =====================================================================
--  540_fiyat_listesi_kopyala.sql
--  Fiyat listesini satırlarıyla birlikte kopyalar.
--
--  Kullanıcı: "fiyat listesinde 'Listeyi Üret' butonu yerine Kopyala ekle;
--  seçili tek listeyi adının başına 'Kopya' ekleyerek kopyalasın."
--
--  "Listeyi Üret" 539'da anlamını yitirdi: taban liste × çarpan zinciri
--  kalkınca üretim yalnız KALEM listesi kuruyordu. Kopyala ise gerçek
--  ihtiyaç: var olan bir tarifeden yeni tarife türetmek (2027 listesi,
--  kuruma özel liste) - fiyatlar taşınır, sonra topluca zamlanır.
--
--  KOPYA BAĞIMSIZDIR: kaynağa bir bağ kurulmaz (539'da o zincir söküldü).
--  Kaynak liste sonradan değişse kopya etkilenmez - "hangi fiyat geçerli"
--  sorusu tek listeye bakarak cevaplanır.
--
--  VARSAYILAN KOPYALANMAZ: aynı yönde iki varsayılan liste olamaz (DB tekil
--  indeksi) ve kopya, kurulumun varsayılan tarifesi olmayı kendiliğinden
--  hak etmez.
-- =====================================================================

create or replace function public.fn_fiyat_listesi_kopyala(
    p_liste_id integer,
    p_yeni_ad varchar default null,
    p_kullanici integer default 0)
returns integer language plpgsql as $$
declare
    l      public.fiyat_listesi%rowtype;
    v_yeni integer;
    v_ad   varchar(80);
begin
    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then
        raise exception 'Fiyat listesi bulunamadı: %', p_liste_id using errcode = 'GK422';
    end if;

    -- Ad 80 karakterle sınırlı: "Kopya " öneki uzun adı taşırmasın.
    v_ad := left(coalesce(nullif(btrim(p_yeni_ad), ''), 'Kopya ' || l.ad), 80);

    insert into public.fiyat_listesi
        (ad, tarife_tipi, yon, kdv_dahil, durum, varsayilan,
         baslangic, bitis, aciklama, sube_id, ekleyen, degistiren)
    values
        (v_ad, l.tarife_tipi, l.yon, l.kdv_dahil, l.durum, 0,
         l.baslangic, l.bitis, l.aciklama, l.sube_id, p_kullanici, p_kullanici)
    returning id into v_yeni;

    -- SATIRLAR: SUT kilidi (518) kopyalama sırasında açılır - hedef liste de
    --   SUT tarifesindeyse tetik fiyatı reddederdi ve kopya boş kalırdı.
    perform set_config('gentegre.sut_yukleme', '1', true);

    insert into public.fiyat_listesi_satir
        (liste_id, stok_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim,
         durum, yazim, carpan, taban_fiyat, katki_tutar, ekleyen, degistiren)
    select v_yeni, s.stok_id, s.hizmet_id, s.fiyat, s.doviz_cinsi, s.kdv_dahil,
           s.birim, s.durum, s.yazim, s.carpan, s.taban_fiyat, s.katki_tutar,
           p_kullanici, p_kullanici
      from public.fiyat_listesi_satir s
     where s.liste_id = p_liste_id;

    perform set_config('gentegre.sut_yukleme', '', true);

    return v_yeni;
end $$;

comment on function public.fn_fiyat_listesi_kopyala(integer, varchar, integer) is
    'Fiyat listesini satırlarıyla kopyalar; kopya BAĞIMSIZDIR, varsayılan bayrağı taşınmaz (540).';
