-- =====================================================================
--  491_kurum_entegrasyon_durumu.sql
--  Kurum Profili > "5 · Entegrasyonlar" sekmesi CANLI.
--
--  Sekme mockup'tan gelen 12 sabit satirdi: "bağlı / test / gizli"
--  rozetleri gercek hesaplara bakmiyordu (kullanici: "entegrasyonlar
--  sekmesini de canliya bagla"). Kural sunucuda: her entegrasyonun bu
--  kurulumda GEREKLI olup olmadigi urun modu + acik modullerden, DURUMU
--  ise entegrasyon_hesap satirlarindan cikar.
--
--  YALNIZ GERCEK KODLAR listelenir (entegrasyon_hesap.kod ile ayni kume:
--  EBELGE · UTS · ITS · SKRS · ENABIZ · MEDULA · SMS). Mockup'taki PACS,
--  LIS, POS, e-Imza, KPS, WebRTC satirlarinin hesap tanimi henuz yok -
--  canli gorunumde "bagli" yazmalari yanlis bilgi olurdu; ekran bunlari
--  ayri bir "hazirlanan" notunda anar.
--
--  gereklilik: 2 zorunlu · 1 önerilen · 0 opsiyonel   (-1 = bu kurulumda
--              anlamsiz, satir hic donmez)
--  durum:      2 canli hesap · 1 test hesabi · 0 hesap yok
-- =====================================================================

create or replace function public.fn_kurum_entegrasyon_durumu(p_sube integer default 0)
returns table (sira smallint, kod varchar, ad varchar, gereklilik smallint,
               gerekce varchar, durum smallint, hesap varchar, son_sonuc varchar)
language plpgsql
stable
as $$
declare
    v_mod    smallint := public.fn_urun_modu(p_sube);
    v_saglik boolean  := v_mod in (2, 3);
    v_stok   boolean  := public.fn_kurum_modul_acik('stok', p_sube);
    v_muayene boolean := public.fn_kurum_modul_acik('muayene', p_sube);
    r        record;
begin
    for r in
        with katalog(sira, kod, ad, gereklilik, gerekce) as (
            values
              (1::smallint, 'EBELGE'::varchar, 'e-Fatura / e-Arşiv'::varchar,
               2::smallint, 'her kurulumda zorunlu'::varchar),
              (2, 'MEDULA', 'MEDULA (SGK provizyon, e-reçete, e-rapor)',
               case when v_saglik then 2 else -1 end,
               'SGK''li hasta kabul ediliyorsa zorunlu'),
              (3, 'SKRS', 'SKRS / Sağlık.NET kod sunucusu',
               case when v_saglik then 2 else -1 end,
               'ICD-10, ilaç ve klinik listeleri buradan gelir'),
              (4, 'ENABIZ', 'e-Nabız / USS',
               case when v_saglik and v_muayene then 2 else -1 end,
               'muayene modülü açıkken bildirim zorunlu'),
              (5, 'UTS', 'ÜTS (Ürün Takip Sistemi)',
               case when v_stok then 1 else -1 end,
               'tıbbi cihaz/malzeme hareketi bildirilir'),
              (6, 'ITS', 'İTS (İlaç Takip Sistemi)',
               case when v_stok and v_saglik then 0 else -1 end,
               'ilaç satışı/kullanımı varsa'),
              (7, 'SMS', 'SMS sağlayıcı',
               1, 'randevu hatırlatma, panik bildirim, portal doğrulama')
        )
        select k.sira, k.kod, k.ad, k.gereklilik::smallint as gereklilik, k.gerekce,
               -- Hesap durumu: CANLI hesap test hesabina baskindir - ikisi de
               --   tanimliysa kurulum canliya gecmis demektir.
               coalesce(h.durum, 0)::smallint as durum,
               coalesce(h.hesap, '')::varchar as hesap,
               coalesce(h.son_sonuc, '')::varchar as son_sonuc
          from katalog k
          left join lateral (
              select case when e.test_mi = 0 then 2 else 1 end as durum,
                     e.ad as hesap,
                     left(e.son_sonuc, 160) as son_sonuc
                from public.entegrasyon_hesap e
               where upper(e.kod) = k.kod and e.aktif = 1
                 and (e.sube_id is null or coalesce(p_sube, 0) = 0 or e.sube_id = p_sube)
               order by e.test_mi, e.id
               limit 1) h on true
         where k.gereklilik >= 0
         order by k.sira
    loop
        sira := r.sira; kod := r.kod; ad := r.ad; gereklilik := r.gereklilik;
        gerekce := r.gerekce; durum := r.durum; hesap := r.hesap; son_sonuc := r.son_sonuc;
        return next;
    end loop;
end $$;

comment on function public.fn_kurum_entegrasyon_durumu(integer) is
  'Kurum Profili entegrasyon sekmesi (491): urun modu + acik modullerden '
  'gereklilik, entegrasyon_hesap''tan canli durum; ilgisiz satir donmez.';
