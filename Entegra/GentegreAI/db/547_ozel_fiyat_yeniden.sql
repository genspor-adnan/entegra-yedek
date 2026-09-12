-- =====================================================================
--  547_ozel_fiyat_yeniden.sql
--  Özel (ücretli) liste fiyatları yeniden üretilir: SUT × 10.
--
--  Kullanıcı: "şimdiki özel fiyatları da SUT'un 10 katı olarak ekle".
--
--  DURUM: 538 Özel listeyi SUT'un 10 katıyla doldurmuştu; katalog yeniden
--  kurulunca (521'in tekrar koşması) Özel listenin 10.066 satırı FİYATSIZ
--  geri geldi - bugün hepsinin fiyatı 0,00. Başvuruda Özel liste seçiliyken
--  satır yine 0,00 geliyor.
--
--  YAPILAN: 538'deki karar aynen tekrarlanır - üretim fonksiyonu
--  (`fn_fiyat_liste_turet`, 536/538) yeni bir mekanizma olmadan yeniden
--  koşar. Sıra ÖNEMLİ ve 538'in TERSİ: önce SUT, sonra TTB. İki liste
--  4.145 kalemde çakışıyor; burada satır yalnız FİYATSIZKEN dolduğu için
--  önce koşan kazanır - çakışan kalemde istenen fiyat SUT'unki (SGK bedeli
--  daha gerçekçi bir taban). TTB ikinci koşuda SUT'ta karşılığı olmayan
--  kalemleri doldurur.
--
--  ELLE GİRİLEN FİYAT KORUNUR: `p_elle_yazilani_koru = true` ile yalnız
--  fiyatı 0 olan satırlar doldurulur. 538'den farkı budur - orada kat
--  değişimi listenin tamamını yeniden fiyatlandırma kararıydı; burada amaç
--  kaybolan fiyatları geri koymak, kullanıcının elle düzelttiği satırı
--  ezmek değil.
--
--  TEKRAR ÇALIŞTIRILABİLİR: ikinci koşuda dolu satır kalmadığı için hiçbir
--  satıra dokunmaz.
-- =====================================================================

do $$
declare
    v_ozel integer;
    v_sut  integer;
    v_ttb  integer;
    v_a    integer;
    v_b    integer;
    v_bos  integer;
begin
    select id into v_ozel from public.fiyat_listesi where tarife_tipi = 1 order by id limit 1;
    select id into v_sut  from public.fiyat_listesi where tarife_tipi = 3 order by id limit 1;
    select id into v_ttb  from public.fiyat_listesi where tarife_tipi = 2 order by id limit 1;
    if v_ozel is null or v_sut is null then
        raise notice '547: Özel ya da SUT listesi yok - atlandı.';
        return;
    end if;

    select public.fn_fiyat_liste_turet(v_ozel, v_sut, 10, null, true) into v_b;
    if v_ttb is not null then
        select public.fn_fiyat_liste_turet(v_ozel, v_ttb, 10, null, true) into v_a;
    end if;

    select count(*) into v_bos
      from public.fiyat_listesi_satir
     where liste_id = v_ozel and coalesce(fiyat, 0) = 0;

    raise notice '547: Özel liste (#%) x10 - TTB''den % satır, SUT''tan % satır; % satır hâlâ fiyatsız.',
                 v_ozel, coalesce(v_a, 0), v_b, v_bos;
end $$;
