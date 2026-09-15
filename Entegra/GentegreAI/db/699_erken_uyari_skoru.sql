-- 699: ERKEN UYARI SKORU (NEWS) — İZLEM SATIRINDA HESAPLANIR.
--
-- NEDEN VERİTABANINDA: skor bir İŞ KURALIDIR ve izlem satırı üç ayrı yoldan
--   yazılıyor (yatış kartının İzlem sekmesi, hemşire izlem ekranının hızlı
--   girişi, ileride cihaz/monitör aktarımı). Kural ekranda dursaydı, üçünden
--   biri skoru boş bırakır ve "eşiği aşan hasta" listesi sessizce eksik
--   çalışırdı.
--
-- NEDEN SATIRDA SAKLANIYOR (görünümde hesaplanmıyor): skor O ANIN kararıdır ve
--   geçmişe dönük değişmemeli. Eşik tablosu yarın güncellenirse dünkü satırın
--   skoru da değişir, "o gün neye göre hekime bildirdik" sorusunun cevabı
--   kaybolurdu.
--
-- ÖLÇEK: NEWS (National Early Warning Score) alt puanları — solunum, SpO2,
--   sistolik, nabız, ateş ve bilinç. Kendi ölçeğimizi uydurmuyoruz: skorun
--   değeri, klinik personelin eşiklerini ezbere bilmesinden geliyor.
--
-- EKSİK ÖLÇÜM SIFIR DEĞİLDİR: ölçülmeyen parametre puana KATILMAZ ve satır
--   "kısmi skor" olur. Boş değeri 0 saymak, hiç ölçülmemiş bir hastayı
--   "tamamen normal" gösterirdi.

create or replace function public.fn_erken_uyari(
    p_solunum   smallint,
    p_spo2      smallint,
    p_sistolik  smallint,
    p_nabiz     smallint,
    p_ates      numeric,
    p_gks       smallint
) returns smallint
language sql
immutable
as $$
    select (
        coalesce(case
            when p_solunum is null then null
            when p_solunum <= 8  then 3
            when p_solunum <= 11 then 1
            when p_solunum <= 20 then 0
            when p_solunum <= 24 then 2
            else 3 end, 0)
      + coalesce(case
            when p_spo2 is null then null
            when p_spo2 <= 91 then 3
            when p_spo2 <= 93 then 2
            when p_spo2 <= 95 then 1
            else 0 end, 0)
      + coalesce(case
            when p_sistolik is null then null
            when p_sistolik <= 90  then 3
            when p_sistolik <= 100 then 2
            when p_sistolik <= 110 then 1
            when p_sistolik <= 219 then 0
            else 3 end, 0)
      + coalesce(case
            when p_nabiz is null then null
            when p_nabiz <= 40  then 3
            when p_nabiz <= 50  then 1
            when p_nabiz <= 90  then 0
            when p_nabiz <= 110 then 1
            when p_nabiz <= 130 then 2
            else 3 end, 0)
      + coalesce(case
            when p_ates is null then null
            when p_ates <= 35.0 then 3
            when p_ates <= 36.0 then 1
            when p_ates <= 38.0 then 0
            when p_ates <= 39.0 then 1
            else 2 end, 0)
      -- BİLİNÇ: GKS 15'in altı NEWS'te tek kalemde 3 puandır.
      + coalesce(case
            when p_gks is null then null
            when p_gks < 15 then 3
            else 0 end, 0)
    )::smallint
$$;

comment on function public.fn_erken_uyari(smallint, smallint, smallint, smallint,
                                          numeric, smallint) is
  'NEWS erken uyarı skoru (699). Ölçülmeyen parametre puana KATILMAZ - boşu '
  'sıfır saymak, hiç ölçülmemiş hastayı normal gösterirdi.';

-- ---------------------------------------------------------- tetikleyici ----
-- SKOR ELLE DE YAZILABİLİR: kurum kendi ölçeğini kullanıyorsa ya da kayıt
--   geçmişten aktarılıyorsa değer korunur. Tetikleyici yalnız BOŞ skoru
--   doldurur - üzerine yazsaydı, dışarıdan gelen gerçek skoru silerdi.
create or replace function public.tg_yatis_izlem_skor() returns trigger
language plpgsql
as $$
begin
    if new.erken_uyari is null then
        new.erken_uyari := public.fn_erken_uyari(
            new.solunum, new.spo2, new.sistolik, new.nabiz, new.ates, new.gks);
    end if;
    return new;
end $$;

drop trigger if exists tg_yatis_izlem_skor on public.yatis_izlem;
create trigger tg_yatis_izlem_skor
    before insert or update on public.yatis_izlem
    for each row execute function public.tg_yatis_izlem_skor();

-- ------------------------------------------------- mevcut satırları doldur --
-- Skoru boş kalan ESKİ satırlar: veri tek seferlik tamamlanır (tetikleyici
--   yalnız yeni yazımda çalışır). Dolu skora dokunulmaz.
update public.yatis_izlem
   set erken_uyari = public.fn_erken_uyari(solunum, spo2, sistolik, nabiz, ates, gks)
 where erken_uyari is null;
