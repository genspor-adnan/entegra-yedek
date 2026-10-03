-- =====================================================================
--  940_personel_unvan_yalniz_onek.sql
--  PERSONELDE taraf.unvan YALNIZ ÜNVAN (kullanıcı: "personelde ünvan tam
--  adı tutmasın, sadece Dr. veya Prof.Dr. gibi olsun" · "yeni kolon açma,
--  taraf.unvan'ı kullan" · "dış dr. için de aynı olsun").
--
--  Önceden personel / dış doktor kaydında unvan "Dr. Alim Sarı" gibi TAM
--  addı (306: önek + ad + soyad). Artık yalnız ünvan ("Dr.", "Prof.Dr.") ya
--  da boş. Kurum / şirket / hasta kayıtlarında unvan değişmez - orada unvan
--  kaydın kendi adıdır.
--
--  GÖRÜNEN AD TEK YERDEN: public.fn_taraf_ad(unvan, ad, soyad)
--    * ad + soyad boş (kurum, şirket, sistem hesabı) -> unvan
--    * unvan boş                                      -> ad + soyad
--    * unvan yalnız noktalı kısaltma (Dr., Prof.Dr.)  -> unvan + ad + soyad
--    * diğer (hasta, şirket, henüz ayrıştırılmamış)   -> unvan
--  Adı taraf.unvan'dan okuyan görünümler ve fonksiyonlar bu ifadeye geçer;
--  tip birebir korunur (varchar(120)), kolon adları değişmez.
--
--  IMMUTABLE: tabloya bakmaz, indekslenebilir. Liste araması
--  fn_ara_metin(<kolon ifadesi>) kullandığı için aynı ifadeye trigram
--  indeksi eklenir - hasta aramasında eski unvan indeksinin karşılığı.
--
--  VERİ ONARIMI yalnız KANITLANABİLİR satırlarda: unvan TAM OLARAK
--  [önek +] ad + soyad olan personel. Elle farklı yazılmış unvan
--  dokunulmadan kalır (görünen ad onu aynen gösterir). Eski değerler
--  _yedek_940_personel_unvan tablosuna yazılır.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_taraf_ad(p_unvan varchar, p_ad varchar, p_soyad varchar)
returns varchar
language sql immutable parallel safe as $$
    select case
        when coalesce(btrim(p_ad), '') = '' and coalesce(btrim(p_soyad), '') = ''
            then coalesce(p_unvan, '')
        when coalesce(btrim(p_unvan), '') = ''
            then btrim(coalesce(nullif(btrim(p_ad), ''), '')
                       || coalesce(' ' || nullif(btrim(p_soyad), ''), ''))
        when btrim(p_unvan) ~ '^([[:alpha:]]{1,6}\.)+$'
            then btrim(p_unvan)
                 || coalesce(' ' || nullif(btrim(p_ad), ''), '')
                 || coalesce(' ' || nullif(btrim(p_soyad), ''), '')
        else p_unvan
    end
$$;

comment on function public.fn_taraf_ad(varchar, varchar, varchar) is
  'Tarafin gorunen adi (940): personelde unvan yalniz onek (Dr.), ad ayri.';

-- Arama indeksi: liste aramasi fn_ara_metin(fn_taraf_ad(...)::varchar(120)).
create index if not exists ix_taraf_gorunen_ad_ara on public.taraf
    using gin (public.fn_ara_metin((public.fn_taraf_ad(unvan, ad, soyad)::character varying(120))::text) gin_trgm_ops);

-- ---------------------------------------------------------------------
--  Görünen adı okuyan görünümler ve fonksiyonlar (otomatik üretildi:
--  <taraf takma adı>.unvan -> public.fn_taraf_ad(...)::varchar(120)).
-- ---------------------------------------------------------------------
create or replace view public.v_isg_ziyaret as
 SELECT z.id,
    z.firma_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS firma_adi,
    z.tarih,
    z.saat_bas,
    z.saat_bit,
    z.sure_dk,
    z.tur,
    kt.ad AS tur_adi,
    z.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    z.katilanlar,
    z.bolumler,
    z.gozlem,
    z.oneri,
    z.termin,
    z.sorumlu,
    z.egitim,
    z.defter_sayfa,
    z.imza_hekim,
    z.imza_uzman,
    z.imza_isveren,
    z.imza_hekim + z.imza_uzman + z.imza_isveren AS imza_sayisi,
    z.sonraki_ziyaret,
        CASE
            WHEN z.termin IS NOT NULL AND z.termin < CURRENT_DATE THEN 1
            ELSE 0
        END AS termin_gecti,
    z.aciklama,
    z.sube_id,
    z.ekleme_tarihi
   FROM isg_ziyaret z
     JOIN isg_firma f ON f.id = z.firma_id
     JOIN taraf t ON t.id = f.taraf_id
     LEFT JOIN taraf h ON h.id = z.hekim_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'isg.ziyaret_tur'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = z.tur;

create or replace view public.v_isg_firma_lookup as
 SELECT f.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    f.durum AS aktif
   FROM isg_firma f
     JOIN taraf t ON t.id = f.taraf_id;

create or replace view public.v_isg_firma as
 SELECT f.id,
    f.taraf_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS firma_adi,
    COALESCE(t.kod, ''::character varying) AS firma_kodu,
    f.sgk_sicil,
    f.nace,
    f.nace_ad,
    f.tehlike,
    kt.ad AS tehlike_adi,
    f.calisan_sayisi,
    ( SELECT count(*) AS count
           FROM isg_calisan c
          WHERE c.firma_id = f.id AND c.durum = 1) AS aktif_calisan,
    f.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    f.isg_uzman_id,
    COALESCE(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::character varying(120), ''::character varying) AS isg_uzman_adi,
    f.dsp_id,
    COALESCE(public.fn_taraf_ad(d.unvan, d.ad, d.soyad)::character varying(120), ''::character varying) AS dsp_adi,
    fn_isg_aylik_dk(f.id) AS plan_dk,
    f.aylik_dk,
    f.sozlesme_bas,
    f.sozlesme_bit,
    f.ziyaret_sikligi,
    f.calisma,
    f.gece_calisan,
    f.isg_kurulu,
    f.yetkili,
    f.yetkili_tel,
    f.adres,
    f.aciklama,
    f.durum,
        CASE f.durum
            WHEN 1 THEN 'Aktif'::text
            ELSE 'Pasif'::text
        END AS durum_adi,
    f.sube_id,
    f.ekleme_tarihi,
    ( SELECT count(*) AS count
           FROM isg_olay o
          WHERE o.firma_id = f.id AND o.tur = 1 AND o.tarih >= date_trunc('year'::text, now())) AS kaza_yil,
    ( SELECT count(*) AS count
           FROM isg_calisan c
          WHERE c.firma_id = f.id AND c.durum = 1 AND (COALESCE(( SELECT max(m.tarih) AS max
                   FROM isg_muayene m
                  WHERE m.calisan_id = c.id AND m.durum = 2), c.ise_giris, CURRENT_DATE - 1) + make_interval(months => fn_isg_periyot_ay(c.id))) < (CURRENT_DATE + 30)) AS vade_yaklasan,
    ( SELECT COALESCE(sum(z.sure_dk), 0::bigint) + COALESCE(sum(0), 0::bigint)
           FROM isg_ziyaret z
          WHERE z.firma_id = f.id AND date_trunc('month'::text, z.tarih::timestamp with time zone) = date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)) AS ziyaret_dk_ay,
    ( SELECT COALESCE(sum(m.sure_dk), 0::bigint) AS "coalesce"
           FROM isg_muayene m
          WHERE m.firma_id = f.id AND m.durum = 2 AND date_trunc('month'::text, m.tarih::timestamp with time zone) = date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)) AS muayene_dk_ay
   FROM isg_firma f
     JOIN taraf t ON t.id = f.taraf_id
     LEFT JOIN taraf h ON h.id = f.hekim_id
     LEFT JOIN taraf u ON u.id = f.isg_uzman_id
     LEFT JOIN taraf d ON d.id = f.dsp_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'isg.tehlike'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = f.tehlike;

create or replace view public.v_cagri as
 SELECT c.id,
    c.kanal,
    kk.ad AS kanal_adi,
    c.yon,
        CASE c.yon
            WHEN 1 THEN 'Gelen'::text
            ELSE 'Giden'::text
        END AS yon_adi,
    c.arayan_no,
    c.aranan_no,
    c.taraf_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (COALESCE(t.ad, ''::character varying)::text || ' '::text) || COALESCE(t.soyad, ''::character varying)::text), ''::text), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text) AS taraf_adi,
    COALESCE(t.hasta::integer, 0) AS hasta,
    COALESCE(t.musteri::integer, 0) AS musteri,
    COALESCE(t.personel::integer, 0) AS personel,
    c.kuyruk_id,
    COALESCE(q.ad, ''::character varying) AS kuyruk_adi,
    c.agent_id,
    COALESCE(ag.ad, ''::character varying) AS agent_adi,
    c.dis_ref,
    c.baslama,
    c.cevap,
    c.bitis,
    c.bekleme_sn,
    c.sure_sn,
    c.islem_sonrasi_sn,
    c.konu_id,
    COALESCE(k.ad, ''::character varying) AS konu_adi,
    c.alt_konu_id,
    COALESCE(ak.ad, ''::character varying) AS alt_konu_adi,
    c.sonuc,
    COALESCE(ks.ad, ''::character varying) AS sonuc_adi,
    c.oncelik,
    c.notu,
    c.kayit_url,
    c.durum,
    kd.ad AS durum_adi,
    c.kampanya_id,
    COALESCE(kp.ad, ''::character varying) AS kampanya_adi,
    c.kampanya_kisi_id,
    c.geri_arama,
    c.geri_arama_tamam,
    c.gorev_id,
    c.memnuniyet,
    c.kalite_puan,
        CASE
            WHEN c.cevap IS NULL THEN 0
            WHEN c.bekleme_sn <= COALESCE(q.sla_sn, 20) THEN 1
            ELSE 0
        END AS sla_icinde,
    ( SELECT count(*) AS count
           FROM cagri_ilgili i
          WHERE i.cagri_id = c.id) AS ilgili_sayisi,
    c.sube_id,
    c.ekleyen,
    c.ekleme_tarihi
   FROM cagri c
     LEFT JOIN taraf t ON t.id = c.taraf_id
     LEFT JOIN cagri_kuyruk q ON q.id = c.kuyruk_id
     LEFT JOIN v_kullanici_lookup ag ON ag.id = c.agent_id
     LEFT JOIN cagri_konu k ON k.id = c.konu_id
     LEFT JOIN cagri_konu ak ON ak.id = c.alt_konu_id
     LEFT JOIN cagri_kampanya kp ON kp.id = c.kampanya_id
     LEFT JOIN kod_liste lk ON lk.kod::text = 'cagri.kanal'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = c.kanal
     LEFT JOIN kod_liste ls ON ls.kod::text = 'cagri.sonuc'::text
     LEFT JOIN kod_deger ks ON ks.liste_id = ls.id AND ks.deger = c.sonuc
     LEFT JOIN kod_liste ld ON ld.kod::text = 'cagri.durum'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = ld.id AND kd.deger = c.durum;

create or replace view public.v_lab_tekrar_istegi as
 SELECT t.id,
    t.istem_satir_id AS satir_id,
    s.istem_id,
    i.istem_no,
    s.tetkik_id,
    s.kod,
    s.ad AS tetkik,
    i.taraf_id AS hasta_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS hasta,
    t.tur,
    t.gerekce_kod,
    t.gerekce,
    COALESCE(d.ad, ''::character varying) AS gerekce_adi,
    t.isteyen_id,
    COALESCE(k.ad, ''::character varying) AS isteyen,
    t.istek_zamani,
    t.durum,
    t.sonuc_id,
    t.karsilayan_sonuc_id,
    t.kapanma_zamani,
    t.iptal_neden,
    t.sube_id,
    n.barkod,
    ( SELECT (a.konum::text || ' · '::text) || a.goz::text
           FROM v_lab_arsiv a
          WHERE a.numune_id = n.id AND a.durum = 1
         LIMIT 1) AS arsiv_yeri
   FROM lab_tekrar_istegi t
     JOIN lab_istem_satir s ON s.id = t.istem_satir_id
     JOIN lab_istem i ON i.id = s.istem_id
     LEFT JOIN lab_numune n ON n.id = s.numune_id
     LEFT JOIN taraf h ON h.id = i.taraf_id
     LEFT JOIN v_kullanici_lookup k ON k.id = t.isteyen_id
     LEFT JOIN kod_deger d ON d.deger = t.gerekce_kod AND d.dil = 0 AND d.liste_id = (( SELECT l.id
           FROM kod_liste l
          WHERE l.kod::text = 'lab.tekrar_gerekce'::text));

create or replace view public.v_isg_calisan as
 SELECT c.id,
    c.hasta_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (COALESCE(t.ad, ''::character varying)::text || ' '::text) || COALESCE(t.soyad, ''::character varying)::text), ''::text), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text) AS calisan_adi,
    COALESCE(t.vkno, ''::character varying) AS tckn,
    COALESCE(t.cep_tel, ''::character varying) AS cep_tel,
    h.dogum_tarihi,
    h.cinsiyet,
    c.firma_id,
    public.fn_taraf_ad(ft.unvan, ft.ad, ft.soyad)::character varying(120) AS firma_adi,
    f.tehlike,
    kt.ad AS tehlike_adi,
    c.bolum_id,
    COALESCE(b.ad, ''::character varying) AS bolum_adi,
    c.gorev,
    c.ise_giris,
    c.isten_ayrilis,
    c.calisma,
    kc.ad AS calisma_adi,
    c.maruziyet,
    COALESCE(NULLIF(b.maruziyet::text, ''::text)::jsonb, '[]'::jsonb) AS bolum_maruziyet,
    COALESCE(b.tetkik_paketi, ''::character varying) AS tetkik_paketi,
    c.meslek_oykusu,
    c.kkd,
    c.egitim,
    c.riza_tarihi,
    c.periyot_ay,
    fn_isg_periyot_ay(c.id) AS periyot_hesap,
    m.tarih AS son_muayene,
    m.tur AS son_muayene_tur,
    m.kanaat AS son_kanaat,
    kk.ad AS son_kanaat_adi,
    m.kosul AS son_kosul,
    m.sonraki_tarih AS hekim_sonraki,
    COALESCE(m.sonraki_tarih::timestamp without time zone, COALESCE(m.tarih, c.ise_giris, c.ekleme_tarihi::date) + make_interval(months => fn_isg_periyot_ay(c.id)))::date AS vade,
    COALESCE(m.sonraki_tarih::timestamp without time zone, COALESCE(m.tarih, c.ise_giris, c.ekleme_tarihi::date) + make_interval(months => fn_isg_periyot_ay(c.id)))::date - CURRENT_DATE AS kalan_gun,
    ( SELECT count(*) AS count
           FROM isg_muayene x
          WHERE x.calisan_id = c.id AND x.durum = 2) AS muayene_sayisi,
    ( SELECT count(*) AS count
           FROM isg_olay o
          WHERE o.calisan_id = c.id) AS olay_sayisi,
    ( SELECT count(*) AS count
           FROM isg_muayene x
          WHERE x.calisan_id = c.id AND x.durum = 1) AS acik_muayene,
    c.aciklama,
    c.durum,
        CASE c.durum
            WHEN 1 THEN 'Aktif'::text
            ELSE 'Ayrıldı'::text
        END AS durum_adi,
    c.sube_id,
    c.ekleme_tarihi
   FROM isg_calisan c
     JOIN taraf t ON t.id = c.hasta_id
     LEFT JOIN taraf_hasta h ON h.id = t.id
     JOIN isg_firma f ON f.id = c.firma_id
     JOIN taraf ft ON ft.id = f.taraf_id
     LEFT JOIN isg_firma_bolum b ON b.id = c.bolum_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.calisan_id,
            x.hasta_id,
            x.firma_id,
            x.tur,
            x.tarih,
            x.hekim_id,
            x.muayene_id,
            x.form_istek_id,
            x.kanaat,
            x.kosul,
            x.tani,
            x.sevk,
            x.sonraki_tarih,
            x.isveren_bildirim,
            x.tetkik_ozet,
            x.sure_dk,
            x.durum,
            x.aciklama,
            x.sube_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi
           FROM isg_muayene x
          WHERE x.calisan_id = c.id AND x.durum = 2
          ORDER BY x.tarih DESC, x.id DESC
         LIMIT 1) m ON true
     LEFT JOIN kod_liste lt ON lt.kod::text = 'isg.tehlike'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = f.tehlike
     LEFT JOIN kod_liste lc ON lc.kod::text = 'isg.calisma'::text
     LEFT JOIN kod_deger kc ON kc.liste_id = lc.id AND kc.deger = c.calisma
     LEFT JOIN kod_liste lk ON lk.kod::text = 'isg.kanaat'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = m.kanaat;

create or replace view public.v_isg_muayene as
 SELECT m.id,
    m.calisan_id,
    m.hasta_id,
    c.calisan_adi,
    m.firma_id,
    c.firma_adi,
    c.bolum_adi,
    c.gorev,
    m.tur,
    kt.ad AS tur_adi,
    m.tarih,
    m.hekim_id,
    COALESCE(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    m.muayene_id,
    m.form_istek_id,
    fi.durum AS form_durum,
    kfd.ad AS form_durum_adi,
    m.kanaat,
    kk.ad AS kanaat_adi,
    m.kosul,
    m.tani,
    m.sevk,
    m.sonraki_tarih,
    m.isveren_bildirim,
    m.tetkik_ozet,
    m.sure_dk,
    m.durum,
        CASE m.durum
            WHEN 1 THEN 'Açık'::text
            WHEN 2 THEN 'Tamamlandı'::text
            ELSE 'İptal'::text
        END AS durum_adi,
    m.aciklama,
    m.sube_id,
    m.ekleme_tarihi
   FROM isg_muayene m
     JOIN v_isg_calisan c ON c.id = m.calisan_id
     LEFT JOIN taraf hk ON hk.id = m.hekim_id
     LEFT JOIN form_istek fi ON fi.id = m.form_istek_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'isg.muayene_tur'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = m.tur
     LEFT JOIN kod_liste lk ON lk.kod::text = 'isg.kanaat'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = m.kanaat
     LEFT JOIN kod_liste lf ON lf.kod::text = 'form.istek_durum'::text
     LEFT JOIN kod_deger kfd ON kfd.liste_id = lf.id AND kfd.deger = fi.durum;

create or replace view public.v_isg_olay as
 SELECT o.id,
    o.firma_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS firma_adi,
    o.calisan_id,
    COALESCE(c.calisan_adi, ''::text) AS calisan_adi,
    o.tur,
    kt.ad AS tur_adi,
    o.tarih,
    o.yer,
    o.aciklama,
    o.yaralanma,
    o.ilk_mudahale,
    o.gun_kaybi,
    o.taniklar,
    o.sgk_bildirim,
    o.kok_neden,
    o.duzeltici,
    o.ise_donus_muayene_id,
        CASE
            WHEN (o.tur = ANY (ARRAY[1, 2])) AND o.sgk_bildirim IS NULL THEN GREATEST(0, o.tarih::date + 5 - CURRENT_DATE)
            ELSE NULL::integer
        END AS sgk_kalan_gun,
        CASE
            WHEN (o.tur = ANY (ARRAY[1, 2])) AND o.sgk_bildirim IS NULL AND (o.tarih::date + 5) < CURRENT_DATE THEN 1
            ELSE 0
        END AS sgk_gecikti,
    o.durum,
        CASE o.durum
            WHEN 1 THEN 'Açık'::text
            ELSE 'Kapandı'::text
        END AS durum_adi,
    o.sube_id,
    o.ekleme_tarihi
   FROM isg_olay o
     JOIN isg_firma f ON f.id = o.firma_id
     JOIN taraf t ON t.id = f.taraf_id
     LEFT JOIN v_isg_calisan c ON c.id = o.calisan_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'isg.olay_tur'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = o.tur;

create or replace view public.v_telerad_istek as
 SELECT i.id,
    i.istek_no,
    i.kurum_id,
    k.taraf_id AS kurum_taraf_id,
    COALESCE(public.fn_taraf_ad(kt.unvan, kt.ad, kt.soyad)::character varying(120), ''::character varying) AS kurum_adi,
    i.yon,
    i.oncelik,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), i.dis_hasta_kimlik) AS hasta_adi,
    i.dis_hasta_kimlik,
    i.dis_erisim_no,
    i.modalite,
    COALESCE(hz.ad, ''::character varying) AS tetkik_adi,
    i.klinik_bilgi,
    i.cekim_zamani,
    i.gelis_zamani,
    i.sla_dk,
    i.sla_bitis,
        CASE
            WHEN i.sla_bitis IS NULL OR i.durum >= 6 THEN NULL::integer
            ELSE floor(EXTRACT(epoch FROM i.sla_bitis::timestamp with time zone - now()) / 60::numeric)::integer
        END AS kalan_dk,
        CASE
            WHEN i.durum < 6 AND i.sla_bitis IS NOT NULL AND now() > i.sla_bitis THEN 1
            ELSE 0
        END::smallint AS sla_riskli,
    i.sla_asildi,
    i.goruntu_sayisi,
    i.seri_sayisi,
    i.goruntu_durum,
    i.durum,
    i.atanan_radyolog_id,
    COALESCE(public.fn_taraf_ad(r.unvan, r.ad, r.soyad)::character varying(120), ''::character varying) AS radyolog_adi,
    i.okuma_bas,
    i.onay_zamani,
    i.teslim_zamani,
    i.teslim_durum,
    i.ucret,
    i.radyoloji_istem_id,
    i.rapor_id,
    i.sube_id,
    i.fatura_belge_id
   FROM telerad_istek i
     JOIN telerad_kurum k ON k.id = i.kurum_id
     LEFT JOIN taraf kt ON kt.id = k.taraf_id
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN taraf r ON r.id = i.atanan_radyolog_id
     LEFT JOIN hizmet hz ON hz.id = i.tetkik_hizmet_id;

create or replace view public.v_onay_kutusu as
 SELECT v.adim_id AS id,
    v.onay_id,
    v.kaynak_tur,
    v.kaynak_id,
    v.sube_id,
    v.akis_kod,
    v.akis_ad,
    v.olcu,
    v.olcu_adi,
    v.sira,
    v.adim_ad,
    v.rol,
    v.atanan_kullanici_id,
    v.durum,
    v.gerekce,
    v.baslama,
    v.termin,
    v.gecikme_gun,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(NULLIF(t.talep_no::text, ''::text), '#'::text || v.kaynak_id::text)
            WHEN 904 THEN COALESCE(NULLIF(z.izin_no::text, ''::text), 'İzin #'::text || v.kaynak_id::text)
            WHEN 1224 THEN COALESCE(NULLIF(w.is_emri_no::text, ''::text), 'İş emri #'::text || v.kaynak_id::text)
            WHEN 1257 THEN COALESCE(NULLIF(av.avans_no::text, ''::text), 'Avans #'::text || v.kaynak_id::text)
            WHEN 1256 THEN COALESCE(NULLIF(ib.belge_no::text, ''::text), 'Başvuru #'::text || COALESCE(isk.belge_id, 0)::text)
            WHEN 976 THEN (COALESCE(NULLIF(dk.kod::text, ''::text), 'DOK-'::text || dk.id::text) || ' v'::text) || ds.surum_no::text
            WHEN 1312 THEN COALESCE(NULLIF(ms.beyan_no::text, ''::text), 'Masraf #'::text || v.kaynak_id::text)
            WHEN 1314 THEN COALESCE(NULLIF(bt.talep_no::text, ''::text), 'Belge #'::text || v.kaynak_id::text)
            ELSE '#'::text || v.kaynak_id::text
        END AS kayit_no,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(NULLIF(t.gerekce::text, ''::text), 'Satınalma talebi'::text)
            WHEN 904 THEN (((
            CASE z.tur
                WHEN 1 THEN 'Yıllık izin'::text
                WHEN 2 THEN 'Mazeret izni'::text
                WHEN 3 THEN 'Rapor'::text
                WHEN 4 THEN 'Ücretsiz izin'::text
                ELSE 'İzin'::text
            END || ' · '::text) || to_char(z.baslangic_tarihi::timestamp with time zone, 'DD.MM'::text)) || '-'::text) || to_char(z.bitis_tarihi::timestamp with time zone, 'DD.MM.YYYY'::text)
            WHEN 1224 THEN (COALESCE(NULLIF(dm.ad::text, ''::text), 'Cihaz'::text) || ' · '::text) || COALESCE(NULLIF(w.ariza_metni::text, ''::text), 'onarım'::text)
            WHEN 1257 THEN ((COALESCE(NULLIF(av.gerekce::text, ''::text), 'Avans'::text) || ' · '::text) || av.taksit_sayisi::text) || ' taksit'::text
            WHEN 1256 THEN ((COALESCE(NULLIF(isk.gerekce::text, ''::text), 'İskonto talebi'::text) || ' · '::text) || (( SELECT count(*)::text AS count
               FROM iskonto_talep_satir ts
              WHERE ts.talep_id = isk.id))) || ' kalem'::text
            WHEN 976 THEN COALESCE(NULLIF(dk.ad::text, ''::text), 'Doküman'::text) || COALESCE(' · '::text || NULLIF(ds.degisiklik_notu::text, ''::text), ''::text)
            WHEN 1312 THEN ((COALESCE(NULLIF(ms.aciklama::text, ''::text), 'Masraf beyanı'::text) || ' · '::text) || (( SELECT count(*)::text AS count
               FROM personel_masraf_satir mss
              WHERE mss.beyan_id = ms.id))) || ' belge'::text
            WHEN 1314 THEN
            CASE bt.tur
                WHEN 1 THEN 'Çalışma Belgesi'::text
                WHEN 2 THEN 'Maaş Yazısı'::text
                WHEN 3 THEN 'Vize Yazısı'::text
                WHEN 4 THEN 'SGK Hizmet Dökümü'::text
                ELSE 'Belge'::text
            END || COALESCE(' · '::text || NULLIF(bt.amac::text, ''::text), ''::text)
            ELSE ''::text
        END AS konu,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(d.ad, ''::character varying)
            WHEN 904 THEN COALESCE(NULLIF(zp.gorev::text, ''::text), ''::text)::character varying
            WHEN 1224 THEN COALESCE(wd.ad, ''::character varying)
            WHEN 1257 THEN COALESCE(NULLIF(ap.gorev::text, ''::text), ''::text)::character varying
            WHEN 1256 THEN COALESCE(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::character varying(120), ''::character varying)
            WHEN 976 THEN COALESCE(dkat.ad, ''::character varying)
            WHEN 1312 THEN COALESCE(NULLIF(mp.gorev::text, ''::text), ''::text)::character varying
            WHEN 1314 THEN COALESCE(NULLIF(bp.gorev::text, ''::text), ''::text)::character varying
            ELSE ''::character varying
        END AS birim,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::character varying(120), ''::character varying)
            WHEN 904 THEN COALESCE(public.fn_taraf_ad(zt.unvan, zt.ad, zt.soyad)::character varying(120), ''::character varying)
            WHEN 1224 THEN COALESCE(public.fn_taraf_ad(wb.unvan, wb.ad, wb.soyad)::character varying(120), ''::character varying)
            WHEN 1257 THEN COALESCE(public.fn_taraf_ad(at.unvan, at.ad, at.soyad)::character varying(120), ''::character varying)
            WHEN 1256 THEN COALESCE(public.fn_taraf_ad(ii.unvan, ii.ad, ii.soyad)::character varying(120), ''::character varying)
            WHEN 976 THEN COALESCE(public.fn_taraf_ad(dy.unvan, dy.ad, dy.soyad)::character varying(120), ''::character varying)
            WHEN 1312 THEN COALESCE(public.fn_taraf_ad(mt.unvan, mt.ad, mt.soyad)::character varying(120), ''::character varying)
            WHEN 1314 THEN COALESCE(public.fn_taraf_ad(btt.unvan, btt.ad, btt.soyad)::character varying(120), ''::character varying)
            ELSE ''::character varying
        END AS talep_eden
   FROM v_onay_bekleyen v
     LEFT JOIN satinalma_talep t ON v.kaynak_tur = 1241 AND t.id = v.kaynak_id
     LEFT JOIN departman d ON d.id = t.departman_id
     LEFT JOIN taraf p ON p.id = t.isteyen_id
     LEFT JOIN personel_izin z ON v.kaynak_tur = 904 AND z.id = v.kaynak_id
     LEFT JOIN taraf zt ON zt.id = z.taraf_id
     LEFT JOIN taraf_personel zp ON zp.id = z.taraf_id
     LEFT JOIN demirbas_is_emri w ON v.kaynak_tur = 1224 AND w.id = v.kaynak_id
     LEFT JOIN demirbas dm ON dm.id = w.demirbas_id
     LEFT JOIN departman wd ON wd.id = w.departman_id
     LEFT JOIN taraf wb ON wb.id = w.bildiren_id
     LEFT JOIN personel_avans av ON v.kaynak_tur = 1257 AND av.id = v.kaynak_id
     LEFT JOIN taraf at ON at.id = av.taraf_id
     LEFT JOIN taraf_personel ap ON ap.id = av.taraf_id
     LEFT JOIN iskonto_talep isk ON v.kaynak_tur = 1256 AND isk.id = v.kaynak_id
     LEFT JOIN belge ib ON ib.id = isk.belge_id
     LEFT JOIN taraf ih ON ih.id = ib.taraf_id
     LEFT JOIN taraf ii ON ii.id = isk.isteyen_id
     LEFT JOIN dokuman_surum ds ON v.kaynak_tur = 976 AND ds.id = v.kaynak_id
     LEFT JOIN dokuman dk ON dk.id = ds.dokuman_id
     LEFT JOIN dokuman_kategori dkat ON dkat.id = dk.kategori_id
     LEFT JOIN taraf dy ON dy.id = ds.yukleyen_id
     LEFT JOIN personel_masraf ms ON v.kaynak_tur = 1312 AND ms.id = v.kaynak_id
     LEFT JOIN taraf mt ON mt.id = ms.taraf_id
     LEFT JOIN taraf_personel mp ON mp.id = ms.taraf_id
     LEFT JOIN personel_belge_talep bt ON v.kaynak_tur = 1314 AND bt.id = v.kaynak_id
     LEFT JOIN taraf btt ON btt.id = bt.taraf_id
     LEFT JOIN taraf_personel bp ON bp.id = bt.taraf_id;

