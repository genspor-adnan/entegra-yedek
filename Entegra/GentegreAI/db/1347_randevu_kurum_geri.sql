-- ============================================================================
--  1347 - RANDEVUDA ÖDEYEN KURUM GERİ GELİYOR + Özel (Ücretli) kurum sözleşmesiz de seçilebilir
--
--  Kullanıcı (16.11.2026): "randevu kartına hizmetten önce Kurum ekle.. o da başvuruya geçsin" · "default ücretli olsun".
--
--  266 bu kolonu "ödeyen kurum hastada durur, randevu sadeleşsin" diye kaldırmıştı; görüntüleme merkezi akışında
--  randevu alınırken kurum belli oluyor ve başvuruya aynen geçmesi isteniyor - karar geri alındı. Hastanın kayıtlı
--  kurumu (taraf_hasta.kurum_id) yine durur; randevudaki değer O RANDEVUNUN ödeyeni, başvuruya dönüşte önceliklidir.
--
--  Varsayılan: tür 1 "Özel (Ücretli)" kurum (KartAlani.VarsayilanSql, kart meta'sında çözülür).
--
--  v_anlasmali_kurum_lookup: aktif = geçerli sözleşme VARDI; Özel (tür 1) kurumda sözleşme yok (485: ücreti hasta
--  öder, tarife kurumun satış listesinden). Bu yüzden Özel kurum ödeyen listelerinde "pasif" sayılıp çıkmıyordu.
--  Artık tür 1 kurum durum = 1 ise aktiftir.
-- ============================================================================
alter table public.randevu add column if not exists kurum_id integer references public.taraf(id);
comment on column public.randevu.kurum_id is
  'Randevuyu ödeyecek kurum (1347; 265''in geri gelişi). Başvuruya dönüşte belge_basvuru.odeyen_kurum_id olur. '
  'Varsayılan tür 1 Özel (Ücretli).';
create index if not exists ix_randevu_kurum on public.randevu (kurum_id) where kurum_id is not null;

create or replace view public.v_anlasmali_kurum_lookup as
 select t.id,
        case when t.kod::text = '' then public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
             else (t.kod::text || ' - ') || public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)::text
        end as ad,
        case when t.durum = 1
              and (k.tur = 1  -- Özel (Ücretli): sözleşme aranmaz (485)
                   or exists (select 1 from public.kurum_sozlesme s
                               where s.kurum_id = t.id and s.durum = 1
                                 and (s.baslangic is null or s.baslangic <= current_date)
                                 and (s.bitis is null or s.bitis >= current_date))) then 1 else 0
        end as aktif
   from public.taraf t
   join public.taraf_kurum k on k.id = t.id
  where t.kurum = 1 and k.anlasmali = 1;
comment on view public.v_anlasmali_kurum_lookup is
  '1338/1347: ödeyen kurum seçim listesi - yalnız anlaşmalı; aktif = geçerli sözleşmesi var YA DA tür 1 Özel (sözleşmesiz).';
