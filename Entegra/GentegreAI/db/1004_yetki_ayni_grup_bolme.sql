-- =============================================================================
--  1004 - AYNI GRUPTA BİRDEN ÇOK EKRAN AÇAN YETKİ KODLARINI BÖLME (AŞAMA 1)
--
--  Kullanıcı (09.10.2026): "B grubunu da böl" -> "1 ile başla, sonra 2".
--  Temel prensip: "genprofil ile seçtiğim menüler yetki matrisinde
--  görünecek.. yetki matrisinde gör=True dediğim menüler de kullanıcı
--  menüsünde görünecek" / "menü koduyla yetki matrisi kodları aynı olmalı".
--
--  1003 farklı menü gruplarını açan 8 kodu böldü. Burada aynı grubun içinde
--  birden çok ekran açan 58 kod: ana ekran eski kodu korur, diğer 117 ekran
--  kendi kodunu alır (örn. muayene -> Çalışma Listesi; muayene.recete,
--  muayene.liste, muayene.sablon, muayene.makro). Harita:
--  Gentegre.Cekirdek/Yetki/EkranKodlari.AyniGrup.cs (web listeTanimlari ile
--  birlikte üretildi).
--
--  AŞAMA 1: yeni kod eski kodun sunucu kapısını açar; DAĞITIM: eski kodu olan
--  her role yeni kod AYNI haklarla (gör/ekle/değiştir/sil/değer/kapsam) -
--  kimse yetki kazanmaz ya da kaybetmez. Yetki satırı sıra / ürün modu /
--  modül bilgisini eski koddan alır (kapalı modülün ekranı matriste yine
--  görünmez). Betik idempotent; var olan rol_yetki satırına dokunmaz.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40))
  on commit drop;