create or replace view public.v_servis_ziyaret as
 SELECT z.id,
    z.is_emri_id,
    e.is_emri_no,
    e.sube_id,
    e.cagri_id,
    g.cagri_no,
    COALESCE(public.fn_taraf_ad(mt.unvan, mt.ad, mt.soyad)::character varying(120), ''::character varying) AS taraf_adi,
    z.sira,
    z.teknisyen_id,
    COALESCE(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::character varying(120), ''::character varying) AS teknisyen_adi,
    z.plan_zamani,
    z.varis,
    z.ayrilis,
    z.yol_km,
    z.arac,
    z.mesai_disi,
    z.yapilan,
    z.sonuc,
        CASE z.sonuc
            WHEN 1 THEN 'Çözüldü'::text
            WHEN 2 THEN 'Çözülemedi'::text
            WHEN 3 THEN 'Parça bekliyor'::text
            WHEN 4 THEN 'İptal'::text
            ELSE 'Sürüyor'::text
        END AS sonuc_adi,
    z.sonuc_metni,
    z.imza_alindi,
    z.iscilik_saat,
    z.tutar,
        CASE
            WHEN z.varis IS NOT NULL AND z.ayrilis IS NOT NULL THEN round(EXTRACT(epoch FROM z.ayrilis - z.varis) / 3600.0, 2)
            ELSE NULL::numeric
        END AS yerinde_saat
   FROM servis_ziyaret z
     JOIN demirbas_is_emri e ON e.id = z.is_emri_id
     LEFT JOIN servis_cagri g ON g.id = e.cagri_id
     LEFT JOIN taraf mt ON mt.id = e.musteri_taraf_id
     LEFT JOIN taraf tk ON tk.id = z.teknisyen_id;

create or replace view public.v_servis_sozlesme as
 SELECT s.id,
    s.sozlesme_no,
    s.taraf_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS taraf_adi,
    s.sube_id,
    s.baslangic,
    s.bitis,
    s.kapsam,
        CASE s.kapsam
            WHEN 1 THEN 'İşçilik'::text
            WHEN 2 THEN 'İşçilik + yol'::text
            ELSE 'Tam kapsam'::text
        END AS kapsam_adi,
    s.sla_saat,
    s.periyot_ay,
    s.yillik_bedel,
    s.durum,
    s.aciklama,
    s.bitis - CURRENT_DATE AS kalan_gun,
    ( SELECT count(*) AS count
           FROM taraf_cihaz c
          WHERE c.sozlesme_id = s.id) AS cihaz_sayisi,
    ( SELECT count(*) AS count
           FROM servis_cagri g
          WHERE g.sozlesme_id = s.id AND g.sla_bitis IS NOT NULL AND COALESCE(g.kapanis, now()) > g.sla_bitis) AS sla_asim
   FROM servis_sozlesme s
     JOIN taraf t ON t.id = s.taraf_id;

create or replace view public.v_taraf_cihaz as
 SELECT c.id,
    c.taraf_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS taraf_adi,
    c.sube_id,
    c.ad,
    c.marka,
    c.model,
    c.seri_no,
    TRIM(BOTH ' '::text FROM (c.marka::text || ' '::text) || c.model::text) AS marka_model,
    c.kurulum_tarihi,
    c.garanti_bitis,
        CASE
            WHEN c.garanti_bitis IS NULL THEN 0
            WHEN c.garanti_bitis >= CURRENT_DATE THEN 1
            ELSE 2
        END AS garanti_durum,
    c.sozlesme_id,
    s.bitis AS sozlesme_bitis,
    c.satis_belge_id,
    c.bolge,
    c.adres,
    c.durum,
    c.aciklama,
    ( SELECT count(*) AS count
           FROM servis_cagri g
          WHERE g.taraf_cihaz_id = c.id) AS cagri_sayisi
   FROM taraf_cihaz c
     JOIN taraf t ON t.id = c.taraf_id
     LEFT JOIN servis_sozlesme s ON s.id = c.sozlesme_id;

create or replace view public.v_servis_cagri as
 SELECT g.id,
    g.cagri_no,
    g.sube_id,
    g.taraf_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS taraf_adi,
    g.taraf_cihaz_id,
    COALESCE(NULLIF(g.cihaz_metni::text, ''::text), TRIM(BOTH ' '::text FROM (((COALESCE(c.ad, ''::character varying)::text || ' '::text) || COALESCE(c.marka, ''::character varying)::text) || ' '::text) || COALESCE(c.model, ''::character varying)::text)) AS cihaz,
    c.seri_no,
    g.sozlesme_id,
    g.kapsam_tur,
        CASE g.kapsam_tur
            WHEN 1 THEN 'Ücretli'::text
            WHEN 2 THEN 'Sözleşme'::text
            WHEN 3 THEN 'Üretici garantisi'::text
            ELSE 'Kendi garantimiz'::text
        END AS kapsam_adi,
    g.oncelik,
    g.bildiren,
    g.telefon,
    g.acilis,
    g.sla_bitis,
    g.ilk_yanit,
    g.kapanis,
    g.durum,
    g.sikayet,
    g.sonuc,
    COALESCE(c.bolge, ''::character varying) AS bolge,
        CASE
            WHEN g.durum >= 5 OR g.sla_bitis IS NULL THEN NULL::integer
            ELSE floor(EXTRACT(epoch FROM g.sla_bitis - now()) / 60::numeric)::integer
        END AS sla_kalan_dk,
    ( SELECT count(*) AS count
           FROM demirbas_is_emri e
          WHERE e.cagri_id = g.id) AS is_emri_sayisi,
    ( SELECT count(*) AS count
           FROM servis_ziyaret z
             JOIN demirbas_is_emri e2 ON e2.id = z.is_emri_id
          WHERE e2.cagri_id = g.id) AS ziyaret_sayisi,
        CASE g.durum
            WHEN 0 THEN 'Açık'::text
            WHEN 1 THEN 'Atandı'::text
            WHEN 2 THEN 'Yolda'::text
            WHEN 3 THEN 'Yerinde'::text
            WHEN 4 THEN 'Parça bekliyor'::text
            WHEN 5 THEN 'Çözüldü'::text
            WHEN 8 THEN 'İptal'::text
            ELSE ''::text
        END AS durum_adi
   FROM servis_cagri g
     JOIN taraf t ON t.id = g.taraf_id
     LEFT JOIN taraf_cihaz c ON c.id = g.taraf_cihaz_id;

create or replace view public.v_servis_is_emri as
 SELECT e.id,
    e.is_emri_no,
    e.sube_id,
    e.sahiplik,
        CASE e.sahiplik
            WHEN 2 THEN 'Dış iş'::text
            ELSE 'İç iş'::text
        END AS sahiplik_adi,
    e.cagri_id,
    g.cagri_no,
    e.demirbas_id,
    e.musteri_taraf_id,
    COALESCE(public.fn_taraf_ad(mt.unvan, mt.ad, mt.soyad)::character varying(120), d.ad, ''::character varying) AS sahip_adi,
    e.taraf_cihaz_id,
    COALESCE(NULLIF(tc.ad::text, ''::text), d.ad::text, ''::text) AS cihaz,
    e.tur,
    e.oncelik,
    e.durum,
    e.kapsam_tur,
        CASE e.kapsam_tur
            WHEN 1 THEN 'Ücretli'::text
            WHEN 2 THEN 'Sözleşme'::text
            WHEN 3 THEN 'Üretici garantisi'::text
            ELSE 'Kendi garantimiz'::text
        END AS kapsam_adi,
    e.bildirim_zamani,
    e.ilk_mudahale,
    e.tamamlanma,
    e.planlanan,
    e.ariza_metni,
    e.yapilan_is,
    e.iscilik_tutar,
    e.parca_tutar,
    e.diger_tutar,
    e.toplam_tutar,
    e.teklif_no,
    e.belge_id,
    e.onay_durum,
    e.onayli_tutar,
    ( SELECT count(*) AS count
           FROM servis_ziyaret z
          WHERE z.is_emri_id = e.id) AS ziyaret_sayisi,
    ( SELECT count(*) AS count
           FROM servis_emanet m
          WHERE m.is_emri_id = e.id AND m.durum = 1) AS acik_emanet,
        CASE e.durum
            WHEN 0 THEN 'Açık'::text
            WHEN 1 THEN 'Planlandı'::text
            WHEN 2 THEN 'Sürüyor'::text
            WHEN 3 THEN 'Parça bekliyor'::text
            WHEN 4 THEN 'Dış serviste'::text
            WHEN 5 THEN 'Tamamlandı'::text
            WHEN 8 THEN 'İptal'::text
            ELSE ''::text
        END AS durum_adi
   FROM demirbas_is_emri e
     LEFT JOIN servis_cagri g ON g.id = e.cagri_id
     LEFT JOIN taraf mt ON mt.id = e.musteri_taraf_id
     LEFT JOIN taraf_cihaz tc ON tc.id = e.taraf_cihaz_id
     LEFT JOIN demirbas d ON d.id = e.demirbas_id;

create or replace view public.v_servis_emanet as
 SELECT m.id,
    m.emanet_no,
    m.sube_id,
    m.is_emri_id,
    e.is_emri_no,
    m.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS taraf_adi,
    m.demirbas_id,
    COALESCE(NULLIF(m.cihaz_metni::text, ''::text), d.ad::text, ''::text) AS cihaz,
    m.veris,
    m.iade,
    m.durum,
    m.aciklama,
        CASE
            WHEN m.durum = 1 THEN CURRENT_DATE - m.veris::date
            ELSE NULL::integer
        END AS gun,
        CASE m.durum
            WHEN 1 THEN 'Dışarıda'::text
            WHEN 2 THEN 'İade alındı'::text
            ELSE ''::text
        END AS durum_adi
   FROM servis_emanet m
     LEFT JOIN demirbas_is_emri e ON e.id = m.is_emri_id
     LEFT JOIN taraf t ON t.id = m.taraf_id
     LEFT JOIN demirbas d ON d.id = m.demirbas_id;

create or replace view public.v_onay_vekalet as
 SELECT k.id,
    k.devreden_id,
    COALESCE(NULLIF(public.fn_taraf_ad(dv.unvan, dv.ad, dv.soyad)::character varying(120)::text, ''::text), ku1.kod::text, '#'::text || k.devreden_id::text) AS devreden_ad,
    k.devralan_id,
    COALESCE(NULLIF(public.fn_taraf_ad(da.unvan, da.ad, da.soyad)::character varying(120)::text, ''::text), ku2.kod::text, '#'::text || k.devralan_id::text) AS devralan_ad,
    k.baslangic,
    k.bitis,
    k.akis_id,
    COALESCE(a.ad, ''::character varying) AS akis_ad,
    k.aciklama,
    k.aktif,
    k.sube_id,
        CASE
            WHEN k.aktif = 1 AND CURRENT_DATE >= k.baslangic AND CURRENT_DATE <= k.bitis THEN 1
            ELSE 0
        END::smallint AS yururlukte,
    k.ekleme_tarihi,
    k.degistirme_tarihi
   FROM onay_vekalet k
     LEFT JOIN taraf_kullanici ku1 ON ku1.id = k.devreden_id
     LEFT JOIN taraf dv ON dv.id = k.devreden_id
     LEFT JOIN taraf_kullanici ku2 ON ku2.id = k.devralan_id
     LEFT JOIN taraf da ON da.id = k.devralan_id
     LEFT JOIN onay_akis a ON a.id = k.akis_id;

create or replace view public.v_onay_akis_adim as
 SELECT a.id,
    a.akis_id,
    a.sira,
    a.ad,
    a.sahip_turu,
    a.rol,
    a.kullanici_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ku.kod::text, ''::text) AS kullanici_ad,
    a.esik_alt,
    a.bayrak,
    a.karar_turu,
    a.sure_gun,
    a.e_imza_zorunlu,
    a.aktif,
        CASE
            WHEN a.esik_alt IS NOT NULL AND COALESCE(a.bayrak, ''::character varying)::text <> ''::text THEN (a.esik_alt::text || ' ve üstü + '::text) || a.bayrak::text
            WHEN a.esik_alt IS NOT NULL THEN a.esik_alt::text || ' ve üstü'::text
            WHEN COALESCE(a.bayrak, ''::character varying)::text <> ''::text THEN a.bayrak::text || ' bayrağı'::text
            ELSE 'her kayıtta'::text
        END AS kosul
   FROM onay_akis_adim a
     LEFT JOIN taraf_kullanici ku ON ku.id = a.kullanici_id
     LEFT JOIN taraf t ON t.id = a.kullanici_id;

create or replace view public.v_servis_teknisyen as
 SELECT k.id AS taraf_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), t.ad::text) AS ad,
    k.rol_id,
    COALESCE(r.ad, ''::character varying) AS rol_adi,
    COALESCE(p.gorev, ''::character varying) AS gorev,
    k.aktif
   FROM taraf_kullanici k
     JOIN taraf t ON t.id = k.id
     LEFT JOIN rol r ON r.id = k.rol_id
     LEFT JOIN taraf_personel p ON p.id = k.id
  WHERE k.aktif = 1 AND (EXISTS ( SELECT 1
           FROM rol_yetki ry
             JOIN yetki y ON y.id = ry.yetki_id
          WHERE ry.rol_id = k.rol_id AND y.kod::text = 'servis'::text AND ry.gor = 1));

create or replace view public.v_servis_cizelge as
 SELECT z.id,
    z.is_emri_id,
    e.is_emri_no,
    e.sube_id,
    g.cagri_no,
    g.id AS cagri_id,
    z.teknisyen_id,
    COALESCE(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::character varying(120), ''::character varying) AS teknisyen_adi,
    COALESCE(public.fn_taraf_ad(mt.unvan, mt.ad, mt.soyad)::character varying(120), d.ad, ''::character varying) AS taraf_adi,
    COALESCE(NULLIF(tc.ad::text, ''::text), NULLIF(g.cihaz_metni::text, ''::text), d.ad::text, ''::text) AS cihaz,
    COALESCE(g.bolge_metni, ''::character varying) AS bolge,
    COALESCE(z.varis, z.plan_zamani) AS bas,
    COALESCE(z.ayrilis,
        CASE
            WHEN z.sonuc = 0 THEN GREATEST(now(), COALESCE(z.varis, z.plan_zamani))
            ELSE COALESCE(z.varis, z.plan_zamani) + '01:00:00'::interval
        END) AS "bit",
    z.sonuc,
    z.yol_km,
    z.arac,
    z.mesai_disi,
    z.tutar,
    z.yapilan,
    e.oncelik,
    e.sahiplik,
        CASE
            WHEN g.sla_bitis IS NOT NULL AND g.durum < 5 AND now() > g.sla_bitis THEN 1
            ELSE 0
        END AS sla_asildi
   FROM servis_ziyaret z
     JOIN demirbas_is_emri e ON e.id = z.is_emri_id
     LEFT JOIN ( SELECT c.id,
            c.cagri_no,
            c.sla_bitis,
            c.durum,
            c.cihaz_metni,
            COALESCE(tcz.bolge, ''::character varying) AS bolge_metni
           FROM servis_cagri c
             LEFT JOIN taraf_cihaz tcz ON tcz.id = c.taraf_cihaz_id) g ON g.id = e.cagri_id
     LEFT JOIN taraf mt ON mt.id = e.musteri_taraf_id
     LEFT JOIN taraf tk ON tk.id = z.teknisyen_id
     LEFT JOIN taraf_cihaz tc ON tc.id = e.taraf_cihaz_id
     LEFT JOIN demirbas d ON d.id = e.demirbas_id;

create or replace view public.v_telerad_kurum_lookup as
 SELECT k.id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying)::text ||
        CASE k.yon
            WHEN 2 THEN ' (giden)'::text
            WHEN 3 THEN ' (iki yön)'::text
            ELSE ''::text
        END AS ad,
    k.aktif
   FROM telerad_kurum k
     JOIN taraf t ON t.id = k.taraf_id;

create or replace view public.v_lab_arsiv as
 SELECT a.id,
    a.numune_id,
    n.barkod,
    n.hasta_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS hasta,
    i.istem_no,
    n.numune_tipi,
    n.tup_tipi,
    a.konum_id,
    fn_lab_arsiv_yol(a.konum_id) AS konum,
    a.goz,
    k.sicaklik,
    a.giris_zamani,
    a.saklama_gun,
    a.imha_hedef,
        CASE
            WHEN a.imha_hedef IS NULL THEN NULL::integer
            ELSE a.imha_hedef - CURRENT_DATE
        END AS kalan_gun,
    a.durum,
    a.cikis_zamani,
    a.cikis_neden,
    a.not_metni,
    a.sube_id
   FROM lab_numune_arsiv a
     JOIN lab_numune n ON n.id = a.numune_id
     JOIN lab_istem i ON i.id = n.istem_id
     LEFT JOIN taraf h ON h.id = n.hasta_id
     LEFT JOIN lab_arsiv_konum k ON k.id = a.konum_id;

create or replace view public.v_personel_izin_bakiye as
 SELECT t.id AS taraf_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ''::text) AS personel_ad,
    p.ise_giris_tarihi,
    y.yil,
    COALESCE(h.hak_gun, fn_izin_hak_gun(p.ise_giris_tarihi, y.yil, p.dogum_tarihi)) AS hak_gun,
    COALESCE(h.devir_gun, 0::numeric) AS devir_gun,
    COALESCE(h.ek_gun, 0::numeric) AS ek_gun,
    COALESCE(( SELECT sum(i.gun) AS sum
           FROM personel_izin i
          WHERE i.taraf_id = t.id AND i.tur = 1 AND i.durum = 2 AND EXTRACT(year FROM i.baslangic_tarihi) = y.yil::numeric AND i.bitis_tarihi < CURRENT_DATE), 0::bigint) AS kullanilan_gun,
    COALESCE(( SELECT sum(i.gun) AS sum
           FROM personel_izin i
          WHERE i.taraf_id = t.id AND i.tur = 1 AND i.durum = 2 AND EXTRACT(year FROM i.baslangic_tarihi) = y.yil::numeric AND i.bitis_tarihi >= CURRENT_DATE), 0::bigint) AS planlanan_gun,
    COALESCE(( SELECT sum(i.gun) AS sum
           FROM personel_izin i
          WHERE i.taraf_id = t.id AND i.tur = 1 AND (i.durum = ANY (ARRAY[0, 1])) AND EXTRACT(year FROM i.baslangic_tarihi) = y.yil::numeric), 0::bigint) AS onayda_gun,
    p.sube_id
   FROM taraf t
     JOIN taraf_personel p ON p.id = t.id
     CROSS JOIN ( SELECT EXTRACT(year FROM CURRENT_DATE)::smallint AS yil) y
     LEFT JOIN personel_izin_hak h ON h.taraf_id = t.id AND h.yil = y.yil
  WHERE t.personel = 1;

create or replace view public.v_personel_izin as
 SELECT i.id,
    i.taraf_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ''::text) AS personel_ad,
    COALESCE(NULLIF(p.gorev::text, ''::text), ''::text) AS gorev_ad,
    p.yonetici_taraf_id,
    COALESCE(NULLIF(public.fn_taraf_ad(am.unvan, am.ad, am.soyad)::character varying(120)::text, ''::text), ''::text) AS amir_ad,
    i.izin_no,
    i.tur,
    i.baslangic_tarihi,
    i.bitis_tarihi,
    i.gun,
    i.is_gunu,
    i.durum,
    i.aciklama,
    i.red_neden,
    i.iptal_neden,
    i.belge_no,
    i.yerine_id,
    COALESCE(NULLIF(public.fn_taraf_ad(yt.unvan, yt.ad, yt.soyad)::character varying(120)::text, ''::text), ''::text) AS yerine_ad,
    i.talep_tarihi,
    i.sube_id,
    ( SELECT v.adim_ad
           FROM v_onay_bekleyen v
          WHERE v.kaynak_tur = 904 AND v.kaynak_id = i.id
          ORDER BY v.sira
         LIMIT 1) AS bekleyen_basamak,
    COALESCE(( SELECT max(v.gecikme_gun) AS max
           FROM v_onay_bekleyen v
          WHERE v.kaynak_tur = 904 AND v.kaynak_id = i.id), 0) AS onay_gecikme_gun,
    ( SELECT count(*) AS count
           FROM personel_izin x
             JOIN taraf_personel xp ON xp.id = x.taraf_id
          WHERE x.id <> i.id AND x.durum = 2 AND p.yonetici_taraf_id IS NOT NULL AND xp.yonetici_taraf_id = p.yonetici_taraf_id AND x.baslangic_tarihi <= i.bitis_tarihi AND x.bitis_tarihi >= i.baslangic_tarihi) AS cakisan_izin,
    i.ekleme_tarihi,
    i.degistirme_tarihi
   FROM personel_izin i
     JOIN taraf t ON t.id = i.taraf_id
     LEFT JOIN taraf_personel p ON p.id = i.taraf_id
     LEFT JOIN taraf yt ON yt.id = i.yerine_id
     LEFT JOIN taraf am ON am.id = p.yonetici_taraf_id;

create or replace view public.v_lab_panik_acik as
 SELECT r.id AS sonuc_id,
    s.id AS satir_id,
    i.id AS istem_id,
    i.istem_no,
    t.kod,
    t.ad AS tetkik,
    COALESCE(NULLIF(r.deger_metin::text, ''::text), TRIM(BOTH FROM to_char(r.deger_sayisal, 'FM999999990.999999'::text))) AS deger,
    r.birim,
    r.bayrak,
    r.olcum_zamani,
    r.onay_zamani,
    i.taraf_id AS hasta_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS hasta,
    i.personel_id AS hekim_id,
    COALESCE(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::character varying(120), ''::character varying) AS hekim,
    (EXTRACT(epoch FROM now() - COALESCE(r.olcum_zamani, r.ekleme_tarihi)) / 60::numeric)::integer AS gecen_dk,
    b.id AS bildirim_id,
    b.bildirim_zamani,
    b.bildirilen_ad,
    b.kanal,
    b.teyit_zamani,
    b.teyit_eden,
    COALESCE(b.yukseltme::integer, 0) AS yukseltme,
        CASE
            WHEN b.id IS NULL THEN 1
            WHEN b.teyit_zamani IS NULL THEN 2
            ELSE 3
        END AS durum,
    r.sube_id
   FROM lab_sonuc r
     JOIN lab_istem_satir s ON s.id = r.istem_satir_id
     JOIN lab_istem i ON i.id = s.istem_id
     JOIN lab_tetkik t ON t.id = r.tetkik_id
     LEFT JOIN taraf h ON h.id = i.taraf_id
     LEFT JOIN taraf p ON p.id = i.personel_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.sonuc_id,
            x.bildiren_id,
            x.bildirim_zamani,
            x.bildirilen_ad,
            x.bildirilen_taraf_id,
            x.kanal,
            x.teyit_zamani,
            x.teyit_eden,
            x.yukseltme,
            x.aciklama
           FROM lab_panik_bildirim x
          WHERE x.sonuc_id = r.id
          ORDER BY x.teyit_zamani DESC NULLS LAST, x.id DESC
         LIMIT 1) b ON true
  WHERE r.panik = 1 AND r.durum <> 4 AND (b.id IS NULL OR b.teyit_zamani IS NULL);

create or replace view public.v_telerad_nobetci as
 SELECT n.id,
    n.radyolog_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS radyolog_adi,
    n.baslangic,
    n.bitis,
    n.tur,
        CASE n.tur
            WHEN 2 THEN 'Gece'::text
            WHEN 3 THEN 'Hafta sonu'::text
            WHEN 4 THEN 'Yedek'::text
            ELSE 'Gündüz'::text
        END AS tur_adi,
    n.kurum_id,
    n.modalite,
    n.azami_is,
    n.sube_id,
    ( SELECT count(*) AS count
           FROM telerad_istek i
          WHERE i.atanan_radyolog_id = n.radyolog_id AND i.durum >= 3 AND i.durum <= 5) AS acik_is,
    (now()::timestamp without time zone >= n.baslangic AND now()::timestamp without time zone < n.bitis)::integer::smallint AS su_an
   FROM telerad_nobet n
     LEFT JOIN taraf t ON t.id = n.radyolog_id
  WHERE n.aktif = 1;

create or replace view public.v_personel_avans as
 SELECT a.id,
    a.avans_no,
    a.taraf_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ''::text) AS personel_ad,
    COALESCE(NULLIF(p.gorev::text, ''::text), ''::text) AS gorev_ad,
    COALESCE(NULLIF(public.fn_taraf_ad(am.unvan, am.ad, am.soyad)::character varying(120)::text, ''::text), ''::text) AS amir_ad,
    a.talep_tarihi,
    a.tutar,
    a.taksit_sayisi,
    a.ilk_donem,
    a.durum,
    a.odeme_islem_id,
    a.odeme_tarihi,
    a.gerekce,
    a.red_neden,
    a.iptal_neden,
    a.sube_id,
    COALESCE(( SELECT sum(k.tutar) AS sum
           FROM personel_avans_kesinti k
          WHERE k.avans_id = a.id AND k.durum = 1), 0::numeric) AS kesilen_tutar,
    a.tutar - COALESCE(( SELECT sum(k.tutar) AS sum
           FROM personel_avans_kesinti k
          WHERE k.avans_id = a.id AND k.durum = 1), 0::numeric) AS kalan_tutar,
    ( SELECT count(*) AS count
           FROM personel_avans_kesinti k
          WHERE k.avans_id = a.id AND k.durum = 0) AS bekleyen_taksit,
    ( SELECT count(*) AS count
           FROM personel_avans_kesinti k
          WHERE k.avans_id = a.id AND k.durum = 0 AND k.donem::text < to_char(CURRENT_DATE::timestamp with time zone, 'YYYY-MM'::text)) AS geciken_taksit,
    ( SELECT v.adim_ad
           FROM v_onay_bekleyen v
          WHERE v.kaynak_tur = 1257 AND v.kaynak_id = a.id
          ORDER BY v.sira
         LIMIT 1) AS bekleyen_basamak,
    a.ekleme_tarihi,
    a.degistirme_tarihi
   FROM personel_avans a
     JOIN taraf t ON t.id = a.taraf_id
     LEFT JOIN taraf_personel p ON p.id = a.taraf_id
     LEFT JOIN taraf am ON am.id = p.yonetici_taraf_id;

create or replace view public.v_personel_hareket as
 SELECT h.id,
    h.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS personel_ad,
    COALESCE(p.sicil_no, ''::character varying) AS sicil_no,
    h.tur,
    COALESCE(kd.ad, ''::character varying) AS tur_adi,
    h.yururluk,
    h.bitis,
        CASE
            WHEN h.bitis IS NOT NULL THEN 1
            ELSE 0
        END::smallint AS sureli,
        CASE
            WHEN h.yururluk <= CURRENT_DATE AND (h.bitis IS NULL OR h.bitis >= CURRENT_DATE) AND h.id = (( SELECT h2.id
               FROM personel_hareket h2
              WHERE h2.taraf_id = h.taraf_id AND h2.yururluk <= CURRENT_DATE AND (h2.bitis IS NULL OR h2.bitis >= CURRENT_DATE)
              ORDER BY h2.yururluk DESC, h2.id DESC
             LIMIT 1)) THEN 1
            ELSE 0
        END::smallint AS gecerli,
        CASE
            WHEN h.yururluk > CURRENT_DATE THEN 1
            ELSE 0
        END::smallint AS ileri,
    h.gorev,
    h.gorev_id,
    COALESCE(g.ad, ''::character varying) AS gorev_adi,
    h.departman_id,
    COALESCE(d.ad, ''::character varying) AS departman_adi,
    h.rol_id,
    COALESCE(r.ad, ''::character varying) AS rol_adi,
    h.yonetici_taraf_id,
    COALESCE(public.fn_taraf_ad(y.unvan, y.ad, y.soyad)::character varying(120), ''::character varying) AS yonetici_ad,
    h.sube_id,
    COALESCE(s.ad, ''::character varying) AS sube_adi,
    h.calisma_sekli,
    h.sozlesme_turu,
    h.unvan,
    h.karar_no,
    h.belge_no,
    h.gerekce,
    h.aciklama,
    h.kaynak,
    h.ekleyen,
    h.ekleme_tarihi
   FROM personel_hareket h
     LEFT JOIN taraf t ON t.id = h.taraf_id
     LEFT JOIN taraf_personel p ON p.id = h.taraf_id
     LEFT JOIN taraf y ON y.id = h.yonetici_taraf_id
     LEFT JOIN personel_gorev g ON g.id = h.gorev_id
     LEFT JOIN departman d ON d.id = h.departman_id
     LEFT JOIN rol r ON r.id = h.rol_id
     LEFT JOIN sube s ON s.id = h.sube_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ik.hareket_tur'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger = h.tur;

