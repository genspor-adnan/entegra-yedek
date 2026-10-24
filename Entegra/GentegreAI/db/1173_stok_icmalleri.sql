-- =============================================================================
--  1173  STOK İCMALLERİ - Stok Değer, SKT / Lot, Sayım Fark
--
--  Kullanıcı (24.10.2026): "stok değer, SKT ve sayım fark icmalleri için mockup
--  yap" -> "web'e uygula; soruların cevabını bilmiyorum, genel uygulanan sistem
--  ne ise o şekilde yap". Mockup'lar Ekranlar/Stok/stok_deger_icmali.html,
--  stok_skt_icmali.html, stok_sayim_fark_icmali.html.
--
--  1) v_stok_hareket: stok bakiyesini değiştiren her belge satırı (giren / çıkan,
--     depo, tarih). Kural BelgeDeposu.StokDurumGuncelleAsync ile AYNI: kesin belge
--     (durum 0), türü stoku etkiler (kasa_islem_turu.stok_etkiler), satır stok
--     (tur 1) ve stok_durum_degis = 1 (irsaliyeden türeyen fatura ikinci kez
--     düşmez); yön fn_belge_cikis_mi (iade ters), transfer iki satır (çıkış deposu
--     eksi, giriş deposu artı); miktar 0 ise adet. "Tarih itibarıyla" bakiye =
--     stok_durum.kalan - o tarihten SONRAKİ hareketler; son giriş / çıkış ve
--     12 aylık çıkış (devir hızı) buradan.
--  2) Ekran kodları (1003 ilkesi: bir kod bir menü ekranı) - hakları stok.liste'den
--     kopyalanır (Stok Listesi'ni gören rol icmalleri de görür; kimse yetki
--     kazanmaz / kaybetmez). Var olan rol_yetki satırına dokunulmaz.
--  3) Asistan rehberi satırları. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create or replace view public.v_stok_hareket as
with s as (
    select bs.stok_id, b.id as belge_id, b.tur, b.tipi, b.belge_tarihi::date as tarih,
           case when coalesce(bs.miktar, 0) <> 0 then bs.miktar else coalesce(bs.adet, 0) end as m,
           coalesce(bs.cikis_depo_id, b.cikis_depo_id) as cikis_depo,
           coalesce(bs.giris_depo_id, b.giris_depo_id) as giris_depo,
           public.fn_belge_cikis_mi(b.tur, b.tipi) as cikis
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      join public.kasa_islem_turu k on k.kod = b.tur and k.stok_etkiler = 1
     where bs.tur = 1 and bs.stok_id is not null and bs.stok_durum_degis = 1 and b.durum = 0
)
select stok_id, cikis_depo as depo_id, tarih, 0::numeric as giren, m as cikan, belge_id, tur
  from s where tur = 20 and cikis_depo is not null
union all
select stok_id, giris_depo, tarih, m, 0, belge_id, tur
  from s where tur = 20 and giris_depo is not null
union all
select stok_id,
       case when cikis then coalesce(cikis_depo, giris_depo) else coalesce(giris_depo, cikis_depo) end,
       tarih, case when cikis then 0 else m end, case when cikis then m else 0 end, belge_id, tur
  from s where tur <> 20 and coalesce(cikis_depo, giris_depo) is not null;

comment on view public.v_stok_hareket is
  '1173: stok bakiyesini degistiren belge satirlari (giren / cikan, depo, tarih) - BelgeDeposu.StokDurumGuncelleAsync kurali.';

-- ------------------------------------------------------------ ekran kodları --
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40))
  on commit drop;
insert into _bolme values
  ('stok.deger_icmali',      'stok.liste', 'Stok Değer İcmali (Stok & Hizmet)', 'Stok & Hizmet'),
  ('stok.skt_icmali',        'stok.liste', 'SKT / Lot İcmali (Stok & Hizmet)',  'Stok & Hizmet'),
  ('stok.sayim_fark_icmali', 'stok.liste', 'Sayım Fark İcmali (Stok & Hizmet)', 'Stok & Hizmet');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1173: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, 0, 0, 0, ry.deger, ry.kapsam, 0
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

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, 'Stok & Hizmet', v.baslik, v.yetki_kodu, 0, v.anahtar, v.aciklama, ''
  from (values
    ('stok-deger-icmali', '/stok-deger-icmali', 'Stok Değer İcmali', 'Stok & Hizmet › Stok Değer İcmali',
     'stok.deger_icmali',
     'stok değer icmal envanter maliyet depo kategori tarih itibarıyla hareketsiz ölü stok devir hızı eksi bakiye',
     'Tarih itibarıyla depo / kategori bazında stok miktarı ve değeri (ortalama maliyet, son alış ya da satış '
     || 'fiyatı), stok yaşı ve devir hızı; eksi bakiye, maliyeti tanımsız, lot uyuşmazlığı, hareketsiz kalemler.'),
    ('stok-skt-icmali', '/stok-skt-icmali', 'SKT / Lot İcmali', 'Stok & Hizmet › SKT / Lot İcmali',
     'stok.skt_icmali',
     'skt son kullanma tarihi miad lot seri imha iade fefo yaklaşan geçmiş',
     'Lot bakiyelerinin son kullanma tarihine göre dağılımı: geçmiş, 30 / 90 / 180 gün içinde; aylık takvim, '
     || 'FEFO ve satış hızı önerileri, eksi lot, lotsuz bakiye, SKT''si boş lot.'),
    ('stok-sayim-fark-icmali', '/stok-sayim-fark-icmali', 'Sayım Fark İcmali', 'Stok & Hizmet › Sayım Fark İcmali',
     'stok.sayim_fark_icmali',
     'sayım fark icmal fazla eksik doğruluk tekrar eden kayıp kaçak depo sayım',
     'Dönemdeki stok sayımlarının fazla / eksik tutarı, doğruluk oranı, tekrar eden eksikler, lot karışıklığı, '
     || 'kategori / depo / sayan kırılımı ve uzun süredir sayılmayan depolar.'))
    as v(kaynak, rota, baslik, yol, yetki_kodu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
