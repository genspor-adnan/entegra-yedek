-- =====================================================================
--  568_idari_birimler.sql
--  Hastanenin İDARİ BİRİMLERİ ve idari/sağlık personeli GÖREVLERİ eklenir.
--
--  Kullanıcı: "bir hastanede idari bölümleri de ekle."
--
--  SKRS klinik listesi yalnız TIBBİ birimleri sayar; hastanenin yarısı orada
--  yok: başhekimlik, faturalama, satınalma, bilgi işlem… Personel kartında
--  bölüm seçilirken bunlar olmadan muhasebeciye "Kardiyoloji" yazmak
--  gerekiyordu.
--
--  KOD ALANI BOŞ: idari birimin SKRS karşılığı yoktur ve olmamalı - e-Nabız
--  paketine yalnız kodu olan (tıbbi) bölümler girer, idari birim oraya sızmaz.
--  Randevuya da kapalı (`randevu_verilebilir = 0`).
--
--  GÖREVLER DE GERİ GELİYOR: 559 SKRS branş listesini kurarken kurumun kendi
--  görev tanımlarını (Hemşire, Tıbbi Sekreter, Muhasebe, IT Destek…) yedeğe
--  almıştı. İdari bölüm açıp personele görev seçtirememek yarım iş olurdu;
--  yedekteki 29 görev, SKRS branşlarının YANINA geri konur (kod boş - bunlar
--  branş değil, kurumun kadro tanımı).
--
--  TEKRAR ÇALIŞTIRILABİLİR: ada göre eşleşir, var olan eklenmez.
-- =====================================================================

do $$
declare
    v_ust    integer;
    v_bolum  integer;
    v_gorev  integer;
begin
    -- ------------------------------------------------- ust baslik (agac) ----
    insert into public.departman (kod, ad, ustbirim_id, durum, sira, randevu_verilebilir, ekleyen)
    select '', 'İdari Birimler', null, 1, 80, 0, 0
     where not exists (select 1 from public.departman
                        where ad = 'İdari Birimler' and ustbirim_id is null);
    select id into v_ust from public.departman
     where ad = 'İdari Birimler' and ustbirim_id is null limit 1;

    -- ----------------------------------------------------- idari bolumler ----
    insert into public.departman (kod, ad, ustbirim_id, durum, sira, randevu_verilebilir, ekleyen)
    select '', x.ad, v_ust, 1, x.sira, 0, 0
      from (values
        ('Başhekimlik',                 10),
        ('İdari ve Mali İşler Müdürlüğü', 20),
        ('İnsan Kaynakları',            30),
        ('Muhasebe ve Finans',          40),
        ('Satınalma',                   50),
        ('Depo / Ambar',                60),
        ('Faturalama ve Provizyon',     70),
        ('Hasta Kabul / Danışma',       80),
        ('Çağrı Merkezi / Randevu',     90),
        ('Bilgi İşlem',                100),
        ('Kalite Yönetimi',            110),
        ('Hasta Hakları',              120),
        ('Arşiv',                      130),
        ('Teknik Servis / Biyomedikal',140),
        ('Sterilizasyon Ünitesi',      150),
        ('Temizlik Hizmetleri',        160),
        ('Güvenlik',                   170),
        ('Mutfak / Yemekhane',         180),
        ('Halkla İlişkiler / Pazarlama', 190),
        ('Eğitim Birimi',              200)
      ) as x(ad, sira)
     where not exists (select 1 from public.departman d where d.ad = x.ad);
    get diagnostics v_bolum = row_count;

    -- --------------------------------------- kurumun kendi gorev tanimlari ----
    if to_regclass('public._yedek_personel_gorev_559') is not null then
        insert into public.personel_gorev (kod, ad, departman_id, durum, sira, ekleyen)
        select '', btrim(y.ad), 0, 1, 0, 0
          from public._yedek_personel_gorev_559 y
         where btrim(y.ad) <> ''
           and not exists (select 1 from public.personel_gorev g
                            where public.fn_ara_metin(g.ad) = public.fn_ara_metin(btrim(y.ad)));
        get diagnostics v_gorev = row_count;
    end if;

    raise notice '568: % idari bolum, % gorev eklendi.', v_bolum, coalesce(v_gorev, 0);
end $$;

-- Geri gelen gorevlerde yazim: "müdür" -> "Müdür" (563'teki bicim kurali).
update public.personel_gorev
   set ad = public.fn_tr_baslik(ad)
 where ad <> public.fn_tr_baslik(ad)
   and coalesce(kod, '') = '';
