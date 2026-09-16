-- 713: Klinik Kalite HESAPLAMA MOTORU.
--
-- 711 rehberin kod kümelerini yükledi; bu dosya onları HBYS verisinin üzerinde
-- çalıştırıp gösterge pay/paydasını üretir.
--
-- TEMEL KARAR — OLAY (hasta + tarih) DÖNDÜREN TEK PRİMİTİF. Dört ayrı kaynak
--   var (muayene tanısı, yatış tanısı, SUT işlemi, ATC ilacı) ve her gösterge
--   bunların bir alt kümesini kullanıyor. Her gösterge için ayrı sorgu
--   yazsaydık 217 sorgu bakılamaz hale gelirdi; kod kümesini olaya çeviren tek
--   fonksiyon (`fn_klinik_kod_olay`) yazıp göstergeyi onun üstüne kurduk.
--   Fonksiyon TARİH de döndürür - pencereli göstergelerde "payda olayından
--   kaç gün sonra" sorusu ancak tarihle yanıtlanır.
--
-- TEMEL KARAR — PAY, PAYDANIN İÇİNDEN SEÇİLİR. Rehber hemen her kartta "paydaki
--   hastalar içinde ..." diyor. Payı bağımsız saysaydık, o dönem ameliyat
--   olmamış ama komplikasyon tanısı almış hasta payı şişirir ve oran 100'ü
--   aşabilirdi.
--
-- TEMEL KARAR — İZLEM PENCERESİ (`pencere_gun`). "İlk 2 ay içinde yeniden
--   yatış" gibi göstergelerde pay olayı, payda olayından sonraki N gün içinde
--   olmalı. Pencere rehberde ayrı bir alan değil, metnin içinde yazıyor;
--   ayrıştırıldı (217'nin 83'ünde bulundu) ve DÜZENLENEBİLİR bırakıldı -
--   metinden türetilen değer her zaman doğru olmaz (ör. DP.G7 "2-12 ay" iki
--   sınırlı, tek alana sığmıyor; 60 gün olarak çıktı). Pencere 0 ise pay
--   olayının aynı dönem içinde olması yeterli sayılır.
--
-- TEMEL KARAR — SONUÇ DEĞİL, PAY/PAYDA YAZILIR. Motor `klinik_gosterge_donem`
--   satırına pay ve paydayı yazar; `sonuc` 711'deki tetiğin işidir. Motor da
--   sonucu hesaplasaydı formül iki yerde olurdu.
--
-- TEMEL KARAR — KESİNLEŞMİŞ DÖNEM YENİDEN HESAPLANMAZ. Bakanlığa gönderilen
--   sayının sonradan değişmesi, geri bildirim raporlarıyla kurum kaydı
--   arasında açıklanamayan fark üretir.
--
-- SINIR — BU MOTOR REHBERİN HER TEKNİK NOTUNU UYGULAMAZ. Uyguladıkları: kod
--   kümesi eşleşmesi (ICD ana+ek tanı, SUT işlem, ATC ilaç), tekil hasta,
--   dönem aralığı, izlem penceresi, şube. Uygulamadıkları: yaş/cinsiyet
--   süzgeçleri (`hedef_grup` serbest metin), taraf (sağ/sol diz) ayrımı,
--   "hariç tutulacaklar", gebe izlem paketi gibi HBYS dışı kaynaklar. Bu
--   yüzden sonuç `kaynak = 0` (otomatik) olarak işaretlenir ve kullanıcı
--   kesinleştirmeden önce görür; gösterge bazında sapma varsa elle düzeltilir.

-- ============================================================ izlem penceresi ==
alter table public.klinik_gosterge
  add column if not exists pencere_gun smallint not null default 0;

comment on column public.klinik_gosterge.pencere_gun is
  'Pay olayının payda olayından sonra kaç gün içinde olması gerektiği. '
  '0 = pencere yok (aynı dönem yeterli). Rehber metninden türetildi, düzenlenebilir.';