create or replace view public.v_onay_sozlu as
 SELECT a.id AS adim_id,
    n.id AS onay_id,
    n.kaynak_tur,
    n.kaynak_id,
    n.sube_id,
    k.kod AS akis_kod,
    k.ad AS akis_ad,
    a.sira,
    a.ad AS adim_ad,
    a.rol,
    a.karar_veren_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ku.kod::text, '#'::text || a.karar_veren_id::text) AS karar_veren_ad,
    a.karar_zamani,
    a.gerekce,
    a.yazili_son,
        CASE
            WHEN a.yazili_son IS NULL THEN 0
            ELSE GREATEST(0, floor(EXTRACT(epoch FROM now() - a.yazili_son) / 3600::numeric)::integer)
        END AS gecikme_saat,
        CASE
            WHEN a.yazili_son IS NOT NULL AND a.yazili_son < now() THEN 1
            ELSE 0
        END AS gecikti,
    n.durum AS zincir_durum
   FROM onay_adim a
     JOIN onay n ON n.id = a.onay_id
     LEFT JOIN onay_akis k ON k.id = n.akis_id
     LEFT JOIN taraf t ON t.id = a.karar_veren_id
     LEFT JOIN taraf_kullanici ku ON ku.id = a.karar_veren_id
  WHERE a.durum = 4;

create or replace view public.v_personel_masraf as
 SELECT m.id,
    m.beyan_no,
    m.taraf_id,
    m.sube_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ''::text) AS personel_ad,
    COALESCE(NULLIF(p.gorev::text, ''::text), ''::text) AS gorev_ad,
    COALESCE(NULLIF(public.fn_taraf_ad(am.unvan, am.ad, am.soyad)::character varying(120)::text, ''::text), ''::text) AS amir_ad,
    m.beyan_tarihi,
    m.aciklama,
    m.toplam_tutar,
    m.durum,
    m.red_neden,
    ( SELECT count(*) AS count
           FROM personel_masraf_satir s
          WHERE s.beyan_id = m.id) AS satir_sayisi,
    ( SELECT min(s.harcama_tarihi) AS min
           FROM personel_masraf_satir s
          WHERE s.beyan_id = m.id) AS ilk_harcama,
    ( SELECT v.adim_ad
           FROM v_onay_bekleyen v
          WHERE v.kaynak_tur = 1312 AND v.kaynak_id = m.id
          ORDER BY v.sira
         LIMIT 1) AS bekleyen_basamak,
    m.ekleme_tarihi,
    m.degistirme_tarihi
   FROM personel_masraf m
     JOIN taraf t ON t.id = m.taraf_id
     LEFT JOIN taraf_personel p ON p.id = m.taraf_id
     LEFT JOIN taraf am ON am.id = p.yonetici_taraf_id;

create or replace view public.v_personel_belge_talep as
 SELECT b.id,
    b.talep_no,
    b.taraf_id,
    b.sube_id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), ''::text) AS personel_ad,
    COALESCE(NULLIF(p.gorev::text, ''::text), ''::text) AS gorev_ad,
    b.talep_tarihi,
    b.tur,
        CASE b.tur
            WHEN 1 THEN 'Çalışma Belgesi'::text
            WHEN 2 THEN 'Maaş Yazısı'::text
            WHEN 3 THEN 'Vize Yazısı'::text
            WHEN 4 THEN 'SGK Hizmet Dökümü'::text
            ELSE 'Diğer'::text
        END AS tur_adi,
    b.amac,
    b.muhatap,
    b.adet,
    b.teslim_sekli,
    b.durum,
    b.otomatik_onay,
    b.red_neden,
    b.hazirlayan_id,
    COALESCE(NULLIF(public.fn_taraf_ad(hz.unvan, hz.ad, hz.soyad)::character varying(120)::text, ''::text), ''::text) AS hazirlayan_ad,
    b.hazirlama_tarihi,
    b.teslim_tarihi,
        CASE
            WHEN b.durum = ANY (ARRAY[4, 5, 3, 8]) THEN 0
            ELSE GREATEST(0, CURRENT_DATE - b.talep_tarihi)
        END AS bekleme_gun,
    ( SELECT v.adim_ad
           FROM v_onay_bekleyen v
          WHERE v.kaynak_tur = 1314 AND v.kaynak_id = b.id
          ORDER BY v.sira
         LIMIT 1) AS bekleyen_basamak,
    b.aciklama,
    b.ekleme_tarihi,
    b.degistirme_tarihi
   FROM personel_belge_talep b
     JOIN taraf t ON t.id = b.taraf_id
     LEFT JOIN taraf_personel p ON p.id = b.taraf_id
     LEFT JOIN taraf hz ON hz.id = b.hazirlayan_id;

create or replace view public.v_telerad_bakanlik_eksik as
 SELECT i.id,
    i.istek_no,
    i.kurum_id,
    COALESCE(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::character varying(120), ''::character varying) AS kurum_adi,
    COALESCE(i.dis_erisim_no, ''::character varying) AS dis_erisim_no,
    i.durum,
    i.oncelik,
    i.modalite,
    i.gelis_zamani,
    i.teslim_zamani,
    i.sube_id,
    fn_telerad_bakanlik_eksik(i.id) AS eksik,
        CASE
            WHEN i.teslim_zamani IS NOT NULL THEN 'kritik'::text
            WHEN i.durum >= 6 THEN 'uyari'::text
            ELSE ''::text
        END AS satir_rengi
   FROM telerad_istek i
     JOIN telerad_kurum k ON k.id = i.kurum_id
     JOIN taraf tk ON tk.id = k.taraf_id
  WHERE k.bakanlik_gonderim = 1 AND fn_telerad_bakanlik_eksik(i.id) <> ''::text;

create or replace view public.v_asi_uygulama as
 SELECT u.id,
    u.taraf_id,
    u.belge_id,
    u.muayene_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS hasta,
    h.vkno AS kimlik_no,
    u.asi_id,
    a.kod AS asi_kod,
    a.ad AS asi,
    a.skrs_kod,
    a.doz_sayisi,
    u.doz_no,
    u.lot,
    u.barkod,
    u.uygulama_sekli,
    u.uygulama_yeri,
    u.islem_turu,
    u.ozel_durum,
    u.izlem_yeri,
    u.uygulayan_id,
    COALESCE(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::character varying(120), ''::character varying) AS uygulayan,
    p.vkno AS uygulayan_tckn,
    u.uygulama_zamani,
    u.bilgi_alinan_ad,
    u.bilgi_alinan_tel,
    u.sorgu_no,
    u.aciklama,
    u.durum,
    u.iptal_neden,
    u.enabiz_durum,
    u.sube_id,
    GREATEST((a.doz_sayisi - u.doz_no)::integer, 0) AS kalan_doz
   FROM asi_uygulama u
     JOIN asi a ON a.id = u.asi_id
     LEFT JOIN taraf h ON h.id = u.taraf_id
     LEFT JOIN taraf p ON p.id = u.uygulayan_id;

create or replace view public.v_personel_grup_lookup as
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
        CASE
            WHEN t.durum = 1 THEN 1
            ELSE 0
        END::smallint AS aktif,
    COALESCE(NULLIF(d.ad::text, ''::text), 'Bölümsüz'::text) AS grup
   FROM taraf t
     LEFT JOIN departman d ON d.id = t.departman
  WHERE t.personel = 1;

create or replace view public.v_telerad_teslim as
 SELECT t.id,
    t.istek_id,
    i.istek_no,
    COALESCE(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::character varying(120), ''::character varying) AS kurum_adi,
    t.hedef,
        CASE t.hedef
            WHEN 2 THEN 'Bakanlık'::text
            ELSE 'Kurum'::text
        END AS hedef_adi,
    t.durum,
        CASE t.durum
            WHEN 0 THEN 'İptal'::text
            WHEN 1 THEN 'Bekliyor'::text
            WHEN 2 THEN 'Gönderiliyor'::text
            WHEN 3 THEN 'Teslim edildi'::text
            ELSE 'Hata'::text
        END AS durum_adi,
    t.deneme_no,
    t.son_deneme,
    t.sonraki_deneme,
    t.ack_kodu,
    t.hata_metni,
    t.mesaj_kontrol_no,
    t.sube_id,
        CASE
            WHEN t.durum = 4 THEN 'kritik'::text
            WHEN t.durum = 1 AND t.deneme_no > 0 THEN 'uyari'::text
            WHEN t.durum = 0 THEN 'pasif'::text
            ELSE ''::text
        END AS satir_rengi
   FROM telerad_teslim t
     JOIN telerad_istek i ON i.id = t.istek_id
     JOIN telerad_kurum k ON k.id = i.kurum_id
     JOIN taraf tk ON tk.id = k.taraf_id;

create or replace view public.v_telerad_gelen as
 SELECT g.id,
    g.geldi_zamani,
    g.kontrol_no,
    g.accession_no,
    g.hasta_tckn,
    COALESCE(i.istek_no, ''::character varying) AS istek_no,
    COALESCE(public.fn_taraf_ad(tk.unvan, tk.ad, tk.soyad)::character varying(120), ''::character varying) AS kurum_adi,
    g.gonderen_skrs,
        CASE g.kaynak_tur
            WHEN 1 THEN 'Bakanlık'::text
            WHEN 2 THEN 'Kurum'::text
            ELSE 'Bilinmiyor'::text
        END AS kaynak_adi,
    g.kaynak_tur,
    g.radyolog_ad,
    g.radyolog_tckn,
    g.onay_zamani,
    g.durum,
        CASE g.durum
            WHEN 0 THEN 'Çözümlenemedi'::text
            WHEN 1 THEN 'Eşleşmedi'::text
            WHEN 2 THEN 'İşlendi'::text
            WHEN 3 THEN 'Mükerrer'::text
            ELSE 'Hata'::text
        END AS durum_adi,
    g.hata_metni,
    g.kaynak_ip,
    g.istek_id,
    g.rapor_id,
    g.sube_id,
        CASE
            WHEN g.durum = ANY (ARRAY[0, 1, 4]) THEN 'kritik'::text
            WHEN g.durum = 3 THEN 'pasif'::text
            ELSE ''::text
        END AS satir_rengi
   FROM telerad_gelen g
     LEFT JOIN telerad_istek i ON i.id = g.istek_id
     LEFT JOIN telerad_kurum k ON k.id = i.kurum_id
     LEFT JOIN taraf tk ON tk.id = k.taraf_id;

create or replace view public.v_cocuk_izlem as
 SELECT i.id,
    i.taraf_id,
    i.belge_id,
    i.muayene_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS cocuk,
    hh.dogum_tarihi,
    hh.cinsiyet,
        CASE
            WHEN hh.dogum_tarihi IS NULL THEN NULL::integer
            ELSE (EXTRACT(year FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)) * 12::numeric + EXTRACT(month FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)))::integer
        END AS yas_ay,
    i.kacinci_izlem,
    i.islem_turu,
    i.izlem_tarihi,
    i.boy_cm,
    i.kilo_kg,
    i.bas_cevresi_cm,
    i.dogum_agirligi_g,
    i.hemoglobin,
    i.hematokrit,
    i.beslenme,
    i.d_vitamini,
    i.demir,
    i.gkd,
    i.gorme,
    i.dkh,
    i.dkh_yapilmama,
    i.ntp,
    i.oneri,
    i.aciklama,
    i.durum,
    i.iptal_neden,
    i.enabiz_durum,
    i.sube_id,
    fn_cocuk_persentil(hh.cinsiyet, 1::smallint,
        CASE
            WHEN hh.dogum_tarihi IS NULL THEN NULL::integer
            ELSE (EXTRACT(year FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)) * 12::numeric + EXTRACT(month FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)))::integer
        END, i.kilo_kg) AS kilo_persentil,
    fn_cocuk_persentil(hh.cinsiyet, 2::smallint,
        CASE
            WHEN hh.dogum_tarihi IS NULL THEN NULL::integer
            ELSE (EXTRACT(year FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)) * 12::numeric + EXTRACT(month FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)))::integer
        END, i.boy_cm) AS boy_persentil,
    fn_cocuk_persentil(hh.cinsiyet, 3::smallint,
        CASE
            WHEN hh.dogum_tarihi IS NULL THEN NULL::integer
            ELSE (EXTRACT(year FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)) * 12::numeric + EXTRACT(month FROM age(i.izlem_tarihi::date::timestamp with time zone, hh.dogum_tarihi::timestamp with time zone)))::integer
        END, i.bas_cevresi_cm) AS bas_persentil
   FROM cocuk_izlem i
     LEFT JOIN taraf h ON h.id = i.taraf_id
     LEFT JOIN taraf_hasta hh ON hh.id = i.taraf_id;

create or replace view public.v_portal_davet as
 SELECT d.id,
    d.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS kisi,
    d.kanal,
        CASE d.kanal
            WHEN 2 THEN 'E-posta'::text
            ELSE 'SMS'::text
        END AS kanal_adi,
    d.alici,
    d.durum,
        CASE d.durum
            WHEN 2 THEN 'Kullanıldı'::text
            WHEN 3 THEN 'İptal'::text
            WHEN 1 THEN
            CASE
                WHEN d.gecerlilik < now()::timestamp without time zone THEN 'Süresi doldu'::text
                ELSE 'Bekliyor'::text
            END
            ELSE NULL::text
        END AS durum_adi,
    d.gecerlilik,
    d.deneme,
    d.gonderim_hata,
    d.kullanim_zamani,
    d.ekleme_tarihi,
    d.sube_id,
        CASE
            WHEN d.durum = 1 AND d.gecerlilik < now()::timestamp without time zone THEN 'uyari'::text
            WHEN d.durum = 3 THEN 'pasif'::text
            WHEN d.gonderim_hata::text <> ''::text THEN 'kritik'::text
            ELSE ''::text
        END AS satir_rengi
   FROM portal_davet d
     LEFT JOIN taraf t ON t.id = d.taraf_id;

create or replace view public.v_goz_unite_akis as
 SELECT b.id AS belge_id,
    b.sube_id,
    b.taraf_id AS hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    i.id AS istasyon_id,
    i.istasyon,
    i.giris AS istasyon_giris,
    i.oda,
    i.sira_no,
    i.personel_id,
    i.dilatasyon_zamani,
    i.dilatasyon_ilac,
        CASE
            WHEN i.dilatasyon_zamani IS NULL THEN NULL::integer
            WHEN (i.dilatasyon_zamani + '00:20:00'::interval) <= now() THEN 1
            ELSE 0
        END AS dilatasyon_hazir,
    EXTRACT(epoch FROM now() - i.giris)::integer / 60 AS bekleme_dk,
    gm.id AS goz_muayene_id,
    gm.muayene_turu,
    m.personel_id AS hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi
   FROM goz_ziyaret_istasyon i
     JOIN belge b ON b.id = i.belge_id
     JOIN taraf t ON t.id = i.hasta_id
     LEFT JOIN muayene m ON m.belge_id = b.id
     LEFT JOIN goz_muayene gm ON gm.muayene_id = m.id
     LEFT JOIN taraf h ON h.id = m.personel_id
  WHERE i.cikis IS NULL;

create or replace view public.v_steril_birim as
 SELECT b.id,
    b.barkod,
    b.tur,
    COALESCE(kt.ad, ''::character varying) AS tur_adi,
    b.set_id,
    COALESCE(s.ad, ''::character varying) AS set_adi,
    COALESCE(s.kod, ''::character varying) AS set_kodu,
    b.ad,
    b.durum,
    COALESCE(kd.ad, ''::character varying) AS durum_adi,
    b.durum_zaman,
    EXTRACT(epoch FROM now() - b.durum_zaman::timestamp with time zone)::integer / 60 AS durum_dk,
    b.dongu_sayisi,
    b.yaglama_sayisi,
    b.son_yaglama,
    b.yaglama_gerekli,
    b.uretici_esigi,
        CASE
            WHEN b.uretici_esigi > 0 AND b.dongu_sayisi >= b.uretici_esigi THEN 1
            WHEN s.dongu_esigi > 0 AND b.dongu_sayisi >= s.dongu_esigi THEN 1
            ELSE 0
        END AS bakim_zamani,
    b.son_dongu_id,
    ( SELECT d.sayac_no
           FROM steril_dongu d
          WHERE d.id = b.son_dongu_id) AS son_dongu_no,
    b.son_kullanim,
    b.son_taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS son_hasta_adi,
    b.son_belge_id,
    b.konum,
    b.aciklama,
    b.aktif,
    b.sube_id,
    ( SELECT p.skt
           FROM steril_paket p
          WHERE p.birim_id = b.id AND (p.durum = ANY (ARRAY[2, 3]))
          ORDER BY p.id DESC
         LIMIT 1) AS skt,
    ( SELECT p.barkod
           FROM steril_paket p
          WHERE p.birim_id = b.id AND (p.durum = ANY (ARRAY[1, 2, 3, 8]))
          ORDER BY p.id DESC
         LIMIT 1) AS paket_barkod,
    COALESCE(s.implant::integer, 0) AS implant
   FROM steril_birim b
     LEFT JOIN steril_set s ON s.id = b.set_id
     LEFT JOIN taraf t ON t.id = b.son_taraf_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'steril.birim_tur'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = b.tur
     LEFT JOIN kod_liste ld ON ld.kod::text = 'steril.birim_durum'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = ld.id AND kd.deger = b.durum;

create or replace view public.v_steril_paket as
 SELECT p.id,
    p.barkod,
    p.birim_id,
    b.barkod AS birim_barkod,
    b.ad AS birim_adi,
    b.tur AS birim_tur,
    COALESCE(s.ad, ''::character varying) AS set_adi,
    COALESCE(s.implant::integer, 0) AS implant,
    p.dongu_id,
    d.sayac_no AS dongu_no,
    COALESCE(c.ad, ''::character varying) AS cihaz_adi,
    d.bitis AS steril_tarihi,
    d.durum AS dongu_durum,
    p.paket_tur,
    COALESCE(kp.ad, ''::character varying) AS paket_tur_adi,
    p.paketleyen_id,
    COALESCE(pk.ad, ''::character varying) AS paketleyen_adi,
    p.paketleme_zamani,
    p.skt,
        CASE
            WHEN p.skt IS NULL THEN NULL::integer
            ELSE p.skt - CURRENT_DATE
        END AS skt_kalan_gun,
    p.raf,
    p.durum,
    COALESCE(kd.ad, ''::character varying) AS durum_adi,
    fn_steril_paket_kullanilabilir(p.id) AS kullanilabilir,
    p.sube_id,
    ( SELECT k.zaman
           FROM steril_paket_kullanim k
          WHERE k.paket_id = p.id
          ORDER BY k.id DESC
         LIMIT 1) AS kullanim_zamani,
    ( SELECT COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS "coalesce"
           FROM steril_paket_kullanim k
             LEFT JOIN taraf t ON t.id = k.taraf_id
          WHERE k.paket_id = p.id
          ORDER BY k.id DESC
         LIMIT 1) AS kullanan_hasta
   FROM steril_paket p
     JOIN steril_birim b ON b.id = p.birim_id
     LEFT JOIN steril_set s ON s.id = b.set_id
     LEFT JOIN steril_dongu d ON d.id = p.dongu_id
     LEFT JOIN steril_cihaz c ON c.id = d.cihaz_id
     LEFT JOIN v_kullanici_lookup pk ON pk.id = p.paketleyen_id
     LEFT JOIN kod_liste lp ON lp.kod::text = 'steril.paket_tur'::text
     LEFT JOIN kod_deger kp ON kp.liste_id = lp.id AND kp.deger = p.paket_tur
     LEFT JOIN kod_liste ld ON ld.kod::text = 'steril.paket_durum'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = ld.id AND kd.deger = p.durum;

create or replace view public.v_steril_paket_kullanim as
 SELECT k.id,
    k.paket_id,
    p.barkod AS paket_barkod,
    b.ad AS birim_adi,
    COALESCE(s.ad, ''::character varying) AS set_adi,
    p.dongu_id,
    d.sayac_no AS dongu_no,
    COALESCE(c.ad, ''::character varying) AS cihaz_adi,
    d.durum AS dongu_durum,
    k.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS hasta_adi,
    COALESCE(t.kod, ''::character varying) AS dosya_no,
    k.belge_id,
    COALESCE(bl.belge_no, ''::character varying) AS belge_no,
    k.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    k.unite,
    k.okutan_id,
    COALESCE(ok.ad, ''::character varying) AS okutan_adi,
    k.zaman,
    k.notu,
    k.sube_id,
    ( SELECT i.sonuc
           FROM steril_dongu_indikator i
          WHERE i.dongu_id = d.id AND i.tur = 6
          ORDER BY i.id DESC
         LIMIT 1) AS bio_sonuc
   FROM steril_paket_kullanim k
     JOIN steril_paket p ON p.id = k.paket_id
     JOIN steril_birim b ON b.id = p.birim_id
     LEFT JOIN steril_set s ON s.id = b.set_id
     LEFT JOIN steril_dongu d ON d.id = p.dongu_id
     LEFT JOIN steril_cihaz c ON c.id = d.cihaz_id
     LEFT JOIN taraf t ON t.id = k.taraf_id
     LEFT JOIN taraf h ON h.id = k.hekim_id
     LEFT JOIN belge bl ON bl.id = k.belge_id
     LEFT JOIN v_kullanici_lookup ok ON ok.id = k.okutan_id;

create or replace view public.v_gebe_izlem as
 SELECT i.id,
    i.gebelik_id,
    i.taraf_id,
    i.belge_id,
    i.muayene_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS gebe,
    g.sat,
    g.beklenen_dogum,
    g.gebelik_no,
    g.risk_durumu,
    fn_gebelik_hafta(g.sat, g.beklenen_dogum, i.izlem_tarihi::date) AS hafta,
    i.kacinci_izlem,
    i.islem_turu,
    i.izlem_tarihi,
    i.boy_cm,
    i.kilo_kg,
    i.sistolik,
    i.diastolik,
    i.fetus_kalp_sesi,
    i.hemoglobin,
    i.idrar_protein,
    i.gdm,
    i.demir,
    i.d_vitamini,
    i.anomali,
    i.oneri,
    i.aciklama,
    i.durum,
    i.iptal_neden,
    i.enabiz_durum,
    i.sube_id,
    ( SELECT count(*) AS count
           FROM gebe_izlem_risk r
          WHERE r.izlem_id = i.id) AS risk_sayisi
   FROM gebe_izlem i
     JOIN gebelik g ON g.id = i.gebelik_id
     LEFT JOIN taraf h ON h.id = i.taraf_id;

create or replace view public.v_gebelik as
 SELECT g.id,
    g.taraf_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS gebe,
    g.sat,
    g.beklenen_dogum,
    COALESCE(g.beklenen_dogum, g.sat + 280) AS tahmini_dogum,
    fn_gebelik_hafta(g.sat, g.beklenen_dogum) AS hafta,
    g.gebelik_no,
    g.risk_durumu,
    g.onceki_dogum,
    g.durum,
    g.sonuc_tarihi,
    g.aciklama,
    g.sube_id,
    ( SELECT count(*) AS count
           FROM gebe_izlem i
          WHERE i.gebelik_id = g.id AND i.durum = 1) AS izlem_sayisi,
    g.sat IS NOT NULL AND g.onceki_dogum IS NOT NULL AS bildirime_hazir
   FROM gebelik g
     LEFT JOIN taraf h ON h.id = g.taraf_id;

create or replace view public.v_yatak_panosu as
 SELECT yk.id AS yatak_id,
    yk.sube_id,
    yk.kod AS yatak_kod,
    yk.tip AS yatak_tip,
    yk.durum AS yatak_durum,
    yk.durum_notu,
    o.id AS oda_id,
    o.kod AS oda_kod,
    o.ad AS oda_ad,
    o.bina,
    o.kat,
    o.tur AS oda_tur,
    o.cinsiyet_kurali,
    o.izolasyon,
    d.id AS departman_id,
    d.ad AS departman_ad,
    y.id AS yatis_id,
    y.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    th.cinsiyet,
    y.giris_tarihi,
    y.tahmini_cikis,
    y.durum AS yatis_durum,
        CASE
            WHEN y.id IS NULL THEN NULL::integer
            ELSE CURRENT_DATE - y.giris_tarihi::date
        END AS yatis_gun,
        CASE
            WHEN y.tahmini_cikis = CURRENT_DATE THEN 1
            ELSE 0
        END AS bugun_bosalacak
   FROM yatak yk
     JOIN oda o ON o.id = yk.oda_id
     LEFT JOIN departman d ON d.id = o.departman_id
     LEFT JOIN yatis y ON y.yatak_id = yk.id AND (y.durum = ANY (ARRAY[1, 2, 3]))
     LEFT JOIN taraf t ON t.id = y.hasta_id
     LEFT JOIN taraf_hasta th ON th.id = y.hasta_id
  WHERE yk.aktif = 1 AND o.aktif = 1;

create or replace view public.v_hasta_avans as
 SELECT ki.id AS kasa_islem_id,
    ki.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ki.taraf_unvan, ''::character varying) AS hasta_adi,
    COALESCE(t.kod, ''::character varying) AS dosya_no,
    ki.sube_id,
    ki.islem_tarihi,
    COALESCE(NULLIF(ki.makbuz_no::text, ''::text), ki.islem_no::text, ''::text) AS makbuz_no,
    ki.tur,
    COALESCE(kt.ad, ''::character varying) AS islem_adi,
    COALESCE(h.ad, ''::character varying) AS hesap_adi,
    ki.tutar AS alinan,
    COALESCE(d.dagitilan, 0::numeric) AS kullanilan,
    i.iade,
    GREATEST(ki.tutar - COALESCE(d.dagitilan, 0::numeric) - i.iade, 0::numeric) AS kalan,
        CASE
            WHEN GREATEST(ki.tutar - COALESCE(d.dagitilan, 0::numeric) - i.iade, 0::numeric) > 0.005 THEN
            CASE
                WHEN i.iade > 0.005 THEN 'Kısmen İade'::text
                WHEN COALESCE(d.dagitilan, 0::numeric) > 0.005 THEN 'Kısmen Kullanıldı'::text
                ELSE 'Açık'::text
            END
            WHEN i.iade > 0.005 THEN 'İade Edildi'::text
            ELSE 'Kullanıldı'::text
        END AS durum_adi,
    i.iade_tarihi,
    ki.avans,
    d.belge_id,
    COALESCE(d.belge_no, ''::text) AS belge_no,
    COALESCE(ki.aciklama, ''::character varying) AS aciklama,
    ki.ekleme_tarihi
   FROM kasa_islem ki
     JOIN taraf t ON t.id = ki.taraf_id AND t.grup = 101
     LEFT JOIN kasa_islem_turu kt ON kt.kod = ki.tur
     LEFT JOIN hesap h ON h.id = ki.hesap_id
     LEFT JOIN LATERAL ( SELECT sum(x.tutar) AS dagitilan,
            min(bs.belge_id) AS belge_id,
            string_agg(DISTINCT NULLIF(b.belge_no::text, ''::text), ', '::text) AS belge_no
           FROM kasa_islem_dagitim x
             JOIN belge_satir bs ON bs.id = x.belge_satir_id
             LEFT JOIN belge b ON b.id = bs.belge_id
          WHERE x.kasa_islem_id = ki.id) d ON true
     LEFT JOIN LATERAL ( SELECT COALESCE(sum(abs(x.tutar)), 0::numeric) AS iade,
            max(x.islem_tarihi) AS iade_tarihi
           FROM kasa_islem x
          WHERE x.avans_kaynak_id = ki.id AND x.durum <> 3 AND x.iptal_islem_id IS NULL) i ON true
  WHERE ki.durum = 2 AND ki.iptal_islem_id IS NULL AND COALESCE(kt.yon::integer, 1) = 1 AND (ki.avans = 1 OR GREATEST(ki.tutar - COALESCE(d.dagitilan, 0::numeric) - i.iade, 0::numeric) > 0.005);

