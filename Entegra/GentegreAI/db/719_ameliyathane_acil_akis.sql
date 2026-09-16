-- =====================================================================
--  719_ameliyathane_acil_akis.sql
--  İŞ AKIŞI UÇLARININ VERİTABANI TARAFI (715/716 üzerine).
--
--  715 ve 716 tabloları kurdu; kart ve liste onları okuyup yazıyor. Akış
--  uçları (ameliyatı başlat/bitir, talebi planla, triyajı değiştir, çıkış
--  kararı) üç şey istiyor ve üçü de VERİTABANINDA olmalı, uçta değil:
--
--    1) NUMARA: `ameliyat_no` ve `acil_basvuru.protokol_no` kolonları 715/716'da
--       açıldı ama hiç doldurulmuyordu. Numarayı uca gömseydik kurum biçimi
--       değiştiremezdi; 634'teki ortak üreticiye iki tür daha ekliyoruz.
--       ŞABLON YOKSA BOŞ KALIR - bugünkü davranış korunur (634 kuralı).
--
--    2) AMELİYAT NOTU İMZADAN SONRA DEĞİŞMEZ. 715 bunu YORUMDA söylüyordu,
--       kural olarak koymuyordu: imza yalnız iki alanı dolduran bir güncelleme
--       olsaydı, imzalı notun gövdesi sonradan sessizce değiştirilebilirdi.
--       Kural uçta dursaydı doğrudan SQL ya da ileride yazılacak ikinci bir uç
--       onu atlardı - imzanın anlamı "bu metin benimdir"dir.
--
--    3) SALON ÇAKIŞMASI görünür olmalı. Engellemiyoruz (acil vaka planlı
--       vakanın üstüne alınır ve bu meşrudur), ama uç kullanıcıya sorabilsin
--       diye çakışmayı tek yerden soran bir fonksiyon var - aynı hesabı uçta
--       ve raporda iki kez yazmak, iki farklı cevap üretirdi.
-- =====================================================================

-- ------------------------------------------------------- numara türleri
-- 635'in görünümü yeniden tanımlanıyor (en yüksek numaralı dosya geçerli) -
--   634 DEĞİL: 635 araya "Reçete No"yu (tür 905) ekledi ve 634'ün üstüne
--   yazmak onu listeden düşürürdü.
--
-- TÜR NUMARALARI BOŞTAN SEÇİLİR, sıradan değil: 905 reçetenin. Ameliyat 906,
--   acil protokolü 907. Kullanılmış bir türe ikinci anlam yüklemek, o türün
--   şablonunu (ön ek, hane, sayaç) paylaşmak demektir - reçetenin "R-" ön eki
--   ameliyat numarasına basılırdı.
--
-- SIRA hastanın izlediği yolu verir; acil protokolü başvurunun kardeşidir
--   (kapıdan girişte doğar), ameliyat numarası ise işlem tarafındadır.
create or replace view public.v_numara_turu_kimlik as
 select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif,
        1::smallint as sira
union all
 select  19, 'Başvuru Protokol No'::varchar,  1::smallint, 2::smallint
union all
 select 907, 'Acil Protokol No'::varchar,     1::smallint, 3::smallint
union all
 select 902, 'Muayene No'::varchar,           1::smallint, 4::smallint
union all
 select 905, 'Reçete No'::varchar,            1::smallint, 5::smallint
union all
 select 901, 'Laboratuvar İstem No'::varchar, 1::smallint, 6::smallint
union all
 select 903, 'Radyoloji İstem No'::varchar,   1::smallint, 7::smallint
union all
 select 906, 'Ameliyat No'::varchar,          1::smallint, 8::smallint
union all
 select 904, 'e-Nabız Paket No'::varchar,     1::smallint, 9::smallint;

comment on view public.v_numara_turu_kimlik is
  '719: hasta belgelerinin numara turleri (635 + ameliyat 906 / acil protokol 907). '
  'Sira hastanin izledigi yolu verir; sablon yoksa numara BOS kalir.';

