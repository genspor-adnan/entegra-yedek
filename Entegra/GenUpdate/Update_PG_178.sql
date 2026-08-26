-- ============================================================
-- Update_PG_178.sql   #pg   (PostgreSQL)
-- SGK e-Fatura alanlari
--
-- SGK faturalari icin FATBASLIK.TIPI=25 kullanilir.
-- Senaryo TEMEL kalir; RepSenaryo'ya yeni kayit gerekmez.
-- ============================================================

ALTER TABLE IF EXISTS fatbaslik_user
    ADD COLUMN IF NOT EXISTS sgk_ilave_tipi varchar(20),
    ADD COLUMN IF NOT EXISTS sgk_mukellef_kodu varchar(50),
    ADD COLUMN IF NOT EXISTS sgk_mukellef_adi varchar(150),
    ADD COLUMN IF NOT EXISTS sgk_dosya_no varchar(50),
    ADD COLUMN IF NOT EXISTS sgk_donem_bas date,
    ADD COLUMN IF NOT EXISTS sgk_donem_bit date;

INSERT INTO genini (bolum, anahtar, deger, sira, dil)
SELECT -2407, 'SGK', '25', 25, -1
WHERE NOT EXISTS (
    SELECT 1 FROM genini WHERE bolum=-2407 AND anahtar='SGK' AND dil=-1
);

UPDATE genini
   SET deger='25', sira=COALESCE(sira, 25)
 WHERE bolum=-2407 AND anahtar='SGK' AND dil=-1;

UPDATE alanlar SET tur=1, caption='SGK Ilave Tipi', sql=NULL, top=20
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_ILAVE_TIPI';
UPDATE alanlar SET tur=1, caption='SGK Mukellef Kodu', top=20
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_MUKELLEF_KODU';
UPDATE alanlar SET tur=1, caption='SGK Mukellef Adi', top=20
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_MUKELLEF_ADI';
UPDATE alanlar SET tur=1, caption='SGK Dosya No', top=70
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DOSYA_NO';
UPDATE alanlar SET tur=3, caption='SGK Donem Bas.', top=70
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DONEM_BAS';
UPDATE alanlar SET tur=3, caption='SGK Donem Bit.', top=70
 WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DONEM_BIT';

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_ILAVE','SGK Ilave Tipi',
       NULL,'PanelEkAlanlar',25,20,2,false,false,false,'Tahoma','clWindowText',8,'16777215',18,180,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_ILAVE');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_MKOD','SGK Mukellef Kodu',
       NULL,'PanelEkAlanlar',25,220,2,false,false,false,'Tahoma','clWindowText',8,'16777215',18,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_MKOD');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_MADI','SGK Mukellef Adi',
       NULL,'PanelEkAlanlar',25,370,2,false,false,false,'Tahoma','clWindowText',8,'16777215',18,220,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_MADI');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_DOSYA','SGK Dosya No',
       NULL,'PanelEkAlanlar',25,20,52,false,false,false,'Tahoma','clWindowText',8,'16777215',18,180,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_DOSYA');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_DBAS','SGK Donem Bas.',
       NULL,'PanelEkAlanlar',25,220,52,false,false,false,'Tahoma','clWindowText',8,'16777215',18,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_DBAS');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',11,'FATBASLIK_USER','LBL_SGK_DBIT','SGK Donem Bit.',
       NULL,'PanelEkAlanlar',25,370,52,false,false,false,'Tahoma','clWindowText',8,'16777215',18,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='LBL_SGK_DBIT');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',1,'FATBASLIK_USER','SGK_ILAVE_TIPI','SGK Ilave Tipi',
       NULL,
       'PanelEkAlanlar',25,20,20,false,false,false,'Tahoma','clWindowText',8,'16777215',21,180,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_ILAVE_TIPI');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',1,'FATBASLIK_USER','SGK_MUKELLEF_KODU','SGK Mukellef Kodu',
       NULL,'PanelEkAlanlar',25,220,20,false,false,false,'Tahoma','clWindowText',8,'16777215',21,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_MUKELLEF_KODU');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',1,'FATBASLIK_USER','SGK_MUKELLEF_ADI','SGK Mukellef Adi',
       NULL,'PanelEkAlanlar',25,370,20,false,false,false,'Tahoma','clWindowText',8,'16777215',21,220,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_MUKELLEF_ADI');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',1,'FATBASLIK_USER','SGK_DOSYA_NO','SGK Dosya No',
       NULL,'PanelEkAlanlar',25,20,70,false,false,false,'Tahoma','clWindowText',8,'16777215',21,180,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DOSYA_NO');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',3,'FATBASLIK_USER','SGK_DONEM_BAS','SGK Donem Bas.',
       NULL,'PanelEkAlanlar',25,220,70,false,false,false,'Tahoma','clWindowText',8,'16777215',21,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DONEM_BAS');

INSERT INTO alanlar
  (ekranadi,tur,tablo,alanadi,caption,sql,konum,tag,"left",top,bold,italik,altcizgi,font,fontcolor,fontsize,arkarenk,height,width,ekleyen,eklemetarihi,subeid)
SELECT 'FaturaWizardDlg',3,'FATBASLIK_USER','SGK_DONEM_BIT','SGK Donem Bit.',
       NULL,'PanelEkAlanlar',25,370,70,false,false,false,'Tahoma','clWindowText',8,'16777215',21,130,1,now(),1
WHERE NOT EXISTS (SELECT 1 FROM alanlar WHERE ekranadi='FaturaWizardDlg' AND alanadi='SGK_DONEM_BIT');


