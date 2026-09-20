-- =====================================================================
--  881_enabiz_hasta_mesaji_411.sql
--  HASTA MESAJI ARTIK USS PAKETİ (411) — 877'nin TAŞIMASI DEĞİŞTİ
--  (KTS denetim maddeleri H7 / D14; H1 · D16 · D17 de aynı yoldan gider)
--
--  877'de mesajı `NabizHBYS.svc` üzerinde ayrı bir SOAP metoduyla
--  göndermeyi tasarlamış ve "metot adı kılavuzda yok" diye kapıyı kapalı
--  bırakmıştık. Doğrusu buymuş: **hastaya mesaj bir USS PAKETİDİR** —
--  rehberdeki **411 Doktor Mesajı Paketi**. Yani mesaj, 101/102/103 ile
--  aynı kuyruktan, aynı `SYSSendMessage` çağrısıyla gider.
--
--  Şema (rehber.enabiz.gov.tr, 19.09.2026):
--    HASTA_TAKIP_BILGISI / SYSTakipNo                     zorunlu
--    DOKTOR_MESAJI_VERI_SETI
--      HASTA_MESAJLARI_TURU  (SKRS db954393-…)            zorunlu
--      MESAJ_DETAYI                                       zorunlu
--      MESAJ_TARIHI (datetime)                            zorunlu
--
--  SKRS "HASTA MESAJLARI" LİSTESİ BİZİM KAYNAK KODLARIMIZLA ÖRTÜŞÜYOR
--  (servisten çekilip doğrulandı): 1 Randevu iptali · 2 Numune reddi ·
--  3 Laboratuvar panik değer · 4 Doktorun mesajı · 5 Protez randevusu
--  iptali. 877'de kendi kafamıza göre tanımladığımız `kaynak` kodları
--  (1 hekim elle · 2 numune reddi · 3 randevu iptali) şimdi bu listeye
--  eşleniyor - mesajın TÜRÜ artık uydurma değil, Bakanlık listesinden.
--
--  NE DEĞİŞMEDİ: kuyruk tablosu, ekran, yetki, otomatik mesaj tetikleri
--  (numune reddi 879) ve "kuyrukta bekler, gönderimi arka plan yapar"
--  davranışı. Değişen yalnız TAŞIMA: mesaj satırı artık 411 paketi
--  üretir, gönderimi `enabiz.gonder` kuyruğu yapar.
-- =====================================================================

-- --------------------------------------------- SKRS mesaj türü listesi ----
insert into public.kod_liste (kod, ad, skrs_liste)
select 'enabiz.hasta_mesaj_turu', 'e-Nabız Hasta Mesajı Türü (SKRS)',
       'db954393-57be-4a56-872c-58619e2779f3'
 where not exists (select 1 from public.kod_liste k where k.kod = 'enabiz.hasta_mesaj_turu');

--  DEĞER = SKRS KODUNUN KENDİSİ. Yerel bir numara uydurup eşleme tablosu
--  taşımak yerine (609'daki karar), listenin kendisi SKRS'nin kopyasıdır.
insert into public.kod_deger (liste_id, deger, ad, skrs_kod, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger::text, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    (1, 'Randevu iptali'),
    (2, 'Numune reddi'),
    (3, 'Laboratuvar panik değer'),
    (4, 'Doktorun mesajı'),
    (5, 'Protez randevusu iptali')
  ) as v(deger, ad) on l.kod = 'enabiz.hasta_mesaj_turu'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ----------------------------------------------------------- kolonlar ----
alter table public.enabiz_mesaj
  add column if not exists mesaj_turu smallint,        -- enabiz.hasta_mesaj_turu (SKRS)
  add column if not exists paket_id   bigint;          -- üretilen 411 paketi

--  MEVCUT SATIRLARIN TÜRÜ KAYNAKTAN TÜRETİLİR. Eşleme tek yerde dursun
--  diye fonksiyon: hem göç hem de yeni satırlar aynı kuralı kullanır.
create or replace function public.fn_enabiz_mesaj_turu(p_kaynak smallint)
returns smallint language sql immutable as $$
    select case p_kaynak
             when 1 then 4::smallint   -- hekim elle      → DOKTORUN MESAJI
             when 2 then 2::smallint   -- numune reddi    → NUMUNE REDDI
             when 3 then 1::smallint   -- randevu iptali  → RANDEVU IPTALI
             when 4 then 4::smallint   -- sonuç bilgilendirme → DOKTORUN MESAJI
             else 4::smallint
           end;
$$;

comment on function public.fn_enabiz_mesaj_turu(smallint) is
  '881: yerel mesaj kaynagi -> SKRS HASTA MESAJLARI turu. Panik deger (3) ve '
  'protez randevu iptali (5) icin kaynak kodu acildiginda buraya eklenir.';

update public.enabiz_mesaj
   set mesaj_turu = public.fn_enabiz_mesaj_turu(kaynak)
 where mesaj_turu is null;

alter table public.enabiz_mesaj
  alter column mesaj_turu set default 4;

comment on column public.enabiz_mesaj.mesaj_turu is
  '881: SKRS HASTA MESAJLARI turu (411 paketinin zorunlu alani). Bos gelirse '
  'kaynaktan turetilir (fn_enabiz_mesaj_turu).';
comment on column public.enabiz_mesaj.paket_id is
  '881: satirdan uretilen 411 paketi. Gonderim durumu paketin kendisindedir.';

-- --------------------------------------------------------- paket türü ----
insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, uss_surum, tetik_olay, sure_siniri_saat, zorunlu_alanlar, aktif)
select 'HASTA_MESAJI', 'Doktor Mesajı (hastaya)', '411', '2.2',
       'mesaj_kuyruga_alindi', 24,
       '["HASTA_TAKIP_BILGISI/SYSTakipNo",
         "DOKTOR_MESAJI_VERI_SETI/HASTA_MESAJLARI_TURU",
         "DOKTOR_MESAJI_VERI_SETI/MESAJ_DETAYI",
         "DOKTOR_MESAJI_VERI_SETI/MESAJ_TARIHI"]'::jsonb,
       1
 where not exists (select 1 from public.enabiz_paket_turu t where t.kod = 'HASTA_MESAJI');

