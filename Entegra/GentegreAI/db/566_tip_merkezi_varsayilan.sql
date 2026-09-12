-- =====================================================================
--  566_tip_merkezi_varsayilan.sql
--  BÖLÜM ve GÖREV listeleri ORTALAMA BİR TIP MERKEZİNE göre daraltılır.
--
--  Kullanıcı: "bölüm ve görevde ortalama tıp merkezinde bulunanları aktif,
--  diğerlerini pasif yap."
--
--  SKRS listeleri ülkedeki BÜTÜN klinik ve branşları sayıyor (106 bölüm,
--  165 görev): üniversite kürsüleri, askeri sağlık, yoğun bakım çeşitleri,
--  AMATEM, COVID aşı birimleri… Tıp merkezinde bunların çoğu yok ve her
--  ekranda listeyi uzatıyor.
--
--  KAYIT SİLİNMEZ, PASİFE ALINIR: kurum bir branşı sonradan açarsa kart
--  ekranından aktif eder - SKRS kodu, ağaçtaki yeri ve geçmiş kayıtların
--  bağı korunur. Aktif/pasif zaten listelerin standart cip süzgeci.
--
--  AKTİF SET (tıp merkezinin gündelik kadrosu):
--    poliklinikler  - dahiliye, kardiyoloji, göğüs, nöroloji, psikiyatri,
--                     endokrin, gastroenteroloji, nefroloji, dermatoloji,
--                     fizik tedavi, çocuk, kadın doğum,
--    cerrahi        - genel cerrahi, ortopedi, KBB, göz, üroloji, plastik,
--                     anesteziyoloji (girişim/sedasyon için gerekli),
--    tanı           - radyoloji, tıbbi biyokimya, tıbbi mikrobiyoloji,
--                     tıbbi patoloji,
--    diğer          - acil, aile hekimliği, beslenme ve diyet.
--
--  PASİF KALANLAR: bütün yoğun bakımlar, çocuk ve cerrahi yan dalları,
--  transplantasyon, askeri/adli/halk sağlığı, temel bilimler (anatomi,
--  fizyoloji, farmakoloji, histoloji, embriyoloji), AMATEM/ÇEMATEM, COVID
--  aşı birimleri, palyatif bakım, hiperbarik, sualtı hekimliği…
--
--  ÜST BAŞLIKLAR (ağaç düğümleri) AKTİF KALIR: altında aktif bölüm varsa
--  başlık da görünmeli, yoksa ağaç kopuk gözükür.
--
--  TEKRAR ÇALIŞTIRILABİLİR: karar ada bakar, id'ye değil.
-- =====================================================================

do $$
declare
    -- Desen `fn_ara_metin` ciktisina gore YAZILIR: kucuk harf + ASCII
    --   ("iç hastalıkları" -> "ic hastaliklari").
    v_aktif text :=
        'acil tip|^acil$|aile hekimligi|anesteziyoloji'
        || '|beslenme|diyet'
        || '|ic hastaliklari|dahiliye'
        || '|kardiyoloji'
        || '|gogus hastaliklari'
        || '|noroloji'
        || '|ruh sagligi|psikiyatri'
        || '|endokrin'
        || '|gastroenteroloji|gastroentereolji|gastroentroloji'
        || '|nefroloji'
        || '|deri ve zuhrevi|dermatoloji'
        || '|fiziksel tip|fizik tedavi'
        || '|cocuk sagligi'
        || '|kadin hastaliklari|kadin dogum'
        || '|genel cerrahi'
        || '|ortopedi'
        || '|kulak burun bogaz'
        || '|goz hastaliklari'
        || '|uroloji'
        || '|plastik'
        || '|radyoloji'
        || '|tibbi biyokimya|tibbi mikrobiyoloji|tibbi patoloji';
    -- Aktif desene uysa bile TIP MERKEZINDE OLMAYANLAR (yan dal / yogun
    --   bakim / cocuk alt branslari): "cocuk kardiyolojisi" aktif desene
    --   "kardiyoloji" ile takiliyor.
    v_haric text :=
        'yogun bakim|cocuk (?!sagligi)|askeri|adli|palyatif|hiperbarik'
        || '|sualti|transplantasyon|nakli|amatem|cematem|covid'
        || '|anatomi|fizyoloji|farmakoloji|histoloji|embriyoloji|biyofizik'
        || '|halk sagligi|is ve meslek|spor hekimligi|havacilik';
    v_b_aktif integer; v_b_pasif integer;
    v_g_aktif integer; v_g_pasif integer;
begin
    -- --------------------------------------------------------- BOLUMLER ----
    update public.departman d
       set durum = case
             -- Ust basliklar (agac dugumu, kodu yok) her zaman acik kalir.
             when coalesce(d.kod, '') = '' then 1
             when public.fn_ara_metin(d.ad) ~ v_haric then 0
             when public.fn_ara_metin(d.ad) ~ v_aktif then 1
             else 0 end;

    select count(*) filter (where durum = 1), count(*) filter (where durum = 0)
      into v_b_aktif, v_b_pasif from public.departman;

    -- ---------------------------------------------------------- GOREVLER ----
    update public.personel_gorev g
       set durum = case
             when public.fn_ara_metin(g.ad) ~ v_haric then 0
             when public.fn_ara_metin(g.ad) ~ v_aktif then 1
             else 0 end;

    select count(*) filter (where durum = 1), count(*) filter (where durum = 0)
      into v_g_aktif, v_g_pasif from public.personel_gorev;

    raise notice '566: bolum % aktif / % pasif · gorev % aktif / % pasif.',
                 v_b_aktif, v_b_pasif, v_g_aktif, v_g_pasif;
end $$;