-- ------------------------------------------------- numarayı KİM yazar
-- TETİK YAZAR, UÇ DEĞİL. Ameliyat iki yoldan doğuyor (talepten planlama ve
--   doğrudan kart), acil başvurusu ise yalnız karttan; numarayı uca koysaydık
--   karttan açılan kayıt numarasız kalır ve "bazılarında var bazılarında yok"
--   diye görünürdü. Tek yazıcı olunca hangi yoldan gelirse gelsin numara aynı
--   kuralla üretilir.
--
-- ŞABLON YOKSA BOŞ KALIR (634/635 kuralı): numarası olmayan bir alana
--   kendiliğinden numara basmak, kurumun hiç istemediği bir kimliği kayıtlara
--   yazmak olurdu. Kurum ayar satırı açarsa numaralanmaya başlar.
--
-- DOLU GELEN NUMARAYA DOKUNULMAZ: göç/aktarım kendi numarasını taşır.
create or replace function public.fn_ameliyat_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.ameliyat_no), '') = '' then
        new.ameliyat_no := public.fn_numara_kimlik_uret(
            906, coalesce(new.sube_id, 0), 'ameliyat', 'ameliyat_no',
            coalesce(new.plan_baslangic::date, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_ameliyat_no on public.ameliyat;
create trigger tg_ameliyat_no
  before insert on public.ameliyat
  for each row execute function public.fn_ameliyat_no_uret();

create or replace function public.fn_acil_protokol_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.protokol_no), '') = '' then
        new.protokol_no := public.fn_numara_kimlik_uret(
            907, coalesce(new.sube_id, 0), 'acil_basvuru', 'protokol_no',
            coalesce(new.giris_zamani::date, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_acil_protokol_no on public.acil_basvuru;
create trigger tg_acil_protokol_no
  before insert on public.acil_basvuru
  for each row execute function public.fn_acil_protokol_no_uret();

-- --------------------------------------------- ameliyat notu imza kilidi
-- İmzalı not DEĞİŞMEZ - `ek_not` hariç. Ek not bilerek açık: ameliyat sonrası
--   gelişen bir bilgi (patoloji sonucu, komplikasyon) not gövdesini
--   değiştirmeden eklenebilmeli; kapatsaydık kullanıcı imzayı kaldırıp
--   yeniden imzalamaya ya da notu hiç imzalamamaya giderdi.
--
-- İMZANIN KENDİSİ DE GERİ ALINAMAZ: imzalayan/zaman alanları bir kez dolar.
--   "Yanlış imzaladım" durumunun yanıtı ek nottur, imzayı silmek değil.
create or replace function public.fn_ameliyat_not_imza_kilidi()
returns trigger language plpgsql as $tg$
begin
    if old.imza_zamani is null then
        return new;
    end if;

    if new.imza_zamani is distinct from old.imza_zamani
       or new.imzalayan_id is distinct from old.imzalayan_id then
        raise exception 'İmzalanmış ameliyat notunun imzası değiştirilemez.'
              using errcode = 'check_violation';
    end if;

    if new.onceki_tani  is distinct from old.onceki_tani
       or new.sonraki_tani is distinct from old.sonraki_tani
       or new.bulgu       is distinct from old.bulgu
       or new.islem_metni is distinct from old.islem_metni
       or new.dren        is distinct from old.dren
       or new.patoloji    is distinct from old.patoloji then
        raise exception 'İmzalanmış ameliyat notu değiştirilemez; ek not alanını kullanın.'
              using errcode = 'check_violation';
    end if;

    return new;
end;
$tg$;

drop trigger if exists tg_ameliyat_not_imza_kilidi on public.ameliyat_not;
create trigger tg_ameliyat_not_imza_kilidi
  before update on public.ameliyat_not
  for each row execute function public.fn_ameliyat_not_imza_kilidi();

-- --------------------------------------------------- salon çakışma sorusu
-- "Bu salonda bu aralıkta başka ameliyat var mı?" Aralık kesişimi tek yerde:
--   uçta, panoda ve raporda ayrı ayrı yazılsaydı biri `>=` diğeri `>` kullanır
--   ve aynı plan bir ekranda çakışık, diğerinde temiz görünürdü.
--
-- Bitiş = gerçek bitiş varsa o, yoksa plan süresi (süre girilmemişse 60 dk
--   varsayılır - sıfır süre her planı "çakışmıyor" yapardı).
-- İPTAL (8) SAYILMAZ: iptal edilen vaka masayı işgal etmez.
create or replace function public.fn_ameliyat_salon_cakisma(
        p_salon_id integer,
        p_baslangic timestamptz,
        p_sure_dk integer,
        p_haric_id bigint default null)
returns table (id bigint, ameliyat_no varchar, plan_baslangic timestamptz,
               bitis timestamptz, hasta_ad text)
language sql stable as $govde$
    select a.id, a.ameliyat_no, a.plan_baslangic,
           coalesce(a.bitis_zamani,
                    a.plan_baslangic + (coalesce(nullif(a.plan_sure_dk, 0), 60)
                                        || ' minutes')::interval) as bitis,
           coalesce(t.unvan, '')::text as hasta_ad
      from public.ameliyat a
      left join public.taraf t on t.id = a.hasta_id
     where a.salon_id = p_salon_id
       and a.durum <> 8
       and a.plan_baslangic is not null
       and (p_haric_id is null or a.id <> p_haric_id)
       -- Aralık kesişimi: [bas, bitis) x [p_bas, p_bitis)
       and a.plan_baslangic
           < p_baslangic + (coalesce(nullif(p_sure_dk, 0), 60) || ' minutes')::interval
       and coalesce(a.bitis_zamani,
                    a.plan_baslangic + (coalesce(nullif(a.plan_sure_dk, 0), 60)
                                        || ' minutes')::interval)
           > p_baslangic
     order by a.plan_baslangic;
$govde$;

comment on function public.fn_ameliyat_salon_cakisma(integer, timestamptz, integer, bigint) is
  '719: salon/saat cakismasi - TEK kaynak. Engellemez, cakisanlari doner.';