create or replace view public.v_gebelik_sonuc as
 SELECT s.id,
    s.gebelik_id,
    s.taraf_id,
    s.belge_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS gebe,
    g.sat,
    g.gebelik_no,
    fn_gebelik_hafta(g.sat, g.beklenen_dogum, s.sonlanma_tarihi::date) AS sonlanma_haftasi,
    s.sonlanma_tarihi,
    s.sonuc,
    s.dogum_yontemi,
    s.dogum_yeri,
    s.doguma_yardim,
    s.canli_bebek,
    s.olu_bebek,
    s.sezaryan_endikasyon,
    s.endikasyon_neden,
    s.aciklama,
    s.durum,
    s.iptal_neden,
    s.enabiz_durum,
    s.sube_id,
    ( SELECT count(*) AS count
           FROM gebe_izlem i
          WHERE i.gebelik_id = g.id AND i.durum = 1) AS izlem_sayisi
   FROM gebelik_sonuc s
     JOIN gebelik g ON g.id = s.gebelik_id
     LEFT JOIN taraf h ON h.id = s.taraf_id;

create or replace view public.v_gebelik_sonucsuz as
 SELECT g.id AS gebelik_id,
    g.taraf_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (h.ad::text || ' '::text) || h.soyad::text), ''::text), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)::text) AS gebe,
    g.sat,
    g.sonuc_tarihi,
    g.sube_id
   FROM gebelik g
     LEFT JOIN taraf h ON h.id = g.taraf_id
  WHERE g.durum = 2 AND NOT (EXISTS ( SELECT 1
           FROM gebelik_sonuc s
          WHERE s.gebelik_id = g.id AND s.durum = 1));

create or replace view public.v_dis_plan_lookup as
 SELECT p.id,
    (((p.plan_no::text || ' · '::text) || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text))::character varying(160) AS ad,
    p.sube_id,
        CASE
            WHEN p.durum = ANY (ARRAY[1, 2, 3, 4]) THEN 1
            ELSE 0
        END AS aktif
   FROM dis_tedavi_plani p
     JOIN taraf t ON t.id = p.hasta_id;

create or replace view public.v_dis_tedavi_plani as
 SELECT p.id,
    p.sube_id,
    p.plan_no,
    p.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    p.hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    p.varyant,
    p.durum,
    p.toplam,
    p.indirim,
    p.net,
    p.gecerlilik_bitis,
    p.hasta_onay_zamani,
    p.proforma_no,
    p.ekleme_tarihi::date AS tarih,
    (( SELECT count(*) AS count
           FROM dis_tedavi_plani_satir s
          WHERE s.plan_id = p.id AND s.durum <> 4))::integer AS satir_sayisi,
    (( SELECT count(*) AS count
           FROM dis_tedavi_plani_satir s
          WHERE s.plan_id = p.id AND s.durum = 3))::integer AS yapilan_sayisi,
    ( SELECT COALESCE(sum(s.net), 0::numeric) AS "coalesce"
           FROM dis_tedavi_plani_satir s
          WHERE s.plan_id = p.id AND s.durum = 3) AS yapilan_tutar,
    ( SELECT COALESCE(sum(k.odenen), 0::numeric) AS "coalesce"
           FROM dis_odeme_plani o
             JOIN dis_odeme_taksit k ON k.odeme_plani_id = o.id
          WHERE o.plan_id = p.id) AS tahsil
   FROM dis_tedavi_plani p
     JOIN taraf t ON t.id = p.hasta_id
     LEFT JOIN taraf h ON h.id = p.hekim_id;

create or replace view public.v_dis_lab_isemri as
 SELECT i.id,
    i.sube_id,
    i.isemri_no,
    i.lab_id,
    l.ad AS lab_adi,
    i.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    i.hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    i.plan_satir_id,
    i.is_turu,
    i.dis_nolar,
    i.malzeme,
    i.renk,
    i.gonderim_tarihi,
    i.beklenen_tarih,
    i.teslim_tarihi,
    i.asama,
    i.lab_fiyat,
    i.hasta_fiyat,
        CASE
            WHEN i.asama = ANY (ARRAY[8, 9]) THEN 0
            WHEN i.beklenen_tarih IS NOT NULL AND i.beklenen_tarih < CURRENT_DATE THEN 1
            ELSE 0
        END AS gecikti,
    ( SELECT r.baslangic
           FROM randevu r
          WHERE r.lab_isemri_id = i.id AND r.durum <> 4
          ORDER BY r.baslangic DESC
         LIMIT 1) AS sonraki_randevu
   FROM dis_lab_isemri i
     JOIN dis_lab l ON l.id = i.lab_id
     JOIN taraf t ON t.id = i.hasta_id
     LEFT JOIN taraf h ON h.id = i.hekim_id;

create or replace view public.v_dis_seans as
 SELECT s.id,
    s.sube_id,
    s.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    s.hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    s.unit_id,
    u.ad AS unit_adi,
    s.plan_id,
    p.plan_no,
    s.randevu_id,
    s.belge_id,
    s.baslangic,
    s.bitis,
    s.sure_dk,
    s.durum,
    (( SELECT count(*) AS count
           FROM dis_seans_islem i
          WHERE i.seans_id = s.id))::integer AS islem_sayisi,
    ( SELECT string_agg(hz.ad::text, ' · '::text ORDER BY i.id) AS string_agg
           FROM dis_seans_islem i
             JOIN hizmet hz ON hz.id = i.hizmet_id
          WHERE i.seans_id = s.id) AS islemler
   FROM dis_seans s
     JOIN taraf t ON t.id = s.hasta_id
     LEFT JOIN taraf h ON h.id = s.hekim_id
     LEFT JOIN dis_unit u ON u.id = s.unit_id
     LEFT JOIN dis_tedavi_plani p ON p.id = s.plan_id;

create or replace view public.v_dis_gunluk_akis as
 SELECT r.id,
    r.sube_id,
    r.baslangic,
    r.sure_dk,
    r.durum AS randevu_durum,
    r.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    EXTRACT(year FROM age(CURRENT_DATE::timestamp with time zone, th.dogum_tarihi::timestamp with time zone))::integer AS yas,
    r.hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    r.unit_id,
    u.ad AS unit_adi,
    u.kod AS unit_kod,
    r.plan_satir_id,
    ps.plan_id,
    p.plan_no,
    ps.sira AS plan_sira,
    COALESCE(hz.ad, r.aciklama) AS planli_islem,
    ps.dis_no,
    ps.seans_sayisi,
    ps.yapilan_seans,
    ps.lab_isemri_id,
    li.asama AS lab_asama,
    p.durum AS plan_durum,
        CASE
            WHEN p.id IS NULL THEN 0::bigint
            ELSE ( SELECT count(*) AS count
               FROM dis_tedavi_plani_satir x
              WHERE x.plan_id = p.id AND x.durum = 3)
        END::integer AS plan_yapilan,
        CASE
            WHEN p.id IS NULL THEN 0::bigint
            ELSE ( SELECT count(*) AS count
               FROM dis_tedavi_plani_satir x
              WHERE x.plan_id = p.id AND x.durum <> 4)
        END::integer AS plan_toplam_satir,
    COALESCE(( SELECT sum(x.net) AS sum
           FROM dis_tedavi_plani_satir x
          WHERE x.plan_id = p.id AND x.durum = 3), 0::numeric) - COALESCE(( SELECT sum(k.odenen) AS sum
           FROM dis_odeme_plani o
             JOIN dis_odeme_taksit k ON k.odeme_plani_id = o.id
          WHERE o.plan_id = p.id), 0::numeric) AS bakiye,
    s.id AS seans_id,
    s.baslangic AS seans_baslangic,
    s.durum AS seans_durum,
    r.belge_id
   FROM randevu r
     JOIN taraf t ON t.id = r.hasta_id
     LEFT JOIN taraf_hasta th ON th.id = r.hasta_id
     LEFT JOIN taraf h ON h.id = r.hekim_id
     LEFT JOIN dis_unit u ON u.id = r.unit_id
     LEFT JOIN dis_tedavi_plani_satir ps ON ps.id = r.plan_satir_id
     LEFT JOIN dis_tedavi_plani p ON p.id = ps.plan_id
     LEFT JOIN hizmet hz ON hz.id = COALESCE(ps.hizmet_id, r.hizmet_id)
     LEFT JOIN dis_lab_isemri li ON li.id = ps.lab_isemri_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.baslangic,
            x.durum
           FROM dis_seans x
          WHERE x.randevu_id = r.id
          ORDER BY x.id DESC
         LIMIT 1) s ON true
  WHERE r.bolum = 2 OR r.unit_id IS NOT NULL;

create or replace view public.v_dis_hasta as
 SELECT t.id,
    t.sube_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS unvan,
    t.telefon,
    t.cep_tel,
    th.dogum_tarihi,
    EXTRACT(year FROM age(CURRENT_DATE::timestamp with time zone, th.dogum_tarihi::timestamp with time zone))::integer AS yas,
    (( SELECT count(*) AS count
           FROM dis_odontogram o
          WHERE o.hasta_id = t.id AND o.aktif = 1 AND o.katman = 1 AND o.durum_kod <> 0))::integer AS bulgu_sayisi,
    ( SELECT p.plan_no
           FROM dis_tedavi_plani p
          WHERE p.hasta_id = t.id AND (p.durum = ANY (ARRAY[3, 4]))
          ORDER BY p.id DESC
         LIMIT 1) AS aktif_plan_no,
    ( SELECT max(s.baslangic) AS max
           FROM dis_seans s
          WHERE s.hasta_id = t.id) AS son_seans,
    ( SELECT max(m.muayene_tarihi) AS max
           FROM muayene m
          WHERE m.taraf_id = t.id) AS son_muayene
   FROM taraf t
     JOIN taraf_hasta th ON th.id = t.id
  WHERE t.hasta = 1;

create or replace view public.v_medula_takip as
 SELECT b.id AS belge_id,
    b.sube_id,
    b.belge_no,
    b.belge_tarihi,
    b.taraf_id AS hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    bb.personel_id AS hekim_id,
    public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    bb.bolum_id,
    d.ad AS bolum_adi,
    bb.odeyen_kurum_id,
    public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::character varying(120) AS odeyen_adi,
    p.sgk_durum,
    p.sgk_takip_no,
    p.sgk_provizyon_no,
    p.sgk_takip_turu,
    p.sgk_provizyon_tipi,
    p.sgk_sigorta_turu,
    p.sgk_mustehaklik,
    p.sgk_mustehaklik_zaman,
    p.sgk_takip_tarihi,
    p.sgk_gecerlilik,
    p.sgk_red_nedeni,
    p.sgk_cikis_zaman,
    p.sgk_sevkli,
    p.sgk_sevk_kurum,
    p.sgk_brans_kodu,
    (( SELECT count(*) AS count
           FROM medula_islem i
          WHERE i.belge_id = b.id AND i.durum = 2))::integer AS kabul_islem,
    (( SELECT count(*) AS count
           FROM medula_islem i
          WHERE i.belge_id = b.id AND i.durum = 3))::integer AS hatali_islem,
    (( SELECT count(*) AS count
           FROM belge_satir s
          WHERE s.belge_id = b.id AND s.hizmet_id IS NOT NULL))::integer AS satir_sayisi,
    COALESCE(( SELECT sum(s.tutar_kdvli) AS sum
           FROM belge_satir s
          WHERE s.belge_id = b.id), 0::numeric) AS yerel_tutar,
    f.id AS medula_fatura_id,
    f.medula_fatura_no,
    f.medula_tutar,
    f.durum AS fatura_durum,
    (( SELECT count(*) AS count
           FROM medula_kuyruk q
          WHERE q.belge_id = b.id AND (q.durum = ANY (ARRAY[4, 5]))))::integer AS hata_sayisi
   FROM belge b
     JOIN belge_basvuru bb ON bb.id = b.id
     JOIN taraf t ON t.id = b.taraf_id
     LEFT JOIN taraf h ON h.id = bb.personel_id
     LEFT JOIN departman d ON d.id = bb.bolum_id
     LEFT JOIN taraf k ON k.id = bb.odeyen_kurum_id
     LEFT JOIN belge_provizyon p ON p.id = b.id
     LEFT JOIN medula_fatura f ON f.belge_id = b.id AND f.durum <> 7
  WHERE b.tur = 19;

create or replace view public.v_medula_kuyruk as
 SELECT q.id,
    q.sube_id,
    q.servis,
    q.islem,
    q.kaynak_tablo,
    q.kaynak_id,
    q.hasta_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS hasta_adi,
    q.belge_id,
    q.sonuc_kod,
    q.sonuc_mesaj,
    q.durum,
    q.deneme,
    q.sonraki_deneme,
    q.gonderim,
    q.sure_ms,
    q.oncelik,
    q.kullanici_id,
    COALESCE(u.ad, ''::character varying) AS kullanici_adi,
    q.ekleme_tarihi,
    q.istek IS NOT NULL AS istek_var,
    q.yanit IS NOT NULL AS yanit_var
   FROM medula_kuyruk q
     LEFT JOIN taraf t ON t.id = q.hasta_id
     LEFT JOIN v_kullanici_lookup u ON u.id = q.kullanici_id;

create or replace view public.v_medula_fatura as
 SELECT f.id,
    f.sube_id,
    f.belge_id,
    b.belge_no,
    f.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    f.takip_no,
    f.fatura_turu,
    f.donem_id,
    dn.yil AS donem_yil,
    dn.ay AS donem_ay,
    f.medula_fatura_no,
    f.fatura_tarihi,
    f.yerel_tutar,
    f.medula_tutar,
    f.hasta_katilim,
    f.sgk_tutar,
    f.yerel_tutar - f.medula_tutar AS fark,
    f.durum,
    f.sonuc_kod,
    f.sonuc_mesaj,
    f.kayit_zaman,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    ( SELECT COALESCE(sum(k.tutar), 0::numeric) AS "coalesce"
           FROM medula_kesinti k
          WHERE k.medula_fatura_id = f.id) AS kesinti
   FROM medula_fatura f
     JOIN belge b ON b.id = f.belge_id
     JOIN taraf t ON t.id = f.hasta_id
     LEFT JOIN belge_basvuru bb ON bb.id = b.id
     LEFT JOIN taraf h ON h.id = bb.personel_id
     LEFT JOIN medula_donem dn ON dn.id = f.donem_id;

create or replace view public.v_medula_fatura_lookup as
 SELECT f.id,
    (((COALESCE(NULLIF(f.medula_fatura_no::text, ''::text), 'taslak'::text) || ' · '::text) || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text))::character varying(160) AS ad,
    f.sube_id,
        CASE
            WHEN f.durum = ANY (ARRAY[2, 3, 4, 5, 6]) THEN 1
            ELSE 0
        END AS aktif
   FROM medula_fatura f
     JOIN taraf t ON t.id = f.hasta_id;

create or replace view public.v_dis_lab_isemri_etiket as
 SELECT i.id,
    i.sube_id,
    i.isemri_no,
    i.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    th.dogum_tarihi,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    i.lab_id,
    l.ad AS lab_adi,
    i.is_turu,
    COALESCE(kt.ad, ''::character varying) AS is_turu_adi,
    i.dis_nolar,
    i.malzeme,
    i.renk,
    i.olcu_tipi,
    COALESCE(ko.ad, ''::character varying) AS olcu_tipi_adi,
    i.ek_istek,
    i.gonderim_tarihi,
    i.beklenen_tarih,
    i.asama,
    COALESCE(ka.ad, ''::character varying) AS asama_adi,
    i.etiket_basim,
    i.son_etiket_tarihi
   FROM dis_lab_isemri i
     JOIN dis_lab l ON l.id = i.lab_id
     JOIN taraf t ON t.id = i.hasta_id
     LEFT JOIN taraf_hasta th ON th.id = i.hasta_id
     LEFT JOIN taraf h ON h.id = i.hekim_id
     LEFT JOIN kod_liste lt ON lt.kod::text = 'dis.lab_is_turu'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = i.is_turu
     LEFT JOIN kod_liste lo ON lo.kod::text = 'dis.olcu_tipi'::text
     LEFT JOIN kod_deger ko ON ko.liste_id = lo.id AND ko.deger = i.olcu_tipi
     LEFT JOIN kod_liste la ON la.kod::text = 'dis.lab_asama'::text
     LEFT JOIN kod_deger ka ON ka.liste_id = la.id AND ka.deger = i.asama;

create or replace view public.v_dis_icon_skor as
 SELECT s.id,
    s.sube_id,
    s.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    s.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    s.tarih,
    s.olcum_turu,
    COALESCE(ko.ad, ''::character varying) AS olcum_turu_adi,
    s.estetik,
    s.ust_ark,
    s.capraz,
    s.dikey,
    s.bukkal,
    s.toplam,
        CASE
            WHEN s.toplam > 43 THEN 1
            ELSE 0
        END::smallint AS tedavi_gerekir,
    fn_dis_icon_karmasiklik(s.toplam) AS karmasiklik,
    COALESCE(kk.ad, ''::character varying) AS karmasiklik_adi,
    s.oncesi_id,
    o.toplam AS oncesi_toplam,
    fn_dis_icon_iyilesme(o.toplam, s.toplam) AS iyilesme,
    COALESCE(ki.ad, ''::character varying) AS iyilesme_adi,
    s.not_metin,
    s.muayene_id,
    s.ekleme_tarihi
   FROM dis_icon_skor s
     JOIN taraf t ON t.id = s.hasta_id
     LEFT JOIN taraf h ON h.id = s.hekim_id
     LEFT JOIN dis_icon_skor o ON o.id = s.oncesi_id
     LEFT JOIN kod_liste lo ON lo.kod::text = 'dis.icon_olcum'::text
     LEFT JOIN kod_deger ko ON ko.liste_id = lo.id AND ko.deger = s.olcum_turu
     LEFT JOIN kod_liste lk ON lk.kod::text = 'dis.icon_karmasiklik'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = fn_dis_icon_karmasiklik(s.toplam)
     LEFT JOIN kod_liste li ON li.kod::text = 'dis.icon_iyilesme'::text
     LEFT JOIN kod_deger ki ON ki.liste_id = li.id AND ki.deger = fn_dis_icon_iyilesme(o.toplam, s.toplam);

create or replace view public.v_hekim_calisma_sablon as
 SELECT s.id,
    s.sube_id,
    COALESCE(sb.ad, 'Tüm şubeler'::character varying) AS sube_adi,
    s.hekim_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hekim_adi,
    s.departman_id,
    d.ad AS departman_adi,
    s.ad,
    s.gunler,
    s.bas1,
    s.bit1,
    s.bas2,
    s.bit2,
    s.slot_dk,
    s.kanallar,
    s.gunluk_kota,
    s.portal_yuzde,
    s.kontrol_yuzde,
    s.tekrar,
    s.gecerli_bas,
    s.gecerli_bit,
    s.aktif,
    s.aciklama,
    ((((s.bas1::text || '–'::text) || s.bit1::text) ||
        CASE
            WHEN NULLIF(s.bas2::text, ''::text) IS NOT NULL THEN ((' · '::text || s.bas2::text) || '–'::text) || s.bit2::text
            ELSE ''::text
        END))::character varying(40) AS saat,
    ((( SELECT string_agg(
                CASE g.g
                    WHEN '1'::text THEN 'Pzt'::text
                    WHEN '2'::text THEN 'Sal'::text
                    WHEN '3'::text THEN 'Çar'::text
                    WHEN '4'::text THEN 'Per'::text
                    WHEN '5'::text THEN 'Cum'::text
                    WHEN '6'::text THEN 'Cmt'::text
                    WHEN '7'::text THEN 'Paz'::text
                    ELSE NULL::text
                END, ' '::text ORDER BY g.g) AS string_agg
           FROM unnest(string_to_array(s.gunler::text, ','::text)) g(g))))::character varying(40) AS gun_adlari
   FROM hekim_calisma_sablon s
     JOIN taraf t ON t.id = s.hekim_id
     JOIN departman d ON d.id = s.departman_id
     LEFT JOIN sube sb ON sb.id = s.sube_id;

create or replace view public.v_hekim_calisma_istisna as
 SELECT i.id,
    i.sube_id,
    COALESCE(sb.ad, 'Tüm şubeler'::character varying) AS sube_adi,
    i.hekim_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hekim_adi,
    i.departman_id,
    COALESCE(d.ad, 'Tüm bölümler'::character varying) AS departman_adi,
    i.tur,
    i.bas_tarih,
    i.bit_tarih,
    i.saat_bas,
    i.saat_bit,
    i.slot_dk,
    i.kanallar,
    i.aciklama,
    i.durum,
    (( SELECT count(*) AS count
           FROM randevu r
          WHERE r.hekim_id = i.hekim_id AND (r.durum = ANY (ARRAY[1, 2])) AND r.baslangic::date >= i.bas_tarih AND r.baslangic::date <= i.bit_tarih AND ((i.tur = ANY (ARRAY[1, 2, 5])) OR i.tur = 3 AND r.baslangic::time without time zone < i.saat_bas::time without time zone)))::integer AS etkilenen_randevu
   FROM hekim_calisma_istisna i
     JOIN taraf t ON t.id = i.hekim_id
     LEFT JOIN departman d ON d.id = i.departman_id
     LEFT JOIN sube sb ON sb.id = i.sube_id;

create or replace view public.v_enabiz_erisim as
 SELECT e.id,
    e.sube_id,
    e.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    e.hasta_kimlik,
    e.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    e.hekim_kimlik,
    e.muayene_id,
    e.belge_id,
    e.zaman,
    e.sonuc,
    COALESCE(ks.ad, ''::character varying) AS sonuc_adi,
    e.anahtar_onek,
    e.servis_mesaji,
    e.ip
   FROM enabiz_erisim e
     JOIN taraf t ON t.id = e.hasta_id
     LEFT JOIN taraf h ON h.id = e.hekim_id
     LEFT JOIN kod_liste lk ON lk.kod::text = 'enabiz.erisim_sonuc'::text
     LEFT JOIN kod_deger ks ON ks.liste_id = lk.id AND ks.deger = e.sonuc;

create or replace view public.v_ariza_talep as
 SELECT t.id,
    t.talep_no,
    t.kategori,
    ( SELECT kod_deger.ad
           FROM kod_deger
          WHERE kod_deger.liste_id = (( SELECT kod_liste.id
                   FROM kod_liste
                  WHERE kod_liste.kod::text = 'ariza.kategori'::text)) AND kod_deger.deger = t.kategori AND kod_deger.dil = 0) AS kategori_adi,
    t.ekip,
    ( SELECT kod_deger.ad
           FROM kod_deger
          WHERE kod_deger.liste_id = (( SELECT kod_liste.id
                   FROM kod_liste
                  WHERE kod_liste.kod::text = 'ariza.ekip'::text)) AND kod_deger.deger = t.ekip AND kod_deger.dil = 0) AS ekip_adi,
    t.konum,
    t.aciklama,
    t.oncelik,
    ( SELECT kod_deger.ad
           FROM kod_deger
          WHERE kod_deger.liste_id = (( SELECT kod_liste.id
                   FROM kod_liste
                  WHERE kod_liste.kod::text = 'ariza.oncelik'::text)) AND kod_deger.deger = t.oncelik AND kod_deger.dil = 0) AS oncelik_adi,
    t.demirbas_id,
    COALESCE(d.ad, ''::character varying) AS demirbas_adi,
    t.talep_eden,
    COALESCE(NULLIF(TRIM(BOTH FROM (te.ad::text || ' '::text) || te.soyad::text), ''::text), public.fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120)::text, ''::text) AS talep_eden_adi,
    t.sorumlu_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (so.ad::text || ' '::text) || so.soyad::text), ''::text), public.fn_taraf_ad(so.unvan, so.ad, so.soyad)::character varying(120)::text, ''::text) AS sorumlu_adi,
    t.durum,
    ( SELECT kod_deger.ad
           FROM kod_deger
          WHERE kod_deger.liste_id = (( SELECT kod_liste.id
                   FROM kod_liste
                  WHERE kod_liste.kod::text = 'ariza.durum'::text)) AND kod_deger.deger = t.durum AND kod_deger.dil = 0) AS durum_adi,
    t.cozum_notu,
    t.kapanis_tarihi,
    t.sube_id,
    t.ekleme_tarihi
   FROM ariza_talep t
     LEFT JOIN demirbas d ON d.id = t.demirbas_id
     LEFT JOIN taraf te ON te.id = t.talep_eden
     LEFT JOIN taraf so ON so.id = t.sorumlu_id;

create or replace view public.v_enabiz_mesaj as
 SELECT m.id,
    m.sube_id,
    m.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    m.hasta_kimlik,
    m.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    m.hekim_kimlik,
    m.belge_id,
    m.kaynak,
    COALESCE(kk.ad, ''::character varying) AS kaynak_adi,
    m.kaynak_id,
    m.mesaj_turu,
    COALESCE(kt.ad, ''::character varying) AS mesaj_turu_adi,
    m.metin,
    m.durum,
    COALESCE(kd.ad, ''::character varying) AS durum_adi,
    m.deneme,
    m.gonderim_zamani,
    m.yanit_kod,
    m.yanit_mesaj,
    m.son_hata,
    m.paket_id,
    COALESCE(p.paket_no, ''::character varying) AS paket_no,
    p.durum AS paket_durum,
    m.ekleme_tarihi,
    m.ekleyen
   FROM enabiz_mesaj m
     JOIN taraf t ON t.id = m.hasta_id
     LEFT JOIN taraf h ON h.id = m.hekim_id
     LEFT JOIN enabiz_paket p ON p.id = m.paket_id
     LEFT JOIN kod_liste lk ON lk.kod::text = 'enabiz.mesaj_kaynak'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = m.kaynak
     LEFT JOIN kod_liste lt ON lt.kod::text = 'enabiz.hasta_mesaj_turu'::text
     LEFT JOIN kod_deger kt ON kt.liste_id = lt.id AND kt.deger = m.mesaj_turu
     LEFT JOIN kod_liste ld ON ld.kod::text = 'enabiz.mesaj_durum'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = ld.id AND kd.deger = m.durum;

create or replace view public.v_ftr_program_lookup as
 SELECT p.id,
    (((p.program_no::text || ' · '::text) || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text))::character varying(200) AS ad,
        CASE
            WHEN p.durum = ANY (ARRAY[1, 2, 3]) THEN 1
            ELSE 0
        END AS aktif
   FROM ftr_program p
     JOIN taraf t ON t.id = p.hasta_id;

create or replace view public.v_ftr_degerlendirme_lookup as
 SELECT d.id,
    (((((to_char(d.tarih::timestamp with time zone, 'DD.MM.YYYY'::text) || ' · '::text) || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text) || ' · '::text) || COALESCE(kd.ad, ''::character varying)::text))::character varying(200) AS ad,
    1 AS aktif
   FROM ftr_degerlendirme d
     JOIN taraf t ON t.id = d.hasta_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ftr.bolge'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger = d.bolge;

create or replace view public.v_ftr_unite as
 SELECT u.id,
    u.sube_id,
    u.kod,
    u.ad,
    u.sorumlu_id,
    COALESCE(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::character varying(120), ''::character varying) AS sorumlu_adi,
    u.aktif,
    u.aciklama,
    (( SELECT count(*) AS count
           FROM ftr_kabin k
          WHERE k.unite_id = u.id AND k.aktif = 1))::integer AS kabin_sayisi
   FROM ftr_unite u
     LEFT JOIN taraf s ON s.id = u.sorumlu_id;

create or replace view public.v_ftr_degerlendirme as
 SELECT d.id,
    d.sube_id,
    d.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    d.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    d.tarih,
    d.bolge,
    COALESCE(kd.ad, ''::character varying) AS bolge_adi,
    d.taraf_yon,
    d.icd_kod,
    d.tani_ad,
    d.sikayet_suresi,
    d.vas_istirahat,
    d.vas_aktivite,
    d.vas_gece,
    d.kirmizi_bayrak,
    d.rapor_no,
    d.rapor_seans,
    d.sevk_kaynak,
    ( SELECT p.program_no
           FROM ftr_program p
          WHERE p.degerlendirme_id = d.id
          ORDER BY p.id DESC
         LIMIT 1) AS program_no,
    (( SELECT count(*) AS count
           FROM ftr_olcek o
          WHERE o.degerlendirme_id = d.id))::integer AS olcek_sayisi
   FROM ftr_degerlendirme d
     JOIN taraf t ON t.id = d.hasta_id
     LEFT JOIN taraf h ON h.id = d.hekim_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ftr.bolge'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger = d.bolge;

