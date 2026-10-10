-- =============================================================================
--  1020  HASTA BORÇ TAKİBİ - işlem tablosu, hatırlatma şablonları, ekran kodu
--
--  Kullanıcı (10.10.2026): "hasta borç takibini kodla" (mockup Ekranlar/
--  İcmal/hasta_borc_takibi.html).
--
--  hasta_borc_islem: hastanın borcu için yapılan her iş TEK tabloda, türüyle:
--    tur 1 hatırlatma (bildirim kuyruğuna bağlı: bildirim_id)
--        2 ödeme sözü (tutar + vade)
--        3 ödeme planı (tutar + ilk vade + taksit sayısı)
--        4 tahsilata çağır işareti
--        5 not
--  durum: 0 geçerli, 9 iptal / kaldırıldı. Söz / planın tutulup tutulmadığı
--  SAKLANMAZ - vade geçtiğinde borç hâlâ açık mı diye sunucu hesaplar.
--  Borç tutarı da saklanmaz: her zaman başvurulardan (hasta icmali kuralı).
--
--  ŞABLONLAR: borc.hatirlatma (SMS), borc.hatirlatma.eposta - değişkenler
--  hasta_ad, tutar, kurum, telefon. bildirim.kaynak_tur = 48 (borç takibi).
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    hasta.borc_takip   Kayıt Kabul › Hasta Borç Takibi   ← banko_onay
--  Banko Onaylarını (vezne sorumlusu) gören rol yeni ekranı AYNI haklarla
--  görür. İdempotent.
-- =============================================================================

create table if not exists public.hasta_borc_islem (
    id                serial primary key,
    hasta_id          integer not null references public.taraf(id),
    tur               smallint not null check (tur between 1 and 5),
    kanal             smallint,
    bildirim_id       bigint,
    tutar             numeric(18,2),
    vade              date,
    taksit_sayisi     smallint,
    aciklama          varchar(500) not null default '',
    durum             smallint not null default 0,
    sube_id           integer,
    ekleyen           integer not null default 0,
    ekleme_tarihi     timestamptz not null default now(),
    degistiren        integer,
    degistirme_tarihi timestamptz
);
create index if not exists ix_hasta_borc_islem_hasta on public.hasta_borc_islem (hasta_id, tur, durum);

insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select v.kod, v.ad, v.kanal, v.konu, v.govde, v.degiskenler::json, 1, v.aciklama, 0 from (values
    ('borc.hatirlatma', 'Borç hatırlatma (SMS)', 1, '',
     'Sayın {{hasta_ad}}, {{kurum}} hesabınızda {{tutar}} TL ödenmemiş bakiye bulunmaktadır. Bilgi: {{telefon}}',
     '{"hasta_ad":"Hasta adı","tutar":"Açık borç","kurum":"Kurum adı","telefon":"Kurum telefonu"}',
     'Hasta Borç Takibi toplu hatırlatma'),
    ('borc.hatirlatma.eposta', 'Borç hatırlatma (e-posta)', 2, '{{kurum}} - ödenmemiş bakiye',
     E'Sayın {{hasta_ad}},

{{kurum}} hesabınızda {{tutar}} TL ödenmemiş bakiye bulunmaktadır. '
     || E'Ödeme ve bilgi için {{telefon}} numaralı telefondan bize ulaşabilirsiniz.

Saygılarımızla,
{{kurum}}',
     '{"hasta_ad":"Hasta adı","tutar":"Açık borç","kurum":"Kurum adı","telefon":"Kurum telefonu"}',
     'Hasta Borç Takibi toplu hatırlatma (e-posta)')
) as v(kod, ad, kanal, konu, govde, degiskenler, aciklama)
where not exists (select 1 from public.bildirim_sablon s where s.kod = v.kod);

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('hasta.borc_takip', 'banko_onay', 'Hasta Borç Takibi (Kayıt Kabul)', 'Kasa');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1020: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- ---------------------------------------------------------- yardım kataloğu --
--  Asistan ekranı tarif edebilsin (yeni ekran = ai_rehber_ekran satırı).
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('hasta-borc-takibi', '/hasta-borc-takibi', 'Hasta Borç Takibi', 'Kayıt Kabul › Hasta Borç Takibi',
     'Kayıt Kabul', 'Hasta Borç Takibi', 'hasta.borc_takip', 2,
     'hasta borç takibi açık borç hatırlatma sms e-posta ödeme sözü ödeme planı tahsilata çağır',
     'Açık borcu olan hastalar; toplu SMS / e-posta hatırlatma, ödeme sözü ve planı, '
     || 'tahsilata çağır işareti, hatırlatma geçmişi ve A4 borç bildirim mektubu.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
