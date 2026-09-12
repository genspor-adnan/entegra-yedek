-- =====================================================================
--  569_idari_gorevler.sql
--  İDARİ GÖREV (kadro) tanımları eklenir - "Muhasebe Müdürü vb."
--
--  Kullanıcı: "idari görevleri de ekle, Muhasebe Müdürü vb."
--
--  568 idari BÖLÜMLERİ açtı ve kurumun eski kadro tanımlarını (Hemşire,
--  Tıbbi Sekreter, Muhasebe, IT Destek…) yedekten geri getirdi. O liste
--  hastanenin idari kadrosunu karşılamıyor: başhekimlik, müdürlük, kalite,
--  faturalama, teknik servis gibi birimlerin görev adları yoktu.
--
--  KOD BOŞ: bunlar SKRS branşı değil, kurumun kadro tanımı. Branş (kodlu)
--  satırlarla aynı listede dururlar; ayrım kodun dolu olup olmamasıdır.
--
--  BÖLÜME BAĞLANMAZ (`departman_id = 0`): aynı görev birden çok birimde
--  geçebilir ("Sekreter", "Sorumlu"); bağımsız görev her bölümde seçilebilir.
--
--  TEKRAR ÇALIŞTIRILABİLİR: ada göre eşleşir, var olan eklenmez.
-- =====================================================================

do $$
declare v_sayi integer;
begin
    insert into public.personel_gorev (kod, ad, departman_id, durum, sira, ekleyen)
    select '', x.ad, 0, 1, 0, 0
      from (values
        -- yonetim
        ('Başhekim'), ('Başhekim Yardımcısı'), ('Mesul Müdür'),
        ('Hastane Müdürü'), ('Hastane Müdür Yardımcısı'), ('İdari Müdür'),
        -- mali
        ('Muhasebe Müdürü'), ('Muhasebe Sorumlusu'), ('Muhasebe Elemanı'),
        ('Mali İşler Sorumlusu'), ('Finans Sorumlusu'),
        ('Faturalama Sorumlusu'), ('Faturalama Görevlisi'),
        ('Provizyon Görevlisi'), ('Tahsilat Görevlisi'), ('Vezne Görevlisi'),
        -- satinalma / lojistik
        ('Satınalma Müdürü'), ('Satınalma Sorumlusu'),
        ('Depo Sorumlusu'), ('Ambar Görevlisi'), ('Şoför'),
        -- insan kaynaklari / egitim
        ('İnsan Kaynakları Müdürü'), ('İnsan Kaynakları Uzmanı'),
        ('Eğitim Sorumlusu'), ('Bordro Sorumlusu'),
        -- hasta hizmetleri
        ('Hasta Kabul Sorumlusu'), ('Danışma Görevlisi'),
        ('Çağrı Merkezi Operatörü'), ('Santral Görevlisi'),
        ('Hasta Hakları Sorumlusu'), ('Hasta İlişkileri Sorumlusu'),
        -- kalite / arsiv
        ('Kalite Direktörü'), ('Kalite Sorumlusu'),
        ('Arşiv Sorumlusu'), ('Arşiv Görevlisi'),
        -- teknik / destek
        ('Bilgi İşlem Müdürü'), ('Bilgi İşlem Sorumlusu'), ('Sistem Yöneticisi'),
        ('Teknik Servis Sorumlusu'), ('Biyomedikal Teknikeri'),
        ('Sterilizasyon Personeli'), ('Temizlik Personeli'),
        ('Güvenlik Görevlisi'), ('Aşçı'), ('Yemekhane Görevlisi'),
        -- tanitim
        ('Halkla İlişkiler Sorumlusu'), ('Pazarlama Sorumlusu'),
        ('Sağlık Turizmi Sorumlusu')
      ) as x(ad)
     where not exists (select 1 from public.personel_gorev g
                        where public.fn_ara_metin(g.ad) = public.fn_ara_metin(x.ad));
    get diagnostics v_sayi = row_count;
    raise notice '569: % idari gorev eklendi.', v_sayi;
end $$;
