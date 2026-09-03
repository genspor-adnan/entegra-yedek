-- ============================================================================
--  363 - HAKEDIS SATIRINDA ROL ISARETI KONTROLU
--
--  Kullanici: "hakediş ekranını da bu işaretlere göre kontrol et".
--
--  Prim rol isaretleri (361/362) NEREDE DURUYOR:
--    ic personel -> taraf_prim_rol satirlari
--    dis hekim   -> taraf_personel.calisma_sekli = 3 ("Gönderen")
--
--  Hakedis satiri ise GECMISTE uretilmis bir kayittir: kalem rolu o gun
--  girilmis, prim dogmus olabilir. Isaret sonradan kaldirilinca (or. dis hekim
--  "Tam Zamanlı"ya cevrildi, personelin "Yapan" isareti silindi) eski satirlar
--  yerinde kalir - hakedis TARIHSEL kayittir, geriye donuk silinmez.
--
--  Bu yuzden kural DOGRULAMA degil GORUNURLUKTUR: satirin kisisi bugun o rolde
--  isaretli mi, listede yazar. Uyusmayan satir "İşaret yok" rozetiyle durur;
--  kullanici ya kisinin kartina isareti geri koyar ya da satiri iptal eder.
--
--  Prim URETIMI bilerek engellenmedi: kalem rolu zaten isaretli kisilerden
--  seciliyor (basvuru combosu + prim rol modali), tek delik gecmise donuk
--  duzeltmelerdir ve orada dogru davranis kaydi kaybetmek degil GOSTERMEKTIR.
-- ============================================================================

create or replace view public.v_hakedis_satir as
 SELECT hs.id,
    hs.hakedis_id,
    hs.taraf_id,
    COALESCE(t.unvan, ''::character varying) AS kisi,
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
    COALESCE(h2.unvan, ''::character varying) AS hasta,
    b.sube_id,
    -- ROL ISARETI (363): kisi BUGUN bu rolde isaretli mi (361/362).
    (CASE WHEN EXISTS (SELECT 1 FROM public.v_prim_rol_aday a
                        WHERE a.id = hs.taraf_id AND a.rol = hs.rol)
          THEN 1 ELSE 0 END)::smallint AS rol_isaretli,
    (CASE WHEN EXISTS (SELECT 1 FROM public.v_prim_rol_aday a
                        WHERE a.id = hs.taraf_id AND a.rol = hs.rol)
          THEN 'Uygun'::text ELSE 'İşaret yok'::text END) AS isaret_adi
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

comment on view public.v_hakedis_satir is
  'Hakedis satirlari (324/330/332) + rol isareti kontrolu (363): rol_isaretli / '
  'isaret_adi kolonlari kisinin BUGUNKU prim rol isaretiyle uyumu gosterir - '
  'satir tarihsel kayittir, isaret kalkinca silinmez.';
