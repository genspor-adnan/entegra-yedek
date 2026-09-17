-- ============================================================================
--  Gentegre AI — HASTA AVANSI: DAMGA VE TAKİP
--  779_hasta_avansi.sql
--
--  Kullanıcı: *"hastadan alınan avans tahsilatı takibi yapabilmeliyiz"*.
--
--  ============ ZATEN VAR OLAN: DAĞITILMAMIŞ TAHSİLAT ==================
--  322 "avans"ı dolaylı tanımlamıştı: belge satırlarına dağıtılmamış tahsilat
--  avanstır (`v_taraf_avans`), belge kartındaki şerit onu satırlara mahsup
--  eder. Eksik olan TAKİPTİ - kimden ne zaman ne kadar avans alındığı, ne
--  kadarının kullanıldığı ve kimde ne kaldığı hiçbir ekranda toplu
--  görünmüyordu; para ancak hasta bir belgeye geldiğinde hatırlanıyordu.
--
--  ============ NEDEN AYRI BİR DAMGA (kasa_islem.avans) ================
--  "Dağıtılmamış olan avanstır" kuralı tek başına iki soruyu karıştırıyor:
--
--    * Kayıt kabul BİLEREK avans alır (kapora, peşin paket ödemesi) -
--      niyeti baştan bellidir.
--    * Bir başvuru tahsilatının küçük bir kalıntısı da dağıtılmamış kalabilir
--      (kuruş farkı, satırı sonra girilen tetkik) - bu bir avans NİYETİ
--      değildir.
--
--  Damga niyeti kaydeder ve avans TAMAMEN KULLANILDIKTAN SONRA da kaydı
--  listede tutar: "geçen ay aldığımız 2.000 TL avans nereye gitti" sorusunun
--  cevabı, para bittiği an kaybolmasın. Damgasız dağıtılmamış tahsilatlar da
--  listede görünür (322 davranışı korunur), yalnız kapandıklarında düşerler.
--
--  ============ AYRI TABLO AÇILMADI ====================================
--  Avans bir kasa işlemidir: nakit/POS/banka ayrımı, makbuz numarası, iptal,
--  muhasebe fişi, şube ve kullanıcı damgası hep orada. İkinci bir tablo
--  kasanın bakiyesini avanstan habersiz bırakır, iptal ve fiş akışını
--  ikilerdi (753'te personel avansında verilen kararın aynısı).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- damga ------
alter table public.kasa_islem
  add column if not exists avans smallint not null default 0;

comment on column public.kasa_islem.avans is
  'Bilerek alinan AVANS tahsilati mi (779): 1 ise kullanilsa bile avans listesinde kalir.';

-- Avans listesi hastaya gore suzuyor; damgali kayit sayisi toplam kasa
--   islemine gore kucuk, kismi index yeterli.
create index if not exists ix_kasa_islem_avans
    on public.kasa_islem (taraf_id, islem_tarihi)
 where avans = 1;

-- --------------------------------------------------------- avans listesi --
-- HASTA = taraf.grup 101 (hasta kaynagindaki sabit kosulun aynisi).
-- Yalniz GERCEKLESMIS (durum 2), iptal edilmemis ve TAHSILAT yonundeki
--   islemler: odeme (kurumdan cikan para) avans degildir.
create or replace view public.v_hasta_avans as
select ki.id                                   as kasa_islem_id,
       ki.taraf_id,
       coalesce(t.unvan, ki.taraf_unvan, '')   as hasta_adi,
       coalesce(t.kod, '')                     as dosya_no,
       ki.sube_id,
       ki.islem_tarihi,
       coalesce(nullif(ki.makbuz_no, ''), ki.islem_no, '') as makbuz_no,
       ki.tur,
       coalesce(kt.ad, '')                     as islem_adi,
       coalesce(h.ad, '')                      as hesap_adi,
       ki.tutar                                as alinan,
       coalesce(d.dagitilan, 0)                as kullanilan,
       greatest(ki.tutar - coalesce(d.dagitilan, 0), 0) as kalan,
       case when greatest(ki.tutar - coalesce(d.dagitilan, 0), 0) <= 0.005
                 then 'Kullanıldı'
            when coalesce(d.dagitilan, 0) > 0.005
                 then 'Kısmen Kullanıldı'
            else 'Açık' end                    as durum_adi,
       ki.avans,
       ki.belge_id,
       coalesce(b.belge_no, '')                as belge_no,
       coalesce(ki.aciklama, '')               as aciklama,
       ki.ekleme_tarihi
  from public.kasa_islem ki
  join public.taraf t                on t.id  = ki.taraf_id and t.grup = 101
  left join public.kasa_islem_turu kt on kt.kod = ki.tur
  left join public.hesap h            on h.id  = ki.hesap_id
  left join public.belge b            on b.id  = ki.belge_id
  left join lateral (
       select sum(x.tutar) as dagitilan
         from public.kasa_islem_dagitim x
        where x.kasa_islem_id = ki.id) d on true
 where ki.durum = 2
   and ki.iptal_islem_id is null
   and coalesce(kt.yon, 1) = 1
   and (ki.avans = 1
        or greatest(ki.tutar - coalesce(d.dagitilan, 0), 0) > 0.005);

comment on view public.v_hasta_avans is
  'Hastadan alinan avans tahsilatlari (779): alinan / kullanilan / kalan ve durumu.';

-- -------------------------------------------------------- hasta bakiyesi --
-- Hasta seridi ve basvuru karti "bu hastanin acik avansi var mi" diye tek
--   satir sorar; toplami listede tekrar hesaplamak yerine burada.
create or replace view public.v_hasta_avans_bakiye as
select a.taraf_id,
       sum(a.kalan)                            as acik_avans,
       count(*) filter (where a.kalan > 0.005) as acik_islem,
       max(a.islem_tarihi)                     as son_avans_tarihi
  from public.v_hasta_avans a
 group by a.taraf_id;

comment on view public.v_hasta_avans_bakiye is
  'Hastanin kullanilmamis avans toplami (779).';

do $$
declare v_acik numeric; v_adet int;
begin
    select coalesce(sum(kalan), 0), count(*) into v_acik, v_adet
      from public.v_hasta_avans where kalan > 0.005;
    raise notice '779 tamam: hasta avans damgasi + gorunumleri kuruldu. '
                 'Acik avans: % kayit, % tutar (mevcut dagitilmamis '
                 'tahsilatlar).', v_adet, v_acik;
end $$;