create or replace view public.v_ftr_program as
 SELECT p.id,
    p.sube_id,
    p.program_no,
    p.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    p.degerlendirme_id,
    p.hekim_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    p.fizyoterapist_id,
    COALESCE(public.fn_taraf_ad(f.unvan, f.ad, f.soyad)::character varying(120), ''::character varying) AS fizyoterapist_adi,
    p.unite_id,
    COALESCE(u.ad, ''::character varying) AS unite_adi,
    p.kabin_id,
    COALESCE(k.ad, ''::character varying) AS kabin_adi,
    p.bolge,
    COALESCE(kd.ad, ''::character varying) AS bolge_adi,
    p.icd_kod,
    p.tani_ad,
    p.seans_sayisi,
    p.siklik_haftalik,
    p.seans_sure_dk,
    p.saat,
    p.baslangic,
    p.bitis_tahmini,
    p.bitis,
    p.rapor_no,
    p.rapor_seans_hakki,
    p.kalan_hak,
    p.odeyen_kurum_id,
    COALESCE(public.fn_taraf_ad(ku.unvan, ku.ad, ku.soyad)::character varying(120), 'Hasta öder'::character varying) AS odeyen_adi,
    p.belge_id,
    p.ara_degerlendirme_seans,
    p.yapilan_seans,
    p.devamsiz,
    p.durum,
        CASE p.durum
            WHEN 1 THEN 'Taslak'::text
            WHEN 2 THEN 'Sürüyor'::text
            WHEN 3 THEN 'Ara değerlendirme'::text
            WHEN 4 THEN 'Tamamlandı'::text
            WHEN 5 THEN 'Sonlandırıldı'::text
            ELSE ''::text
        END AS durum_adi,
    p.yanit,
    p.sonuc_notu,
    p.aciklama,
    ( SELECT min(s.tarih) AS min
           FROM ftr_seans s
          WHERE s.program_id = p.id AND s.durum = 1 AND s.tarih >= CURRENT_DATE) AS sonraki_seans,
    ( SELECT s.vas_once
           FROM ftr_seans s
          WHERE s.program_id = p.id AND s.durum = 3 AND s.vas_once IS NOT NULL
          ORDER BY s.sira
         LIMIT 1) AS vas_ilk,
    ( SELECT s.vas_sonra
           FROM ftr_seans s
          WHERE s.program_id = p.id AND s.durum = 3 AND s.vas_sonra IS NOT NULL
          ORDER BY s.sira DESC
         LIMIT 1) AS vas_son,
    (( SELECT count(*) AS count
           FROM ftr_program_uygulama x
          WHERE x.program_id = p.id))::integer AS uygulama_sayisi,
    p.ekleme_tarihi
   FROM ftr_program p
     JOIN taraf t ON t.id = p.hasta_id
     LEFT JOIN taraf h ON h.id = p.hekim_id
     LEFT JOIN taraf f ON f.id = p.fizyoterapist_id
     LEFT JOIN ftr_unite u ON u.id = p.unite_id
     LEFT JOIN ftr_kabin k ON k.id = p.kabin_id
     LEFT JOIN taraf ku ON ku.id = p.odeyen_kurum_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ftr.bolge'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger = p.bolge;

create or replace view public.v_ftr_seans as
 SELECT s.id,
    s.sube_id,
    s.program_id,
    p.program_no,
    p.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    p.bolge,
    COALESCE(kd.ad, ''::character varying) AS bolge_adi,
    s.sira,
    p.seans_sayisi,
    s.tarih,
    s.saat,
    s.baslangic,
    s.bitis,
    s.fizyoterapist_id,
    COALESCE(public.fn_taraf_ad(f.unvan, f.ad, f.soyad)::character varying(120), ''::character varying) AS fizyoterapist_adi,
    s.kabin_id,
    COALESCE(k.ad, ''::character varying) AS kabin_adi,
    s.vas_once,
    s.vas_sonra,
    s.ev_uyum,
    s.durum,
        CASE s.durum
            WHEN 1 THEN 'Planlı'::text
            WHEN 2 THEN 'Sürüyor'::text
            WHEN 3 THEN 'Yapıldı'::text
            WHEN 4 THEN 'Gelmedi'::text
            WHEN 5 THEN 'İptal'::text
            WHEN 6 THEN 'Yarım'::text
            ELSE ''::text
        END AS durum_adi,
    (( SELECT count(*) AS count
           FROM ftr_seans_uygulama x
          WHERE x.seans_id = s.id))::integer AS uygulama_sayisi,
    (( SELECT count(*) AS count
           FROM ftr_seans_uygulama x
          WHERE x.seans_id = s.id AND x.yapildi = 1))::integer AS yapilan_uygulama,
        CASE
            WHEN s.baslangic IS NOT NULL THEN EXTRACT(epoch FROM COALESCE(s.bitis, now()) - s.baslangic)::integer / 60
            ELSE 0
        END AS sure_dk,
    s.uygulama_notu,
    s.komplikasyon,
    s.imza
   FROM ftr_seans s
     JOIN ftr_program p ON p.id = s.program_id
     JOIN taraf t ON t.id = p.hasta_id
     LEFT JOIN taraf f ON f.id = s.fizyoterapist_id
     LEFT JOIN ftr_kabin k ON k.id = s.kabin_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ftr.bolge'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger = p.bolge;

create or replace view public.v_ftr_olcek as
 SELECT o.id,
    o.sube_id,
    o.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    o.degerlendirme_id,
    o.program_id,
    COALESCE(p.program_no, ''::character varying) AS program_no,
    o.tarih,
    o.olcek,
    COALESCE(ko.ad, ''::character varying) AS olcek_adi,
    o.asama,
        CASE o.asama
            WHEN 1 THEN 'Kür başı'::text
            WHEN 2 THEN 'Ara'::text
            WHEN 3 THEN 'Kür sonu'::text
            WHEN 4 THEN 'Kontrol'::text
            ELSE ''::text
        END AS asama_adi,
    o.skor,
    o.hedef,
    o.not_metin
   FROM ftr_olcek o
     JOIN taraf t ON t.id = o.hasta_id
     LEFT JOIN ftr_program p ON p.id = o.program_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'ftr.olcek'::text
     LEFT JOIN kod_deger ko ON ko.liste_id = kl.id AND ko.deger = o.olcek;

create or replace view public.v_bzbh_bildirim as
 SELECT b.id,
    b.sube_id,
    b.hasta_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    COALESCE(t.vkno, ''::character varying) AS hasta_kimlik,
    b.muayene_id,
    b.belge_id,
    b.hastalik_id,
    COALESCE(h.ad, ''::character varying) AS hastalik_adi,
    COALESCE(h.grup::integer, 0) AS grup,
    COALESCE(kg.ad, ''::character varying) AS grup_adi,
    COALESCE(h.sure_saat::integer, 24) AS sure_saat,
    b.icd_kod,
    COALESCE(i.ad, ''::character varying) AS icd_adi,
    b.hekim_id,
    COALESCE(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::character varying(120), ''::character varying) AS hekim_adi,
    b.tani_zamani,
    b.vaka_tipi,
    COALESCE(kv.ad, ''::character varying) AS vaka_tipi_adi,
    b.belirti_tarihi,
    b.durum,
    COALESCE(kd.ad, ''::character varying) AS durum_adi,
    b.bildirim_zamani,
    b.paket_id,
    COALESCE(p.paket_no, ''::character varying) AS paket_no,
    b.not_metin,
    b.ekleme_tarihi,
        CASE
            WHEN b.durum <> 0 THEN 0
            WHEN b.tani_zamani IS NULL THEN 0
            WHEN now() > (b.tani_zamani + make_interval(hours => COALESCE(h.sure_saat::integer, 24))) THEN 1
            ELSE 0
        END::smallint AS gecikti
   FROM bzbh_bildirim b
     JOIN taraf t ON t.id = b.hasta_id
     LEFT JOIN bzbh_hastalik h ON h.id = b.hastalik_id
     LEFT JOIN icd i ON i.kod::text = b.icd_kod::text
     LEFT JOIN taraf hk ON hk.id = b.hekim_id
     LEFT JOIN enabiz_paket p ON p.id = b.paket_id
     LEFT JOIN kod_liste lg ON lg.kod::text = 'bzbh.grup'::text
     LEFT JOIN kod_deger kg ON kg.liste_id = lg.id AND kg.deger = COALESCE(h.grup::integer, 0)
     LEFT JOIN kod_liste lv ON lv.kod::text = 'bzbh.vaka_tipi'::text
     LEFT JOIN kod_deger kv ON kv.liste_id = lv.id AND kv.deger = b.vaka_tipi
     LEFT JOIN kod_liste ld ON ld.kod::text = 'bzbh.durum'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = ld.id AND kd.deger = b.durum;

create or replace view public.v_tedarikci_skor as
 SELECT t.id AS firma_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS unvan,
    COALESCE(100::numeric + sum(o.skor_etki) FILTER (WHERE o.zaman >= (now() - '1 year'::interval)), 100::numeric)::numeric(6,2) AS skor,
    count(*) FILTER (WHERE o.tur = 1 AND o.zaman >= (now() - '1 year'::interval)) AS gecikme,
    count(*) FILTER (WHERE o.tur = 2 AND o.zaman >= (now() - '1 year'::interval)) AS uygunsuzluk,
    count(*) FILTER (WHERE o.tur = 3 AND o.zaman >= (now() - '1 year'::interval)) AS fatura_farki,
    (EXISTS ( SELECT 1
           FROM tedarikci_belge b
          WHERE b.firma_id = t.id AND b.gecerlilik IS NOT NULL AND b.gecerlilik < CURRENT_DATE)) AS belge_suresi_doldu
   FROM taraf t
     LEFT JOIN tedarikci_olay o ON o.firma_id = t.id
  WHERE t.tedarikci = 1
  GROUP BY t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120);

create or replace view public.v_kabul_irsaliye_lookup as
 SELECT b.id,
    ((((COALESCE(NULLIF(b.belge_no::text, ''::text), '#'::text || b.id) || ' · '::text) || to_char(b.belge_tarihi, 'DD.MM.YYYY'::text)) || ' · '::text) || COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), '(tedarikçi yok)'::text)) ||
        CASE
            WHEN b.tur = 11 THEN ' · fatura'::text
            ELSE ''::text
        END AS ad,
        CASE
            WHEN COALESCE(b.durum::integer, 0) = 2 THEN 0
            ELSE 1
        END::smallint AS aktif,
    b.sube_id,
    b.belge_tarihi
   FROM belge b
     LEFT JOIN taraf t ON t.id = b.taraf_id
  WHERE (b.tur = ANY (ARRAY[10, 11])) AND b.belge_tarihi >= (CURRENT_DATE - '1 year'::interval);

create or replace view public.v_kabul_siparis_lookup as
 SELECT b.id,
    (((COALESCE(NULLIF(b.belge_no::text, ''::text), '#'::text || b.id) || ' · '::text) || to_char(b.belge_tarihi, 'DD.MM.YYYY'::text)) || ' · '::text) || COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), '(tedarikçi yok)'::text) AS ad,
        CASE
            WHEN COALESCE(b.durum::integer, 0) = 2 THEN 0
            ELSE 1
        END::smallint AS aktif,
    b.sube_id,
    b.belge_tarihi
   FROM belge b
     LEFT JOIN taraf t ON t.id = b.taraf_id
  WHERE b.tur = 9 AND b.belge_tarihi >= (CURRENT_DATE - '1 year'::interval);

create or replace view public.v_basvuru_hekim as
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    COALESCE(t.kod, ''::character varying) AS kod,
    regexp_replace((COALESCE(t.cep_tel, ''::character varying)::text || ' '::text) || COALESCE(t.telefon, ''::character varying)::text, '[^0-9]'::text, ''::text, 'g'::text) AS telefon_ham,
    COALESCE(t.departman::integer, 0) AS bolum_id,
    COALESCE(( SELECT regexp_replace(d.ad::text, '^—\s*'::text, ''::text) AS regexp_replace
           FROM departman d
          WHERE d.id = t.departman), ''::text) AS bolum_adi,
    ( SELECT count(*) AS count
           FROM belge_basvuru bb
             JOIN belge b ON b.id = bb.id
          WHERE bb.personel_id = t.id AND b.tur = 19 AND b.tipi = 30 AND b.belge_tarihi::date = CURRENT_DATE) AS bugun_basvuru,
    COALESCE(t.durum::integer, 1) AS durum,
    1::smallint AS dis_mi
   FROM taraf t
     JOIN taraf_personel p ON p.id = t.id
  WHERE t.personel = 1 AND p.dis_hekim = 1 AND fn_basvuru_hekim_dis_mi(0) = 1
UNION ALL
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    COALESCE(t.kod, ''::character varying) AS kod,
    regexp_replace((COALESCE(t.cep_tel, ''::character varying)::text || ' '::text) || COALESCE(t.telefon, ''::character varying)::text, '[^0-9]'::text, ''::text, 'g'::text) AS telefon_ham,
    COALESCE(t.departman::integer, 0) AS bolum_id,
    COALESCE(( SELECT regexp_replace(d.ad::text, '^—\s*'::text, ''::text) AS regexp_replace
           FROM departman d
          WHERE d.id = t.departman), ''::text) AS bolum_adi,
    ( SELECT count(*) AS count
           FROM belge_basvuru bb
             JOIN belge b ON b.id = bb.id
          WHERE bb.personel_id = t.id AND b.tur = 19 AND b.tipi = 30 AND b.belge_tarihi::date = CURRENT_DATE) AS bugun_basvuru,
    COALESCE(t.durum::integer, 1) AS durum,
    0::smallint AS dis_mi
   FROM taraf t
  WHERE t.personel = 1 AND fn_hekim_planli(t.id) = 1 AND fn_basvuru_hekim_dis_mi(0) = 0;

create or replace view public.v_cek_senet_portfoy as
 SELECT c.id,
    c.tur,
    c.yon,
    c.durum,
    c.vade,
    c.tutar,
    c.doviz_cinsi,
    c.yerel_tutar,
    c.seri_no,
    c.banka_adi,
    c.taraf_id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS taraf_unvan,
    c.hesap_id,
    h.ad AS hesap_adi,
    c.proje_id,
    c.sube_id,
    c.vade - CURRENT_DATE AS kalan_gun
   FROM cek_senet c
     LEFT JOIN taraf t ON t.id = c.taraf_id
     LEFT JOIN hesap h ON h.id = c.hesap_id
  WHERE c.durum <> ALL (ARRAY[0, 50, 70]);

create or replace view public.v_dis_hekim_lookup as
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    COALESCE(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::character varying(120), ''::character varying)::text AS kurum,
    COALESCE(kd.ad, ''::character varying) AS brans,
    t.durum AS aktif
   FROM taraf t
     JOIN taraf_personel p ON p.id = t.id
     LEFT JOIN taraf k ON k.id = t.bag_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'hekim.brans'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger::text = NULLIF(p.brans::text, ''::text)
  WHERE p.dis_hekim = 1 AND COALESCE(t.durum::integer, 1) = 1;

create or replace view public.v_firsat_liste as
 SELECT f.id,
    f.firsat_no,
    f.konu,
    f.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS taraf_unvan,
    COALESCE(sk.ad, ''::character varying) AS sektor,
    f.sorumlu_id,
    COALESCE(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::character varying(120), ''::character varying) AS sorumlu_adi,
    f.kaynak,
    f.tur,
    f.asama,
    f.oncelik,
    f.durum,
    f.tahmini_tutar,
    f.doviz_cinsi,
    f.doviz_kuru,
    f.olasilik,
    round(f.tahmini_tutar * f.olasilik::numeric / 100.0, 2) AS agirlikli_tutar,
    f.beklenen_kapanis,
    f.son_temas,
    f.sonraki_aksiyon,
    f.kapanis_tarihi,
    f.kayip_nedeni,
    f.aciklama,
    f.sube_id,
    f.ekleme_tarihi
   FROM firsat f
     LEFT JOIN taraf t ON t.id = f.taraf_id
     LEFT JOIN taraf s ON s.id = f.sorumlu_id
     LEFT JOIN kod_liste kls ON kls.kod::text = 'taraf.sektor'::text
     LEFT JOIN kod_deger sk ON sk.liste_id = kls.id AND sk.deger = t.sektor;

create or replace view public.v_hakedis_ozet as
 SELECT hs.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS kisi,
    count(*) FILTER (WHERE hs.hakedis_id IS NULL AND (hs.durum = ANY (ARRAY[2, 3]))) AS acik_satir,
    COALESCE(sum(hs.tutar) FILTER (WHERE hs.hakedis_id IS NULL AND (hs.durum = ANY (ARRAY[2, 3]))), 0::numeric) AS acik_tutar,
    count(*) FILTER (WHERE hs.durum = 1) AS taslak_satir,
    COALESCE(sum(hs.tutar) FILTER (WHERE hs.durum = 1), 0::numeric) AS taslak_tutar,
    COALESCE(sum(hs.tutar) FILTER (WHERE hs.hakedis_id IS NOT NULL), 0::numeric) AS kapanan_tutar,
    COALESCE(sum(hs.tutar), 0::numeric) AS toplam,
    min(hs.tarih) AS ilk_tarih,
    max(hs.tarih) AS son_tarih
   FROM hakedis_satir hs
     LEFT JOIN taraf t ON t.id = hs.taraf_id
  WHERE hs.durum <> 0
  GROUP BY hs.taraf_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120);

create or replace view public.v_hasta_lookup as
 SELECT t.id,
    (((((COALESCE(NULLIF(TRIM(BOTH FROM public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)), ''::text), TRIM(BOTH FROM (t.ad::text || ' '::text) || t.soyad::text)) ||
        CASE h.cinsiyet
            WHEN 1 THEN ' — ♂ E'::text
            WHEN 2 THEN ' — ♀ K'::text
            ELSE ' — ?'::text
        END) ||
        CASE
            WHEN h.dogum_tarihi IS NOT NULL THEN ' '::text || EXTRACT(year FROM age(h.dogum_tarihi::timestamp with time zone))::integer::text
            ELSE ''::text
        END) ||
        CASE
            WHEN COALESCE(NULLIF(t.cep_tel::text, ''::text), NULLIF(t.telefon::text, ''::text), ''::text) <> ''::text THEN ' · ☎ '::text || COALESCE(NULLIF(t.cep_tel::text, ''::text), t.telefon::text)
            ELSE ''::text
        END) ||
        CASE
            WHEN t.durum = 2 THEN ' · ADAY'::text
            ELSE ''::text
        END))::character varying(200) AS ad,
        CASE
            WHEN t.durum = ANY (ARRAY[1, 2]) THEN 1
            ELSE 0
        END AS aktif
   FROM taraf t
     LEFT JOIN taraf_hasta h ON h.id = t.id
  WHERE t.hasta = 1;

create or replace view public.v_hesap_atama_lookup as
 SELECT '-1'::integer AS id,
    '★ Ana Kasa (varsayılan)'::text AS ad,
    1 AS aktif
UNION
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text AS ad,
    1 AS aktif
   FROM taraf t
  WHERE t.personel = 1 AND t.durum = 1
UNION
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text AS ad,
    1 AS aktif
   FROM taraf t
     JOIN taraf_kullanici k ON k.id = t.id
  WHERE k.aktif = 1;

create or replace view public.v_kullanici_lookup as
 SELECT k.id,
    COALESCE(NULLIF(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text), k.kod::text)::character varying AS ad,
    k.aktif
   FROM taraf_kullanici k
     LEFT JOIN taraf t ON t.id = k.id;

create or replace view public.v_kurum_lookup as
 SELECT t.id,
        CASE
            WHEN t.kod::text = ''::text THEN public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text
            ELSE (t.kod::text || ' - '::text) || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text
        END AS ad,
        CASE
            WHEN t.durum = 1 AND (EXISTS ( SELECT 1
               FROM kurum_sozlesme s
              WHERE s.kurum_id = t.id AND s.durum = 1 AND (s.baslangic IS NULL OR s.baslangic <= CURRENT_DATE) AND (s.bitis IS NULL OR s.bitis >= CURRENT_DATE))) THEN 1
            ELSE 0
        END AS aktif
   FROM taraf t
     JOIN taraf_kurum k ON k.id = t.id
  WHERE t.kurum = 1;

create or replace view public.v_mali_hareket_ek as
 SELECT m.id,
    m.kasa_islem_id,
    m.sira,
    m.tur,
    t.ad AS tur_adi,
    t.grup AS tur_grup,
    t.cari_ekstre,
    t.hesap_ekstre,
    t.bakiye_dahil,
    m.hesap_turu,
    m.hesap_id,
    h.ad AS hesap_adi,
    h.doviz_cinsi AS hesap_dovizi,
    m.taraf_id,
    COALESCE(NULLIF(ki.taraf_unvan::text, ''::text), public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::character varying(120)::text, ''::text) AS taraf_unvan,
    m.belge_id,
    m.belge_no,
    COALESCE(ki.islem_no, ''::character varying) AS islem_no,
    m.islem_tarihi,
    m.plan_tarihi,
    m.borc,
    m.alacak,
    m.doviz_cinsi,
    m.doviz_kuru,
    m.yerel_borc,
    m.yerel_alacak,
    m.masraf_id,
    ma.ad AS masraf_adi,
    m.hizmet_id,
    hz.ad AS hizmet_adi,
    COALESCE(m.proje_id, ki.proje_id) AS proje_id,
    p.ad AS proje_adi,
    m.merkez_id,
    m.cek_senet_id,
    m.aciklama,
    m.sube_id,
    COALESCE(ki.durum::integer, 2) AS islem_durum
   FROM mali_hareket m
     JOIN kasa_islem_turu t ON t.kod = m.tur
     LEFT JOIN kasa_islem ki ON ki.id = m.kasa_islem_id
     LEFT JOIN hesap h ON h.id = m.hesap_id
     LEFT JOIN taraf tr ON tr.id = m.taraf_id
     LEFT JOIN masraf ma ON ma.id = m.masraf_id
     LEFT JOIN hizmet hz ON hz.id = m.hizmet_id
     LEFT JOIN proje p ON p.id = COALESCE(m.proje_id, ki.proje_id)
  WHERE COALESCE(ki.kaynak_tur, 0) <> 6;

create or replace view public.v_plan_vade as
 SELECT ki.id,
    ki.tur,
    t.ad AS tur_adi,
    t.grup AS tur_grup,
    ki.plan_tarihi,
    ki.taraf_id,
    COALESCE(NULLIF(ki.taraf_unvan::text, ''::text), public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::character varying(120)::text, ''::text) AS taraf_unvan,
    ki.doviz_cinsi,
    ki.tutar,
    ki.gerceklesen_tutar,
    ki.kalan_tutar,
    ki.yerel_tutar,
    ki.aciklama,
    ki.proje_id,
    ki.sube_id,
    CURRENT_DATE - ki.plan_tarihi AS gecikme_gun
   FROM kasa_islem ki
     JOIN kasa_islem_turu t ON t.kod = ki.tur
     LEFT JOIN taraf tr ON tr.id = ki.taraf_id
  WHERE ki.durum = 1;

create or replace view public.v_prim_taraf_lookup as
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    1 AS aktif
   FROM taraf t
     JOIN taraf_personel p ON p.id = t.id;

create or replace view public.v_mesaj_sohbet as
 SELECT s.id,
    u.kullanici_id,
    s.tip,
        CASE
            WHEN s.tip = ANY (ARRAY[2, 3]) THEN s.ad::text
            ELSE COALESCE(( SELECT COALESCE(NULLIF(btrim(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text), ''::text), t.kod::text) AS "coalesce"
               FROM mesaj_uye u2
                 JOIN taraf t ON t.id = u2.kullanici_id
              WHERE u2.sohbet_id = s.id AND u2.kullanici_id <> u.kullanici_id
              ORDER BY u2.kullanici_id
             LIMIT 1), '(boş sohbet)'::text)
        END AS baslik,
        CASE
            WHEN s.tip = 1 THEN ( SELECT u3.kullanici_id
               FROM mesaj_uye u3
              WHERE u3.sohbet_id = s.id AND u3.kullanici_id <> u.kullanici_id
              ORDER BY u3.kullanici_id
             LIMIT 1)
            ELSE NULL::integer
        END AS karsi_id,
    s.son_mesaj_tarihi,
    ( SELECT m.metin
           FROM mesaj m
          WHERE m.sohbet_id = s.id AND m.durum = 1
          ORDER BY m.tarih DESC, m.id DESC
         LIMIT 1) AS son_metin,
    ( SELECT m.gonderen_id
           FROM mesaj m
          WHERE m.sohbet_id = s.id AND m.durum = 1
          ORDER BY m.tarih DESC, m.id DESC
         LIMIT 1) AS son_gonderen_id,
    (( SELECT count(*) AS count
           FROM mesaj m
          WHERE m.sohbet_id = s.id AND m.durum = 1 AND m.gonderen_id <> u.kullanici_id AND (u.son_okuma IS NULL OR m.tarih > u.son_okuma)))::integer AS okunmamis,
    (( SELECT count(*) AS count
           FROM mesaj_uye u4
          WHERE u4.sohbet_id = s.id AND u4.ayrilma_tarihi IS NULL))::integer AS uye_sayisi,
    u.favori,
    u.sabit,
    u.sessiz,
    u.arsiv,
    u.rol,
    u.son_okuma,
    s.kaynak_tur,
    s.kaynak_id
   FROM mesaj_sohbet s
     JOIN mesaj_uye u ON u.sohbet_id = s.id AND u.ayrilma_tarihi IS NULL
  WHERE s.durum = 1;

create or replace view public.v_prim_rol_aday as
 SELECT r.taraf_id AS id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    r.rol,
    r.varsayilan,
    0::smallint AS dis_mi,
    COALESCE(t.departman::integer, 0) AS bolum_id,
    COALESCE(t.durum::integer, 1) AS durum
   FROM taraf_prim_rol r
     JOIN taraf t ON t.id = r.taraf_id
     JOIN taraf_personel p ON p.id = r.taraf_id
  WHERE COALESCE(p.dis_hekim::integer, 0) = 0 AND COALESCE(p.calisma_sekli::integer, 0) = 3
UNION ALL
 SELECT t.id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    1::smallint AS rol,
    1::smallint AS varsayilan,
    1::smallint AS dis_mi,
    COALESCE(t.departman::integer, 0) AS bolum_id,
    COALESCE(t.durum::integer, 1) AS durum
   FROM taraf t
     JOIN taraf_personel p ON p.id = t.id
  WHERE p.dis_hekim = 1 AND COALESCE(p.calisma_sekli::integer, 0) = 3
UNION ALL
 SELECT r.taraf_id AS id,
    public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS ad,
    r.rol,
    r.varsayilan,
    1::smallint AS dis_mi,
    COALESCE(t.departman::integer, 0) AS bolum_id,
    COALESCE(t.durum::integer, 1) AS durum
   FROM taraf_prim_rol r
     JOIN taraf t ON t.id = r.taraf_id
     JOIN taraf_personel p ON p.id = r.taraf_id
  WHERE p.dis_hekim = 1 AND COALESCE(p.calisma_sekli::integer, 0) = 3 AND r.rol = 5;

create or replace view public.v_radyoloji_kritik_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    i.cekim_tarihi,
    kb.id AS bildirim_id,
    COALESCE(kb.bulgu, ''::character varying) AS bulgu,
    COALESCE(kb.bildirilen_ad, ''::character varying) AS bildirilen_ad,
    kb.bildiren_id,
    COALESCE(public.fn_taraf_ad(bd.unvan, bd.ad, bd.soyad)::character varying(120), ''::character varying) AS bildiren,
    kb.yol,
    kb.bildirim_zamani,
    COALESCE(kb.teyit_alindi::integer, 0) AS teyit_alindi,
    kb.kapatma_zamani,
        CASE
            WHEN kb.id IS NULL THEN 1
            WHEN kb.kapatma_zamani IS NOT NULL THEN 4
            WHEN COALESCE(kb.teyit_alindi::integer, 0) = 1 THEN 3
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(kb.bildirim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, r.yazma_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS gecen_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.sablon_id,
            x.sablon_surum,
            x.durum,
            x.yazan_id,
            x.yazma_tarihi,
            x.onaylayan_id,
            x.onay_tarihi,
            x.kilit,
            x.ust_rapor_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi,
            x.rapor_no
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN LATERAL ( SELECT k.id,
            k.istem_id,
            k.rapor_id,
            k.bulgu,
            k.bildiren_id,
            k.bildirilen_id,
            k.bildirilen_ad,
            k.yol,
            k.bildirim_zamani,
            k.geri_bildirim,
            k.ekleyen,
            k.ekleme_tarihi,
            k.teyit_alindi,
            k.kapatan_id,
            k.kapatma_zamani
           FROM radyoloji_kritik_bulgu k
          WHERE k.istem_id = i.id
          ORDER BY k.id DESC
         LIMIT 1) kb ON true
     LEFT JOIN taraf bd ON bd.id = kb.bildiren_id
  WHERE COALESCE(i.kritik::integer, 0) = 1 AND COALESCE(i.durum::integer, 1) > 0;

create or replace view public.v_radyoloji_teslim_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    COALESCE(h.telefon, ''::character varying) AS telefon,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    COALESCE(public.fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::character varying(120), ''::character varying) AS radyolog,
    i.durum AS istem_durum,
    COALESCE(i.cd_istendi::integer, 0) AS cd_istendi,
    t.id AS teslim_id,
    t.teslim_zamani,
    COALESCE(t.alan_ad, ''::character varying) AS alan_ad,
    COALESCE(t.alan_yakinlik, ''::character varying) AS alan_yakinlik,
    COALESCE(public.fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120), ''::character varying) AS teslim_eden,
    COALESCE(t.rapor_verildi::integer, 0) AS rapor_verildi,
    COALESCE(t.film_verildi::integer, 0) AS film_verildi,
    COALESCE(t.cd_verildi::integer, 0) AS cd_verildi,
    COALESCE(t.dijital_verildi::integer, 0) AS dijital_verildi,
        CASE
            WHEN t.id IS NULL THEN 1
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.sablon_id,
            x.sablon_surum,
            x.durum,
            x.yazan_id,
            x.yazma_tarihi,
            x.onaylayan_id,
            x.onay_tarihi,
            x.kilit,
            x.ust_rapor_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi,
            x.rapor_no
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN taraf ry ON ry.id = COALESCE(r.onaylayan_id, r.yazan_id)
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.rapor_id,
            x.tur,
            x.teslim_zamani,
            x.teslim_eden_id,
            x.alan_ad,
            x.alan_yakinlik,
            x.kimlik_dogrulandi,
            x.aciklama,
            x.ekleyen,
            x.ekleme_tarihi,
            x.rapor_verildi,
            x.film_verildi,
            x.cd_verildi,
            x.dijital_verildi
           FROM radyoloji_teslim x
          WHERE x.istem_id = i.id
          ORDER BY x.id DESC
         LIMIT 1) t ON true
     LEFT JOIN taraf te ON te.id = t.teslim_eden_id
  WHERE COALESCE(i.durum::integer, 1) >= 5;

