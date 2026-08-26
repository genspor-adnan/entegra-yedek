-- ============================================================================
--  Gentegre AI — Satis/Alis belge ayarlari + e-Belge opsiyonlari
--  155_belge_ebelge_ayarlari.sql
--
--  Kullanici: "Ayarlar altina Satış Belgeleri ve Alış Belgeleri ac, ikisine de
--  Genel sekmesi; satista sagina e-Belge sekmesi; Delphi'de alis/satis
--  ayarlari altindaki e-belge opsiyonlarinin TUMUNU buraya tasi."
--
--  KAYNAK: Delphi `UOpsiyonFatura` (Opsiyonlar > Fatura > E-Belge). Orada
--  opsiyonlar GENINI'de NEGATIF KODLARLA duruyor (-24030 e-Fatura aktif,
--  -24031 entegrator, ...). Burada okunur anahtarlara cevrildi:
--
--      ebelge.*     entegrator baglantisi (butun e-belge turleri icin ORTAK)
--      efatura.*    earsiv.*    eirsaliye.*    esmm.*
--
--  ALIS tarafinda e-Belge YOK: gelen belgeyi GIB'e biz gondermeyiz. "Gelen ...
--  al" bayraklari e-Belge sekmesinde, cunku ayni entegrator baglantisini
--  kullanirlar.
--
--  TASINMADI (bilerek):
--    * XSLT sablon secimleri - Delphi'de DOKUMLER tablosundan combo doluyor;
--      GentegreAI'de belge sablonu deposu henuz yok.
--    * "Seri Kurallari" ve "Alan Eslestirme" gridleri - tek degerli ayar degil,
--      SATIRLI tanimlar; kendi kartlarini isterler.
--
--  BULGU (Delphi tarafinda, burada TEKRARLANMADI): `Ops_OpsiyonEIrsaliye` ve
--    `Ops_OpsiyonIhracatGonder` AYNI GENINI kodunu (-24024) kullaniyor; iki
--    ayri opsiyon tek deger uzerinde yaziyor. Burada ayri anahtarlar verildi.
--
--  BAYRAKLAR KAPALI BASLAR: acik varsayilan, kurulumu yapilmamis bir sistemde
--    belgeleri GIB'e gondermeye calisirdi.
-- ============================================================================
\set ON_ERROR_STOP on

-- Ayar satiri + aciklamasi. Var olan degeri EZMEZ (kullanici girmis olabilir).
create or replace function pg_temp.ayar_ekle(p_anahtar text, p_deger text, p_aciklama text)
returns void language plpgsql as $$
begin
    insert into public.referans (anahtar, deger, aciklama)
    values (p_anahtar, p_deger, p_aciklama)
    on conflict (anahtar) do update set aciklama = excluded.aciklama;
end $$;

-- ---------------------------------------------------- belge girisi (yon) ----
select pg_temp.ayar_ekle('belge.satis.vade_gun', '30',
    'Satış belgelerinde varsayılan vade (gün)');
select pg_temp.ayar_ekle('belge.satis.varsayilan_seri', 'WEB',
    'Satış belgelerinde varsayılan seri');
select pg_temp.ayar_ekle('belge.alis.vade_gun', '30',
    'Alış belgelerinde varsayılan vade (gün)');
select pg_temp.ayar_ekle('belge.alis.varsayilan_seri', 'WEB',
    'Alış belgelerinde varsayılan seri');

-- ------------------------------------------------- entegrator baglantisi ----
select pg_temp.ayar_ekle('ebelge.aktif', '0',
    'e-Belge kullanımda (kapalıysa hiçbir belge GİB''e gönderilmez)');
select pg_temp.ayar_ekle('ebelge.entegrator', '',
    'Entegratör adı (Delphi: GENINI -24031)');
select pg_temp.ayar_ekle('ebelge.vkn', '',
    'e-Belge gönderiminde kullanılan vergi / kimlik numarası');
select pg_temp.ayar_ekle('ebelge.kullanici', '',
    'Entegratör kullanıcı adı');
