-- 292: Belgenin varsayılan fiyat listesi KAMPANYANIN listesini de tanısın.
--
-- Bulgu (SGK muayene testi): başvuruda ödeyen kurum SGK seçilince başlıkta
-- kampanya rozeti "KMP-2026 · SGK Anlaşmalı Fiyatlar" çıkıyor ama Fiyat
-- Listesi "Satış" (genel varsayılan) olarak kalıyordu; kalem eklenince
-- /api/fiyat/kalem listeId=6 ile çağrılıp SUT bedeli bulunamıyor, birim fiyat
-- 0,00 geliyordu.
--
-- Kök neden: BelgeKarti'nda ödeyen kurum değişince İKİ ayrı istek koşuyor —
-- fn_belge_varsayilan_liste ve kampanya çözümü — ikisi de belgenin listesini
-- yazıyor. fn_belge_varsayilan_liste kampanyayı bilmediği için genel satış
-- listesini döndürüyor ve geç dönen cevap kampanyanınkini eziyordu (yarış).
--
-- Çözüm: öncelik SUNUCUDA tek yerde kurulsun. Kampanyanın kendi fiyat listesi
-- varsa o kazanır; yoksa eski zincir (ödeyen kurumun cari listesi > carinin
-- listesi > yön varsayılanı) aynen işler. Böylece iki istek de AYNI listeyi
-- döndürür, hangisi önce biterse bitsin sonuç değişmez.
--
-- YÖN KORUMASI: kampanya belge yönünden bağımsız tanımlanır. Satış kampanyası
-- bir alış belgesine liste dayatmasın diye kampanyanın listesi yalnız belgenin
-- yönüyle eşleşiyorsa (ve aktifse) kabul edilir.

create or replace function public.fn_belge_varsayilan_liste(
    p_tur             integer,
    p_taraf_id        integer,
    p_tarih           date default current_date,
    p_odeyen_kurum_id integer default null)
returns integer
language sql stable as $$
    select coalesce(
        -- 1) KAMPANYA LISTESI (274): anlaşma hem baz listeyi hem indirimi
        --    tayin eder. Kampanya kurum > cari sırasıyla fn_taraf_kampanya'da
        --    çözülür; ödeyen kurum varsa fiyatı ÖDEYEN taraf belirler.
        (select fl.id
           from public.kampanya k
           join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
          where k.id = public.fn_taraf_kampanya(
                           case when coalesce(p_odeyen_kurum_id, 0) > 0
                                then p_odeyen_kurum_id else p_taraf_id end,
                           p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2) Ödeyen kurum bir caridir: listesi de cari kuralından okunur.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,

        -- 3) Carinin kendi listesi / yönün varsayılanı.
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$$;

comment on function public.fn_belge_varsayilan_liste(integer, integer, date, integer) is
  'Belgenin varsayılan fiyat listesi (278/292): kampanya listesi > ödeyen kurumun listesi > carinin listesi > yön varsayılanı.';