create or replace view public.v_sigorta_hesap_lookup as
 SELECT h.id,
    s.kod,
    ((s.ad::text || ' · '::text) || COALESCE(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::character varying(120), ''::character varying)::text) ||
        CASE
            WHEN e.test_mi = 1 THEN ' (test)'::text
            ELSE ''::text
        END AS ad,
        CASE
            WHEN h.durum = 0 THEN 1
            ELSE 0
        END::smallint AS aktif
   FROM sigorta_hesap h
     JOIN sigorta_saglayici s ON s.id = h.saglayici_id
     JOIN entegrasyon_hesap e ON e.id = h.hesap_id
     LEFT JOIN taraf k ON k.id = h.kurum_id;

create or replace view public.v_rad_hekim_lookup as
 SELECT t.id,
    TRIM(BOTH FROM (COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying)::text ||
        CASE
            WHEN COALESCE(h.brans, ''::character varying)::text <> ''::text THEN ' · '::text || h.brans::text
            WHEN COALESCE(kd.ad, ''::character varying)::text <> ''::text THEN ' · '::text || kd.ad::text
            ELSE ''::text
        END) ||
        CASE
            WHEN COALESCE(h.dis_mi::integer, 0) = 1 OR COALESCE(p.dis_hekim::integer, 0) = 1 THEN ' (dış)'::text
            ELSE ''::text
        END)::character varying(200) AS ad,
        CASE
            WHEN COALESCE(t.durum::integer, 1) = 1 THEN 1
            ELSE 0
        END AS aktif
   FROM taraf t
     LEFT JOIN taraf_hekim h ON h.id = t.id
     LEFT JOIN taraf_personel p ON p.id = t.id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'hekim.brans'::text
     LEFT JOIN kod_deger kd ON kd.liste_id = kl.id AND kd.deger::text = NULLIF(p.brans::text, ''::text)
  WHERE t.hekim = 1 OR t.personel = 1 AND fn_hekim_planli(t.id) = 1 OR COALESCE(p.dis_hekim::integer, 0) = 1;

create or replace view public.v_radyoloji_worklist as
 SELECT i.id,
    i.sube_id,
    i.accession_no,
    i.durum,
    i.oncelik,
    i.modalite,
    COALESCE(md.ad, ''::character varying) AS modalite_adi,
    COALESCE(dd.ad, ''::character varying) AS durum_adi,
    i.cekim_tarihi,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta_adi,
    COALESCE(hz.kod, ''::character varying) AS tetkik_kodu,
    COALESCE(hz.ad, ''::character varying) AS tetkik_adi,
    COALESCE(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::character varying(120), NULLIF(i.dis_hekim_ad::text, ''::text)::character varying) AS isteyen,
    COALESCE(public.fn_taraf_ad(ik.unvan, ik.ad, ik.soyad)::character varying(120), ''::character varying) AS isteyen_kurum,
    i.belge_id,
    b.belge_no,
    COALESCE(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::character varying(120), ''::character varying) AS odeyen_kurum,
    r.id AS rapor_id,
    COALESCE(r.durum::integer, 0) AS rapor_durum,
    COALESCE(public.fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::character varying(120), ''::character varying) AS raporlayan,
    round(EXTRACT(epoch FROM now()::timestamp without time zone::timestamp with time zone - COALESCE(i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk,
    i.serbest
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN taraf ih ON ih.id = i.istek_hekim_id
     LEFT JOIN taraf ik ON ik.id = i.istek_kurum_id
     LEFT JOIN belge b ON b.id = i.belge_id
     LEFT JOIN belge_basvuru bb ON bb.id = b.id
     LEFT JOIN taraf ok ON ok.id = bb.odeyen_kurum_id
     LEFT JOIN radyoloji_rapor r ON r.istem_id = i.id AND r.ust_rapor_id IS NULL
     LEFT JOIN taraf ry ON ry.id = COALESCE(r.onaylayan_id, r.yazan_id)
     LEFT JOIN kod_deger md ON md.deger = i.modalite AND md.liste_id = (( SELECT kod_liste.id
           FROM kod_liste
          WHERE kod_liste.kod::text = 'rad.modalite'::text))
     LEFT JOIN kod_deger dd ON dd.deger = i.durum AND dd.liste_id = (( SELECT kod_liste.id
           FROM kod_liste
          WHERE kod_liste.kod::text = 'rad.istem_durum'::text));

create or replace view public.v_hakedis_satir as
 SELECT hs.id,
    hs.hakedis_id,
    hs.taraf_id,
    COALESCE(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''::character varying) AS kisi,
    hs.rol,
    COALESCE(kr.ad, ''::character varying) AS rol_adi,
    hs.tarih,
    hs.belge_tur,
    COALESCE(bt.ad, ''::character varying) AS belge_tur_adi,
    k.tur AS tahsilat_turu,
    COALESCE(tt.ad, ''::character varying) AS tahsilat_turu_adi,
        CASE
            WHEN hs.dagitim_id IS NULL THEN 2
            ELSE 1
        END AS kaynak_tur,
        CASE
            WHEN hs.dagitim_id IS NULL THEN 'Faturalama'::text
            ELSE 'Tahsilat'::text
        END AS kaynak_adi,
    hs.pay,
        CASE hs.pay
            WHEN 2 THEN 'Kurum payı'::text
            WHEN 1 THEN 'Hasta payı'::text
            ELSE 'Tümü'::text
        END AS pay_adi,
    hs.taban,
    hs.oran_tipi,
    hs.deger,
    hs.pay_yuzde,
    hs.tutar,
    hs.durum,
        CASE hs.durum
            WHEN 1 THEN 'Taslak'::text
            WHEN 2 THEN 'Kesin'::text
            WHEN 3 THEN 'Onaylı'::text
            WHEN 4 THEN 'Ödendi'::text
            ELSE ''::text
        END AS durum_adi,
    hs.belge_satir_id,
    s.belge_id,
    COALESCE(hz.ad, st.ad, s.aciklama::character varying, ''::character varying) AS kalem,
    COALESCE(public.fn_taraf_ad(h2.unvan, h2.ad, h2.soyad)::character varying(120), ''::character varying) AS hasta,
    b.sube_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM v_prim_rol_aday a
              WHERE a.id = hs.taraf_id AND a.rol = hs.rol)) THEN 1
            ELSE 0
        END::smallint AS rol_isaretli,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM v_prim_rol_aday a
              WHERE a.id = hs.taraf_id AND a.rol = hs.rol)) THEN 'Uygun'::text
            ELSE 'İşaret yok'::text
        END AS isaret_adi
   FROM hakedis_satir hs
     LEFT JOIN taraf t ON t.id = hs.taraf_id
     JOIN belge_satir s ON s.id = hs.belge_satir_id
     JOIN belge b ON b.id = s.belge_id
     LEFT JOIN kasa_islem_dagitim d ON d.id = hs.dagitim_id
     LEFT JOIN kasa_islem k ON k.id = d.kasa_islem_id
     LEFT JOIN kasa_islem_turu tt ON tt.kod = k.tur
     LEFT JOIN kasa_islem_turu bt ON bt.kod = hs.belge_tur
     LEFT JOIN taraf h2 ON h2.id = b.taraf_id
     LEFT JOIN hizmet hz ON hz.id = s.hizmet_id
     LEFT JOIN stok st ON st.id = s.stok_id
     LEFT JOIN kod_liste kl ON kl.kod::text = 'prim.rol'::text
     LEFT JOIN kod_deger kr ON kr.liste_id = kl.id AND kr.deger = hs.rol
  WHERE hs.durum <> 0;

create or replace view public.v_form_istek as
 SELECT i.id,
    i.sablon_id,
    s.kod AS sablon_kod,
    s.ad AS sablon_adi,
    s.aile,
    ka.ad AS aile_adi,
    i.surum,
    i.hasta_id,
    COALESCE(NULLIF(TRIM(BOTH FROM (t.ad::text || ' '::text) || t.soyad::text), ''::text), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120)::text, ''::text) AS hasta_adi,
    i.kaynak_tur,
    kb.ad AS kaynak_adi,
    i.kaynak_id,
    i.kanal,
    kk.ad AS kanal_adi,
    i.son_gecerlilik,
    i.gonderim,
    i.acilis,
    i.dogrulama_deneme,
    i.riza_zamani,
    i.asama,
    i.skor,
    i.sonuc,
    i.tamamlanma,
    i.dolduran_id,
    COALESCE(kd.ad, ''::character varying) AS dolduran_adi,
    i.aktarim_zamani,
    i.durum,
    kdu.ad AS durum_adi,
    jsonb_array_length(i.imzalar) AS imza_sayisi,
    i.aciklama,
    i.sube_id,
    i.ekleme_tarihi,
    i.ekleyen,
    COALESCE(ke.ad, ''::character varying) AS gonderen_adi,
        CASE
            WHEN (i.durum = ANY (ARRAY[1, 2, 3])) AND i.son_gecerlilik IS NOT NULL AND i.son_gecerlilik < now() THEN 1
            ELSE 0
        END AS suresi_gecti
   FROM form_istek i
     JOIN form_sablon s ON s.id = i.sablon_id
     LEFT JOIN taraf t ON t.id = i.hasta_id
     LEFT JOIN v_kullanici_lookup kd ON kd.id = i.dolduran_id
     LEFT JOIN v_kullanici_lookup ke ON ke.id = i.ekleyen
     LEFT JOIN kod_liste la ON la.kod::text = 'form.aile'::text
     LEFT JOIN kod_deger ka ON ka.liste_id = la.id AND ka.deger = s.aile
     LEFT JOIN kod_liste lb ON lb.kod::text = 'form.baglam'::text
     LEFT JOIN kod_deger kb ON kb.liste_id = lb.id AND kb.deger = i.kaynak_tur
     LEFT JOIN kod_liste lk ON lk.kod::text = 'form.kanal'::text
     LEFT JOIN kod_deger kk ON kk.liste_id = lk.id AND kk.deger = i.kanal
     LEFT JOIN kod_liste ldu ON ldu.kod::text = 'form.istek_durum'::text
     LEFT JOIN kod_deger kdu ON kdu.liste_id = ldu.id AND kdu.deger = i.durum;

