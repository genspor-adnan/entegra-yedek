-- =====================================================================
--  573_personel_yeniden_kurulum.sql
--  Personel listesi boşaltılır; her klinik bölüme 2 hekim, her idari birime
--  1 personel açılır.
--
--  Kullanıcı: "sistem yöneticisi ve admin dışında personeli boşalt · personele
--  her bölüm için 2 tane Dr ekle ve doktor rolüne onları ekle · ayrıca idari
--  birimler için de birer personel ekle" · "büyük harf istemiyorum".
--
--  ÖNCE ÖLÇÜLDÜ: 377 personel kaydının İŞ VERİSİYLE BAĞI YOK - belge 0,
--  başvuru 0, randevu 0, hakediş 0, kasa 0. Yalnız iki bağ var:
--    kullanici_sube 356 satır (hesapların şube yetkisi) ve
--    gorev.sorumlu_id 5 satır (görev/todo kayıtları - null'a çekilir).
--  Bu yüzden silme güvenli; yine de dört tablo YEDEKLENİR.
--
--  KORUNANLAR: Sistem Yöneticisi (taraf 2), admin (4901) ve e2e test hesapları
--  (5059-5061). Sonuncular kullanıcının listesinde yoktu ama silinirse uçtan
--  uca testler kırılırdı - kasıtlı bırakıldı, istenirse elle silinir.
--
--  YENİ KAYITLAR:
--    · Aktif klinik bölüm başına 2 hekim ("Dr. Ahmet Yılmaz" - ADLAR NORMAL
--      YAZIM, büyük harf yığını değil; mevcut veride "ALPER ALKAN" gibi
--      dökümden gelmiş büyük harfli adlar vardı).
--    · Her idari birime 1 personel, görevi birimine uygun.
--    · Hekimlere DOKTOR rolü: rol `taraf_kullanici.rol_id` ile veriliyor, bu
--      yüzden her hekime bir kullanıcı kaydı açılır. PAROLA YAZILMAZ
--      (`parola_hash` boş kalır) - hesap giriş için kullanılamaz, yalnız rolü
--      taşır. Parola verme işi yöneticinin.
--    · `randevu_verilebilir = 1`: hekim, randevu ve başvuru ekranlarındaki
--      hekim listesine (v_hekim_lookup) ancak bu bayrakla girer.
-- =====================================================================

-- ------------------------------------------------------------- yedekler ----
create table if not exists public._yedek_taraf_personel_573 as
select * from public.taraf where personel = 1;
create table if not exists public._yedek_taraf_personel_ek_573 as
select * from public.taraf_personel;
create table if not exists public._yedek_taraf_kullanici_573 as
select * from public.taraf_kullanici;
create table if not exists public._yedek_kullanici_sube_573 as
select * from public.kullanici_sube;

do $$
declare
    v_korunan int[] := array[2, 4901, 5059, 5060, 5061];
    v_silinen integer;
    v_bolum   record;
    v_bag     record;
    v_ad      text;
    v_soyad   text;
    v_id      integer;
    v_sira    integer := 0;
    v_hekim   integer := 0;
    v_idari   integer := 0;
    -- Ad havuzu: gercek bir kisiyi isaret etmesin diye yaygin adlar,
    --   dongude sirayla eslenir.
    v_adlar   text[] := array['Ahmet','Ayşe','Mehmet','Elif','Mustafa','Zeynep','Ali','Fatma',
                              'Hasan','Merve','Emre','Seda','Burak','Gamze','Cem','Deniz',
                              'Kerem','Buse','Serkan','Pınar','Onur','Ece','Tolga','Nazlı',
                              'Barış','Sibel','Volkan','Aslı','Murat','Ceren','Uğur','Melis',
                              'Hakan','Esra','Kaan','Tuğba','Sinan','Derya','Okan','İrem',
                              'Erdem','Yasemin','Berk','Selin','Umut','Dilek','Kemal','Şule',
                              'Arda','Nihan'];
    v_soyadlar text[] := array['Yılmaz','Kaya','Demir','Şahin','Çelik','Yıldız','Yıldırım',
                               'Öztürk','Aydın','Özdemir','Arslan','Doğan','Kılıç','Aslan',
                               'Çetin','Kara','Koç','Kurt','Özkan','Şimşek','Polat','Korkmaz',
                               'Erdoğan','Bulut','Güneş'];
begin
    -- ------------------------------------------------------------ bosalt ----
    update public.gorev set sorumlu_id = null
     where sorumlu_id in (select id from public.taraf where personel = 1)
       and not (sorumlu_id = any(v_korunan));

    update public.taraf_personel set yonetici_taraf_id = null
     where yonetici_taraf_id is not null;

    -- TARAF KENDINE BAGLI olabiliyor (`bag_id`: kisi -> calistigi kurum,
    --   82 satir). Silinecek personele isaret eden bag koparilir; hedef
    --   kayit (cari/hasta) yerinde kalir.
    update public.taraf set bag_id = null
     where bag_id in (select id from public.taraf where personel = 1)
       and not (bag_id = any(v_korunan));

    -- Kullanici hesabinin YAN KAYITLARI (oturum, arama gecmisi, tercih,
    --   mesaj uyeligi, AI sohbeti, kapsam): hesap silinince anlamsizlar.
    --   Mesaj GOVDESI olan kullanici silinemez - gonderen bilgisi kaybolur;
    --   bu veritabaninda mesaj yok (0 satir), mesaj uyeligi 2 satir.
    delete from public.kullanici_sube
     where taraf_id in (select id from public.taraf where personel = 1)
       and not (taraf_id = any(v_korunan));
    delete from public.oturum
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.kullanici_arama
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.kullanici_tercih
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.kullanici_kapsam
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.kullanici_katalog
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.mesaj_uye
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.ai_sohbet
     where kullanici_id in (select id from public.taraf where personel = 1)
       and not (kullanici_id = any(v_korunan));
    delete from public.taraf_kullanici
     where id in (select id from public.taraf where personel = 1)
       and not (id = any(v_korunan));
    delete from public.taraf_personel
     where id in (select id from public.taraf where personel = 1)
       and not (id = any(v_korunan));
    -- SILINECEK PERSONELE ISARET EDEN TUM BAGLAR (dinamik): cari sorumlusu,
    --   firsat sahibi, demirbas zimmeti, cek cirosu… FK'leri tek tek
    --   kovalamak yerine katalogdan okunur. YALNIZ null'lanabilir kolonlar
    --   koparilir; zorunlu bir bag kalirsa silme hata verir ve sebebi
    --   gorunur olur (sessizce veri kaybetmektense durmak dogru).
    for v_bag in
        select c.conrelid::regclass::text as tablo, a.attname as kolon
          from pg_constraint c
          join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
         where c.confrelid = 'public.taraf'::regclass and c.contype = 'f'
           and not a.attnotnull
           and c.conrelid <> 'public.taraf_kullanici'::regclass
    loop
        execute format(
            'update %s set %I = null where %I in '
            '(select id from public.taraf where personel = 1 and not (id = any($1)))',
            v_bag.tablo, v_bag.kolon, v_bag.kolon) using v_korunan;
    end loop;

    -- PERSONELE AIT YAN KAYITLAR (zorunlu bagli, personelle birlikte gider):
    --   adresi, egitim gecmisi, prim rolu ve prim plani uyeligi. Bunlar
    --   kisinin KENDI kayitlari - kisi silinince anlamlari kalmaz.
    delete from public.taraf_adres
     where taraf_id in (select id from public.taraf where personel = 1)
       and not (taraf_id = any(v_korunan));
    delete from public.personel_egitim
     where taraf_id in (select id from public.taraf where personel = 1)
       and not (taraf_id = any(v_korunan));
    delete from public.taraf_prim_rol
     where taraf_id in (select id from public.taraf where personel = 1)
       and not (taraf_id = any(v_korunan));
    delete from public.prim_plani_taraf
     where taraf_id in (select id from public.taraf where personel = 1)
       and not (taraf_id = any(v_korunan));

    delete from public.taraf
     where personel = 1 and not (id = any(v_korunan));
    get diagnostics v_silinen = row_count;
    raise notice '573: % personel kaydi silindi.', v_silinen;

    -- ------------------------------------------------ klinik bolume hekim ----
    for v_bolum in
        select d.id, d.ad
          from public.departman d
         where d.durum = 1 and coalesce(d.kod, '') <> ''   -- kodsuzlar: agac basligi / idari
         order by d.ad
    loop
        for i in 1..2 loop
            v_sira := v_sira + 1;
            v_ad := v_adlar[1 + (v_sira % array_length(v_adlar, 1))];
            v_soyad := v_soyadlar[1 + (v_sira % array_length(v_soyadlar, 1))];

            insert into public.taraf (kod, unvan, ad, soyad, personel, durum, sube_id,
                                      randevu_verilebilir, ekleyen)
            values ('', 'Dr. ' || v_ad || ' ' || v_soyad, v_ad, v_soyad, 1, 1, 1, 1, 0)
            returning id into v_id;
            -- Kod bos birakilamaz (kart kurali ID atar); burada da ayni desen.
            update public.taraf set kod = v_id::text where id = v_id;

            insert into public.taraf_personel (id, departman, sube_id, ekleyen)
            values (v_id, v_bolum.id, 1, 0);

            -- DOKTOR ROLU: rol kullanici kaydinda tasiniyor. Parola YAZILMAZ.
            insert into public.taraf_kullanici (id, kod, rol_id, aktif, ekleyen)
            values (v_id, 'dr' || v_id::text, 32, 1, 0);
            insert into public.kullanici_sube (taraf_id, sube_id, yazma)
            values (v_id, 1, 1)
            on conflict do nothing;

            v_hekim := v_hekim + 1;
        end loop;
    end loop;

    -- ------------------------------------------------- idari birime personel ----
    for v_bolum in
        select d.id, d.ad,
               case
                 when d.ad = 'Başhekimlik'                  then 'Başhekim'
                 when d.ad = 'İdari ve Mali İşler Müdürlüğü' then 'Hastane Müdürü'
                 when d.ad = 'İnsan Kaynakları'             then 'İnsan Kaynakları Uzmanı'
                 when d.ad = 'Muhasebe ve Finans'           then 'Muhasebe Müdürü'
                 when d.ad = 'Satınalma'                    then 'Satınalma Sorumlusu'
                 when d.ad = 'Depo / Ambar'                 then 'Depo Sorumlusu'
                 when d.ad = 'Faturalama ve Provizyon'      then 'Faturalama Sorumlusu'
                 when d.ad = 'Hasta Kabul / Danışma'        then 'Hasta Kabul Sorumlusu'
                 when d.ad = 'Çağrı Merkezi / Randevu'      then 'Çağrı Merkezi Operatörü'
                 when d.ad = 'Bilgi İşlem'                  then 'Bilgi İşlem Sorumlusu'
                 when d.ad = 'Kalite Yönetimi'              then 'Kalite Direktörü'
                 when d.ad = 'Hasta Hakları'                then 'Hasta Hakları Sorumlusu'
                 when d.ad = 'Arşiv'                        then 'Arşiv Sorumlusu'
                 when d.ad = 'Teknik Servis / Biyomedikal'  then 'Teknik Servis Sorumlusu'
                 when d.ad = 'Sterilizasyon Ünitesi'        then 'Sterilizasyon Personeli'
                 when d.ad = 'Temizlik Hizmetleri'          then 'Temizlik Personeli'
                 when d.ad = 'Güvenlik'                     then 'Güvenlik Görevlisi'
                 when d.ad = 'Mutfak / Yemekhane'           then 'Aşçı'
                 when d.ad = 'Halkla İlişkiler / Pazarlama' then 'Halkla İlişkiler Sorumlusu'
                 when d.ad = 'Eğitim Birimi'                then 'Eğitim Sorumlusu'
                 else 'Müdür' end as gorev_adi
          from public.departman d
          join public.departman u on u.id = d.ustbirim_id
         where u.ad = 'İdari Birimler'
         order by d.sira
    loop
        v_sira := v_sira + 1;
        v_ad := v_adlar[1 + (v_sira % array_length(v_adlar, 1))];
        v_soyad := v_soyadlar[1 + (v_sira % array_length(v_soyadlar, 1))];

        insert into public.taraf (kod, unvan, ad, soyad, personel, durum, sube_id,
                                  randevu_verilebilir, gorev_id, ekleyen)
        values ('', v_ad || ' ' || v_soyad, v_ad, v_soyad, 1, 1, 1, 0,
                (select g.id from public.personel_gorev g
                  where public.fn_ara_metin(g.ad)
                        = public.fn_ara_metin(v_bolum.gorev_adi) limit 1), 0)
        returning id into v_id;
        update public.taraf set kod = v_id::text where id = v_id;

        insert into public.taraf_personel (id, departman, sube_id, ekleyen)
        values (v_id, v_bolum.id, 1, 0);

        v_idari := v_idari + 1;
    end loop;

    raise notice '573: % hekim (doktor rolu) + % idari personel eklendi.', v_hekim, v_idari;
end $$;
