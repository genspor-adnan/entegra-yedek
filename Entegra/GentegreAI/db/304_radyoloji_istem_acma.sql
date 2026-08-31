-- 304: Radyoloji ISTEM ACMA yetkisi + istem ekraninin ihtiyaci olan lookup'lar.
--
-- Mockup'lar: radyoloji_hekim_istem.html (ic istem - poliklinikteki hekim
-- basvuruya tetkik ister) ve radyoloji_kayit_kabul.html (dis istem - baska
-- kurumun hekiminden gelen hasta). Ikisi ayni ekranin varyanti: fark
-- isteyenin kim oldugu.
--
-- ISTEM ACMA ayri bir yetki: rapor yazma (rad.rapor_yaz) radyologun,
-- istem acma poliklinik hekiminin ve kayit kabulun isidir - ikisini tek
-- yetkiye baglamak, kabul memuruna rapor yazma hakki verirdi.

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'rad.istem_ac', 'Radyoloji istemi aç', 'radyoloji', 1, 5, 1
 where not exists (select 1 from public.yetki where kod = 'rad.istem_ac');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'rad.istem_ac'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ------------------------------------------------------------- lookup'lar --
-- Istem ekrani tetkikleri MODALITE agacinda gosterir (mockup "Tetkik Ağacı").
-- Radyoloji tetkiki = modalitesi tanimli hizmet; ayri bir "radyoloji hizmeti"
-- bayragi acmak ayni bilgiyi iki yerde tutmak olurdu.
create or replace view public.v_radyoloji_tetkik as
select h.id, h.kod, h.ad, h.modalite, h.kdv,
       coalesce(kd.ad, '') as modalite_adi,
       h.durum
  from public.hizmet h
  left join public.kod_liste kl on kl.kod = 'rad.modalite'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = h.modalite
 where coalesce(h.modalite, 0) > 0 and coalesce(h.durum, 1) = 1;

comment on view public.v_radyoloji_tetkik is
  'Radyoloji tetkikleri (304): modalitesi tanimli aktif hizmetler, modalite adiyla.';

-- Istem ekraninda "isteyen hekim" listesi: randevu verilebilen personel -
-- ayni liste basvuru kartinda da kullaniliyor.
create index if not exists ix_radyoloji_istem_hasta_hizmet
    on public.radyoloji_istem (hasta_id, hizmet_id, ekleme_tarihi desc);