-- ================================================================ kod → olay ==
-- Bir göstergenin bir ROLÜNDEKİ (pay/payda) kod kümesini, o kümeyle eşleşen
--   HASTA + OLAY TARİHİ satırlarına çevirir.
--
-- ICD ÜST KODU: rehber "M22 Patella bozuklukları" gibi noktasız üst kod da
--   yazıyor ve bununla tüm M22.x alt kodlarını kastediyor. Düz eşitlik
--   kullansaydık alt kodu yazılmış hastalar paya hiç girmezdi.
--
-- SUT KODU NOKTALI/NOKTASIZ: rehber '612.420' yazıyor, `hizmet.sut_kodu`
--   '612420' tutuyor. İki taraftan da nokta atılarak karşılaştırılır.
--
-- ÖN TANI ve AYIRICI TANI SAYILMAZ (tur 3, 4): bunlar "olabilir" kaydıdır,
--   hastanın o tanıyı aldığı anlamına gelmez; gösterge payını şişirirdi.
create or replace function public.fn_klinik_kod_olay(
    p_gosterge_id integer,
    p_rol         varchar,
    p_bas         date,
    p_bit         date,
    p_sube_id     integer default 0
) returns table (taraf_id integer, olay_tarihi timestamptz)
language sql
stable
as $fn$
    -- 1) ICD-10: muayene tanısı (ana + ek)
    select m.taraf_id, m.muayene_tarihi
      from public.klinik_gosterge_kod k
      join public.tani t
        on t.icd_kod = k.kod
        or (position('.' in k.kod) = 0 and t.icd_kod like k.kod || '.%')
      join public.muayene m on m.id = t.muayene_id
     where k.gosterge_id = p_gosterge_id and k.rol = p_rol and k.tip = 'icd10'
       and t.tur in (1, 2)
       and m.muayene_tarihi >= p_bas and m.muayene_tarihi < (p_bit + 1)
       and (p_sube_id = 0 or m.sube_id = p_sube_id)

    union all
    -- 2) ICD-10: yatış ve çıkış tanısı (yatan hastada tanı `tani` tablosunda
    --    olmayabilir; yatışın kendi alanları taşır)
    select y.hasta_id, y.giris_tarihi
      from public.klinik_gosterge_kod k
      join public.yatis y
        on y.yatis_tani_kodu = k.kod
        or y.cikis_tani_kodu = k.kod
        or (position('.' in k.kod) = 0
            and (y.yatis_tani_kodu like k.kod || '.%' or y.cikis_tani_kodu like k.kod || '.%'))
     where k.gosterge_id = p_gosterge_id and k.rol = p_rol and k.tip = 'icd10'
       and y.giris_tarihi >= p_bas and y.giris_tarihi < (p_bit + 1)
       and (p_sube_id = 0 or y.sube_id = p_sube_id)

    union all
    -- 3) SUT işlem kodu: belge satırındaki hizmet
    select b.taraf_id, b.belge_tarihi
      from public.klinik_gosterge_kod k
      join public.hizmet h on replace(h.sut_kodu, '.', '') = replace(k.kod, '.', '')
      join public.belge_satir bs on bs.hizmet_id = h.id
      join public.belge b on b.id = bs.belge_id
     where k.gosterge_id = p_gosterge_id and k.rol = p_rol and k.tip = 'sut'
       and coalesce(h.sut_kodu, '') <> ''
       and b.belge_tarihi >= p_bas and b.belge_tarihi < (p_bit + 1)
       and (p_sube_id = 0 or b.sube_id = p_sube_id)

    union all
    -- 4) ATC ilaç kodu: reçete satırındaki barkodun ilacı.
    --    Reçetenin kendi tarih kolonu yok; muayene tarihi varsa o, yoksa
    --    kayıt tarihi kullanılır.
    select r.hasta_id, coalesce(mu.muayene_tarihi, r.ekleme_tarihi)
      from public.klinik_gosterge_kod k
      join public.ilac i on i.atc_kod = k.kod
      join public.recete_satir rs on rs.ilac_barkod = i.barkod
      join public.recete r on r.id = rs.recete_id
      left join public.muayene mu on mu.id = r.muayene_id
     where k.gosterge_id = p_gosterge_id and k.rol = p_rol and k.tip = 'atc'
       and coalesce(mu.muayene_tarihi, r.ekleme_tarihi) >= p_bas
       and coalesce(mu.muayene_tarihi, r.ekleme_tarihi) < (p_bit + 1)
       and (p_sube_id = 0 or r.sube_id = p_sube_id);
$fn$;

comment on function public.fn_klinik_kod_olay(integer, varchar, date, date, integer) is
  'Gösterge kod kümesini (pay/payda) hasta + olay tarihi satırlarına çevirir (713).';

-- ========================================================== dönem aralığı ==
-- Yıl + dönem no + periyottan tarih aralığı. Tek yerde, çünkü hem hesaplama
--   hem raporlama aynı aralığı kullanmak zorunda; iki yerde yazılsaydı
--   "6 aylık 2. dönem" birinde 01.07-31.12, diğerinde 01.07-30.12 olurdu.
create or replace function public.fn_klinik_donem_araligi(
    p_yil smallint, p_donem_no smallint, p_periyot smallint,
    out bas date, out son date
) language plpgsql immutable
as $fn$
declare
    v_ay integer;