CREATE OR REPLACE FUNCTION public.fn_panel_profil(p_sube integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
    v_tip     text;
    v_baslik  text;
    v_kutular jsonb := '[]'::jsonb;
    v_bloklar jsonb := '[]'::jsonb;
begin
    select kurum_tipi into v_tip
      from public.kurum_profil
     where sube_id in (p_sube, 0)
     order by (sube_id = p_sube) desc
     limit 1;
    v_tip := coalesce(v_tip, '');

    -- ------------------------------------------------------ LABORATUVAR --
    if v_tip in ('lab', 'goruntuleme_lab') then
        v_baslik := 'Laboratuvar';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','numune','baslik','Kabul bekleyen numune',
                'deger',(select count(*) from public.lab_numune where durum in (1,2)),
                'alt','etiketlendi / alındı','vurgu','normal','rota','/lab-numune') k
            union all select jsonb_build_object('sira','2','kod','cihazda','baslik','Cihazda çalışılıyor',
                'deger',(select count(*) from public.lab_numune where durum = 4),
                'alt','sonuç bekleniyor','vurgu','normal','rota','/lab-numune')
            union all select jsonb_build_object('sira','3','kod','onay','baslik','Onay bekleyen sonuç',
                'deger',(select count(*) from public.lab_sonuc where durum not in (3,4)),
                'alt','teknik onay / onay','vurgu','uyari','rota','/lab-sonuc')
            union all select jsonb_build_object('sira','4','kod','panik','baslik','Teyit bekleyen panik değer',
                'deger',(select count(*) from public.lab_panik_bildirim where teyit_zamani is null),
                'alt','bildirim teyidi yok','vurgu','tehlike','rota','/lab-sonuc')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod','bolum','baslik','Bölüm kuyruğu','ipucu','çalışılmayı bekleyen tetkik',
            'kolonlar', jsonb_build_array('Bölüm','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(b.ad, s.adet::text) order by s.adet desc)
                  from (select t.bolum, count(*) adet
                          from public.lab_istem_satir i
                          join public.lab_tetkik t on t.id = i.tetkik_id
                         where i.durum < 3 group by t.bolum) s
                  left join lateral (
                        select coalesce(d.ad, 'Bölüm ' || s.bolum) ad
                          from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                         where l.kod = 'lab.bolum' and d.deger = s.bolum) b on true
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ GÖRÜNTÜLEME --
    elsif v_tip = 'goruntuleme' then
        v_baslik := 'Görüntüleme Merkezi';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','istem','baslik','Bekleyen istem',
                'deger',(select count(*) from public.radyoloji_istem where durum = 1),
                'alt','çekim bekliyor','vurgu','normal','rota','/radyoloji-istem') k
            union all select jsonb_build_object('sira','2','kod','cekildi','baslik','Çekildi',
                'deger',(select count(*) from public.radyoloji_istem where durum = 2),
                'alt','rapor yazılacak','vurgu','normal','rota','/radyoloji-istem')
            union all select jsonb_build_object('sira','3','kod','rapor','baslik','Rapor bekleyen',
                'deger',(select count(*) from public.radyoloji_istem where durum in (2,3,4)),
                'alt','onaylanmamış','vurgu','uyari','rota','/radyoloji-rapor')
            union all select jsonb_build_object('sira','4','kod','bugun','baslik','Bugün onaylanan',
                'deger',(select count(*) from public.radyoloji_istem
                          where durum >= 5 and degistirme_tarihi::date = current_date),
                'alt','tamamlanan rapor','vurgu','olumlu','rota','/radyoloji-rapor')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod','modalite','baslik','Modalite kuyruğu','ipucu','bekleyen istem sayısı',
            'kolonlar', jsonb_build_array('Modalite','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(coalesce(d.ad,'Tanımsız'), s.adet::text)
                                 order by s.adet desc)
                  from (select i.modalite, count(*) adet from public.radyoloji_istem i
                         where i.durum in (1,2,3,4) group by i.modalite) s
                  left join public.kod_liste l on l.kod = 'rad.modalite'
                  left join public.kod_deger d on d.liste_id = l.id and d.deger = s.modalite
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ TIP MERKEZİ --
    elsif v_tip in ('tip_merkezi','hastane','muayenehane','dal_goz','dal_ftr','dis') then
        v_baslik := 'Klinik';

        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','randevu','baslik','Bugünkü randevu',
                'deger',(select count(*) from public.randevu
                          where baslangic::date = current_date and durum <> 4),
                'alt',(select 'geldi ' || count(*) filter (where durum = 2)
                            || ' · gelmedi ' || count(*) filter (where durum = 3)
                         from public.randevu
                        where baslangic::date = current_date and durum <> 4),
                'vurgu','normal','rota','/randevu') k
            union all select jsonb_build_object('sira','2','kod','basvuru','baslik','Açık başvuru',
                'deger',(select count(*) from public.belge b
                          join public.belge_basvuru bb on bb.id = b.id
                         where b.durum <> 2 and coalesce(b.kapanma_durum, 0) <> 2),
                'alt',(select 'bugün ' || count(*) from public.belge b
                        join public.belge_basvuru bb on bb.id = b.id
                       where b.belge_tarihi::date = current_date and b.durum <> 2),
                'vurgu','normal','rota','/basvuru')
            union all select jsonb_build_object('sira','3','kod','sonuc','baslik','Sonuç bekleyen',
                'deger',(select count(*) from public.lab_istem_satir where durum < 3)
                      + (select count(*) from public.radyoloji_istem where durum in (1,2,3,4)),
                'alt',(select 'lab ' || (select count(*) from public.lab_istem_satir where durum < 3)
                            || ' · radyoloji ' || (select count(*) from public.radyoloji_istem
                                                    where durum in (1,2,3,4))),
                'vurgu','uyari','rota','/lab-istem')
            union all select jsonb_build_object('sira','4','kod','tahsilat','baslik','Bugün tahsilat',
                'deger',(select coalesce(sum(k2.tutar),0) from public.kasa_islem k2
                          where k2.islem_tarihi::date = current_date and k2.durum <> 2
                            and k2.tur in (21,22,25)),
                'bicim','para',
                'alt',(select 'nakit ' || count(*) filter (where tur = 21)
                            || ' · pos ' || count(*) filter (where tur = 25)
                            || ' · havale ' || count(*) filter (where tur = 22)
                         from public.kasa_islem
                        where islem_tarihi::date = current_date and durum <> 2
                          and tur in (21,22,25)),
                'vurgu','olumlu','rota','/kasa-islem')
            -- ACIK TAHSILAT: hasta kovalarinin (1 provizyon · 4 ek katki)
            --   kalani - basvuru kartindaki "Açık Tahsilat" seridiyle AYNI.
            union all select jsonb_build_object('sira','5','kod','acikTahsilat','baslik','Açık tahsilat',
                'deger',(select coalesce(sum(coalesce(a.hasta_provizyon_kalan,0)
                                           + coalesce(a.hasta_ek_katki_kalan,0)),0)
                           from public.v_belge_acik_satir a),
                'bicim','para',
                'alt',(select coalesce(count(distinct a.belge_id),0) || ' başvuru'
                         from public.v_belge_acik_satir a
                        where coalesce(a.hasta_provizyon_kalan,0)
                            + coalesce(a.hasta_ek_katki_kalan,0) > 0),
                'vurgu','tehlike','rota','/basvuru')
            -- ACIK BELGE: ucretlendirilmis ama BELGEYE DONMEMIS tutar.
            --   Donusen tutar hedef satirin YAZILAN brutudur (BelgeDeposu ile
            --   ayni ifade) - matrahtan yeniden hesaplamak 500 TL'yi 500,01
            --   gosteriyordu.
            union all select jsonb_build_object('sira','6','kod','acikBelge','baslik','Açık belge',
                'deger',(select coalesce(sum(greatest(x.tutar - x.donusen, 0)),0) from (
                            select b.id,
                                   coalesce(b.genel_toplam,0) tutar,
                                   coalesce((select sum(case when coalesce(hs.tutar_kdvli,0) > 0
                                                             then hs.tutar_kdvli
                                                             else round(hs.tutar * (1+coalesce(hs.kdv,0)/100.0),2) end)
                                               from public.belge_satir ks
                                               join public.belge_satir hs
                                                 on hs.kaynak_tur = 30 and hs.kaynak_id = ks.id
                                               join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
                                              where ks.belge_id = b.id), 0) donusen
                              from public.belge b
                              join public.belge_basvuru bb on bb.id = b.id
                             where b.durum <> 2) x),
                'bicim','para',
                'alt',(select coalesce(count(*),0) || ' başvuru' from (
                            select b.id from public.belge b
                              join public.belge_basvuru bb on bb.id = b.id
                             where b.durum <> 2
                               and coalesce(b.genel_toplam,0) >
                                   coalesce((select sum(case when coalesce(hs.tutar_kdvli,0) > 0
                                                             then hs.tutar_kdvli
                                                             else round(hs.tutar * (1+coalesce(hs.kdv,0)/100.0),2) end)
                                               from public.belge_satir ks
                                               join public.belge_satir hs
                                                 on hs.kaynak_tur = 30 and hs.kaynak_id = ks.id
                                               join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
                                              where ks.belge_id = b.id), 0)) y),
                'vurgu','uyari','rota','/basvuru')
        ) t(k);

        v_bloklar := jsonb_build_array(
          -- 1 · KURUM & SÖZLEŞME
          jsonb_build_object('kod','kurum','baslik','Kurum & sözleşme','ipucu','açık tahakkuk',
            'kolonlar', jsonb_build_array('Kurum','Tip','Başvuru','Açık'),
            'bicimler', jsonb_build_array('metin','metin','sayi','para'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.unvan, x.tip, x.adet::text, round(x.acik,2)::text)
                               order by x.acik desc)
                from (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) as unvan,
                             case tk.tur when 1 then 'Özel' when 2 then 'ÖSS'
                                         when 3 then 'SGK'  when 4 then 'Kurumu Öder'
                                         else '—' end tip,
                             count(*) adet,
                             sum(coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0)) acik
                        from public.v_belge_acik_satir a
                        join public.taraf t on t.id = a.taraf_id
                        left join public.taraf_kurum tk on tk.id = t.id
                       where coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0) > 0
                       group by public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), tk.tur limit 8) x), '[]'::jsonb)),

          -- 2 · POLİKLİNİK AKIŞI
          jsonb_build_object('kod','poliklinik','baslik','Poliklinik akışı','ipucu','bugün',
            'kolonlar', jsonb_build_array('Bölüm','Randevu','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.ad, x.randevu::text, x.bekleyen::text)
                               order by x.randevu desc)
                from (select coalesce(d.ad,'Bölümsüz') ad,
                             count(*) randevu,
                             count(*) filter (where r.durum = 1) bekleyen
                        from public.randevu r
                        -- Randevu bolumu `bolum` (departman id) kolonunda.
                        left join public.departman d on d.id = r.bolum
                       where r.baslangic::date = current_date and r.durum <> 4
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 3 · YARDIMCI BİRİMLER
          jsonb_build_object('kod','birim','baslik','Yardımcı birimler','ipucu','kuyruk',
            'kolonlar', jsonb_build_array('Birim','Bekleyen','Bugün biten'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', jsonb_build_array(
              jsonb_build_array('Laboratuvar',
                (select count(*) from public.lab_istem_satir where durum < 3)::text,
                (select count(*) from public.lab_sonuc
                  where durum = 3 and degistirme_tarihi::date = current_date)::text),
              jsonb_build_array('Radyoloji',
                (select count(*) from public.radyoloji_istem where durum in (1,2,3,4))::text,
                (select count(*) from public.radyoloji_istem
                  where durum >= 5 and degistirme_tarihi::date = current_date)::text),
              jsonb_build_array('Mikrobiyoloji / kültür',
                (select count(*) from public.lab_kultur where durum < 3)::text,
                (select count(*) from public.lab_kultur
                  where durum >= 3 and degistirme_tarihi::date = current_date)::text))),

          -- 4 · e-NABIZ / BİLDİRİM
          jsonb_build_object('kod','enabiz','baslik','e-Nabız / bildirim','ipucu','son 24 saat',
            'kolonlar', jsonb_build_array('Paket','Üretilen','Gönderilen'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', coalesce((
              -- Gruplama ALT SORGUDA: jsonb_agg icinde count() ic ice
              --   toplama olur (42803).
              select jsonb_agg(jsonb_build_array(x.ad, x.uretilen::text, x.gonderilen::text)
                               order by x.uretilen desc)
                from (select coalesce(pt.ad, 'Paket ' || p.paket_turu_id) ad,
                             count(*) uretilen,
                             count(*) filter (where p.durum >= 3) gonderilen
                        from public.enabiz_paket p
                        left join public.enabiz_paket_turu pt on pt.id = p.paket_turu_id
                       where p.ekleme_tarihi >= now() - interval '24 hours'
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 5 · HEKİM ÜRETİMİ
          jsonb_build_object('kod','hekim','baslik','Hekim üretimi','ipucu','bugün',
            'kolonlar', jsonb_build_array('Hekim','Hasta','Ciro'),
            'bicimler', jsonb_build_array('metin','sayi','para'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.ad, x.hasta::text, round(x.ciro,2)::text)
                               order by x.ciro desc)
                from (select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120),'Atanmamış') ad,
                             count(*) hasta,
                             sum(coalesce(b.genel_toplam,0)) ciro
                        from public.belge b
                        join public.belge_basvuru bb on bb.id = b.id
                        left join public.taraf t on t.id = bb.personel_id
                       where b.belge_tarihi::date = current_date and b.durum <> 2
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 6 · DİKKAT GEREKTİREN
          jsonb_build_object('kod','dikkat','baslik','Dikkat gerektiren','ipucu','iş listesi',
            'kolonlar', jsonb_build_array('Konu','Adet','Etki'),
            'bicimler', jsonb_build_array('metin','sayi','metin'),
            'satirlar', jsonb_build_array(
              jsonb_build_array('Provizyon alınmamış başvuru',
                (select count(*) from public.belge b
                   join public.belge_basvuru bb on bb.id = b.id
                   left join public.belge_provizyon bp on bp.id = b.id
                  where b.durum <> 2 and bb.odeyen_kurum_id is not null
                    and bp.id is null)::text,
                'Tahakkuk edilemez'),
              jsonb_build_array('Onaylanmamış tetkik sonucu',
                (select count(*) from public.lab_sonuc where durum not in (3,4))::text,
                'Hasta bekliyor'),
              jsonb_build_array('Faturası kesilmemiş kurum icmali',
                (select count(*) from public.kurum_icmal where durum < 2)::text,
                'Dönem kapanmaz'),
              jsonb_build_array('e-Nabız hatalı paket',
                (select count(*) from public.enabiz_paket where durum = 9)::text,
                'Bildirim eksik')))
        );
    else
        v_baslik := '';
    end if;

    return jsonb_build_object(
        'kurumTipi', v_tip,
        'baslik',    coalesce(v_baslik, ''),
        'kutular',   coalesce(v_kutular, '[]'::jsonb),
        'bloklar',   coalesce(v_bloklar, '[]'::jsonb));
end $function$;

CREATE OR REPLACE FUNCTION public.fn_ebelge_govde_izibiz(p_belge_id integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
    b            record;
    g            record;   -- gonderici (v_ebelge_gonderici)
    v_tur        smallint; -- 1 e-Fatura · 2 e-Arsiv · 7 e-Irsaliye
    v_arsiv      boolean;
    v_irsaliye   boolean;
    v_profil     text;
    v_belge_tipi text;
    v_para       text;
    v_uuid       text;
    v_xslt       text;
    v_notlar     jsonb := '[]'::jsonb;
    v_ek_ref     jsonb := '[]'::jsonb;
    v_satirlar   jsonb;
    v_vergi      jsonb;
    v_toplam     jsonb;
    v_supplier   jsonb;
    v_customer   jsonb;
    v_content    jsonb;
    v_kok        jsonb;
    v_matrah     numeric := 0;   -- NET (iskonto sonrasi) toplam
    v_kdv        numeric := 0;
    v_iskonto    numeric := 0;
    v_tevkifat   numeric := 0;
    v_tevk_alt   jsonb;
    v_iade_ref   jsonb;
    v_mail       text;
    sv           record;   -- sevkiyat (177)
begin
    select bl.*, e.id as e_belge_id, e.belge_turu as e_tur, e.belge_no as e_no,
           e.uuid as e_uuid, e.alici_alias, e.gonderici_alias,
           t.eposta as taraf_eposta, t.telefon as taraf_telefon
      into b
      from public.belge bl
      join public.e_belge e on e.belge_id = bl.id
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id
     order by e.id desc
     limit 1;

    if not found then
        raise exception 'Belge için hazırlanmış e-Belge yok (%). Önce "e-Fatura Hazırla" çalıştırın.', p_belge_id;
    end if;

    v_tur      := b.e_tur;
    v_arsiv    := v_tur = 2;
    v_irsaliye := v_tur = 7;

    -- ORTAK on-dogrulama (167): firma bilgisi, alici kimligi, kalem/tutar,
    --   desteklenen senaryo. Entegratorden bagimsiz oldugu icin her adaptorde
    --   tekrarlanmaz; adaptor yalniz BICIMLENDIRIR.
    perform public.fn_ebelge_gonderim_dogrula(p_belge_id);

    select * into g from public.v_ebelge_gonderici
     where sube_id = coalesce(nullif(b.sube_id, 0), (select min(id) from public.sube));

    -- Sevkiyat bilgileri ayri tabloda (177); kaydi olmayan belgede gorunum bos
    --   deger dondurur, dolayisiyla ek kontrol gerekmiyor.
    select * into sv from public.v_belge_sevkiyat where belge_id = p_belge_id;

    v_para := public.fn_ebelge_para_kodu(coalesce(nullif(b.belge_dovizi, ''), b.doviz_cinsi));
    v_uuid := coalesce(nullif(btrim(b.e_uuid), ''), gen_random_uuid()::text);

    -- PROFIL ve BELGE TIPI (Delphi SenaryoProfilKodu / FaturaTipKodu).
    v_profil := case
                    when v_irsaliye then 'TEMELIRSALIYE'
                    when v_arsiv    then 'EARSIVFATURA'
                    when coalesce(b.senaryo, 0) = 2 then 'TICARIFATURA'
                    else 'TEMELFATURA' end;
    -- Delphi FaturaTipKodu ile ayni esleme; tevkifatli faturada belge tipi
    --   TEVKIFAT olmali, yoksa GIB "tevkifat var ama tip SATIS" der.
    v_belge_tipi := case
                        when v_irsaliye then 'SEVK'
                        when coalesce(b.tipi, 0) = 2 then 'IADE'
                        when coalesce(b.tipi, 0) = 22 then 'TEVKIFAT'
                        when coalesce(b.tipi, 0) = 24 then 'ISTISNA'
                        when coalesce(b.tipi, 0) = 9 then 'IHRACKAYITLI'
                        when coalesce(b.tipi, 0) = 25 then 'SGK'
                        else 'SATIS' end;

    -- ------------------------------------------------------------ satirlar --
    -- Satir tutari NET'tir (iskonto dusulmus); GIB satirda net ister, iskontoyu
    --   ayri `allowanceCharge` olarak gormek ister. Iskonto tutari brutten
    --   turetilir: brut = miktar * birim fiyat.
    with s as (
        select bs.*,
               round(bs.miktar * bs.birim_fiyat, 2)                       as brut,
               round(bs.miktar * bs.birim_fiyat, 2) - bs.tutar            as isk_tutar,
               round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)           as kdv_tutar,
               -- TEVKIFAT: KDV'nin bir kismi alicida kalir. Oran KODDAN gelir -
               --   elle girilen oran koda uymazsa GIB sematronu reddeder (176).
               coalesce(nullif(bs.tevkifat_orani, 0),
                        public.fn_tevkifat_orani(bs.tevkifat_kodu))          as tevk_oran,
               round(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)
                     * coalesce(nullif(bs.tevkifat_orani, 0),
                                public.fn_tevkifat_orani(bs.tevkifat_kodu)) / 100.0, 2)
                                                                             as tevk_tutar,
               btrim(coalesce(bs.tevkifat_kodu, ''))                         as tevk_kod,
               -- Satir NUMARASI burada uretilir: jsonb_agg icinde pencere
               --   fonksiyonu cagrilamiyor (toplama + pencere ayni ifadede yasak).
               row_number() over (order by bs.sira, bs.id)                 as satir_no
          from public.belge_satir bs
         where bs.belge_id = p_belge_id
         order by bs.sira, bs.id
    )
    select jsonb_agg(
             (jsonb_build_object(
                'id',                  s.satir_no,
                'quantity',            s.miktar,
                'unitCode',            public.fn_ebelge_birim_kodu(s.birim),
                'lineExtensionAmount', s.tutar,
                'itemName',            coalesce(nullif(btrim(s.aciklama), ''), 'Ürün'),
                'itemPrice',           s.birim_fiyat)
              -- Satir iskontosu: multiplierFactorNumeric KESIRDIR (0.15), yuzde
              --   degil - izibiz base * mfn = amount dogrulamasi yapiyor.
              || case when s.isk_tutar > 0.0001 and not v_irsaliye then
                     jsonb_build_object('allowanceCharge', jsonb_build_array(jsonb_build_object(
                         'chargeIndicator', false,
                         'reason', 'İskonto',
                         'multiplierFactorNumeric', round(s.isk_tutar / nullif(s.brut, 0), 6),
                         'amount', round(s.isk_tutar, 2),
                         'baseAmount', s.brut)))
                 else '{}'::jsonb end
              -- e-Irsaliyede vergi YOK; para birimi satirda tasinir.
              -- Satir tevkifati: izibiz SATIRDA 'withholdingTaxTotal' bekler
              --   (fatura duzeyinde 'withHoldingTax'). Matrah = KDV TUTARI,
              --   net degil - izibiz sematron kurali (Delphi'de dogrulanmis).
              || case when s.tevk_tutar > 0.0001 and not v_irsaliye then
                     jsonb_build_object('withholdingTaxTotal', jsonb_build_object(
                         'taxAmount', s.tevk_tutar,
                         'taxSubTotal', jsonb_build_array(jsonb_build_object(
                             'taxableAmount', s.kdv_tutar,
                             'taxAmount', s.tevk_tutar,
                             -- izibiz sematron 856: sira numarasi bos olamaz.
                             'calculationSequenceNumeric', 1,
                             -- TAM SAYI: izibiz "50.00" reddediyor, "50" kabul
                             --   ediyor (Delphi de Round ile gonderiyor).
                             'percent', round(s.tevk_oran)::int,
                             'taxScheme', jsonb_build_object(
                                 'name', 'KDV TEVKIFATI',
                                 'typeCode', s.tevk_kod)))))
                 else '{}'::jsonb end
              || case when v_irsaliye then jsonb_build_object('currencyId', v_para)
                 else jsonb_build_object('taxTotal', jsonb_build_object(
                        'taxAmount', s.kdv_tutar,
                        'taxSubTotal', jsonb_build_array(
                          jsonb_build_object(
                            'taxableAmount', s.tutar,
                            'taxAmount', s.kdv_tutar,
                            'calculationSequenceNumeric', 1,
                            'percent', coalesce(s.kdv, 0),
                            -- KDV 0 ise GIB muafiyet kodu+nedeni ZORUNLU tutar.
                            'taxScheme', jsonb_build_object('name', 'KDV', 'typeCode', '0015'))
                          || case when s.kdv_tutar < 0.001 then
                                 jsonb_build_object(
                                   'taxExemptionCode', coalesce(nullif(s.kdv_muafiyeti::text, '0'), '351'),
                                   'taxExemptionReason',
                                   -- kd.ad ACIK yazilir: CTE'nin kendi kolonlariyla
                                   --   ("s.ad" yok ama satir tipi ad tasiyor) cakisiyor.
                                   coalesce((select kd.ad from public.kod_deger kd
                                              join public.kod_liste kl on kl.id = kd.liste_id
                                             where kl.kod = 'belge.kdv_muafiyeti'
                                               and kd.deger = s.kdv_muafiyeti),
                                            'Diğerleri'))
                             else '{}'::jsonb end)))
                 end
             ) order by s.sira, s.id),
           coalesce(sum(s.tutar), 0),
           coalesce(sum(s.kdv_tutar), 0),
           coalesce(sum(greatest(s.isk_tutar, 0)), 0),
           coalesce(sum(s.tevk_tutar), 0)
      into v_satirlar, v_matrah, v_kdv, v_iskonto, v_tevkifat
      from s;

    if v_satirlar is null then
        raise exception 'Belgede kalem yok; gönderilecek bir şey üretilemedi.';
    end if;

    -- Dip toplam ile KURUS FARKI: satir bazli toplama, belgenin kendi KDV'sinden
    --   yuvarlama yuzunden 1-2 kurus sapabilir. Delphi'deki gibi 2 kurusa kadar
    --   olan farkta BELGENIN degeri esas alinir - GIB toplam uyusmazligini reddeder.
    if abs(v_kdv - coalesce(b.kdv_tutari, 0)) < 0.02 then
        v_kdv := coalesce(b.kdv_tutari, v_kdv);
    end if;

    -- ---------------------------------------------------------- vergi/toplam -
    if not v_irsaliye then
        -- KDV oranina gore gruplanmis ozet (GIB taxTotal.taxSubTotal).
        select jsonb_build_object(
                 'taxAmount', v_kdv,
                 'taxSubTotal', jsonb_agg(jsonb_build_object(
                     'calculationSequenceNumeric', 1,
                     'taxableAmount', x.matrah,
                     'percent', x.oran,
                     'taxAmount', x.vergi,
                     'taxScheme', jsonb_build_object('name', 'KDV', 'typeCode', '0015'))
                   || case when x.vergi < 0.001 then
                          jsonb_build_object('taxExemptionCode', '351',
                                             'taxExemptionReason', 'Diğerleri')
                      else '{}'::jsonb end
                   order by x.oran))
          into v_vergi
          from (select coalesce(bs.kdv, 0)::numeric              as oran,
                       sum(bs.tutar)                             as matrah,
                       sum(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)) as vergi
                  from public.belge_satir bs
                 where bs.belge_id = p_belge_id
                 group by coalesce(bs.kdv, 0)) x;

        -- FATURA DUZEYI TEVKIFAT: izibiz 'withHoldingTax' anahtarini bekler
        --   (satirdaki 'withholdingTaxTotal' ile karistirilmamali; yanlis anahtar
        --   "satirda tevkifat yok" sematron hatasi verir).
        if v_tevkifat > 0.0001 then
            select jsonb_build_object(
                     'taxAmount', round(v_tevkifat, 2),
                     'taxSubTotal', jsonb_agg(jsonb_build_object(
                         'taxableAmount', x.kdv,
                         'taxAmount', x.tevkifat,
                         'calculationSequenceNumeric', 1,
                         'percent', round(x.oran)::int,
                         'taxScheme', jsonb_build_object(
                             'name', 'KDV TEVKIFATI', 'typeCode', x.kod))
                       order by x.oran))
              into v_tevk_alt
              from (select coalesce(nullif(bs.tevkifat_orani, 0),
                                    public.fn_tevkifat_orani(bs.tevkifat_kodu)) as oran,
                           max(btrim(coalesce(bs.tevkifat_kodu, '')))           as kod,
                           sum(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)) as kdv,
                           sum(round(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)
                               * coalesce(nullif(bs.tevkifat_orani, 0),
                                          public.fn_tevkifat_orani(bs.tevkifat_kodu)) / 100.0, 2))
                                                                                as tevkifat
                      from public.belge_satir bs
                     where bs.belge_id = p_belge_id
                       and coalesce(nullif(bs.tevkifat_orani, 0),
                                    public.fn_tevkifat_orani(bs.tevkifat_kodu)) > 0
                     group by 1) x;
        end if;

        -- lineExtensionAmount = BRUT (iskonto oncesi), taxExclusive = NET.
        --   Delphi'deki ayrimin aynisi; GIB "Mal Hizmet Toplam Tutari"ni brut ister.
        v_toplam := jsonb_build_object(
            'lineExtensionAmount', round(v_matrah + v_iskonto, 2),
            'taxExclusiveAmount',  round(v_matrah, 2),
            'taxInclusiveAmount',  round(v_matrah + v_kdv, 2),
            -- Odenecek = matrah + KDV - TEVKIFAT (tevkifat kismini alici
            --   dogrudan devlete oder, satici tahsil etmez).
            'payableAmount',       round(v_matrah + v_kdv - v_tevkifat, 2))
            || case when v_iskonto > 0.0001
                    then jsonb_build_object('allowanceTotalAmount', round(v_iskonto, 2))
                    else '{}'::jsonb end;
    end if;

    -- --------------------------------------------------------------- taraflar
    -- Gonderici ve alici AYNI kaliptan (180): kimlik semasi, TCKN'de ad/soyad,
    --   adres, vergi dairesi. Tek fark ek alanlar - onlar asagida eklenir.
    v_supplier := public.fn_ebelge_taraf_json(
        g.unvan, g.vkno, g.vergi_dairesi,
        g.adres, g.ilce, g.il, g.posta_kodu, g.eposta, g.telefon, g.web);

    -- Mersis / ticaret sicil: izibiz `identifications` dizisinde tasir; GIB
    --   ticari faturada bu iki numarayi arar.
    if g.mersis_no <> '' or g.ticaret_sicil_no <> '' then
        v_supplier := v_supplier || jsonb_build_object('identifications',
            (case when g.mersis_no <> ''
                  then jsonb_build_array(jsonb_build_object('scheme', 'MERSISNO', 'value', g.mersis_no))
                  else '[]'::jsonb end)
            ||
            (case when g.ticaret_sicil_no <> ''
                  then jsonb_build_array(jsonb_build_object('scheme', 'TICARETSICILNO', 'value', g.ticaret_sicil_no))
                  else '[]'::jsonb end));
    end if;

    v_customer := public.fn_ebelge_taraf_json(
        b.taraf_unvan, b.taraf_vkno, b.taraf_vd,
        b.taraf_adres, b.taraf_ilce, b.taraf_il);

    -- e-Arsivde belge alicinin E-POSTASIYLA iletilir: adres bloguna yazilir.
    v_mail := coalesce(nullif(btrim(b.alici_alias), ''), nullif(btrim(b.taraf_eposta), ''), '');
    if v_arsiv and v_mail <> '' then
        v_customer := jsonb_set(v_customer, '{address,email}', to_jsonb(v_mail));
        if coalesce(btrim(b.taraf_telefon), '') <> '' then
            v_customer := jsonb_set(v_customer, '{address,telephone}', to_jsonb(btrim(b.taraf_telefon)));
        end if;
    end if;

    -- ------------------------------------------------------------ notlar ----
    if coalesce(btrim(b.aciklama), '') <> '' then
        v_notlar := v_notlar || to_jsonb(btrim(b.aciklama));
    end if;

    -- ------------------------------------------------- ek referanslar / XSLT -
    -- e-Arsivde gonderim sekli: alici e-postasi varsa ELEKTRONIK, yoksa KAGIT.
    if v_arsiv then
        v_ek_ref := v_ek_ref || jsonb_build_array(jsonb_build_object(
            'documentTypeCode', 'SendingType',
            'documentType',     case when v_mail <> '' then 'ELEKTRONIK' else 'KAGIT' end,
            'id',               '1',
            'issueDate',        to_char(b.belge_tarihi, 'YYYY-MM-DD')));
    end if;

    -- GORUNTULEME SABLONU (XSLT) belgeye GOMULUR. Entegratordeki kayitli sablona
    --   (xsltName='DEFAULT') guvenmek Delphi'de "imza bilgisi bulunamadi" hatasi
    --   verdigi icin sablon her belgede gonderilir. Sablon: bu belge turu icin
    --   varsayilan isaretli dokuman.
    select convert_from(di.icerik, 'UTF8') into v_xslt
      from public.dokuman d
      join public.dokuman_icerik di on di.hash = d.hash
     where d.kaynak = 'ebelge-xslt' and d.kaynak_id = v_tur and d.durum = 1
     order by d.varsayilan desc, d.id
     limit 1;

    if coalesce(btrim(v_xslt), '') = '' then
        raise exception 'Bu belge türü için XSLT şablonu yok. Ayarlar › Satış Belgeleri › e-Belge › XSLT''den ekleyin.';
    end if;

    v_ek_ref := v_ek_ref || jsonb_build_array(jsonb_build_object(
        'id',           v_uuid,
        'documentType', 'XSLT',
        'issueDate',    to_char(b.belge_tarihi, 'YYYY-MM-DD'),
        'attachment',   jsonb_build_object(
            'characterSetCode', 'UTF-8',
            'encodingCode',     'Base64',
            'filename',         coalesce(nullif(btrim(b.e_no), ''), v_uuid) || '.xslt',
            'mimeCode',         'application/xml',
            -- encode(...,'base64') 76 karakterde satir kirar; izibiz tek satir ister.
            'content',          replace(encode(convert_to(v_xslt, 'UTF8'), 'base64'), E'\n', ''))));

    -- --------------------------------------------------------------- content -
    v_content := jsonb_build_object(
        'profile',          v_profil,
        'documentTypeCode', v_belge_tipi,
        'uuid',             v_uuid,
        'issueDate',        to_char(b.belge_tarihi, 'YYYY-MM-DD'),
        'issueTime',        to_char(b.belge_tarihi, 'HH24:MI:SS'),
        'notes',            v_notlar,
        'currencyCode',     v_para,
        'supplierParty',    v_supplier,
        'customerParty',    v_customer,
        'additionalReferences', v_ek_ref,
        'lines',            v_satirlar);

    if coalesce(btrim(b.e_no), '') <> '' then
        v_content := v_content || jsonb_build_object('documentNo', b.e_no);
    end if;
    if not v_irsaliye then
        v_content := v_content || jsonb_build_object('taxTotal', v_vergi,
                                                     'legalMonetaryTotal', v_toplam);
        if v_tevk_alt is not null then
            v_content := v_content || jsonb_build_object('withHoldingTax', v_tevk_alt);
        end if;

        -- IADE (tipi=2): iade edilen ORIJINAL belgenin referansi. GIB schematron
        --   10003 bunu 16 haneli numara + documentTypeCode=IADE ile ZORUNLU
        --   tutar; yoksa belge reddedilir (176 iade_belge_id).
        if coalesce(b.tipi, 0) = 2 then
            select jsonb_agg(jsonb_build_object(
                       'id', coalesce(nullif(btrim(o.belge_no), ''), ''),
                       'issueDate', to_char(o.belge_tarihi, 'YYYY-MM-DD'),
                       'documentTypeCode', 'IADE',
                       'documentType', 'İade Edilen Fatura'))
              into v_iade_ref
              from public.belge o
             where o.id = b.iade_belge_id;

            if v_iade_ref is null then
                raise exception 'İade faturasında hangi faturanın iade edildiği seçilmemiş; GİB referanssız iade belgesini reddeder.';
            end if;
            v_content := v_content || jsonb_build_object('billingReference', v_iade_ref);
        end if;
        -- Faturaya kaynaklik eden irsaliye referansi (GIB ister).
        if coalesce(btrim(b.irsaliye_no), '') <> '' then
            v_content := v_content || jsonb_build_object('despatchDocumentReference',
                jsonb_build_array(jsonb_build_object(
                    'id',        b.irsaliye_no,
                    'issueDate', to_char(coalesce(b.irsaliye_tarihi, b.belge_tarihi), 'YYYY-MM-DD'))));
        end if;
    else
        -- e-Irsaliye: sevkiyat blogu (177 tablosundan). GIB DriverPerson'da
        --   ad ve SOYAD ayri ister; tek alanda tutulan "sofor_ad" son kelimeden
        --   bolunur (aliciyla ayni kural, fn_ad_soyad_ayir).
        v_content := v_content || jsonb_build_object('shipment', jsonb_build_object(
            'id', 1,
            'goodsItems', jsonb_build_array(jsonb_build_object(
                'currencyId', v_para, 'valueAmount', round(v_matrah, 2))),
            'shipmentStages', jsonb_build_array(
                jsonb_strip_nulls(jsonb_build_object(
                    'licensePlateID', nullif(sv.arac_plaka, '')))
                || case when sv.sofor_ad <> '' then
                       (select jsonb_build_object('driverPerson', jsonb_strip_nulls(
                            jsonb_build_object(
                                'firstName', a.ad,
                                'familyName', nullif(a.soyad, ''),
                                'title', 'Sürücü',
                                -- GIB kimlik numarasini NationalityID'de tasir.
                                'nationalityID', nullif(sv.sofor_tckn, ''))))
                          from public.fn_ad_soyad_ayir(sv.sofor_ad) a)
                   else '{}'::jsonb end
                -- Nakliyeyi baska firma yapiyorsa carrierParty (kendi aracimizsa yok).
                || case when sv.tasiyici_id is not null then
                       (select jsonb_strip_nulls(jsonb_build_object('carrierParty',
                            jsonb_build_object(
                                'name', public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120),
                                'identifier', nullif(regexp_replace(coalesce(t.vkno, ''), '\D', '', 'g'), ''),
                                'schemeId', public.fn_ebelge_kimlik_semasi(t.vkno))))
                          from public.taraf t where t.id = sv.tasiyici_id)
                   else '{}'::jsonb end),
            'delivery', jsonb_build_object(
                'deliveryAddress', jsonb_strip_nulls(jsonb_build_object(
                    'country', 'TR',
                    'city', nullif(btrim(coalesce(b.taraf_il, '')), ''),
                    'subCity', nullif(btrim(coalesce(b.taraf_ilce, '')), ''),
                    'streetName', nullif(btrim(coalesce(b.taraf_adres, '')), ''),
                    'postalZone', '34000')),
                'despatch', jsonb_build_object(
                    'actualDespatchDate', to_char(b.belge_tarihi, 'YYYY-MM-DD'),
                    'actualDespatchTime', to_char(b.belge_tarihi, 'HH24:MI:SS')))));
    end if;

    -- ------------------------------------------------------------------ kok --
    -- assignNumber STRING gonderilir (izibiz Postman ornegi boyle): numarayi
    --   biz verdiysek 'false'. Bizde numara hazirlamada uretildigi icin daima false.
    v_kok := jsonb_build_object(
        'documentAction', 'SEND',
        'assignNumber',   case when coalesce(btrim(b.e_no), '') = '' then 'true' else 'false' end,
        'seriePrefix',    left(coalesce(btrim(b.e_no), ''), 3),
        'content',        v_content);

    if v_irsaliye then
        -- Irsaliye icerigi base64 olarak parse edilmesin.
        v_kok := v_kok || jsonb_build_object('compressed', 'false');
    end if;

    -- ALICI POSTA KUTUSU: alias gonderilmezse izibiz ilk buldugu etikete yollar;
    --   cok aliasli mukellefte YANLIS kutuya duser (izibiz teyidi).
    if not v_arsiv and coalesce(btrim(b.alici_alias), '') <> '' then
        v_kok := v_kok || jsonb_build_object('receiverAlias', btrim(b.alici_alias));
    end if;
    if coalesce(btrim(b.gonderici_alias), '') <> '' then
        v_kok := v_kok || jsonb_build_object('senderAlias', btrim(b.gonderici_alias));
    elsif g.gonderici_alias <> '' then
        v_kok := v_kok || jsonb_build_object('senderAlias', g.gonderici_alias);
    end if;

    -- e-Arsiv postasi: mailFlag + mailAdress ile TETIKLENIR (customerParty'deki
    --   e-posta tek basina gondermiyor - Delphi'de dogrulanmis).
    if v_arsiv and v_mail <> '' then
        v_kok := v_kok || jsonb_build_object(
            'mailFlag', true,
            'mailAdress', (select jsonb_agg(btrim(m))
                             from unnest(regexp_split_to_array(v_mail, '[;,\r\n]+')) m
                            where btrim(m) <> ''));
    end if;

    return v_kok;
end $function$;

CREATE OR REPLACE FUNCTION public.fn_ebelge_hazirla(p_belge_id integer, p_kullanici integer)
 RETURNS TABLE(e_belge_id bigint, belge_turu smallint, belge_no character varying, seri character varying, uyari text)
 LANGUAGE plpgsql
AS $function$
declare
    b            record;
    v_tur        smallint;
    v_durum      smallint;
    v_seri       varchar(10);
    v_no         varchar(30);
    v_id         bigint;
    v_mukellef   boolean;
    v_uyari      text := '';
    v_alias      varchar(200) := '';
begin
    select bl.*, t.efatura as taraf_efatura, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) as taraf_ad,
           t.vkno as taraf_vkno, t.alias_eposta, t.alias_irsaliye
      into b
      from public.belge bl
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id;

    if b.id is null then
        raise exception 'Belge bulunamadı.';
    end if;
    if not public.fn_ebelge_acik(b.sube_id) then
        raise exception 'Bu şube e-Fatura mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.';
    end if;
    if exists (select 1 from public.e_belge e where e.belge_id = b.id and e.durum > 0) then
        raise exception 'Bu belge için e-Belge zaten hazırlanmış (durum %).',
              (select max(e.durum) from public.e_belge e where e.belge_id = b.id);
    end if;

    -- DOGRULAMALAR - numara/seri TUKETILMEDEN.
    if coalesce(b.taraf_id, 0) = 0 then
        raise exception 'Belgede cari seçilmemiş.';
    end if;
    if coalesce(btrim(b.taraf_vkno), '') = '' then
        raise exception '% için vergi/kimlik numarası girilmemiş; e-Belge gönderilemez.', b.taraf_ad;
    end if;
    if not exists (select 1 from public.belge_satir s where s.belge_id = b.id) then
        raise exception 'Belgede kalem yok.';
    end if;
    if coalesce(b.genel_toplam, 0) <= 0 then
        raise exception 'Belge tutarı sıfır; e-Belge hazırlanamaz.';
    end if;
    if b.tur = 14
       and coalesce(btrim((select sv.arac_plaka from public.v_belge_sevkiyat sv
                            where sv.belge_id = b.id)), '') = ''
       and coalesce((select sv.tasiyici_id from public.v_belge_sevkiyat sv
                      where sv.belge_id = b.id), 0) = 0 then
        raise exception 'e-İrsaliyede taşıyıcı ya da araç plakası girilmeli (Taşıyıcı / Sevkiyat sekmesi).';
    end if;

    -- BELGE TURU: alici GIB e-Fatura KULLANICISI mi (cari kartindaki bayrak;
    --   bayragi entegratorun gib-users listesi tazeler - bkz. 186 basligi).
    v_mukellef := coalesce(b.taraf_efatura, 0) = 1;
    if b.tur = 14 then
        v_tur := 7; v_durum := 51;
    elsif coalesce(b.senaryo, 0) = 3 or v_mukellef then
        v_tur := 1; v_durum := 1;
        if coalesce(b.senaryo, 0) = 3 and not v_mukellef then
            v_uyari := 'İhracat faturası: alıcı GİB mükellefi değil, belge e-Fatura olarak hazırlandı.';
        end if;
    else
        v_tur := 2; v_durum := 11;
        v_uyari := 'Alıcı e-Fatura mükellefi değil; belge e-Arşiv olarak hazırlandı.';
    end if;

    if not public.fn_ebelge_mukellef_mi(b.sube_id, v_tur) then
        raise exception 'Bu şube % mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.',
              public.fn_ebelge_tur_adi(v_tur);
    end if;

    -- ALICI POSTA KUTUSU (186): e-Arsivde bos kalir, gonderimde e-posta sorulur.
    v_alias := case
                 when v_tur = 1 then coalesce(btrim(b.alias_eposta), '')
                 when v_tur = 7 then coalesce(nullif(btrim(b.alias_irsaliye), ''),
                                              btrim(coalesce(b.alias_eposta, '')))
                 else ''
               end;
    if v_tur in (1, 7) and v_alias = '' then
        v_uyari := btrim(v_uyari || ' Alıcının GİB posta kutusu (alias) boş; ' ||
                         'cari kartından ya da mükellefiyet sorgusundan doldurun.');
    end if;

    v_seri := public.fn_ebelge_seri_bul(v_tur, coalesce(b.senaryo, 0), p_kullanici);
    if coalesce(btrim(v_seri), '') = '' then
        raise exception 'Bu belge türü için seri tanımı yok. Firma Bilgileri › e-Belge › Seri Bilgileri''nden ekleyin.';
    end if;

    v_no := public.fn_ebelge_no_uret(v_seri, extract(year from b.belge_tarihi)::integer);

    insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, belge_no,
                                uuid, alici_alias, durum, ekleyen)
    values (b.id, b.taraf_id, v_tur, 1, v_no,
            gen_random_uuid()::text, v_alias, 1, p_kullanici)
    returning id into v_id;

    update public.belge bl
       set efatura_durum = v_durum,
           efatura_sonuc = 0,
           belge_no = case when coalesce(btrim(bl.belge_no), '') in ('', '0')
                           then v_no else bl.belge_no end,
           degistiren = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where bl.id = b.id;

    return query select v_id, v_tur, v_no::varchar, v_seri::varchar, v_uyari;
end $function$;

CREATE OR REPLACE FUNCTION public.fn_hesap_atama_adi(p_atama integer)
 RETURNS character varying
 LANGUAGE sql
 STABLE
AS $function$
    select case
             when coalesce(p_atama, 0) = 0 then ''
             when p_atama = -1 then 'Ana Kasa'
             else coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) from public.taraf t where t.id = p_atama), 'Personel')
           end::varchar
$function$;

CREATE OR REPLACE FUNCTION public.fn_lab_cihaz_calisma_listesi(p_cihaz_id integer, p_barkod text)
 RETURNS TABLE(istem_satir_id integer, barkod character varying, tetkik_id integer, tetkik_kodu character varying, cihaz_kodu character varying, tetkik_adi character varying, hasta_no integer, hasta_adi text, oncelik smallint)
 LANGUAGE sql
 STABLE
AS $function$
    select s.id, n.barkod, t.id, t.kod,
           coalesce((select e.cihaz_test_kodu
                       from public.lab_cihaz_test_esleme e
                      where e.cihaz_id = p_cihaz_id and e.tetkik_id = t.id
                        and e.durum = 0
                      order by e.id limit 1), t.kod)::varchar,
           t.ad, n.hasta_id,
           coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120)),
           i.oncelik
      from public.lab_numune n
      join public.lab_istem_satir s on s.numune_id = n.id
      join public.lab_istem i on i.id = s.istem_id
      join public.lab_tetkik t on t.id = s.tetkik_id
      join public.taraf h on h.id = n.hasta_id
     where n.barkod = p_barkod
       and n.durum = 3            -- yalniz KABUL EDILMIS numune
       and s.durum in (1, 2, 6)   -- bekleyen / calisiliyor / tekrar
     order by s.sira, s.id;
