-- =============================================================================
--  1382 - RANDEVU SMS: KARTTA "SMS GÖNDER" + ŞUBEYE ÖZGÜ METİN + ŞUBE BAZLI HATIRLATMA
--
--  Kullanıcı (19.11.2026): "randevu kartına SMS Gönder Check ekle.. default seçili olsun.. işaretliyse randevu alan
--  hastaya randevu bilgilerini içeren bir sms atalım.. şubeye özgü olsun mesaj.. istersek mesajı değiştirebilelim..
--  daha sonra da 1 gün kala hatırlatma mesajı göndereceğiz opsiyonel olarak". Kararlar: şube şablonu + kartta
--  düzenleme; hatırlatma şube ayarı + kartta ikinci işaret.
--
--  randevu_sms_ayar (şube başına bir satır): bilgi metni şablonu, hatırlatma açık / kaç saat önce / hatırlatma
--    metni. Boş metin = koddaki varsayılan (RandevuHatirlatmasi). Satırı olmayan şube eski kurum geneli hatırlatma
--    ayarıyla (randevu.hatirlatma_acik / _saat, şablon randevu.hatirlatma) çalışmaya devam eder.
--  randevu: sms_gonder (kartta işaret; DB varsayılanı 0 - kart dışı yollar - aday, erteleme, çalışma planı -
--    kendiliğinden SMS atmaz, kart yeni kayıtta 1 önerir), sms_metni (kartta elle değiştirilen metin; gönderilince
--    temizlenir), sms_hatirlatma (bu randevuda hatırlatma; varsayılan 1), sms_bilgi_baslangic (bilgi SMS'inin hangi
--    randevu saati için gittiği - aynı saat için ikinci kez gitmez, saat değişirse yeni bilgi gider).
--  Şablonlar 'randevu.bilgi' / 'randevu.hatirlatma_sube': gövde {{metin}} - metin şube şablonundan sunucuda
--    hazırlanır (değişkenler: {hasta} {tarih} {gun} {saat} {bolum} {hekim} {sube} {adres} {telefon}). İdempotent.
-- =============================================================================
begin;

create table if not exists public.randevu_sms_ayar (
    sube_id           integer primary key references public.sube(id) on delete cascade,
    bilgi_sablon      varchar(500) not null default '',
    hatirlatma_acik   smallint     not null default 0,
    hatirlatma_saat   smallint     not null default 24 check (hatirlatma_saat between 1 and 168),
    hatirlatma_sablon varchar(500) not null default '',
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz
);
comment on table public.randevu_sms_ayar is
  '1382: şubenin randevu SMS ayarı - bilgi metni, hatırlatma açık / saat / metin (boş metin = varsayılan)';

alter table public.randevu add column if not exists sms_gonder smallint not null default 0;
alter table public.randevu add column if not exists sms_metni varchar(500) not null default '';
alter table public.randevu add column if not exists sms_hatirlatma smallint not null default 1;
alter table public.randevu add column if not exists sms_bilgi_baslangic timestamptz;
comment on column public.randevu.sms_gonder is '1382: kayıtta hastaya randevu bilgi SMS''i gönderilsin (kart varsayılanı 1)';
comment on column public.randevu.sms_metni is '1382: kartta elle değiştirilen bilgi metni (boş = şube şablonu); gönderilince temizlenir';
comment on column public.randevu.sms_hatirlatma is '1382: bu randevuya hatırlatma SMS''i (şube ayarı açıksa)';
comment on column public.randevu.sms_bilgi_baslangic is '1382: bilgi SMS''inin gönderildiği randevu saati (aynı saate ikinci kez gitmez)';

insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'randevu.bilgi', 'Randevu bilgisi (SMS, şube metni)', 1, '', '{{metin}}',
       '{"metin": "Şubenin randevu bilgi metninden hazırlanan mesaj"}', 1,
       'Randevu (1382): kartta SMS Gönder işaretliyse kayıtta hastaya giden bilgi. Metin Randevu › Çalışma Şablonları › SMS''ten (şube).', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'randevu.bilgi');
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'randevu.hatirlatma_sube', 'Randevu hatırlatması (SMS, şube metni)', 1, '', '{{metin}}',
       '{"metin": "Şubenin hatırlatma metninden hazırlanan mesaj"}', 1,
       'Randevu (1382): şube ayarında hatırlatma açıksa randevudan N saat önce. Metin Randevu › Çalışma Şablonları › SMS''ten (şube).', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'randevu.hatirlatma_sube');

commit;