begin
    if p_periyot = 12 then
        bas := make_date(p_yil, 1, 1);
        son := make_date(p_yil, 12, 31);
    elsif p_periyot = 3 then
        v_ay := (greatest(p_donem_no, 1) - 1) * 3 + 1;
        bas := make_date(p_yil, v_ay, 1);
        son := (bas + interval '3 months - 1 day')::date;
    else                                   -- varsayılan 6 aylık
        v_ay := (greatest(p_donem_no, 1) - 1) * 6 + 1;
        bas := make_date(p_yil, v_ay, 1);
        son := (bas + interval '6 months - 1 day')::date;
    end if;
end;
$fn$;

-- ============================================================ tek gösterge ==
-- Bir göstergenin bir dönemdeki pay/paydasını hesaplar. YAZMAZ, döndürür -
--   çağıran ister kaydeder ister önizler.
--
-- `durum` alanı neden var: "0 çıktı" ile "hesaplanamadı" bambaşka iki
--   durumdur. Payda kodu olmayan gösterge hesaplanamaz (elle girilir); paydası
--   0 çıkan gösterge ise o dönem hiç vaka görmemiştir. İkisini de boş satır
--   olarak göstermek kullanıcıyı "veri mi yok, sistem mi bozuk" diye aratır.
create or replace function public.fn_klinik_gosterge_hesapla(
    p_gosterge_id integer,
    p_sube_id     integer,
    p_bas         date,
    p_bit         date
) returns table (pay numeric, payda numeric, durum varchar, aciklama varchar)
language plpgsql
stable
as $fn$
declare
    v_pencere  integer;
    v_pay_kod  integer;
    v_payda_kod integer;
begin
    select g.pencere_gun into v_pencere
      from public.klinik_gosterge g where g.id = p_gosterge_id;
    if not found then
        return query select 0::numeric, 0::numeric, 'yok'::varchar,
                            'Gösterge bulunamadı'::varchar;
        return;
    end if;

    select count(*) filter (where rol = 'pay'),
           count(*) filter (where rol = 'payda')
      into v_pay_kod, v_payda_kod
      from public.klinik_gosterge_kod where gosterge_id = p_gosterge_id;

    if v_payda_kod = 0 or v_pay_kod = 0 then
        return query select 0::numeric, 0::numeric, 'kod_yok'::varchar,
            ('Kod listesi eksik (pay ' || v_pay_kod || ', payda ' || v_payda_kod ||
             ') - elle girilmeli')::varchar;
        return;
    end if;

    return query
    with payda_olay as (
        -- Hastanın DÖNEMDEKİ İLK payda olayı: pencere bu tarihten işler.
        --   Son olayı alsaydık, dönem sonunda ameliyat olan hastanın izlem
        --   penceresi dönem dışına taşar ve pay hep 0 çıkardı.
        select o.taraf_id, min(o.olay_tarihi) as ilk_olay
          from public.fn_klinik_kod_olay(p_gosterge_id, 'payda', p_bas, p_bit, p_sube_id) o
         group by o.taraf_id
    ),
    -- Pay olayı pencere kadar dönem SONRASINA da bakabilmeli: "ilk 60 gün
    --   içinde yeniden yatış" dönemin son gününde ameliyat olanda 60 gün
    --   ileriye bakar.
    pay_olay as (
        select o.taraf_id, o.olay_tarihi
          from public.fn_klinik_kod_olay(
                 p_gosterge_id, 'pay', p_bas,
                 (p_bit + (coalesce(v_pencere, 0) || ' days')::interval)::date,
                 p_sube_id) o
    ),
    eslesen as (
        select distinct d.taraf_id
          from payda_olay d
          join pay_olay y on y.taraf_id = d.taraf_id
         where case
                 when coalesce(v_pencere, 0) > 0
                   then y.olay_tarihi >= d.ilk_olay
                    and y.olay_tarihi < d.ilk_olay + (v_pencere || ' days')::interval
                 else y.olay_tarihi >= p_bas and y.olay_tarihi < (p_bit + 1)
               end
    )
    select (select count(*) from eslesen)::numeric,
           (select count(*) from payda_olay)::numeric,
           case when (select count(*) from payda_olay) = 0 then 'vaka_yok' else 'ok' end::varchar,
           case when (select count(*) from payda_olay) = 0
                then 'Dönemde payda vakası yok'::varchar else ''::varchar end;
