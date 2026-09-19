-- 839: ÇAĞRI MERKEZİ MODÜLÜ (kullanıcı: "Çağrı Merkezi sistemini mockuplara
-- uygun şekilde projeye ekle"). Mockuplar: Ekranlar/CagriMerkezi/*.html.
--
-- Akış: KANAL (santral telefon / WhatsApp / SMS / web formu / e-posta) → ARAYAN
-- TANIMA (numara → taraf: hasta / cari / personel) → ÇAĞRI KAYDI (konu ağacı,
-- not, sonuç) → İŞLEM (randevu, sonuç, ödeme linki, şikayet=görev, geri arama)
-- → GİDEN ARAMA / KAMPANYA (hatırlatma, sonuç hazır, anket, tahsilat, İSG
-- periyodik) → SÜPERVİZÖR (kuyruk, agent, SLA) → KALİTE (puan, AI özet).
--
-- Santral sağlayıcı bağımsız: olaylar (ringing/answered/hold/transfer/hangup)
-- /api/acik/cagri/olay/{saglayici} webhook'undan `cagri_olay`a yazılır;
-- `cagri` başlığı ilk ringing'de açılır, hangup'ta kapanır. Softphone yok
-- (masaüstü telefon + ekran açılışı); WebRTC sonraki adım.
-- Şikayet DÖF tablosu yerine GÖREV (gorev.tur 1, kategori "Şikayet") açar;
-- geri arama = gorev.tur 2 (Hatırlatma) + cagri.geri_arama.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('cagri.kanal',        'Çağrı Kanalı'),
    ('cagri.yon',          'Çağrı Yönü'),
    ('cagri.durum',        'Çağrı Durumu'),
    ('cagri.sonuc',        'Çağrı Sonucu'),
    ('cagri.oncelik',      'Çağrı Önceliği'),
    ('cagri.agent_durum',  'Agent Durumu'),
    ('cagri.mola_sebep',   'Mola Sebebi'),
    ('cagri.kampanya_tur', 'Kampanya Türü'),
    ('cagri.kisi_durum',   'Kampanya Kişi Durumu'),
    ('cagri.olay_tur',     'Santral Olay Türü'),
    ('cagri.hizli_islem',  'Çağrı Hızlı İşlemi')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('cagri.kanal', 1, 'Telefon'), ('cagri.kanal', 2, 'WhatsApp'), ('cagri.kanal', 3, 'SMS'), ('cagri.kanal', 4, 'Web formu'), ('cagri.kanal', 5, 'E-posta'),
    ('cagri.yon', 1, 'Gelen'), ('cagri.yon', 2, 'Giden'),
    ('cagri.durum', 1, 'Çalıyor'), ('cagri.durum', 2, 'Görüşmede'), ('cagri.durum', 3, 'Beklemede'), ('cagri.durum', 4, 'Kayıt bekliyor'),
    ('cagri.durum', 5, 'Tamamlandı'), ('cagri.durum', 6, 'Kaçan'), ('cagri.durum', 7, 'Sesli mesaj'), ('cagri.durum', 8, 'Ulaşılamadı'),
    ('cagri.sonuc', 1, 'Çözüldü'), ('cagri.sonuc', 2, 'Geri aranacak'), ('cagri.sonuc', 3, 'Görev açıldı'), ('cagri.sonuc', 4, 'Ulaşılamadı'),
    ('cagri.sonuc', 5, 'Yönlendirildi'), ('cagri.sonuc', 6, 'Bilgi verildi'), ('cagri.sonuc', 7, 'Randevu verildi'), ('cagri.sonuc', 8, 'Vazgeçti'),
    ('cagri.oncelik', 1, 'Normal'), ('cagri.oncelik', 2, 'Yüksek'), ('cagri.oncelik', 3, 'Acil'),
    ('cagri.agent_durum', 1, 'Hazır'), ('cagri.agent_durum', 2, 'Çağrıda'), ('cagri.agent_durum', 3, 'İşlem sonrası'), ('cagri.agent_durum', 4, 'Mola'), ('cagri.agent_durum', 5, 'Çıkış'),
    ('cagri.mola_sebep', 1, 'Yemek'), ('cagri.mola_sebep', 2, 'Kısa mola'), ('cagri.mola_sebep', 3, 'Eğitim'), ('cagri.mola_sebep', 4, 'Toplantı'), ('cagri.mola_sebep', 5, 'Diğer'),
    ('cagri.kampanya_tur', 1, 'Randevu hatırlatma'), ('cagri.kampanya_tur', 2, 'Sonuç hazır'), ('cagri.kampanya_tur', 3, 'Memnuniyet anketi'),
    ('cagri.kampanya_tur', 4, 'Tahsilat'), ('cagri.kampanya_tur', 5, 'Serbest liste'), ('cagri.kampanya_tur', 6, 'İSG periyodik muayene'),
    ('cagri.kisi_durum', 1, 'Bekliyor'), ('cagri.kisi_durum', 2, 'Mesaj gönderildi'), ('cagri.kisi_durum', 3, 'Ulaşılamadı'), ('cagri.kisi_durum', 4, 'Tamamlandı'),
    ('cagri.kisi_durum', 5, 'Onayladı'), ('cagri.kisi_durum', 6, 'İptal etti'), ('cagri.kisi_durum', 7, 'Vazgeçildi'),
    ('cagri.olay_tur', 1, 'Çaldı'), ('cagri.olay_tur', 2, 'Cevaplandı'), ('cagri.olay_tur', 3, 'Beklet'), ('cagri.olay_tur', 4, 'Bekletme bitti'),
    ('cagri.olay_tur', 5, 'Aktarıldı'), ('cagri.olay_tur', 6, 'Kapandı'), ('cagri.olay_tur', 7, 'Not'), ('cagri.olay_tur', 8, 'Mesaj'), ('cagri.olay_tur', 9, 'İşlem'),
    ('cagri.hizli_islem', 1, 'Randevu'), ('cagri.hizli_islem', 2, 'Sonuç bilgisi'), ('cagri.hizli_islem', 3, 'Bilgi kartı'), ('cagri.hizli_islem', 4, 'Şikayet (görev)'),
    ('cagri.hizli_islem', 5, 'Ödeme linki'), ('cagri.hizli_islem', 6, 'Servis / sipariş'), ('cagri.hizli_islem', 7, 'Geri arama')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ tablolar ==
-- KONU AĞACI: ust_id boş = konu, dolu = alt konu. sla_dk 0 = çağrıda çözüm.
create table if not exists public.cagri_konu (
    id            integer generated always as identity primary key,
    ust_id        integer      references public.cagri_konu(id) on delete cascade,
    ad            varchar(80)  not null,
    sla_dk        integer      not null default 0,
    hizli_islem   smallint     not null default 0,          -- cagri.hizli_islem
    sonuclar      varchar(300) not null default '',         -- virgüllü sonuç metinleri (öneri)
    betik         varchar(1200) not null default '',        -- operatör betiği
    sira          integer      not null default 0,
    aktif         smallint     not null default 1,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_cagri_konu_ust on public.cagri_konu (ust_id, sira);
comment on table public.cagri_konu is 'Çağrı merkezi konu ağacı (839): konu / alt konu, SLA, hızlı işlem, betik.';

-- KUYRUK: santral kuyruğu + beceri; agent kuyruk üyeliği cagri_agent.kuyruklar (JSON dizi).
create table if not exists public.cagri_kuyruk (
    id               integer generated always as identity primary key,
    ad               varchar(60)  not null,
    santral_kodu     varchar(30)  not null default '',
    beceri           varchar(40)  not null default '',
    sla_sn           integer      not null default 20,
    sla_hedef        smallint     not null default 90,      -- %
    max_bekleme_sn   integer      not null default 180,
    tasma_kuyruk_id  integer      references public.cagri_kuyruk(id),
    bekleme_mesaji   varchar(200) not null default '',
    kanal            smallint     not null default 1,       -- cagri.kanal (WhatsApp kuyruğu = 2)
    sira             integer      not null default 0,
    aktif            smallint     not null default 1,
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
comment on table public.cagri_kuyruk is 'Çağrı kuyruğu (839): santral kodu, beceri, SLA hedefi, taşma.';

-- AGENT: kullanıcı ↔ dahili; anlık durum.
create table if not exists public.cagri_agent (
    id            integer generated always as identity primary key,
    kullanici_id  integer      not null,
    dahili        varchar(10)  not null default '',
    softphone     smallint     not null default 1,           -- 1 masaüstü telefon · 2 WebRTC
    kuyruklar     varchar(200) not null default '[]',        -- JSON dizi: kuyruk id'leri
    durum         smallint     not null default 5,           -- cagri.agent_durum
    durum_zaman   timestamp    not null default now(),
    mola_sebep    smallint     not null default 0,
    aktif         smallint     not null default 1,
    sube_id       integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_cagri_agent_kullanici on public.cagri_agent (kullanici_id);
comment on table public.cagri_agent is 'Çağrı merkezi agent (839): kullanıcı ↔ dahili, kuyruk üyeliği, anlık durum.';

-- KAMPANYA: liste sorgusu (kaynak) + kanal adımları; kişiler ayrı tabloda.
create table if not exists public.cagri_kampanya (
    id               integer generated always as identity primary key,
    ad               varchar(120) not null,
    tur              smallint     not null default 5,        -- cagri.kampanya_tur
    kaynak           varchar(30)  not null default 'serbest',-- randevu_yarin | sonuc_hazir | taburcu_anket | vadesi_gecen | isg_periyodik | serbest
    parametre        varchar(200) not null default '',       -- kaynağa göre: tutar eşiği, gün vb.
    sablon_kodu      varchar(60)  not null default '',       -- 1. adım: bildirim şablonu (WhatsApp/SMS); boş = doğrudan arama
    kuyruk_id        integer      references public.cagri_kuyruk(id),  -- 2. adım: arama kuyruğu
    ikinci_adim_dk   integer      not null default 120,      -- mesaja cevap yoksa kaç dk sonra aranır
    deneme           smallint     not null default 3,
    deneme_ara_dk    integer      not null default 120,
    zamanlama        varchar(60)  not null default '',       -- "Her gün 17:00" (metin, bilgi)
    baslama          date,
    bitis            date,
    durum            smallint     not null default 0,        -- 0 taslak · 1 çalışıyor · 2 durdu · 3 bitti
    aciklama         varchar(400) not null default '',
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
comment on table public.cagri_kampanya is 'Giden arama kampanyası (839): kaynak liste + şablon → arama adımı, deneme kuralı.';

create table if not exists public.cagri_kampanya_kisi (
    id            integer      generated always as identity primary key,
    kampanya_id   integer      not null references public.cagri_kampanya(id) on delete cascade,
    taraf_id      integer      references public.taraf(id),
    ad            varchar(150) not null default '',
    telefon       varchar(30)  not null default '',
    kaynak_tur    varchar(30)  not null default '',          -- randevu | lab_istem | belge | isg_calisan | taraf
    kaynak_id     integer      not null default 0,
    ozet          varchar(200) not null default '',          -- "20.09 10:40 Kardiyoloji"
    durum         smallint     not null default 1,           -- cagri.kisi_durum
    deneme        smallint     not null default 0,
    son_deneme    timestamp,
    bildirim_id   bigint,
    cagri_id      integer,
    sonuc         varchar(200) not null default '',
    sube_id       integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_cagri_kampanya_kisi on public.cagri_kampanya_kisi (kampanya_id, durum);
create unique index if not exists ux_cagri_kampanya_kisi_kaynak on public.cagri_kampanya_kisi (kampanya_id, kaynak_tur, kaynak_id) where kaynak_id > 0;

-- ÇAĞRI: başlık. taraf_id tanınan kişi (hasta / cari / personel); boş = tanınmayan arayan.
create table if not exists public.cagri (
    id               integer generated always as identity primary key,
    kanal            smallint     not null default 1,        -- cagri.kanal
    yon              smallint     not null default 1,        -- cagri.yon
    arayan_no        varchar(30)  not null default '',
    aranan_no        varchar(30)  not null default '',
    taraf_id         integer      references public.taraf(id),
    kuyruk_id        integer      references public.cagri_kuyruk(id),
    agent_id         integer,                                -- kullanıcı id
    dis_ref          varchar(80)  not null default '',       -- santral çağrı kimliği (idempotent olay)
    baslama          timestamp    not null default now(),
    cevap            timestamp,
    bitis            timestamp,
    bekleme_sn       integer      not null default 0,
    sure_sn          integer      not null default 0,
    islem_sonrasi_sn integer      not null default 0,
    konu_id          integer      references public.cagri_konu(id),
    alt_konu_id      integer      references public.cagri_konu(id),
    sonuc            smallint     not null default 0,        -- cagri.sonuc
    oncelik          smallint     not null default 1,
    notu             varchar(1200) not null default '',
    kayit_url        varchar(300) not null default '',
    durum            smallint     not null default 1,        -- cagri.durum
    kampanya_id      integer      references public.cagri_kampanya(id),
    kampanya_kisi_id integer,
    geri_arama       timestamp,                              -- sonuç "geri aranacak" ise
    geri_arama_tamam smallint     not null default 0,
    gorev_id         integer,                                -- açılan görev (şikayet / geri arama)
    memnuniyet       smallint     not null default 0,        -- 1..5 anket
    kalite_puan      smallint,
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_cagri_baslama on public.cagri (baslama desc);
create index if not exists ix_cagri_taraf on public.cagri (taraf_id, baslama desc);
create index if not exists ix_cagri_agent on public.cagri (agent_id, baslama desc);
create index if not exists ix_cagri_durum on public.cagri (durum) where durum in (1, 2, 3, 4, 6);
create unique index if not exists ux_cagri_dis_ref on public.cagri (dis_ref) where dis_ref <> '';
comment on table public.cagri is 'Çağrı kaydı (839): kanal/yön, arayan, tanınan taraf, kuyruk/agent, süreler, konu, sonuç, geri arama.';

create table if not exists public.cagri_olay (
    id         bigint generated always as identity primary key,
    cagri_id   integer     not null references public.cagri(id) on delete cascade,
    tur        smallint    not null,                          -- cagri.olay_tur
    zaman      timestamp   not null default now(),
    agent_id   integer,
    aciklama   varchar(300) not null default '',
    veri       varchar(1000) not null default ''             -- santral ham verisi (JSON metin)
);
create index if not exists ix_cagri_olay on public.cagri_olay (cagri_id, zaman);

create table if not exists public.cagri_ilgili (
    id          integer generated always as identity primary key,
    cagri_id    integer      not null references public.cagri(id) on delete cascade,
    kaynak_tur  varchar(30)  not null,                        -- randevu | gorev | belge | bildirim | form_istek | servis | siparis
    kaynak_id   integer      not null,
    aciklama    varchar(200) not null default '',
    ekleyen integer, ekleme_tarihi timestamp not null default now()
);
create index if not exists ix_cagri_ilgili on public.cagri_ilgili (cagri_id);

create table if not exists public.cagri_kalite (
    id             integer generated always as identity primary key,
    cagri_id       integer      not null references public.cagri(id) on delete cascade,
    degerlendiren  integer,
    form_istek_id  integer,
    puan           smallint     not null default 0,
    olcutler       varchar(1000) not null default '',        -- JSON metin: [{ad, agirlik, puan, not}]
    notu           varchar(600) not null default '',
    ozet_ai        varchar(1500) not null default '',
    transkript     text         not null default '',
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_cagri_kalite_cagri on public.cagri_kalite (cagri_id);

-- SANTRAL / KANAL AYARI: şube başına bir satır (kurum_profil gibi).
create table if not exists public.cagri_santral (
    sube_id            integer      primary key,
    saglayici          varchar(20)  not null default 'yok',   -- yok | 3cx | asterisk | bulut | webrtc
    api_adres          varchar(200) not null default '',
    kimlik             varchar(100) not null default '',
    gizli              varchar(200) not null default '',
    webhook_anahtar    varchar(60)  not null default '',
    kayit_kaynak       varchar(200) not null default '',
    kvkk_anons         smallint     not null default 1,
    kayit_saklama_ay   integer      not null default 24,
    ivr                varchar(4000) not null default '[]',   -- JSON metin: [{tus, ad, kuyruk_id, hedef, anons}]
    calisma            varchar(1000) not null default '[]',   -- JSON metin: [{gun, bas, bit}]
    mesai_disi_mesaj   varchar(300) not null default '',
    whatsapp_no        varchar(30)  not null default '',
    whatsapp_token     varchar(300) not null default '',
    bot_ilk_yanit      varchar(300) not null default '',
    eposta_adres       varchar(120) not null default '',
    islem_sonrasi_sn   integer      not null default 45,
    durum              smallint     not null default 0,       -- 0 bağlı değil · 1 bağlı
    son_olay           timestamp,
    degistiren integer, degistirme_tarihi timestamp
);
comment on table public.cagri_santral is 'Çağrı merkezi santral/kanal ayarı (839): sağlayıcı, webhook anahtarı, IVR, çalışma saatleri, WhatsApp.';

-- ============================================================ fonksiyonlar ==
-- Telefonu rakama indirger, son 10 haneyi döner (0532 417 88 21 / +90 532 … aynı anahtar).
create or replace function public.fn_cagri_tel_anahtar(p_tel text) returns text language sql immutable as $$
  select right(regexp_replace(coalesce(p_tel, ''), '[^0-9]', '', 'g'), 10)
$$;

-- ARAYAN TANIMA: numara → taraf adayları (cep_tel / telefon eşleşmesi).
create or replace function public.fn_cagri_arayan_bul(p_tel text)
returns table (taraf_id integer, ad text, hasta smallint, musteri smallint, personel smallint, kurum smallint, cep_tel text, telefon text, son_cagri timestamp)
language sql stable as $$
  select t.id, coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), t.unvan, '')::text,
         t.hasta, t.musteri, t.personel, t.kurum, coalesce(t.cep_tel, '')::text, coalesce(t.telefon, '')::text,
         (select max(c.baslama) from public.cagri c where c.taraf_id = t.id)
    from public.taraf t
   where public.fn_cagri_tel_anahtar(p_tel) <> ''
     and (public.fn_cagri_tel_anahtar(t.cep_tel) = public.fn_cagri_tel_anahtar(p_tel)
       or public.fn_cagri_tel_anahtar(t.telefon) = public.fn_cagri_tel_anahtar(p_tel))
   order by t.hasta desc, t.musteri desc, t.id
   limit 10
$$;

-- ================================================================ görünümler ==
create or replace view public.v_cagri_konu as
select k.id, k.ust_id, coalesce(u.ad, '') as ust_adi, k.ad, case when k.ust_id is null then k.ad else u.ad || ' › ' || k.ad end as tam_ad,
       k.sla_dk, k.hizli_islem, kh.ad as hizli_islem_adi, k.sonuclar, k.betik, k.sira, k.aktif, case k.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi,
       (select count(*) from public.cagri_konu a where a.ust_id = k.id) as alt_sayisi,
       (select count(*) from public.cagri c where c.konu_id = k.id and c.baslama >= current_date - 30) as cagri_30g,
       k.ekleme_tarihi
  from public.cagri_konu k
  left join public.cagri_konu u on u.id = k.ust_id
  left join public.kod_liste lh on lh.kod = 'cagri.hizli_islem' left join public.kod_deger kh on kh.liste_id = lh.id and kh.deger = k.hizli_islem;

create or replace view public.v_cagri_kuyruk as
select q.id, q.ad, q.santral_kodu, q.beceri, q.sla_sn, q.sla_hedef, q.max_bekleme_sn, q.tasma_kuyruk_id, coalesce(t.ad, '') as tasma_adi,
       q.bekleme_mesaji, q.kanal, kk.ad as kanal_adi, q.sira, q.aktif, case q.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi, q.sube_id,
       (select count(*) from public.cagri c where c.kuyruk_id = q.id and c.durum in (1, 3)) as bekleyen,
       (select coalesce(max(extract(epoch from (now() - c.baslama)))::int, 0) from public.cagri c where c.kuyruk_id = q.id and c.durum = 1) as en_uzun_bekleme_sn,
       (select count(*) from public.cagri_agent a where a.aktif = 1 and a.durum = 1 and a.kuyruklar::jsonb @> to_jsonb(array[q.id])) as hazir_agent,
       (select count(*) from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.cevap is not null) as cevaplanan_bugun,
       (select count(*) from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.durum = 6) as kacan_bugun,
       (select count(*) from public.cagri_agent a where a.aktif = 1 and a.kuyruklar::jsonb @> to_jsonb(array[q.id])) as agent_sayisi
  from public.cagri_kuyruk q
  left join public.cagri_kuyruk t on t.id = q.tasma_kuyruk_id
  left join public.kod_liste lk on lk.kod = 'cagri.kanal' left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = q.kanal;

create or replace view public.v_cagri_agent as
select a.id, a.kullanici_id, coalesce(k.ad, '') as agent_adi, a.dahili, a.softphone, case a.softphone when 2 then 'WebRTC' else 'Masaüstü' end as softphone_adi,
       a.kuyruklar, (select string_agg(q.ad, ' · ' order by q.ad) from public.cagri_kuyruk q where a.kuyruklar::jsonb @> to_jsonb(array[q.id])) as kuyruk_adlari,
       a.durum, kd.ad as durum_adi, a.durum_zaman, extract(epoch from (now() - a.durum_zaman))::int as durum_sn, a.mola_sebep,
       a.aktif, case a.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi, a.sube_id,
       (select count(*) from public.cagri c where c.agent_id = a.kullanici_id and c.baslama >= current_date) as cagri_bugun,
       (select coalesce(avg(c.sure_sn), 0)::int from public.cagri c where c.agent_id = a.kullanici_id and c.baslama >= current_date and c.sure_sn > 0) as ort_sure_sn,
       (select c.id from public.cagri c where c.agent_id = a.kullanici_id and c.durum in (2, 3, 4) order by c.baslama desc limit 1) as aktif_cagri_id
  from public.cagri_agent a
  left join public.v_kullanici_lookup k on k.id = a.kullanici_id
  left join public.kod_liste ld on ld.kod = 'cagri.agent_durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = a.durum;

create or replace view public.v_cagri as
select c.id, c.kanal, kk.ad as kanal_adi, c.yon, case c.yon when 1 then 'Gelen' else 'Giden' end as yon_adi, c.arayan_no, c.aranan_no,
       c.taraf_id, coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), t.unvan, '') as taraf_adi,
       coalesce(t.hasta, 0) as hasta, coalesce(t.musteri, 0) as musteri, coalesce(t.personel, 0) as personel,
       c.kuyruk_id, coalesce(q.ad, '') as kuyruk_adi, c.agent_id, coalesce(ag.ad, '') as agent_adi, c.dis_ref,
       c.baslama, c.cevap, c.bitis, c.bekleme_sn, c.sure_sn, c.islem_sonrasi_sn,
       c.konu_id, coalesce(k.ad, '') as konu_adi, c.alt_konu_id, coalesce(ak.ad, '') as alt_konu_adi,
       c.sonuc, coalesce(ks.ad, '') as sonuc_adi, c.oncelik, c.notu, c.kayit_url, c.durum, kd.ad as durum_adi,
       c.kampanya_id, coalesce(kp.ad, '') as kampanya_adi, c.kampanya_kisi_id, c.geri_arama, c.geri_arama_tamam, c.gorev_id, c.memnuniyet, c.kalite_puan,
       case when c.cevap is null then 0 when c.bekleme_sn <= coalesce(q.sla_sn, 20) then 1 else 0 end as sla_icinde,
       (select count(*) from public.cagri_ilgili i where i.cagri_id = c.id) as ilgili_sayisi,
       c.sube_id, c.ekleyen, c.ekleme_tarihi
  from public.cagri c
  left join public.taraf t on t.id = c.taraf_id
  left join public.cagri_kuyruk q on q.id = c.kuyruk_id
  left join public.v_kullanici_lookup ag on ag.id = c.agent_id
  left join public.cagri_konu k on k.id = c.konu_id
  left join public.cagri_konu ak on ak.id = c.alt_konu_id
  left join public.cagri_kampanya kp on kp.id = c.kampanya_id
  left join public.kod_liste lk on lk.kod = 'cagri.kanal' left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = c.kanal
  left join public.kod_liste ls on ls.kod = 'cagri.sonuc' left join public.kod_deger ks on ks.liste_id = ls.id and ks.deger = c.sonuc
  left join public.kod_liste ld on ld.kod = 'cagri.durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = c.durum;

create or replace view public.v_cagri_kampanya as
select p.id, p.ad, p.tur, kt.ad as tur_adi, p.kaynak, p.parametre, p.sablon_kodu, p.kuyruk_id, coalesce(q.ad, '') as kuyruk_adi,
       p.ikinci_adim_dk, p.deneme, p.deneme_ara_dk, p.zamanlama, p.baslama, p.bitis, p.durum,
       case p.durum when 0 then 'Taslak' when 1 then 'Çalışıyor' when 2 then 'Durdu' else 'Bitti' end as durum_adi, p.aciklama, p.sube_id, p.ekleme_tarihi,
       (select count(*) from public.cagri_kampanya_kisi x where x.kampanya_id = p.id) as hedef,
       (select count(*) from public.cagri_kampanya_kisi x where x.kampanya_id = p.id and x.durum in (2, 3, 4, 5, 6)) as ulasilan,
       (select count(*) from public.cagri_kampanya_kisi x where x.kampanya_id = p.id and x.durum in (4, 5)) as basarili,
       (select count(*) from public.cagri_kampanya_kisi x where x.kampanya_id = p.id and x.durum in (1, 3)) as bekleyen
  from public.cagri_kampanya p
  left join public.cagri_kuyruk q on q.id = p.kuyruk_id
  left join public.kod_liste lt on lt.kod = 'cagri.kampanya_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = p.tur;

create or replace view public.v_cagri_kampanya_kisi as
select x.id, x.kampanya_id, p.ad as kampanya_adi, p.tur as kampanya_tur, x.taraf_id, x.ad, x.telefon, x.kaynak_tur, x.kaynak_id, x.ozet,
       x.durum, kd.ad as durum_adi, x.deneme, x.son_deneme, x.bildirim_id, coalesce(b.durum, 0) as bildirim_durum, x.cagri_id, x.sonuc, x.sube_id, x.ekleme_tarihi,
       case when x.durum = 1 or (x.durum = 2 and x.son_deneme < now() - make_interval(mins => p.ikinci_adim_dk))
                 or (x.durum = 3 and x.deneme < p.deneme and x.son_deneme < now() - make_interval(mins => p.deneme_ara_dk)) then 1 else 0 end as aranacak
  from public.cagri_kampanya_kisi x
  join public.cagri_kampanya p on p.id = x.kampanya_id
  left join public.bildirim b on b.id = x.bildirim_id
  left join public.kod_liste ld on ld.kod = 'cagri.kisi_durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = x.durum;

create or replace view public.v_cagri_kalite as
select k.id, k.cagri_id, c.baslama, c.agent_id, c.agent_adi, c.taraf_adi, c.konu_adi, k.degerlendiren, coalesce(d.ad, '') as degerlendiren_adi,
       k.form_istek_id, k.puan, k.olcutler, k.notu, k.ozet_ai, k.transkript, k.ekleme_tarihi
  from public.cagri_kalite k
  join public.v_cagri c on c.id = k.cagri_id
  left join public.v_kullanici_lookup d on d.id = k.degerlendiren;

-- lookups
create or replace view public.v_cagri_konu_lookup as
select k.id, k.ad, k.aktif from public.cagri_konu k where k.ust_id is null;
create or replace view public.v_cagri_altkonu_lookup as
select k.id, k.ad, k.aktif, k.ust_id from public.cagri_konu k where k.ust_id is not null;
create or replace view public.v_cagri_kuyruk_lookup as
select q.id, q.ad, q.aktif from public.cagri_kuyruk q;
create or replace view public.v_cagri_kampanya_lookup as
select p.id, p.ad, case when p.durum in (0, 1) then 1 else 0 end as aktif from public.cagri_kampanya p;

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'cagri', 'Çağrı Merkezi', 'Çağrı Merkezi', 0, 41, 1, 'cagri'
 where not exists (select 1 from public.yetki where kod = 'cagri');
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'Çağrı Merkezi', 0, v.sira, 1, 'cagri' from (values
    ('cagri.pano',       'Operatör panosu (arayan tanıma, hızlı işlem)', 1),
    ('cagri.kayit',      'Çağrı kayıtları (konu, sonuç, not)',            2),
    ('cagri.giden',      'Geri arama listesi ve tıkla-ara',               3),
    ('cagri.kampanya',   'Kampanyalar (hatırlatma, anket, tahsilat)',     4),
    ('cagri.supervizor', 'Süpervizör panosu (kuyruk, agent, SLA)',        5),
    ('cagri.kalite',     'Kalite değerlendirme, ses kaydı, transkript',   6),
    ('cagri.ayar',       'Ayarlar (santral, IVR, kuyruk, konu, agent)',   7)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and (y.kod = 'cagri' or y.kod like 'cagri.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ================================================================== modül ==
insert into public.kurum_modul (kod, ad, sira)
select 'cagri', 'Çağrı Merkezi', 43 where not exists (select 1 from public.kurum_modul where kod = 'cagri');
-- Hastane / tıp merkezi / diş / OSGB'de varsayılan açık; diğer tiplerde (ERP dahil - müşteri
--   hizmetleri) seçilebilir.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'cagri', case when t.kod in ('hastane', 'tip_merkezi', 'dis', 'osgb') then 1 else 0 end
  from public.kurum_tipi t
 where not exists (select 1 from public.kurum_tipi_modul k where k.kurum_tipi = t.kod and k.modul = 'cagri');
update public.kurum_profil set moduller = coalesce(moduller, '{}'::jsonb) || '{"cagri": 1}'::jsonb
 where kurum_tipi in ('hastane', 'tip_merkezi', 'dis', 'osgb') and not (coalesce(moduller, '{}'::jsonb) ? 'cagri');

-- ====================================================== bildirim şablonları ==
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select v.kod, v.ad, v.kanal, v.konu, v.govde, v.degiskenler::json, 1, v.aciklama, 0 from (values
    ('cagri.randevu_hatirlatma', 'Çağrı: randevu hatırlatma', 4, '',
     'Sayın {{ad}}, {{tarih}} {{bolum}} randevunuzu hatırlatırız. Lütfen 15 dk önce geliniz. Onay: 1 · İptal: 2 · Değiştir: 3 — {{kurum}}',
     '{"ad":"Kişi adı","tarih":"Randevu tarih/saat","bolum":"Bölüm / hekim","kurum":"Kurum adı"}', 'Kampanya 1. adımı (WhatsApp; SMS kanalı yoksa SMS)'),
    ('cagri.sonuc_hazir', 'Çağrı: sonuç hazır', 4, '',
     'Sayın {{ad}}, {{tetkik}} sonucunuz hazır. Portal: {{baglanti}} — {{kurum}}',
     '{"ad":"Kişi adı","tetkik":"Tetkik","baglanti":"Portal bağlantısı","kurum":"Kurum adı"}', 'Kampanya: sonuç hazır bildirimi'),
    ('cagri.odeme_linki', 'Çağrı: ödeme linki', 1, '',
     'Sayın {{ad}}, {{tutar}} TL bakiyeniz için ödeme bağlantısı: {{baglanti}} (7 gün geçerli) — {{kurum}}',
     '{"ad":"Kişi adı","tutar":"Tutar","baglanti":"Ödeme bağlantısı","kurum":"Kurum adı"}', 'Operatör hızlı işlemi / tahsilat kampanyası'),
    ('cagri.anket', 'Çağrı: memnuniyet anketi', 1, '',
     'Sayın {{ad}}, hizmetimizi değerlendirmek için: {{baglanti}} — {{kurum}}',
     '{"ad":"Kişi adı","baglanti":"Anket bağlantısı","kurum":"Kurum adı"}', 'Form motoru anket linki'),
    ('cagri.geri_arama', 'Çağrı: geri arama bilgisi', 1, '',
     'Sayın {{ad}}, talebiniz alındı; {{saat}} civarında sizi arayacağız. — {{kurum}}',
     '{"ad":"Kişi adı","saat":"Geri arama saati","kurum":"Kurum adı"}', 'Geri arama planlanınca'),
    ('cagri.yol_tarifi', 'Çağrı: yol tarifi', 4, '',
     '{{kurum}} adresi: {{adres}} · Konum: {{konum}}',
     '{"kurum":"Kurum adı","adres":"Adres","konum":"Harita bağlantısı"}', 'Operatör hızlı işlemi')
  ) as v(kod, ad, kanal, konu, govde, degiskenler, aciklama)
 where not exists (select 1 from public.bildirim_sablon s where s.kod = v.kod);

-- ================================================================== tohum ==
-- Kuyruklar (santral kodu ayarlardan düzenlenir).
insert into public.cagri_kuyruk (ad, santral_kodu, beceri, sla_sn, sla_hedef, max_bekleme_sn, kanal, sira, ekleyen)
select v.ad, v.kod, v.beceri, v.sla, v.hedef, v.mb, v.kanal, v.sira, 0 from (values
    ('Randevu',        'Q-801', 'randevu',  20, 90, 180, 1, 10),
    ('Genel / Bilgi',  'Q-802', 'genel',    20, 85, 180, 1, 20),
    ('Tahsilat',       'Q-803', 'tahsilat', 30, 85, 120, 1, 30),
    ('Servis',         'Q-804', 'servis',   30, 80, 300, 1, 40),
    ('WhatsApp',       '',      'yazili',  300, 95,   0, 2, 50)
  ) as v(ad, kod, beceri, sla, hedef, mb, kanal, sira)
 where not exists (select 1 from public.cagri_kuyruk);
update public.cagri_kuyruk q set tasma_kuyruk_id = (select id from public.cagri_kuyruk where ad = 'Genel / Bilgi')
 where q.ad in ('Randevu', 'Tahsilat', 'Servis', 'WhatsApp') and q.tasma_kuyruk_id is null;
update public.cagri_kuyruk q set tasma_kuyruk_id = (select id from public.cagri_kuyruk where ad = 'Randevu') where q.ad = 'Genel / Bilgi' and q.tasma_kuyruk_id is null;

-- Konu ağacı (mockup): konu → alt konular; hızlı işlem ve SLA.
insert into public.cagri_konu (ad, sla_dk, hizli_islem, sonuclar, betik, sira, ekleyen)
select v.ad, v.sla, v.hizli, v.sonuclar, v.betik, v.sira, 0 from (values
    ('Randevu', 0, 1, 'Randevu verildi,İptal edildi,Uygun saat yok → geri arama', 'Bölüm → hekim tercihi → uygun saat → SMS onayı gönderildiğini söyle. "Randevunuzdan 15 dk önce gelmenizi rica ederiz."', 10),
    ('Sonuç / Rapor', 0, 2, 'Bilgi verildi,Sonuç hazır değil → hazır olunca bildir', 'Kimlik doğrula (doğum yılı / TC son 4). Hazırsa portal / WhatsApp seçeneği sun; hekim yorumu için randevu öner. Değer okuma yok.', 20),
    ('Bilgi', 0, 3, 'Bilgi verildi', 'Adres / çalışma saatleri / fiyat / anlaşmalı kurum bilgi kartından okunur.', 30),
    ('Şikayet / Öneri', 2880, 4, 'Görev açıldı,Çözüldü,Yönetime iletildi', 'Dinle, özür dile, kayıt numarası ver; 48 saat içinde dönüş sözü.', 40),
    ('Tahsilat', 1440, 5, 'Ödeme alındı,Söz alındı (tarih),Ulaşılamadı', 'Bakiyeyi söyle, ödeme linki teklif et, söz tarihini not al.', 50),
    ('Servis / Sipariş', 240, 6, 'Servis açıldı,Bilgi verildi,Teklif gönderildi', 'Cihaz / sipariş no al, servis kaydı aç ya da durum bildir.', 60)
  ) as v(ad, sla, hizli, sonuclar, betik, sira)
 where not exists (select 1 from public.cagri_konu);
insert into public.cagri_konu (ust_id, ad, sira, ekleyen)
select u.id, v.ad, v.sira, 0 from public.cagri_konu u
  join (values
    ('Randevu', 'Yeni', 1), ('Randevu', 'Değiştir', 2), ('Randevu', 'İptal', 3), ('Randevu', 'Sıra sorma', 4),
    ('Sonuç / Rapor', 'Tahlil sonucu', 1), ('Sonuç / Rapor', 'Radyoloji raporu', 2), ('Sonuç / Rapor', 'e-Nabız', 3),
    ('Bilgi', 'Adres / yol', 1), ('Bilgi', 'Çalışma saatleri', 2), ('Bilgi', 'Fiyat', 3), ('Bilgi', 'Anlaşmalı kurum', 4),
    ('Şikayet / Öneri', 'Bekleme', 1), ('Şikayet / Öneri', 'Personel', 2), ('Şikayet / Öneri', 'Fatura', 3), ('Şikayet / Öneri', 'Temizlik', 4),
    ('Tahsilat', 'Borç sorma', 1), ('Tahsilat', 'Ödeme linki', 2), ('Tahsilat', 'Taksit', 3),
    ('Servis / Sipariş', 'Arıza', 1), ('Servis / Sipariş', 'Sipariş durumu', 2), ('Servis / Sipariş', 'İade', 3)
  ) as v(ust, ad, sira) on v.ust = u.ad
 where u.ust_id is null and not exists (select 1 from public.cagri_konu k where k.ust_id = u.id and k.ad = v.ad);

-- Santral ayarı: her kurum profili şubesi için satır (sağlayıcı yok; webhook anahtarı rastgele).
insert into public.cagri_santral (sube_id, saglayici, webhook_anahtar, ivr, calisma, mesai_disi_mesaj, bot_ilk_yanit)
select p.sube_id, 'yok', substr(md5(random()::text || p.sube_id::text), 1, 24),
       '[{"tus":"1","ad":"Randevu","kuyruk":"Randevu"},{"tus":"2","ad":"Tahlil / rapor sonucu","kuyruk":"Genel / Bilgi","self":"sonuc"},{"tus":"3","ad":"Yatan hasta / ziyaret bilgisi","kuyruk":"Genel / Bilgi"},{"tus":"4","ad":"Muhasebe / ödeme","kuyruk":"Tahsilat"},{"tus":"5","ad":"Teknik servis","kuyruk":"Servis"},{"tus":"9","ad":"Operatöre bağlan","kuyruk":"Genel / Bilgi"},{"tus":"0","ad":"Acil (7/24)","hedef":"nobetci"}]',
       '[{"gun":"Pzt-Cum","bas":"08:00","bit":"18:00"},{"gun":"Cmt","bas":"09:00","bit":"14:00"}]',
       'Çalışma saatlerimiz hafta içi 08:00-18:00. Randevu için WhatsApp hattımıza yazabilir ya da mesaj bırakabilirsiniz; sabah sizi arayacağız.',
       'Merhaba, hoş geldiniz. 1 Randevu · 2 Sonuç · 3 Operatör'
  from public.kurum_profil p
 where not exists (select 1 from public.cagri_santral s where s.sube_id = p.sube_id);
