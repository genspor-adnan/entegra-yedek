-- ============================================================================
--  Gentegre AI — TEKNİSYEN ÇİZELGESİ
--  775_servis_teknisyen_cizelge.sql
--
--  Kullanıcı: "teknisyen çizelgesini de yap" (saha mockup'ının çizelge sekmesi,
--  `Ekranlar/TeknikServis/teknik_servis_saha.html`).
--
--  ============ TEKNİSYEN KİM ==========================================
--  Ayrı bir "teknisyen" tablosu AÇILMIYOR. Teknisyen, servis yetkisi olan
--  personeldir - ikinci bir liste tutmak, personel işten ayrıldığında
--  çizelgede durmaya devam eden bir ad bırakırdı.
--
--  `v_servis_teknisyen` iki kümenin birleşimidir:
--    1. rolünde `servis` yetkisi olan aktif kullanıcılar (planlanabilir kişiler)
--    2. o gün ziyareti olan herkes (yetkisi sonradan alınmış olsa bile)
--
--  İkincisi olmasaydı geçmiş bir günün çizelgesi, yetkisi değişen teknisyenin
--  işlerini SAHİPSİZ gösterirdi - olan biteni sonradan değiştirmek olurdu.
--
--  ============ YOL DA BİR BLOKTUR =====================================
--  Çizelge yalnız ziyaretleri çizerse, Çerkezköy'e 96 km giden teknisyenin
--  arası "boş" görünür ve planlayan oraya ikinci iş yazar; iki çağrı da
--  gecikir. Ziyaretin yol süresi ayrı hesaplanmıyor - `yol_km` ekranda
--  bloğun üstünde yazılıyor ve süre, varış/ayrılış arasındaki gerçek zamandan
--  geliyor. Tahmin edilen yol süresini uydurmak yerine ölçüleni gösteriyoruz.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_servis_teknisyen as
select k.id                                   as taraf_id,
       coalesce(nullif(t.unvan, ''), t.ad)    as ad,
       k.rol_id,
       coalesce(r.ad, '')                     as rol_adi,
       coalesce(p.gorev, '')                  as gorev,
       k.aktif
  from public.taraf_kullanici k
  join public.taraf t on t.id = k.id
  left join public.rol r on r.id = k.rol_id
  left join public.taraf_personel p on p.id = k.id
 where k.aktif = 1
   and exists (select 1
                 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = k.rol_id and y.kod = 'servis' and ry.gor = 1);

comment on view public.v_servis_teknisyen is
  '775: cizelgeye satir acilacak kisiler - rolunde `servis` yetkisi olan aktif '
  'kullanicilar. Ayri teknisyen tablosu YOK; personel ayrilinca satir da gider.';

-- ---------------------------------------------------------------------- 2
--  GÜNLÜK ÇİZELGE
--
--  Bir satır = bir ziyaret. Zaman ekseni ekranda kurulur; burada yalnız
--  BAŞLANGIÇ ve BİTİŞ verilir:
--    başlangıç = varış, yoksa planlanan zaman
--    bitiş     = ayrılış, yoksa (sürüyorsa) şimdi, yoksa başlangıç + 1 saat
--
--  SÜREN ZİYARET "ŞİMDİ"YE KADAR UZAR: kapanmamış bir işi bir saatlik blok
--  göstermek, üç saattir süren işi çizelgede bitmiş gibi gösterirdi.
create or replace view public.v_servis_cizelge as
select z.id,
       z.is_emri_id,
       e.is_emri_no,
       e.sube_id,
       g.cagri_no,
       g.id                                   as cagri_id,
       z.teknisyen_id,
       coalesce(tk.unvan, '')                 as teknisyen_adi,
       coalesce(mt.unvan, d.ad, '')           as taraf_adi,
       coalesce(nullif(tc.ad, ''), nullif(g.cihaz_metni, ''), d.ad, '')
                                              as cihaz,
       coalesce(g.bolge_metni, '')            as bolge,
       coalesce(z.varis, z.plan_zamani)       as bas,
       coalesce(z.ayrilis,
                case when z.sonuc = 0 then greatest(now(),
                         coalesce(z.varis, z.plan_zamani))
                     else coalesce(z.varis, z.plan_zamani)
                          + interval '1 hour' end)
                                              as bit,
       z.sonuc,
       z.yol_km,
       z.arac,
       z.mesai_disi,
       z.tutar,
       z.yapilan,
       e.oncelik,
       e.sahiplik,
       -- SLA AŞIMI BLOKTA GÖRÜNÜR: çizelgeye bakan kişi "hangi işe önce
       --   gitmeli" sorusunu burada cevaplar; listeye dönmek zorunda kalmasın.
       case when g.sla_bitis is not null and g.durum < 5
                 and now() > g.sla_bitis then 1 else 0 end as sla_asildi
  from public.servis_ziyaret z
  join public.demirbas_is_emri e on e.id = z.is_emri_id
  left join (select c.id, c.cagri_no, c.sla_bitis, c.durum, c.cihaz_metni,
                    coalesce(tcz.bolge, '') as bolge_metni
               from public.servis_cagri c
               left join public.taraf_cihaz tcz on tcz.id = c.taraf_cihaz_id) g
         on g.id = e.cagri_id
  left join public.taraf mt on mt.id = e.musteri_taraf_id
  left join public.taraf tk on tk.id = z.teknisyen_id
  left join public.taraf_cihaz tc on tc.id = e.taraf_cihaz_id
  left join public.demirbas d on d.id = e.demirbas_id;

comment on view public.v_servis_cizelge is
  '775: gunluk teknisyen cizelgesi. Suren ziyaret SIMDIYE kadar uzar - '
  'kapanmamis isi 1 saatlik blok gostermek bitmis gibi gosterirdi.';

do $$
declare v_tk int;
begin
    select count(*) into v_tk from public.v_servis_teknisyen;
    raise notice '775 tamam: % teknisyen (rolunde servis yetkisi olan aktif '
                 'kullanici).', v_tk;
end $$;