$function$;

CREATE OR REPLACE FUNCTION public.fn_cagri_arayan_bul(p_tel text)
 RETURNS TABLE(taraf_id integer, ad text, hasta smallint, musteri smallint, personel smallint, kurum smallint, cep_tel text, telefon text, son_cagri timestamp without time zone)
 LANGUAGE sql
 STABLE
AS $function$
  select t.id, coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), '')::text,
         t.hasta, t.musteri, t.personel, t.kurum, coalesce(t.cep_tel, '')::text, coalesce(t.telefon, '')::text,
         (select max(c.baslama) from public.cagri c where c.taraf_id = t.id)
    from public.taraf t
   where public.fn_cagri_tel_anahtar(p_tel) <> ''
     and (public.fn_cagri_tel_anahtar(t.cep_tel) = public.fn_cagri_tel_anahtar(p_tel)
       or public.fn_cagri_tel_anahtar(t.telefon) = public.fn_cagri_tel_anahtar(p_tel))
   order by t.hasta desc, t.musteri desc, t.id
   limit 10
$function$;

CREATE OR REPLACE FUNCTION public.tg_prim_plani_taraf_dogrula()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    v_rol    smallint;
    v_unvan  varchar(200);
    v_durum  smallint;
    v_rol_ad text;
begin
    select p.rol into v_rol from public.prim_plani p where p.id = new.plan_id;
    select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), ''), coalesce(t.durum, 1)
      into v_unvan, v_durum
      from public.taraf t where t.id = new.taraf_id;

    if coalesce(v_durum, 1) <> 1 then
        raise exception '% pasif; plana yalnizca aktif personel / dis hekim eklenebilir.',
            v_unvan using errcode = 'GK422';
    end if;

    if not exists (select 1 from public.v_prim_rol_aday a
                    where a.id = new.taraf_id
                      and a.rol = coalesce(v_rol, 0)
                      and coalesce(a.durum, 1) = 1) then
        select coalesce(kd.ad, 'rol ' || coalesce(v_rol, 0)::text) into v_rol_ad
          from public.kod_liste kl
          join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = v_rol
         where kl.kod = 'prim.rol';

        raise exception
            '% kisisi "%" rolunde prim adayi degil. Personel kartindaki Prim '
            'Rolleri sekmesinden bu rolu isaretleyin; dis hekimlerde yalnizca '
            '"Gonderen" rolu vardir.', v_unvan, coalesce(v_rol_ad, '?')
            using errcode = 'GK422';
    end if;
    return new;
end $function$;

CREATE OR REPLACE FUNCTION public.fn_ameliyat_salon_cakisma(p_salon_id integer, p_baslangic timestamp with time zone, p_sure_dk integer, p_haric_id bigint DEFAULT NULL::bigint)
 RETURNS TABLE(id bigint, ameliyat_no character varying, plan_baslangic timestamp with time zone, bitis timestamp with time zone, hasta_ad text)
 LANGUAGE sql
 STABLE
AS $function$
    select a.id, a.ameliyat_no, a.plan_baslangic,
           coalesce(a.bitis_zamani,
                    a.plan_baslangic + (coalesce(nullif(a.plan_sure_dk, 0), 60)
                                        || ' minutes')::interval) as bitis,
           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), '')::text as hasta_ad
      from public.ameliyat a
      left join public.taraf t on t.id = a.hasta_id
     where a.salon_id = p_salon_id
       and a.durum <> 8
       and a.plan_baslangic is not null
       and (p_haric_id is null or a.id <> p_haric_id)
       -- Aralık kesişimi: [bas, bitis) x [p_bas, p_bitis)
       and a.plan_baslangic
           < p_baslangic + (coalesce(nullif(p_sure_dk, 0), 60) || ' minutes')::interval
       and coalesce(a.bitis_zamani,
                    a.plan_baslangic + (coalesce(nullif(a.plan_sure_dk, 0), 60)
                                        || ' minutes')::interval)
           > p_baslangic
     order by a.plan_baslangic;
$function$;

CREATE OR REPLACE FUNCTION public.fn_hekim_calisma_bloklari(p_sube integer, p_bas date, p_bit date, p_hekim integer DEFAULT NULL::integer, p_departman integer DEFAULT NULL::integer)
 RETURNS TABLE(hekim_id integer, hekim character varying, sube_id integer, departman_id integer, departman character varying, gun date, saat_bas time without time zone, saat_bit time without time zone, slot_dk smallint, kanallar character varying, kaynak smallint, istisna_tur smallint, sablon_id integer, istisna_id integer, aciklama character varying)
 LANGUAGE sql
 STABLE
AS $function$
    with g as (select d::date as gun from generate_series(p_bas, p_bit, interval '1 day') d),
    sab as (
        select s.*, g.gun
          from public.hekim_calisma_sablon s
          join g on g.gun >= s.gecerli_bas and (s.gecerli_bit is null or g.gun <= s.gecerli_bit)
         where s.aktif = 1
           and (p_sube = 0 or s.sube_id is null or s.sube_id = p_sube)
           and (p_hekim is null or s.hekim_id = p_hekim)
           and (p_departman is null or s.departman_id = p_departman)
           and (',' || s.gunler || ',') like ('%,' || extract(isodow from g.gun)::text || ',%')
           and (s.tekrar = 1 or (((g.gun - s.gecerli_bas) / 7) % 2) = 0)),
    bl as (
        select s.hekim_id, coalesce(s.sube_id, p_sube) as sube_id, s.departman_id, s.gun,
               s.bas1::time as saat_bas, s.bit1::time as saat_bit, s.slot_dk, s.kanallar, s.id as sablon_id from sab s
        union all
        select s.hekim_id, coalesce(s.sube_id, p_sube), s.departman_id, s.gun,
               s.bas2::time, s.bit2::time, s.slot_dk, s.kanallar, s.id from sab s where nullif(s.bas2, '') is not null),
    ist as (
        select i.id, i.sube_id, i.hekim_id, i.departman_id, i.tur,
               i.saat_bas, i.saat_bit, i.slot_dk, i.kanallar, i.aciklama,
               0::smallint as izin_mi, g.gun
          from public.hekim_calisma_istisna i
          join g on g.gun between i.bas_tarih and i.bit_tarih
         where i.durum = 1
           and (p_sube = 0 or i.sube_id is null or i.sube_id = p_sube)
           and (p_hekim is null or i.hekim_id = p_hekim)
           and (p_departman is null or i.departman_id is null or i.departman_id = p_departman)
        union all
        -- ONAYLI İZİN (748): kaydı İK'da durur, plana buradan yansır.
        --   `tur = 1` (izin) olarak ele alınıyor - aşağıdaki "ezilen" ve
        --   "kapalı gün" dalları zaten 1'i tanıyor, ikinci bir kural
        --   yazmak aynı davranışı iki yerde tarif etmek olurdu.
        select z.id, z.sube_id, z.taraf_id, null::integer, 1::smallint,
               null::varchar, null::varchar, null::smallint, null::varchar,
               case z.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni'
                          when 3 then 'Rapor' when 4 then 'Ücretsiz izin'
                          else 'İzin' end::varchar,
               1::smallint, g.gun
          from public.personel_izin z
          join g on g.gun between z.baslangic_tarihi and z.bitis_tarihi
         where z.durum = 2
           and (p_sube = 0 or z.sube_id is null or z.sube_id = p_sube)
           and (p_hekim is null or z.taraf_id = p_hekim)),
    ezilen as (   -- izin / kongre / kapalı / saat değişikliği o günün şablon bloklarını kaldırır
        select b.* from bl b
         where exists (select 1 from ist i
                        where i.hekim_id = b.hekim_id and i.gun = b.gun and i.tur in (1, 2, 3, 5)
                          and (i.departman_id is null or i.departman_id = b.departman_id)
                          and (i.sube_id is null or i.sube_id = b.sube_id)))
    select b.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) as hekim, b.sube_id, b.departman_id, d.ad as departman, b.gun, b.saat_bas, b.saat_bit, b.slot_dk, b.kanallar,
           1::smallint, null::smallint, b.sablon_id, null::integer, ''::varchar
      from bl b join public.taraf t on t.id = b.hekim_id join public.departman d on d.id = b.departman_id
     where not exists (select 1 from ezilen e where e.sablon_id = b.sablon_id and e.gun = b.gun and e.saat_bas = b.saat_bas)
    union all   -- saat değişikliği (3) ve ek mesai (4): yeni blok
    select i.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), coalesce(i.sube_id, p_sube),
           coalesce(i.departman_id, (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1),
                    (select s.departman_id from public.hekim_calisma_sablon s where s.hekim_id = i.hekim_id and s.aktif = 1 order by s.id limit 1)),
           coalesce(d.ad, ''), i.gun, i.saat_bas::time, i.saat_bit::time,
           coalesce(i.slot_dk, (select b.slot_dk from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1), 15),
           coalesce(i.kanallar, 'B'), 2::smallint, i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id
      left join public.departman d on d.id = coalesce(i.departman_id,
           (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1))
     where i.tur in (3, 4) and i.izin_mi = 0
    union all   -- kapalı günler (izin / kongre / kapalı): görünsün, slot üretmesin
    --   KAYNAK 4 = İK İZNİ: ekran "plan istisnası" ile "İK izni"ni ayırsın -
    --   birincisi plan ekranından, ikincisi izin ekranından düzeltilir.
    select i.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), coalesce(i.sube_id, p_sube), coalesce(i.departman_id, 0), coalesce(d.ad, ''), i.gun,
           null::time, null::time, 0::smallint, ''::varchar,
           case when i.izin_mi = 1 then 4 else 3 end::smallint,
           i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id left join public.departman d on d.id = i.departman_id
     where i.tur in (1, 2, 5)
     order by gun, hekim, saat_bas
$function$;

CREATE OR REPLACE FUNCTION public.fn_belge_talep_yazi(p_talep integer, p_sablon integer DEFAULT NULL::integer)
 RETURNS TABLE(sablon_id integer, sablon_ad character varying, baslik text, govde text, alt_not text, imza_unvan character varying, eksik text[])
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
    t          record;
    s          record;
    v_deger    jsonb;
    v_ham      text;
    v_eksik    text[] := '{}';
    v_anahtar  text;
    v_baslik   text;
    v_govde    text;
    v_alt      text;
    r          record;
begin
    select b.id, b.tur, b.amac, b.muhatap, b.talep_no, b.sube_id,
           b.maas_tutar, b.maas_turu,
           public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::character varying(120) as personel_ad, coalesce(tr.vkno, '') as tc,
           coalesce(p.sicil_no, '')     as sicil,
           coalesce(p.gorev, '')        as gorev,
           p.ise_giris_tarihi, p.calisma_sekli, p.sozlesme_turu,
           coalesce(p.sgk_sicil_no, '') as sgk_sicil,
           coalesce(su.unvan, '')       as kurum_unvan,
           coalesce(su.adres, '')       as kurum_adres,
           coalesce(su.il, '')          as kurum_il,
           coalesce(su.ilce, '')        as kurum_ilce,
           coalesce(su.vkno, '')        as kurum_vkno,
           coalesce(su.vd, '')          as kurum_vd,
           coalesce(su.telefon, '')     as kurum_telefon
      into t
      from public.personel_belge_talep b
      join public.taraf tr              on tr.id = b.taraf_id
      left join public.taraf_personel p on p.id  = b.taraf_id
      left join public.sube su          on su.id = b.sube_id
     where b.id = p_talep;

    if not found then
        raise exception 'Belge talebi bulunamadi: %', p_talep using errcode = 'GK404';
    end if;

    -- ŞABLON SEÇİMİ: elle verilen > şubenin kendi şablonu > ortak (0) >
    --   aynı türün başka dili. Bulunamazsa serbest şablona (9) düşer -
    --   olmasaydı şablonu silinmiş bir türde yazı HİÇ üretilemezdi.
    select * into s from public.belge_yazi_sablonu
     where (p_sablon is not null and id = p_sablon)
        or (p_sablon is null and durum = 1 and tur = t.tur
            and sube_id in (0, t.sube_id))
     order by case when sube_id = t.sube_id then 0 else 1 end,
              case when dil = 'tr' then 0 else 1 end
     limit 1;

    if s.id is null then
        select * into s from public.belge_yazi_sablonu
         where durum = 1 and tur = 9 order by sube_id limit 1;
    end if;

    if s.id is null then
        raise exception 'Bu tur icin yazi sablonu tanimli degil.'
              using errcode = 'GK422';
    end if;

    v_deger := jsonb_build_object(
        'muhatap',      coalesce(nullif(trim(t.muhatap), ''),
                                 case when s.dil = 'en' then 'To Whom It May Concern,'
                                      else 'İlgili Makama,' end),
        'personel_ad',  coalesce(t.personel_ad, ''),
        'tc',           t.tc,
        'sicil',        t.sicil,
        'gorev',        t.gorev,
        'amac',         coalesce(t.amac, ''),
        'talep_no',     coalesce(t.talep_no, ''),
        'sgk_sicil',    t.sgk_sicil,
        'ise_giris',    coalesce(to_char(t.ise_giris_tarihi, 'DD.MM.YYYY'), ''),
        'tarih',        to_char(current_date, 'DD.MM.YYYY'),
        'calisma_sekli', case t.calisma_sekli when 1 then 'tam zamanlı'
                                              when 2 then 'yarı zamanlı'
                                              when 3 then 'primli' else '' end,
        'sozlesme_turu', case t.sozlesme_turu when 1 then 'Belirsiz Süreli'
                                              when 2 then 'Belirli Süreli'
                                              when 3 then 'Deneme Süreli'
                                              when 4 then 'Stajyer/Çırak'
                                              when 5 then 'Mevsimlik' else '' end,
        -- PARA BİÇİMİ TEK YERDEN (770): `fn_para_tr`. 768'de aynı biçim
        --   burada satır içi yazılmıştı; bir biçimin iki kopyası, birinin
        --   sessizce sapması demektir. NULL zaten BOŞ metin döner ve eksik
        --   listesi onu yakalar - davranış aynı, yazan tek.
        --   "TL" şablonda yazılmaz; {para_birimi} kurum profilinden gelir.
        'maas',         public.fn_para_tr(t.maas_tutar),
        'maas_turu',    case t.maas_turu when 1 then 'net' when 2 then 'brüt'
                                         else '' end,
        'para_birimi',  coalesce((select para_birimi from public.kurum_profil
                                   where sube_id = t.sube_id), 'TL'),
        'kurum_unvan',   t.kurum_unvan,
        'kurum_adres',   t.kurum_adres,
        'kurum_il',      t.kurum_il,
        'kurum_ilce',    t.kurum_ilce,
        'kurum_vkno',    t.kurum_vkno,
        'kurum_vd',      t.kurum_vd,
        'kurum_telefon', t.kurum_telefon);

    v_ham := s.baslik || E'\n' || s.govde || E'\n' || s.alt_not;

    -- EKSİKLERİ TOPLA: şablonda geçen her yer tutucu için değer var mı?
    --   Tanınmayan yer tutucu da eksiktir - şablonu yazan yanlış ad yazmış
    --   olabilir ve bunu sessizce yutmak, kâğıda `{maaas}` basardı.
    for v_anahtar in
        select distinct m[1] from regexp_matches(v_ham, '\{([a-z_]+)\}', 'g') m
    loop
        if coalesce(v_deger ->> v_anahtar, '') = '' then
            v_eksik := v_eksik || v_anahtar;
        end if;
    end loop;

    -- DEĞİŞTİRME: yalnız tanınan anahtarlar. Tanınmayan `{...}` metinde
    --   OLDUĞU GİBİ kalır - eksik listesinde zaten görünüyor, sessizce
    --   silmek onu gizlerdi.
    v_baslik := s.baslik;
    v_govde  := s.govde;
    v_alt    := s.alt_not;

    for r in select key, value from jsonb_each_text(v_deger) loop
        v_baslik := replace(v_baslik, '{' || r.key || '}', r.value);
        v_govde  := replace(v_govde,  '{' || r.key || '}', r.value);
        v_alt    := replace(v_alt,    '{' || r.key || '}', r.value);
    end loop;

    sablon_id  := s.id;
    sablon_ad  := s.ad;
    baslik     := v_baslik;
    govde      := v_govde;
    alt_not    := v_alt;
    imza_unvan := s.imza_unvan;
    eksik      := v_eksik;
    return next;
end $function$;

-- ---------------------------------------------------------------------
--  TAKMA ADSIZ okumalar (FROM taraf, nitelik yok): rol görünümleri
--  (cari / hasta / personel ...) ve lookup'lar, hesap planı alt hesabı,
--  randevu izin uyarısındaki hekim adı.
-- ---------------------------------------------------------------------
create or replace view public.v_isg_isveren_lookup as
 SELECT id,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS ad,
        CASE
            WHEN durum = 1 THEN 1
            ELSE 0
        END AS aktif
   FROM taraf t
  WHERE kurum = 1;

create or replace view public.cari as
 SELECT id,
    kod,
    eski_tip,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS unvan,
    fatura_unvan,
    ad,
    soyad,
    statu,
    grup,
    kategori,
    sinif,
    durum,
    sektor,
    alt_sektor,
    bolge,
    alt_bolge,
    temsilci,
    bag_id,
    telefon,
    cep_tel,
    eposta,
    eposta_web,
    vkno,
    vd,
    efatura,
    posta_izin,
    eposta_izin,
    notlar,
    ozel_kod,
    ozel,
    yetki_kodu,
    muh_kodu,
    muh_aktar,
    konum,
    peryot,
    giris_kaynak,
    d_tarih,
    resim,
    sube_id,
    ekleyen,
    ekleme_tarihi,
    degistiren,
    degistirme_tarihi,
    musteri,
    tedarikci,
    personel,
    kisi,
    hasta,
    alias_eposta,
    gorev,
    departman,
    rol,
    ilk_temas,
    muh_hesap_id,
    aday,
    efatura_sorgu_tarihi,
    alias_irsaliye,
    eirsaliye
   FROM taraf
  WHERE musteri = 1 OR tedarikci = 1;

create or replace view public.hasta as
 SELECT id,
    kod,
    eski_tip,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS unvan,
    fatura_unvan,
    ad,
    soyad,
    statu,
    grup,
    kategori,
    sinif,
    durum,
    sektor,
    alt_sektor,
    bolge,
    alt_bolge,
    temsilci,
    bag_id,
    telefon,
    cep_tel,
    eposta,
    eposta_web,
    vkno,
    vd,
    efatura,
    posta_izin,
    eposta_izin,
    notlar,
    ozel_kod,
    ozel,
    yetki_kodu,
    muh_kodu,
    muh_aktar,
    konum,
    peryot,
    giris_kaynak,
    d_tarih,
    resim,
    sube_id,
    ekleyen,
    ekleme_tarihi,
    degistiren,
    degistirme_tarihi,
    musteri,
    tedarikci,
    personel,
    kisi,
    hasta,
    alias_eposta,
    gorev,
    departman,
    rol,
    ilk_temas,
    muh_hesap_id,
    aday,
    efatura_sorgu_tarihi,
    alias_irsaliye,
    eirsaliye
   FROM taraf
  WHERE hasta = 1;

create or replace view public.musteri as
 SELECT id,
    kod,
    eski_tip,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS unvan,
    fatura_unvan,
    ad,
    soyad,
    statu,
    grup,
    kategori,
    sinif,
    durum,
    sektor,
    alt_sektor,
    bolge,
    alt_bolge,
    temsilci,
    bag_id,
    telefon,
    cep_tel,
    eposta,
    eposta_web,
    vkno,
    vd,
    efatura,
    posta_izin,
    eposta_izin,
    notlar,
    ozel_kod,
    ozel,
    yetki_kodu,
    muh_kodu,
    muh_aktar,
    konum,
    peryot,
    giris_kaynak,
    d_tarih,
    resim,
    sube_id,
    ekleyen,
    ekleme_tarihi,
    degistiren,
    degistirme_tarihi,
    musteri,
    tedarikci,
    personel,
    kisi,
    hasta,
    alias_eposta,
    gorev,
    departman,
    rol,
    ilk_temas,
    muh_hesap_id,
    aday,
    efatura_sorgu_tarihi,
    alias_irsaliye,
    eirsaliye
   FROM taraf
  WHERE musteri = 1;

create or replace view public.personel as
 SELECT id,
    kod,
    eski_tip,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS unvan,
    fatura_unvan,
    ad,
    soyad,
    statu,
    grup,
    kategori,
    sinif,
    durum,
    sektor,
    alt_sektor,
    bolge,
    alt_bolge,
    temsilci,
    bag_id,
    telefon,
    cep_tel,
    eposta,
    eposta_web,
    vkno,
    vd,
    efatura,
    posta_izin,
    eposta_izin,
    notlar,
    ozel_kod,
    ozel,
    yetki_kodu,
    muh_kodu,
    muh_aktar,
    konum,
    peryot,
    giris_kaynak,
    d_tarih,
    resim,
    sube_id,
    ekleyen,
    ekleme_tarihi,
    degistiren,
    degistirme_tarihi,
    musteri,
    tedarikci,
    personel,
    kisi,
    hasta,
    alias_eposta,
    gorev,
    departman,
    rol,
    ilk_temas,
    muh_hesap_id,
    aday,
    efatura_sorgu_tarihi,
    alias_irsaliye,
    eirsaliye
   FROM taraf
  WHERE personel = 1;

create or replace view public.tedarikci as
 SELECT id,
    kod,
    eski_tip,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS unvan,
    fatura_unvan,
    ad,
    soyad,
    statu,
    grup,
    kategori,
    sinif,
    durum,
    sektor,
    alt_sektor,
    bolge,
    alt_bolge,
    temsilci,
    bag_id,
    telefon,
    cep_tel,
    eposta,
    eposta_web,
    vkno,
    vd,
    efatura,
    posta_izin,
    eposta_izin,
    notlar,
    ozel_kod,
    ozel,
    yetki_kodu,
    muh_kodu,
    muh_aktar,
    konum,
    peryot,
    giris_kaynak,
    d_tarih,
    resim,
    sube_id,
    ekleyen,
    ekleme_tarihi,
    degistiren,
    degistirme_tarihi,
    musteri,
    tedarikci,
    personel,
    kisi,
    hasta,
    alias_eposta,
    gorev,
    departman,
    rol,
    ilk_temas,
    muh_hesap_id,
    aday,
    efatura_sorgu_tarihi,
    alias_irsaliye,
    eirsaliye
   FROM taraf
  WHERE tedarikci = 1;

create or replace view public.v_cari_lookup as
 SELECT id,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS ad,
        CASE
            WHEN durum = 1 THEN 1
            ELSE 0
        END AS aktif
   FROM taraf
  WHERE musteri = 1 OR tedarikci = 1 OR aday = 1;

create or replace view public.v_hekim_lookup as
 SELECT id,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS ad,
        CASE
            WHEN COALESCE(durum::integer, 1) = 1 THEN 1
            ELSE 0
        END AS aktif
   FROM taraf t
  WHERE personel = 1 AND fn_hekim_planli(id) = 1;

create or replace view public.v_personel_lookup as
 SELECT id,
    public.fn_taraf_ad(unvan, ad, soyad)::character varying(120) AS ad,
        CASE
            WHEN durum = 1 THEN 1
            ELSE 0
        END AS aktif
   FROM taraf
  WHERE personel = 1;

CREATE OR REPLACE FUNCTION public.fn_hesap_plani_alt_ac(p_ust_id integer, p_taraf_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
    v_ust  record;
    v_kod  varchar(20);
    v_id   integer;
    v_ad   varchar(100);
begin
    if p_ust_id is null or p_taraf_id is null then return p_ust_id; end if;

    select id, kod, sinif, doviz_cinsi, seviye into v_ust
      from public.hesap_plani where id = p_ust_id;
    if not found then return p_ust_id; end if;

    v_kod := v_ust.kod || '.' || p_taraf_id::text;

    select id into v_id from public.hesap_plani where kod = v_kod;
    if v_id is not null then return v_id; end if;

    select left(coalesce(nullif(btrim(public.fn_taraf_ad(unvan, ad, soyad)), ''), 'CARI ' || p_taraf_id), 100)
      into v_ad from public.taraf where id = p_taraf_id;

    insert into public.hesap_plani (kod, ad, ust_id, seviye, sinif, doviz_cinsi, calisir_mi, cari_alt_hesap, durum)
    values (v_kod, coalesce(v_ad, 'CARI ' || p_taraf_id), v_ust.id,
            coalesce(v_ust.seviye, 1) + 1, v_ust.sinif, v_ust.doviz_cinsi, 1, 0, 1)
    on conflict (kod) do nothing
    returning id into v_id;

    if v_id is null then
        select id into v_id from public.hesap_plani where kod = v_kod;
    end if;

    -- ust hesap artik yaprak degil
    update public.hesap_plani set calisir_mi = 0 where id = v_ust.id and calisir_mi = 1;
    return coalesce(v_id, p_ust_id);
end $function$;

CREATE OR REPLACE FUNCTION public.tg_randevu_izin_kontrol()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_izin   record;
  v_ayar   text;
  v_hekim  text;
begin
  -- İPTAL/GELMEDİ randevusu kontrol edilmez: geçmişi düzeltmek serbest.
  if coalesce(new.durum, 1) in (3, 4) then return new; end if;
  if new.hekim_id is null then return new; end if;

  select * into v_izin
    from public.fn_hekim_izinli(new.hekim_id, new.baslangic::date);
  if not found then return new; end if;

  select coalesce(nullif(deger, ''), '0') into v_ayar
    from public.referans where anahtar = 'randevu.izinli_hekim';

  -- 1 = YALNIZ UYAR: kurum bilerek yazmak isteyebilir (izin dönüşü ilk
  --   gün kontrolü, yarım gün izin). Uyarı istemci günlüğüne düşer.
  if coalesce(v_ayar, '0') = '1' then
    raise warning 'Hekim % tarihinde izinli (izin #%).',
      new.baslangic::date, v_izin.izin_id;
    return new;
  end if;

  select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Hekim') into v_hekim
    from public.taraf where id = new.hekim_id;

  raise exception '% % tarihinde izinli (% - %). İzinli hekime randevu '
                  'yazılamaz; izni iptal edin ya da başka hekim seçin.',
    v_hekim, to_char(new.baslangic::date, 'DD.MM.YYYY'),
    to_char(v_izin.baslangic, 'DD.MM.YYYY'), to_char(v_izin.bitis, 'DD.MM.YYYY')
    using errcode = 'GK422';
end $function$;

-- ---------------------------------------------------------------------
--  VERİ ONARIMI: personel unvanı -> yalnız önek.
-- ---------------------------------------------------------------------
create table if not exists public._yedek_940_personel_unvan (
    id integer primary key, unvan varchar(120) not null,
    yedek_tarihi timestamptz not null default now());

do $$
declare
    v_onekli integer; v_oneksiz integer; v_dokunulmadi integer;
begin
    -- Yedek: yalniz degisecek satirlar, ikinci calistirmada uzerine yazilmaz.
    insert into public._yedek_940_personel_unvan (id, unvan)
    select t.id, t.unvan
      from public.taraf t join public.taraf_personel p on p.id = t.id
     where coalesce(btrim(t.ad), '') <> ''
       and btrim(t.unvan) !~ '^([[:alpha:]]{1,6}\.)+$'
       and btrim(t.unvan) <> ''
       and (btrim(t.unvan) = btrim(concat_ws(' ', nullif(btrim(t.ad), ''), nullif(btrim(t.soyad), '')))
            or btrim(t.unvan) = substring(btrim(t.unvan) from '^(([[:alpha:]]{1,6}\.)+) ')
                                || ' ' || btrim(concat_ws(' ', nullif(btrim(t.ad), ''), nullif(btrim(t.soyad), ''))))
    on conflict (id) do nothing;

    -- Onekli tam ad: "Dr. Alim Sarı" -> "Dr."
    update public.taraf t
       set unvan = substring(btrim(t.unvan) from '^(([[:alpha:]]{1,6}\.)+) ')
      from public._yedek_940_personel_unvan y
     where y.id = t.id
       and btrim(t.unvan) ~ '^([[:alpha:]]{1,6}\.)+ ';
    get diagnostics v_onekli = row_count;

    -- Oneksiz tam ad: "Alim Sarı" -> ''
    update public.taraf t
       set unvan = ''
      from public._yedek_940_personel_unvan y
     where y.id = t.id
       and btrim(t.unvan) = btrim(concat_ws(' ', nullif(btrim(t.ad), ''), nullif(btrim(t.soyad), '')));
    get diagnostics v_oneksiz = row_count;

    select count(*) into v_dokunulmadi
      from public.taraf t join public.taraf_personel p on p.id = t.id
     where coalesce(btrim(t.ad), '') <> ''
       and btrim(t.unvan) <> ''
       and btrim(t.unvan) !~ '^([[:alpha:]]{1,6}\.)+$';

    raise notice '940 tamam: % personel unvani oneke indi, % bosaltildi (ad+soyad kullanilir), % elle yazilmis unvan dokunulmadi.',
        v_onekli, v_oneksiz, v_dokunulmadi;
end $$;
