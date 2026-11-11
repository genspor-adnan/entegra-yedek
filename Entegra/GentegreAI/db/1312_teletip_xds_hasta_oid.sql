-- 1312 - Teletıp XDS hasta OID'i Bakanlık değerine
--
-- 1310 teletip.xds_hasta_oid için tahmini bir varsayılan (2.16.792.1.2.1.1.5.2.1.1) koymuştu. Teleradyoloji XDS
-- Entegrasyon Kılavuzu 1.15 Şekil 16 ve Bakanlık SendKOS v15 kaynağı (teletip.saglik.gov.tr, 11.11.2026 karşılaştırma)
-- patientId'yi "TCKN^^^&1.3.6.1.4.1.21367.13.20.3000&ISO" olarak veriyor.
--
-- Yalnız değeri hâlâ eski tahmin olan satır düzeltilir; kurumun elle girdiği farklı bir OID'e dokunulmaz.
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;
update public.referans
   set deger = '1.3.6.1.4.1.21367.13.20.3000'
 where anahtar = 'teletip.xds_hasta_oid' and deger = '2.16.792.1.2.1.1.5.2.1.1';
update public.referans
   set aciklama = 'XDS patientId atama otoritesi OID''i (TCKN^^^&OID&ISO). Bakanlık değeri 1.3.6.1.4.1.21367.13.20.3000 (kılavuz XDS 1.15 Şekil 16, SendKOS).'
 where anahtar = 'teletip.xds_hasta_oid';
commit;