-- ------------------------------------------------------------ görünüm ----
--  KOLON EKLENDIGI ICIN ONCE DUSURULUR: PG, var olan bir gorunumun kolon
--  SIRASINI degistirmeye izin vermez ("cannot change name of view column").
drop view if exists public.v_enabiz_mesaj;
create view public.v_enabiz_mesaj as
select m.id,
       m.sube_id,
       m.hasta_id,
       t.unvan                          as hasta_adi,
       m.hasta_kimlik,
       m.hekim_id,
       coalesce(h.unvan, '')            as hekim_adi,
       m.hekim_kimlik,
       m.belge_id,
       m.kaynak,
       coalesce(kk.ad, '')              as kaynak_adi,
       m.kaynak_id,
       m.mesaj_turu,
       coalesce(kt.ad, '')              as mesaj_turu_adi,
       m.metin,
       m.durum,
       coalesce(kd.ad, '')              as durum_adi,
       m.deneme,
       m.gonderim_zamani,
       m.yanit_kod,
       m.yanit_mesaj,
       m.son_hata,
       m.paket_id,
       coalesce(p.paket_no, '')         as paket_no,
       p.durum                          as paket_durum,
       m.ekleme_tarihi,
       m.ekleyen
  from public.enabiz_mesaj m
  join public.taraf t on t.id = m.hasta_id
  left join public.taraf h on h.id = m.hekim_id
  left join public.enabiz_paket p on p.id = m.paket_id
  left join public.kod_liste lk on lk.kod = 'enabiz.mesaj_kaynak'
  left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = m.kaynak
  left join public.kod_liste lt on lt.kod = 'enabiz.hasta_mesaj_turu'
  left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = m.mesaj_turu
  left join public.kod_liste ld on ld.kod = 'enabiz.mesaj_durum'
  left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = m.durum;

comment on view public.v_enabiz_mesaj is
  '881: e-Nabiz hasta mesaji + SKRS turu + uretilen 411 paketi. Mesajin '
  'gonderim durumu artik PAKETIN durumudur.';

-- --------------------------------------------------- eskiyen ayar ----
--  877'nin `enabiz.mesaj_metot` ayarı ARTIK KULLANILMIYOR: mesaj ayrı bir
--  SOAP metodu değil, USS paketi. Satır silinmiyor (kurum doldurmuş
--  olabilir) ama açıklaması ne olduğunu söylüyor.
update public.referans
   set aciklama = 'KULLANILMIYOR (881). Hasta mesajı artık 411 USS paketiyle '
                  || 'gönderiliyor; bu ayar 877''deki eski SOAP tasarımından kaldı.'
 where anahtar = 'enabiz.mesaj_metot';

do $$
begin
    raise notice '881 tamam: 411 paket turu (aktif %), % mesaj satiri turlendi',
        (select aktif from public.enabiz_paket_turu where kod = 'HASTA_MESAJI'),
        (select count(*) from public.enabiz_mesaj where mesaj_turu is not null);
end $$;
