-- =====================================================================
--  554_stok_kategori_agaci.sql
--  STOK KATEGORİ AĞACI: "Tıbbi Malzeme" altında SUT EK-3 branş dalları.
--
--  Kullanıcı: "stok için de yap" (radyoloji/laboratuvar alt kategorilerinin
--  ardından).
--
--  DURUM: 4.292 stok kartının TAMAMI kategorisiz (`kategori = 0`) ve
--  `kategori` tablosunda tur = 1 (stok) hiç satır yok. Stok kartındaki
--  kategori ağacı combosu (544) bu yüzden boş açılıyor, listede "Kategori"
--  kolonu boş.
--
--  KAYNAK: kalemler SUT EK-3 (tıbbi malzeme) listesinden gelmiş ve KOD ÖNEKİ
--  branşı söylüyor - laboratuvarın tersine burada kod GERÇEK bir sinyal:
--      OP ortez/protez · AP artroplasti · AE artroskopi · TV travma ·
--      KV kalp-damar cerrahisi · KR girişimsel kardiyoloji · KN nöroşirurji ·
--      GZ göz · GS gastroenteroloji · GH göğüs · UR üroloji · KB KBB ·
--      KD kadın doğum · NF nefroloji/diyaliz · AN anestezi · AG allogreft ·
--      SG sentetik greft · HG hemostatik/greft · HO hematoloji-onkoloji ·
--      TE transfüzyon · A1 genel tıbbi sarf.
--
--  ÖNEKİ ÇÖZÜLEMEYENLER ("OR", "DO", "10", "M2") ada bakılarak tahmin
--  EDİLMEZ: "Diğer Tıbbi Malzeme" dalında görünür kalır. Yanlış dala atmak,
--  sınıflandırmamaktan kötüdür - kullanıcı kartta elle taşıyabilir.
--
--  TEKRAR ÇALIŞTIRILABİLİR: kategoriler `kod` ile eşleşir; atama yalnız
--  kategorisi BOŞ (0/null) olan kartlara uygulanır - elle taşınan kart
--  yerinde kalır.
-- =====================================================================

do $$
declare
    v_ust  integer;
    v_dal  record;
    v_sayi integer;
begin
    -- ------------------------------------------------------- ust kategori ----
    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select 'STK.TIBBI', 'Tıbbi Malzeme', null, 1, 1
     where not exists (select 1 from public.kategori where kod = 'STK.TIBBI' and tur = 1);

    select id into v_ust from public.kategori where kod = 'STK.TIBBI' and tur = 1 limit 1;

    -- ------------------------------------------------------- brans dallari ----
    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select x.kod, x.ad, v_ust, 1, 1
      from (values
        ('STK.A1',  'Tıbbi Sarf (Genel)'),
        ('STK.AE',  'Artroskopi / Endoskopik Cerrahi'),
        ('STK.AG',  'Allogreft / Doku'),
        ('STK.AN',  'Anestezi / Yoğun Bakım'),
        ('STK.AP',  'Artroplasti (Eklem Protezi)'),
        ('STK.GH',  'Göğüs Hastalıkları'),
        ('STK.GS',  'Gastroenteroloji'),
        ('STK.GZ',  'Göz'),
        ('STK.HG',  'Hemostatik / Greft'),
        ('STK.HO',  'Hematoloji / Onkoloji'),
        ('STK.KB',  'Kulak Burun Boğaz'),
        ('STK.KD',  'Kadın Hastalıkları / Doğum'),
        ('STK.KN',  'Nöroşirurji'),
        ('STK.KR',  'Girişimsel Kardiyoloji'),
        ('STK.KV',  'Kalp - Damar Cerrahisi'),
        ('STK.NF',  'Nefroloji / Diyaliz'),
        ('STK.OP',  'Ortez / Protez'),
        ('STK.TE',  'Transfüzyon'),
        ('STK.TV',  'Travma / Fiksasyon'),
        ('STK.SG',  'Sentetik Greft'),
        ('STK.UR',  'Üroloji'),
        ('STK.DIGER', 'Diğer Tıbbi Malzeme')
      ) as x(kod, ad)
     where not exists (select 1 from public.kategori k where k.kod = x.kod and k.tur = 1);

    -- ------------------------------------------------------------- atama ----
    for v_dal in
        select * from (values
            ('A1', 'STK.A1'), ('AE', 'STK.AE'), ('AG', 'STK.AG'), ('AN', 'STK.AN'),
            ('AP', 'STK.AP'), ('GH', 'STK.GH'), ('GS', 'STK.GS'), ('GZ', 'STK.GZ'),
            ('HG', 'STK.HG'), ('HO', 'STK.HO'), ('KB', 'STK.KB'), ('KD', 'STK.KD'),
            ('KN', 'STK.KN'), ('KR', 'STK.KR'), ('KV', 'STK.KV'), ('NF', 'STK.NF'),
            ('OP', 'STK.OP'), ('TE', 'STK.TE'), ('TV', 'STK.TV'), ('SG', 'STK.SG'),
            ('UR', 'STK.UR')
        ) as t(onek, kat_kod)
    loop
        update public.stok s
           set kategori = (select k.id from public.kategori k
                            where k.kod = v_dal.kat_kod and k.tur = 1 limit 1)
         where coalesce(s.kategori, 0) = 0
           and s.kod like v_dal.onek || '%';
    end loop;

    -- Kalanlar: oneki cozulemeyen kalemler gorunur bir dalda toplanir.
    update public.stok s
       set kategori = (select k.id from public.kategori k
                        where k.kod = 'STK.DIGER' and k.tur = 1 limit 1)
     where coalesce(s.kategori, 0) = 0;

    select count(*) into v_sayi
      from public.stok s join public.kategori k on k.id = s.kategori where k.tur = 1;
    raise notice '554: % stok karti kategori agacina baglandi.', v_sayi;
end $$;