end;
$fn$;

comment on function public.fn_klinik_gosterge_hesapla(integer, integer, date, date) is
  'Bir göstergenin dönem pay/paydasını hesaplar; yazmaz (713).';

-- ================================================================== dönem ==
-- Dönemin TÜM otomatik göstergelerini hesaplar ve `klinik_gosterge_donem`e
--   yazar. Kesinleşmiş satıra dokunmaz.
--
-- Hedef ölçüm satırına KOPYALANIR (dondurulur): rehber ya da kurum hedefi
--   sonradan değişirse geçmiş dönemin "hedefte miydi" yargısı değişmemeli.
create or replace function public.fn_klinik_donem_hesapla(
    p_sube_id   integer,
    p_yil       smallint,
    p_donem_no  smallint default 1,
    p_periyot   smallint default 6,
    p_kullanici integer  default 0
) returns table (yazilan integer, atlanan integer, kodsuz integer, sure_ms integer)
language plpgsql
as $fn$
declare
    v_bas date; v_bit date;
    v_bas_zaman timestamptz := clock_timestamp();
    v_yaz integer := 0; v_atla integer := 0; v_kodsuz integer := 0;
    r  record;
    h  record;
begin
    select bas, son into v_bas, v_bit
      from public.fn_klinik_donem_araligi(p_yil, p_donem_no, p_periyot);

    for r in
        select g.id, g.kod,
               -- Geçerli hedef: kurum kendi hedefini girdiyse o, yoksa rehberin.
               coalesce(g.kurum_hedef_yon, g.hedef_yon)     as hedef_yon,
               coalesce(g.kurum_hedef_deger, g.hedef_deger) as hedef_deger
          from public.klinik_gosterge g
         where g.aktif = 1 and g.otomatik = 1
         order by g.kod
    loop
        -- Kesinleşmiş dönem yeniden hesaplanmaz.
        if exists (select 1 from public.klinik_gosterge_donem d
                    where d.sube_id = p_sube_id and d.gosterge_id = r.id
                      and d.donem_yil = p_yil and d.donem_no = p_donem_no
                      and d.periyot = p_periyot and d.durum = 1) then
            v_atla := v_atla + 1;
            continue;
        end if;

        select * into h
          from public.fn_klinik_gosterge_hesapla(r.id, p_sube_id, v_bas, v_bit);

        if h.durum = 'kod_yok' then
            v_kodsuz := v_kodsuz + 1;
            continue;                      -- elle girilecek; boş satır açmayız
        end if;

        insert into public.klinik_gosterge_donem
               (sube_id, gosterge_id, donem_yil, donem_no, periyot,
                pay, payda, hedef_yon, hedef_deger, durum, kaynak, aciklama,
                ekleyen, degistiren, degistirme_tarihi)
        values (p_sube_id, r.id, p_yil, p_donem_no, p_periyot,
                h.pay, h.payda, r.hedef_yon, r.hedef_deger, 0, 0, h.aciklama,
                p_kullanici, p_kullanici, now())
        on conflict (sube_id, gosterge_id, donem_yil, donem_no, periyot)
        do update set pay = excluded.pay, payda = excluded.payda,
                      hedef_yon = excluded.hedef_yon, hedef_deger = excluded.hedef_deger,
                      kaynak = 0, aciklama = excluded.aciklama,
                      degistiren = p_kullanici, degistirme_tarihi = now();
        v_yaz := v_yaz + 1;
    end loop;

    return query select v_yaz, v_atla, v_kodsuz,
        (extract(epoch from clock_timestamp() - v_bas_zaman) * 1000)::integer;
end;
$fn$;

comment on function public.fn_klinik_donem_hesapla(integer, smallint, smallint, smallint, integer) is
  'Dönemin tüm otomatik göstergelerini hesaplar ve yazar; kesinleşmişe dokunmaz (713).';

-- ============================================================ hızlandırma ==
-- Motor kod kümesinden yola çıkıp veriye gider; bu üç indeks olmadan her
--   gösterge tam tarama yapar.
create index if not exists ix_tani_icd on public.tani (icd_kod);
create index if not exists ix_hizmet_sut on public.hizmet (sut_kodu) where sut_kodu is not null;
create index if not exists ix_ilac_atc on public.ilac (atc_kod) where atc_kod is not null;

