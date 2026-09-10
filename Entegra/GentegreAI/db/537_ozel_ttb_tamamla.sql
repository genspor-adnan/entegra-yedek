-- =====================================================================
--  537_ozel_ttb_tamamla.sql
--  Özel tarifede SUT'tan doldurulamayan satırlar TTB puanından tamamlanır.
--
--  Kullanıcı: "241 satırı da TTB puanından üret."
--
--  536'da Özel liste SUT × 3 ile dolduruldu ama 241 satır fiyatsız kaldı:
--  bunlar SUT'ta KARŞILIĞI OLMAYAN TTB/HUV işlemleri (521'de "SUT.TTB"
--  kategorisi altına alınmışlardı - ortodonti, estetik, ameliyathane dışı
--  anestezi gibi SGK'nın ödemediği kalemler). Çarpılacak SUT fiyatı yok.
--
--  KAYNAK TTB LİSTESİ, KAT AYNI (3): iki kaynak arasında farklı kat
--  kullanmak, aynı listede iki ayrı fiyat mantığı demek olurdu. TTB fiyatı
--  bugün katsayı × çarpan = ham puan (çarpan 1); dönem çarpanı girilince
--  Özel fiyat ETKİLENMEZ - 536'daki gibi kural üretimde, listede değil.
--
--  YALNIZ FİYATSIZ SATIRLAR: `p_elle_yazilani_koru = true` ile SUT'tan gelen
--  9.825 satıra dokunulmaz.
-- =====================================================================

do $$
declare
    v_ozel  integer;
    v_ttb   integer;
    v_sayi  integer;
    v_kalan integer;
begin
    select id into v_ozel from public.fiyat_listesi where tarife_tipi = 1 order by id limit 1;
    select id into v_ttb  from public.fiyat_listesi where tarife_tipi = 2 order by id limit 1;
    if v_ozel is null or v_ttb is null then
        raise notice '537: Özel ya da TTB listesi yok - atlandı.';
        return;
    end if;

    select public.fn_fiyat_liste_turet(v_ozel, v_ttb, 3, null, true) into v_sayi;

    select count(*) into v_kalan
      from public.fiyat_listesi_satir
     where liste_id = v_ozel and coalesce(fiyat, 0) = 0;

    raise notice '537: TTB (#%) puanından % satır dolduruldu; % satır hâlâ fiyatsız.',
                 v_ttb, v_sayi, v_kalan;
end $$;
