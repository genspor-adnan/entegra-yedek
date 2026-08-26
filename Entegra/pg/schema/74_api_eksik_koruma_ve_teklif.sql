-- ============================================================================
-- PG eksik tamamlama / koruma katmani
-- Kaynak: GenUpdate/_Konsolide_66_169
--
-- Amaç:
--   1) MSSQL tarafında eklenen ama PG pilot DB'ye uygulanmamış silme ön-kontrol
--      parçalarını tamamlamak.
--   2) Henüz gerçek PG portu yazılmamış sp_Api_* yazma/silme fonksiyonlarını
--      "function does not exist" yerine açık ve güvenli hata ile durdurmak.
--
-- Not:
--   Bu dosyadaki fn_api_* gövdeleri bilerek kayıt yazmaz/silmez. Gerçek port
--   yapılana kadar logsuz veya yarım veri değişikliği riski alınmaz.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_pg_henuz_portlanmadi(p_api text)
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% PostgreSQL icin henuz portlanmadi. MSSQL konsolide komutundaki is kurali/log govdesi PG karsiligi yazilmadan islem yapilmadi.', p_api
    USING ERRCODE = 'P0001';
END;
$$;

-- Belge dönüşüm rotası: silinebilir kontrolleri ve dönüşüm ekranları tarafından
-- ortak matris olarak kullanılır. MSSQL fn_Prog_BelgeDonusum_Rota portu.
DROP FUNCTION IF EXISTS public.fn_prog_belgedonusum_rota();
CREATE FUNCTION public.fn_prog_belgedonusum_rota()
RETURNS TABLE(
  donusumturu integer,
  aciklama text,
  kaynaktur integer,
  hedeftur integer,
  kaynakbasliktablo text,
  kaynakdetaytablo text,
  hedefbasliktablo text,
  hedefdetaytablo text,
  kaynakbaglanti text,
  kalanhedeftablo text,
  kalangrubu text,
  girisdepokaynak text,
  cikisdepokaynak text,
  depoalani text,
  dovizalani text,
  stokdurumdegis integer,
  kdvmuafiyetkopyala integer,
  ekipmansabit integer,
  carpan integer,
  stokkontrolu integer,
  izlemeaktarim integer,
  uretimrecete integer,
  belgenopolitikasi text,
  destek integer
)
LANGUAGE sql STABLE AS $$
  SELECT *
  FROM (VALUES
    (406, 'Alis siparisi -> alis irsaliyesi',     9,  10, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', 'RAPORDOVIZ',   1,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 1),
    (407, 'Alis siparisi -> alis faturasi',       9,  11, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', NULL,           1,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 1),
    (478, 'Alis siparisi -> alis fisi',           9,  12, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', NULL,           1,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 1),
    (408, 'Alis irsaliyesi -> alis faturasi',    10,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', 'FATURADOVIZI', 0,1,0, 1,0,1,0, 'KULLANICI_GIRISI', 1),
    (427, 'Alis irsaliyesi -> alis fisi',        10,  12, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', 'FATURADOVIZI', 0,1,0, 1,0,1,0, 'KULLANICI_GIRISI', 1),
    (409, 'Satis siparisi -> satis irsaliyesi',  19,  14, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', 'RAPORDOVIZ',   1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (410, 'Satis siparisi -> satis faturasi',    19,  15, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (473, 'Satis siparisi -> satis fisi',        19,  16, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (429, 'Satis siparisi -> giden konsinye',    19, 119, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'SATIS_SIP',  'VARSAYILAN7', 'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (411, 'Satis irsaliyesi -> satis faturasi',  14,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', 'FATURADOVIZI', 0,1,0, 1,0,1,0, 'OTOMATIK',         1),
    (424, 'Satis irsaliyesi -> satis fisi',      14,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', 'FATURADOVIZI', 0,1,0, 1,0,1,0, 'OTOMATIK',         1),
    (414, 'Siparis -> transfer fisi',            19,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (435, 'Stok talebi -> transfer fisi',       105,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,1,0,0, 'OTOMATIK',         1),
    (461, 'Gelen konsinye -> alis faturasi',    109,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'GELEN_KON',  'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', NULL,           1,0,0, 1,0,1,0, 'KULLANICI_GIRISI', 1),
    (468, 'Giden konsinye -> satis irsaliyesi', 119,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO', 'CIKISDEPO', NULL,           0,0,0, 1,0,1,0, 'OTOMATIK',         1),
    (462, 'Giden konsinye -> satis faturasi',   119,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,0,1,0, 'OTOMATIK',         1),
    (472, 'Giden konsinye -> satis fisi',       119,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO', 'CIKISDEPO', NULL,           1,0,0, 1,0,1,0, 'OTOMATIK',         1),
    (415, 'Satis siparisi -> uretim (urun)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO', 'GIRISDEPO', 'RAPORDOVIZ',   1,0,1, 1,0,0,1, 'OTOMATIK',         1),
    (420, 'Satis siparisi -> uretim (sarf)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID', 'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           1,0,1,-1,1,0,0, 'OTOMATIK',         1),
    (425, 'Uretim fisi -> satis irsaliyesi',     6,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO', 'GIRISDEPO', 'FATURADOVIZI', 1,0,0, 1,0,1,0, 'OTOMATIK',         1),
    (426, 'Uretim fisi -> satis faturasi',        6,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',  'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO', 'GIRISDEPO', 'FATURADOVIZI', 1,0,0, 1,0,1,0, 'OTOMATIK',         1),
    (428, 'Satinalma talebi -> alis siparisi',  101,   9, 'SIPARIS',   'SIPARISDETAY', 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 'SIPARISDETAY','TALEP_SIP',  'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', NULL,           0,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 1),
    (412, 'Teklif -> alis siparisi',             80,   9, 'TEKLIF',    'TEKLIFDETAY',  'SIPARIS',   'SIPARISDETAY', 'TEKLIFID',  'SIPARISDETAY','TEKLIF_SIP', 'GIRISDEPO',   'CIKISDEPO', 'GIRISDEPO', NULL,           0,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 0),
    (413, 'Teklif -> satis siparisi',            80,  19, 'TEKLIF',    'TEKLIFDETAY',  'SIPARIS',   'SIPARISDETAY', 'TEKLIFID',  'SIPARISDETAY','TEKLIF_SIP', 'GIRISDEPO',   'CIKISDEPO', 'CIKISDEPO', NULL,           0,0,0, 1,0,0,0, 'KULLANICI_GIRISI', 0)
  ) AS r(
    donusumturu, aciklama, kaynaktur, hedeftur,
    kaynakbasliktablo, kaynakdetaytablo, hedefbasliktablo, hedefdetaytablo,
    kaynakbaglanti, kalanhedeftablo, kalangrubu,
    girisdepokaynak, cikisdepokaynak, depoalani, dovizalani,
    stokdurumdegis, kdvmuafiyetkopyala, ekipmansabit, carpan,
    stokkontrolu, izlemeaktarim, uretimrecete, belgenopolitikasi, destek
  );
$$;

-- Teklif silme ön-kontrolü: MSSQL sp_Prog_Teklif_Silinebilir_Mi portu.
DROP FUNCTION IF EXISTS public.fn_prog_teklif_silinebilir_mi(integer, integer);
CREATE FUNCTION public.fn_prog_teklif_silinebilir_mi(p_teklifid integer DEFAULT 0, p_satirid integer DEFAULT 0)
RETURNS TABLE(silinebilir integer, neden varchar, belgead varchar, belgetarih timestamp, belgeno varchar)
LANGUAGE sql STABLE AS $$
  WITH satirlar AS (
    SELECT td.id AS satirid
    FROM teklifdetay td
    WHERE (p_satirid > 0 AND td.id = p_satirid)
       OR (p_satirid = 0 AND td.teklifid = p_teklifid)
  )
  SELECT y.silinebilir, y.neden, y.belgead, y.belgetarih, y.belgeno
  FROM (
    SELECT
      0 AS silinebilir,
      'DONUSUM'::varchar AS neden,
      (SELECT i.ad FROM islemturleri i WHERE i.tur = s.tur LIMIT 1)::varchar AS belgead,
      s.siparistarih::timestamp AS belgetarih,
      s.siparisno::varchar AS belgeno,
      1 AS sira
    FROM satirlar x
    INNER JOIN public.fn_prog_belgedonusum_rota() r
      ON r.kaynakdetaytablo = 'TEKLIFDETAY'
    INNER JOIN siparisdetay sd
      ON sd.yerid = x.satirid AND sd.yeri = r.donusumturu
    INNER JOIN siparis s
      ON s.id = sd.siparisid

    UNION ALL
    SELECT 1, ''::varchar, NULL::varchar, NULL::timestamp, NULL::varchar, 99
  ) y
  ORDER BY y.sira
  LIMIT 1;
$$;

-- Henüz gerçek PG portu olmayan sp_Api_* fonksiyonları için geçici stub.
-- Önemli: Gerçek port dosyaları daha sonra DEFAULT parametreli fonksiyonlar oluşturur.
-- Bu dosya tekrar çalıştırıldığında gerçek fonksiyonları ezmemeli.
DO $stub$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT * FROM (VALUES
      ('fn_api_belge_donusum_json','sp_Api_Belge_Donusum_Json'),
      ('fn_api_belge_durumhesapla_json','sp_Api_Belge_DurumHesapla_Json'),
      ('fn_api_belge_iptal_json','sp_Api_Belge_Iptal_Json'),
      ('fn_api_belge_kaydet_json','sp_Api_Belge_Kaydet_Json'),
      ('fn_api_belge_klonla_json','sp_Api_Belge_Klonla_Json'),
      ('fn_api_belge_sil_json','sp_Api_Belge_Sil_Json'),
      ('fn_api_belge_siparis_kaydet_json','sp_Api_Belge_Siparis_Kaydet_Json'),
      ('fn_api_belge_siparis_klonla_json','sp_Api_Belge_Siparis_Klonla_Json'),
      ('fn_api_belge_siparis_sil_json','sp_Api_Belge_Siparis_Sil_Json'),
      ('fn_api_belge_toplamhesapla_json','sp_Api_Belge_ToplamHesapla_Json'),
      ('fn_api_cari_klonla_json','sp_Api_Cari_Klonla_Json'),
      ('fn_api_cari_sil_json','sp_Api_Cari_Sil_Json'),
      ('fn_api_ceksenet_sil_json','sp_Api_CekSenet_Sil_Json'),
      ('fn_api_demirbas_sil_json','sp_Api_Demirbas_Sil_Json'),
      ('fn_api_dokuman_sil_json','sp_Api_Dokuman_Sil_Json'),
      ('fn_api_firsat_sil_json','sp_Api_Firsat_Sil_Json'),
      ('fn_api_fiyat_eksikleriekle_json','sp_Api_Fiyat_EksikleriEkle_Json'),
      ('fn_api_gorev_sil_json','sp_Api_Gorev_Sil_Json'),
      ('fn_api_ik_klonla_json','sp_Api_IK_Klonla_Json'),
      ('fn_api_ik_sil_json','sp_Api_IK_Sil_Json'),
      ('fn_api_kasa_sil_json','sp_Api_Kasa_Sil_Json'),
      ('fn_api_kasahareket_sil_json','sp_Api_KasaHareket_Sil_Json'),
      ('fn_api_kredikarti_sil_json','sp_Api_KrediKarti_Sil_Json'),
      ('fn_api_masrafgelir_sil_json','sp_Api_MasrafGelir_Sil_Json'),
      ('fn_api_mesaj_gonder_json','sp_Api_Mesaj_Gonder_Json'),
      ('fn_api_mesaj_kanal_avatar_json','sp_Api_Mesaj_Kanal_Avatar_Json'),
      ('fn_api_mesaj_kanal_favori_json','sp_Api_Mesaj_Kanal_Favori_Json'),
      ('fn_api_mesaj_kanal_kaydet_json','sp_Api_Mesaj_Kanal_Kaydet_Json'),
      ('fn_api_mesaj_kanal_rol_json','sp_Api_Mesaj_Kanal_Rol_Json'),
      ('fn_api_mesaj_kanal_temizle_json','sp_Api_Mesaj_Kanal_Temizle_Json'),
      ('fn_api_mesaj_okundu_json','sp_Api_Mesaj_Okundu_Json'),
      ('fn_api_mesaj_okunmadi_json','sp_Api_Mesaj_Okunmadi_Json'),
      ('fn_api_mesaj_sil_json','sp_Api_Mesaj_Sil_Json'),
      ('fn_api_pos_iskonto_json','sp_Api_POS_Iskonto_Json'),
      ('fn_api_pos_satis_json','sp_Api_POS_Satis_Json'),
      ('fn_api_pos_sil_json','sp_Api_POS_Sil_Json'),
      ('fn_api_pos_tahsilat_json','sp_Api_POS_Tahsilat_Json'),
      ('fn_api_proje_sil_json','sp_Api_Proje_Sil_Json'),
      ('fn_api_servis_sil_json','sp_Api_Servis_Sil_Json'),
      ('fn_api_stok_kaydet_json','sp_Api_Stok_Kaydet_Json'),
      ('fn_api_stok_klonla_json','sp_Api_Stok_Klonla_Json'),
      ('fn_api_stok_sayim_sil_json','sp_Api_Stok_Sayim_Sil_Json'),
      ('fn_api_stok_sil_json','sp_Api_Stok_Sil_Json'),
      ('fn_api_stoksayim_sil_json','sp_Api_StokSayim_Sil_Json'),
      ('fn_api_teklif_sil_json','sp_Api_Teklif_Sil_Json'),
      ('fn_api_uretimemri_sil_json','sp_Api_UretimEmri_Sil_Json'),
      ('fn_api_uretimrecete_sil_json','sp_Api_UretimRecete_Sil_Json')
    ) AS v(fn_name, api_name)
  LOOP
    IF to_regprocedure(format('public.%I(text)', r.fn_name)) IS NULL THEN
      EXECUTE format(
        'CREATE FUNCTION public.%I(kosullar text) RETURNS text LANGUAGE sql AS %L',
        r.fn_name,
        format('SELECT public.fn_api_pg_henuz_portlanmadi(%L)', r.api_name)
      );
    END IF;
  END LOOP;
END
$stub$;