select pg_temp.ayar_ekle('ebelge.sifre', '',
    'Entegratör şifresi. DÜZ METİN saklanır - bu hesabın e-Belge dışında yetkisi olmamalı.');
select pg_temp.ayar_ekle('ebelge.test_aktif', '0',
    'Test ortamı aktif. Açıkken kesilen belgeler RESMİ DEĞİLDİR, GİB''e ulaşmaz.');
select pg_temp.ayar_ekle('ebelge.test_kullanici', '', 'Test ortamı kullanıcı adı');
select pg_temp.ayar_ekle('ebelge.test_sifre', '', 'Test ortamı şifresi (düz metin saklanır)');

-- ------------------------------------------------------------- e-Fatura -----
select pg_temp.ayar_ekle('efatura.gelen_al', '0',
    'Gelen e-Faturaları entegratörden çek');
select pg_temp.ayar_ekle('efatura.senaryo', '1',
    'Varsayılan senaryo: 1 Temel, 2 Ticari, 8 İlaç / Tıbbi Cihaz');
select pg_temp.ayar_ekle('efatura.ihracat_gonder', '0',
    'İhracat faturaları da e-Fatura olarak gönderilsin');
select pg_temp.ayar_ekle('efatura.uretim_url', '', 'e-Fatura üretim servis adresi');
select pg_temp.ayar_ekle('efatura.test_url', '', 'e-Fatura test servis adresi');
select pg_temp.ayar_ekle('efatura.sabit_notlar', '',
    'Her e-Faturaya eklenen sabit not metni');

-- -------------------------------------------------------------- e-Arşiv -----
select pg_temp.ayar_ekle('earsiv.aktif', '0', 'e-Arşiv aktif');
select pg_temp.ayar_ekle('earsiv.uretim_url', '', 'e-Arşiv üretim (giden) servis adresi');
select pg_temp.ayar_ekle('earsiv.gelen_url', '', 'e-Arşiv üretim (gelen) servis adresi');
select pg_temp.ayar_ekle('earsiv.test_url', '', 'e-Arşiv test (giden) servis adresi');
select pg_temp.ayar_ekle('earsiv.sabit_notlar', '', 'Her e-Arşiv faturasına eklenen sabit not');

-- ----------------------------------------------------------- e-İrsaliye -----
select pg_temp.ayar_ekle('eirsaliye.aktif', '0', 'e-İrsaliye aktif');
select pg_temp.ayar_ekle('eirsaliye.gelen_al', '0', 'Gelen e-İrsaliyeleri entegratörden çek');
select pg_temp.ayar_ekle('eirsaliye.gib_alias', '', 'GİB portal adresi (alias)');
select pg_temp.ayar_ekle('eirsaliye.uretim_url', '', 'e-İrsaliye üretim servis adresi');
select pg_temp.ayar_ekle('eirsaliye.test_url', '', 'e-İrsaliye test servis adresi');
select pg_temp.ayar_ekle('eirsaliye.sabit_notlar', '', 'Her e-İrsaliyeye eklenen sabit not');

-- ---------------------------------------------------------------- e-SMM -----
select pg_temp.ayar_ekle('esmm.aktif', '0', 'e-Serbest Meslek Makbuzu aktif');
select pg_temp.ayar_ekle('esmm.uretim_url', '', 'e-SMM üretim servis adresi');
select pg_temp.ayar_ekle('esmm.test_url', '', 'e-SMM test servis adresi');
select pg_temp.ayar_ekle('esmm.sabit_notlar', '', 'Her e-SMM''ye eklenen sabit not');

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi from public.referans
     where anahtar like 'ebelge.%' or anahtar like 'efatura.%' or anahtar like 'earsiv.%'
        or anahtar like 'eirsaliye.%' or anahtar like 'esmm.%' or anahtar like 'belge.satis.%'
        or anahtar like 'belge.alis.%';
    raise notice '155 tamam: % ayar satiri (belge girisi + e-Belge).', v_sayi;
end $$;