insert into _bolme values
  ('acil.pano.cagri', 'acil.pano', 'Çağrılar (Acil)', 'Acil'),
  ('ameliyathane.plan.cizelge', 'ameliyathane.plan', 'Masa Çizelgesi (Ameliyathane)', 'Ameliyathane'),
  ('ariza.ekip', 'ariza', 'Arıza Ekipleri (Teknik Servis)', 'Teknik Servis'),
  ('ayar.demo_verisi', 'ayar', 'Demo Verisi (Yönetim)', 'Yönetim'),
  ('ayar.iceri_alma', 'ayar', 'Excel''den İçeri Alma (Yönetim)', 'Yönetim'),
  ('belge.alis.ayar', 'belge.alis', 'Alış Belgeleri (Alış)', 'Alış'),
  ('belge.alis.fis', 'belge.alis', 'Alış Fişleri (Alış)', 'Alış'),
  ('belge.alis.irsaliye', 'belge.alis', 'Alış İrsaliyeleri (Alış)', 'Alış'),
  ('belge.alis.konsinye', 'belge.alis', 'Alış Konsinyeler (Alış)', 'Alış'),
  ('belge.alis.tahakkuk', 'belge.alis', 'Tahakkuklar (Alış)', 'Alış'),
  ('belge.satis.acik_satir', 'belge.satis', 'Açık Satırlar (Satış)', 'Satış'),
  ('belge.satis.ayar', 'belge.satis', 'Satış Belgeleri (Satış)', 'Satış'),
  ('belge.satis.fatura', 'belge.satis', 'Satış Faturaları (Satış)', 'Satış'),
  ('belge.satis.fis', 'belge.satis', 'Satış Fişleri (Satış)', 'Satış'),
  ('belge.satis.irsaliye', 'belge.satis', 'Satış İrsaliyeleri (Satış)', 'Satış'),
  ('belge.satis.siparis', 'belge.satis', 'Satış Siparişleri (Satış)', 'Satış'),
  ('belge.satis.tahakkuk', 'belge.satis', 'Tahakkuklar (Satış)', 'Satış'),
  ('belge.stok.cikis', 'belge.stok', 'Çıkış Fişi (Stok & Hizmet)', 'Stok & Hizmet'),
  ('belge.stok.giris', 'belge.stok', 'Giriş Fişi (Stok & Hizmet)', 'Stok & Hizmet'),
  ('belge.stok.transfer', 'belge.stok', 'Stok Transfer (Stok & Hizmet)', 'Stok & Hizmet'),
  ('cagri.ayar.agent', 'cagri.ayar', 'Agentlar (dahili) (Çağrı Merkezi)', 'Çağrı Merkezi'),
  ('cagri.ayar.kuyruk', 'cagri.ayar', 'Kuyruklar & SLA (Çağrı Merkezi)', 'Çağrı Merkezi'),
  ('cagri.ayar.santral', 'cagri.ayar', 'Santral · IVR · Kanallar (Çağrı Merkezi)', 'Çağrı Merkezi'),
  ('cari.kisi', 'cari', 'Kişi Listesi (Cari & CRM)', 'Cari & CRM'),
  ('cek_senet.senet', 'cek_senet', 'Senet Listesi (Finans)', 'Finans'),
  ('cihaz.mesaj', 'cihaz', 'Cihaz Mesajları (Laboratuvar)', 'Laboratuvar'),
  ('dis.unit.lab', 'dis.unit', 'Laboratuvarlar (Diş)', 'Diş'),
  ('dokuman.kategori', 'dokuman', 'Kategoriler (Doküman)', 'Doküman'),
  ('dokuman.klasor', 'dokuman', 'Klasörler (Doküman)', 'Doküman'),
  ('entegrasyon.kod_esleme', 'entegrasyon', 'Kod Eşleme (e-Nabız)', 'e-Nabız'),
  ('entegrasyon.kuyruk', 'entegrasyon', 'Gönderim Kuyruğu (e-Nabız)', 'e-Nabız'),
  ('fiyat_listesi.kampanya', 'fiyat_listesi', 'Kampanyalar (Kurumlar & Sigorta)', 'Kurumlar & Sigorta'),
  ('ftr.seans.liste', 'ftr.seans', 'Seanslar (FTR)', 'FTR'),
  ('goz.hasta_ozet', 'goz', 'Hasta Özeti (Göz)', 'Göz'),
  ('goz.cihaz.mesaj', 'goz.cihaz', 'Cihaz Mesajları (Göz)', 'Göz'),
  ('goz.islem.protokol', 'goz.islem', 'İşlem Protokolleri (Göz)', 'Göz'),
  ('goz.recete.kontakt_lens', 'goz.recete', 'Kontakt Lens (Göz)', 'Göz'),
  ('hesap.tanim.banka', 'hesap.tanim', 'Banka Hesapları (Finans)', 'Finans'),
  ('hesap.tanim.banka_tanim', 'hesap.tanim', 'Banka Tanımları (Finans)', 'Finans'),
  ('hesap.tanim.ekstre', 'hesap.tanim', 'Hesap Ekstresi (Finans)', 'Finans'),
  ('hesap.tanim.kredi', 'hesap.tanim', 'Krediler (Finans)', 'Finans'),
  ('hesap.tanim.kredi_karti', 'hesap.tanim', 'Kredi Kartı (Finans)', 'Finans'),
  ('hesap.tanim.pos', 'hesap.tanim', 'POS (Finans)', 'Finans'),
  ('ik.izin.bakiye', 'ik.izin', 'İzin Bakiyesi (İK)', 'İK'),
  ('islem_log.giris', 'islem_log', 'Giriş Kayıtları (Yönetim)', 'Yönetim'),
  ('kasa.finans.ayar', 'kasa.finans', 'Kasa (Finans)', 'Finans'),
  ('kasa.finans.vade', 'kasa.finans', 'Vade / Planlar (Finans)', 'Finans'),
  ('katalog.ilac', 'katalog', 'İlaç Kataloğu (Muayene)', 'Muayene'),
  ('katalog.klinik', 'katalog', 'Klinik Kataloglar (Muayene)', 'Muayene'),
  ('kullanici.onay_akis', 'kullanici', 'Onay Akışları (Yönetim)', 'Yönetim'),
  ('kullanici.onay_vekalet', 'kullanici', 'Onay Vekâleti (Yönetim)', 'Yönetim'),
  ('kurum.icmal', 'kurum', 'Kurum İcmalleri (Kurumlar & Sigorta)', 'Kurumlar & Sigorta'),
  ('lab.akilci_karar', 'lab', 'Akılcı İstem Kararları (Laboratuvar)', 'Laboratuvar'),
  ('lab.arsiv.kayit', 'lab.arsiv', 'Arşiv Kayıtları (Laboratuvar)', 'Laboratuvar'),
  ('lab.dislab.tanim', 'lab.dislab', 'Dış Laboratuvarlar (Laboratuvar)', 'Laboratuvar'),
  ('lab.gen.panel', 'lab.gen', 'Genetik Panelleri (Laboratuvar)', 'Laboratuvar'),
  ('lab.genetik.run', 'lab.genetik', 'Dizileme Runları (Laboratuvar)', 'Laboratuvar'),
  ('lab.genetik.varyant', 'lab.genetik', 'Varyantlar (Laboratuvar)', 'Laboratuvar'),
  ('lab.kk.cihaz_olay', 'lab.kk', 'Cihaz Olayları (Laboratuvar)', 'Laboratuvar'),
  ('lab.kk.dkk', 'lab.kk', 'Dış Kalite (Laboratuvar)', 'Laboratuvar'),
  ('lab.kk.kural', 'lab.kk', 'Westgard Kuralları (Laboratuvar)', 'Laboratuvar'),
  ('lab.kk.lot', 'lab.kk', 'Kontrol Lotları (Laboratuvar)', 'Laboratuvar'),
  ('lab.mikro.antibiyotik', 'lab.mikro', 'Antibiyotikler (Laboratuvar)', 'Laboratuvar'),
  ('lab.mikro.besiyeri', 'lab.mikro', 'Besiyerleri (Laboratuvar)', 'Laboratuvar'),
  ('lab.tetkik.akilci_kural', 'lab.tetkik', 'Akılcı İstem Kuralları (Laboratuvar)', 'Laboratuvar'),
  ('lab.tetkik.indeks', 'lab.tetkik', 'Serum İndeksi (Laboratuvar)', 'Laboratuvar'),
  ('lab.tetkik.panel', 'lab.tetkik', 'Paneller (Laboratuvar)', 'Laboratuvar'),
  ('lab.tetkik.refleks_kural', 'lab.tetkik', 'Refleks Test Kuralları (Laboratuvar)', 'Laboratuvar'),
  ('medula.cagri_gunlugu', 'medula', 'Çağrı Günlüğü (Medula)', 'Medula'),
  ('medula.kuyruk_ayar', 'medula', 'Gönderim Kuyruğu & Ayarlar (Medula)', 'Medula'),
  ('medula.fatura.donem', 'medula.fatura', 'Dönemler (Medula)', 'Medula'),
  ('medula.fatura.kesinti', 'medula.fatura', 'Kesinti / İtiraz (Medula)', 'Medula'),
  ('medula.fatura.liste', 'medula.fatura', 'Faturalar (Medula)', 'Medula'),
  ('medula.recete.rapor', 'medula.recete', 'e-Rapor (Medula)', 'Medula'),
  ('muayene.liste', 'muayene', 'Muayeneler (Muayene)', 'Muayene'),
  ('muayene.makro', 'muayene', 'Metin Makroları (Muayene)', 'Muayene'),
  ('muayene.recete', 'muayene', 'Reçeteler (Muayene)', 'Muayene'),
  ('muayene.sablon', 'muayene', 'Muayene Şablonları (Muayene)', 'Muayene'),
  ('onam.kayit', 'onam', 'Onam Kayıtları (Yönetim)', 'Yönetim'),
  ('personel.bolum', 'personel', 'Bölüm / Görev (İK)', 'İK'),
  ('prim.plan', 'prim', 'Prim Planları (İK)', 'İK'),
  ('prim.kendi.satir', 'prim.kendi', 'Prim Satırları (Muayene)', 'Muayene'),
  ('radyoloji.cihaz', 'radyoloji', 'Cihazlar (Radyoloji)', 'Radyoloji'),
  ('radyoloji.konsultasyon', 'radyoloji', 'Konsültasyonlar (Radyoloji)', 'Radyoloji'),
  ('radyoloji.kritik', 'radyoloji', 'Kritik Bulgular (Radyoloji)', 'Radyoloji'),
  ('radyoloji.protokol', 'radyoloji', 'Çekim Protokolleri (Radyoloji)', 'Radyoloji'),
  ('radyoloji.sablon', 'radyoloji', 'Rapor Şablonları (Radyoloji)', 'Radyoloji'),
  ('radyoloji.teslim', 'radyoloji', 'Sonuç Teslim (Radyoloji)', 'Radyoloji'),
  ('randevu.plan.istisna', 'randevu.plan', 'Çalışma İstisnaları (Randevu)', 'Randevu'),
  ('randevu.plan.sablon', 'randevu.plan', 'Çalışma Şablonları (Randevu)', 'Randevu'),
  ('servis.cizelge', 'servis', 'Çizelge (Teknik Servis)', 'Teknik Servis'),
  ('servis.emanet', 'servis', 'Emanet Cihazlar (Teknik Servis)', 'Teknik Servis'),
  ('servis.is_emri', 'servis', 'İş Emirleri (Teknik Servis)', 'Teknik Servis'),
  ('servis.ziyaret', 'servis', 'Ziyaretler (Teknik Servis)', 'Teknik Servis'),
  ('sigorta.tanim.istek_log', 'sigorta.tanim', 'İstek Günlüğü (Kurumlar & Sigorta)', 'Kurumlar & Sigorta'),
  ('sigorta.tanim.kod_esleme', 'sigorta.tanim', 'Kod Eşleme (Kurumlar & Sigorta)', 'Kurumlar & Sigorta'),
  ('steril.ayar.bakim', 'steril.ayar', 'Bakım · Validasyon (Diş)', 'Diş'),
  ('steril.ayar.kural', 'steril.ayar', 'Test takvimi · Kurallar (Diş)', 'Diş'),
  ('steril.ayar.program', 'steril.ayar', 'Programlar (Diş)', 'Diş'),
  ('steril.birim.set_alet', 'steril.birim', 'Setler · Döner Aletler (Diş)', 'Diş'),
  ('steril.birim.set_tanim', 'steril.birim', 'Set tanımları (içerik) (Diş)', 'Diş'),
  ('steril.izleme.defter', 'steril.izleme', 'İzlenebilirlik · Kayıt Defteri (Diş)', 'Diş'),
  ('stok.ayar', 'stok', 'Stok Ayarları (Stok & Hizmet)', 'Stok & Hizmet'),
  ('stok.its', 'stok', 'Bildirimler (Stok & Hizmet)', 'Stok & Hizmet'),
  ('stok.kategori', 'stok', 'Kategoriler (Stok & Hizmet)', 'Stok & Hizmet'),
  ('teleradyoloji.bakanlik_eksik', 'teleradyoloji', 'Bakanlık Eksikleri (Radyoloji)', 'Radyoloji'),
  ('teleradyoloji.gelen', 'teleradyoloji', 'Gelen Raporlar (Radyoloji)', 'Radyoloji'),
  ('teleradyoloji.pano', 'teleradyoloji', 'Telerad Panosu (Radyoloji)', 'Radyoloji'),
  ('teleradyoloji.teslim', 'teleradyoloji', 'Teslim Kuyruğu (Radyoloji)', 'Radyoloji'),
  ('teleradyoloji.kurum.fatura', 'teleradyoloji.kurum', 'Dönem Faturası (Radyoloji)', 'Radyoloji'),
  ('uretim.is_merkezi', 'uretim', 'İş Merkezleri (Üretim)', 'Üretim'),
  ('uretim.urun_agaci', 'uretim', 'Ürün Ağaçları (Üretim)', 'Üretim'),
  ('uts.bildirim', 'uts', 'Bildirimler (Stok & Hizmet)', 'Stok & Hizmet'),
  ('uts.sorgu', 'uts', 'Ürün Sorgu (Stok & Hizmet)', 'Stok & Hizmet'),
  ('yatan.icmal', 'yatan', 'Hizmet İcmali (Yatan Hasta)', 'Yatan Hasta'),
  ('yatan.yatak_pano', 'yatan', 'Yatak Panosu (Yatan Hasta)', 'Yatan Hasta'),
  ('yatan.order.uygulama', 'yatan.order', 'İlaç Uygulama (Yatan Hasta)', 'Yatan Hasta');

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, sira = excluded.sira,
       urun_modu = excluded.urun_modu, modul = excluded.modul, aktif = 1;

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1004: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

do $$
declare n int; k int;
begin
  select count(*) into k from _bolme;
  select count(*) into n from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
   join _bolme b on b.yeni = y.kod;
  raise notice '1004: % ekran kodu, % rol satırı', k, n;
end $$;

commit;