-- ====================================================== pencere değerleri ==
-- Rehber metninden türetildi (217 göstergenin 83'ünde bulundu). DÜZENLENEBİLİR:
--   metin ayrıştırması her zaman doğru olmaz - ör. DP.G7 rehberde "2-12 ay"
--   diyor, iki sınırlı pencere tek alana sığmadığı için 60 gün çıktı. Yanlış
--   olanı gösterge kartından düzeltmek, motoru gösterge başına dallandırmaktan
--   ucuz.
update public.klinik_gosterge g
   set pencere_gun = v.gun
  from (values
  ('DP.G1', 60),
  ('DP.G2', 60),
  ('DP.G3', 360),
  ('DP.G6', 60),
  ('DP.G7', 60),
  ('DP.G10', 90),
  ('DP.G11', 90),
  ('DP.G12', 30),
  ('DP.G13', 30),
  ('DP.G17', 30),
  ('GD.G30', 5),
  ('KP.G1', 60),
  ('KP.G2', 60),
  ('KP.G3', 360),
  ('KP.G6', 60),
  ('KP.G7', 60),
  ('KP.G10', 90),
  ('KP.G11', 90),
  ('KP.G12', 30),
  ('KP.G13', 30),
  ('KP.G16', 30),
  ('İN.G9', 7),
  ('KK.G1', 30),
  ('KK.G3', 30),
  ('KK.G4', 30),
  ('KK.G5', 30),
  ('KK.G6', 7),
  ('KK.G8', 270),
  ('KK.G10', 30),
  ('KK.G11', 30),
  ('KK.G12', 30),
  ('KH.G6', 90),
  ('KA.G3', 30),
  ('KA.G4', 90),
  ('KA.G6', 90),
  ('KA.G5', 30),
  ('KA.G7', 90),
  ('KA.G8', 180),
  ('KA.G10', 15),
  ('KR.G1', 60),
  ('KR.G2', 60),
  ('KR.G3', 60),
  ('KR.G4', 60),
  ('KR.G5', 60),
  ('KR.G8', 540),
  ('KR.G9', 30),
  ('KR.G10', 30),
  ('PR.G2', 30),
  ('PR.G3', 30),
  ('PR.G4', 30),
  ('PR.G6', 180),
  ('PR.G7', 180),
  ('Dİ.G1', 30),
  ('Dİ.G2', 30),
  ('Dİ.G3', 90),
  ('Dİ.G4', 360),
  ('Dİ.G5', 360),
  ('ÇA.G1', 30),
  ('MK.G1', 30),
  ('MK.G2', 30),
  ('MK.G3', 30),
  ('MK.G4', 30),
  ('MK.G5', 30),
  ('MK.G6', 60),
  ('MK.G7', 60),
  ('MK.G8', 60),
  ('MK.G9', 60),
  ('BM.G1', 30),
  ('BM.G2', 180),
  ('BM.G3', 180),
  ('BM.G4', 180),
  ('BM.G5', 180),
  ('BM.G6', 180),
  ('BM.G7', 180),
  ('BM.G8', 180),
  ('BM.G9', 360),
  ('BM.G10', 7),
  ('BM.G11', 360),
  ('BM.G12', 180),
  ('KB.G1', 365),
  ('KB.G2', 365),
  ('KB.G8', 180),
  ('KB.G9', 365)
  ) as v(kod, gun)
 where g.kod = v.kod and g.pencere_gun = 0;

-- ================================================= otomatik bayrağı düzeltme ==
-- 711 `otomatik` alanını "kod listesi VAR mı" diye doldurmuştu; motor yazılınca
--   bunun yetmediği görüldü: hesaplama HEM pay HEM payda kümesini ister. 202
--   göstergenin 64'ünde yalnız bir taraf var (rehber diğer tarafı serbest
--   metinle tarif ediyor - "1. izlem paketi gönderilen gebe sayısı" gibi) ve
--   motor onları zaten atlıyordu.
--
-- Bayrağı gerçeğe çekiyoruz: aksi halde ekran 202 göstergeyi "otomatik" diye
--   gösterir, kullanıcı hesaplamayı çalıştırır ve 64'ü sessizce boş kalır -
--   "neden hesaplanmadı" sorusunun yanıtı hiçbir yerde yazmaz. Doğru sayı:
--   138 otomatik · 79 elle.
update public.klinik_gosterge g
   set otomatik = case when p.pay_var and p.payda_var then 1 else 0 end
  from (select k.gosterge_id,
               bool_or(k.rol = 'pay')   as pay_var,
               bool_or(k.rol = 'payda') as payda_var
          from public.klinik_gosterge_kod k
         group by k.gosterge_id) p
 where p.gosterge_id = g.id
   and g.otomatik <> case when p.pay_var and p.payda_var then 1 else 0 end;
