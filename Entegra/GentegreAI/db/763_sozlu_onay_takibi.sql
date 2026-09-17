-- ============================================================================
--  Gentegre AI — SÖZLÜ ONAYIN YAZILI TEYİDİ TAKİP EDİLİYOR
--  763_sozlu_onay_takibi.sql
--
--  Kullanıcı: "sözlü onay terminini takip eden işi yap."
--
--  738'den beri karar ucunda `sozlu-onay` var: basamak `durum = 4` olur ve
--  `yazili_son` alanına "şu saate kadar yazılıya çevrilmeli" damgası yazılır.
--  Bugüne kadar o damgaya **kimse bakmıyordu**.
--
--  ============ NEDEN ÖNEMLİ ===========================================
--  Sözlü onay zinciri İLERLETİR: `KararAsync` durum 4'ü "karar verilmiş"
--  sayar, sıradaki basamağa geçer ve gerekirse zinciri tamamlar. Yani sözlü
--  bir onayla avans ödenebilir, doküman yayınlanabilir, talep onaylanabilir.
--
--  Üstelik `v_onay_bekleyen` yalnız `durum in (0, 3)` basamakları döndürür -
--  sözlü onaylı basamak **hiçbir kuyrukta görünmez**. Yazılı teyit hiç
--  gelmezse kayıtta yalnız "sözlü onay" kalır ve kimse fark etmez: imza
--  yerine bir telefon konuşması geçer.
--
--  ============ GERİ ALMIYORUZ =========================================
--  Süre dolunca basamağı bekleyene döndürmek ilk akla gelen çözüm ama
--  YANLIŞ olurdu: zincir çoktan ilerlemiş, para ödenmiş, sürüm yayınlanmış
--  olabilir. Basamağı geri almak o eylemleri geri almaz, yalnız kaydı
--  tutarsız yapar. "Motor karar vermez, sırayı yürütür" ilkesi burada da
--  geçerli: iş GÖRÜNÜR kılınır ve hatırlatılır, kararı insan verir.
--
--  Bu dosya üç şey getiriyor: görünüm (`v_onay_sozlu`), hatırlatma şablonu
--  ve günlük iş. Yazılıya çevirme ucu API tarafında (`/adim/{id}/yaziliya`)
--  - hatırlatma "şunu yap" diyorsa o şey yapılabilir olmalı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) GÖRÜNÜM: yazılı teyit bekleyen sözlü onaylar
--
--     Zincir KAPANMIŞ olsa da satır burada kalır: teyidin gerekliliği
--     zincirin durumuna değil, verilmiş söze bağlıdır. Zaten en tehlikeli
--     hâl budur - kayıt tamamlanmış, dayanağı hâlâ sözlü.
-- ---------------------------------------------------------------------------
create or replace view public.v_onay_sozlu as
select a.id                                   as adim_id,
       n.id                                   as onay_id,
       n.kaynak_tur,
       n.kaynak_id,
       n.sube_id,
       k.kod                                  as akis_kod,
       k.ad                                   as akis_ad,
       a.sira,
       a.ad                                   as adim_ad,
       a.rol,
       a.karar_veren_id,
       coalesce(nullif(t.unvan, ''), ku.kod, '#' || a.karar_veren_id::text)
                                              as karar_veren_ad,
       a.karar_zamani,
       a.gerekce,
       a.yazili_son,
       -- GECİKME SAAT: gün değil - sözlü onayın ömrü saatlerle ölçülür
       --   (varsayılan 24 saat). Gün yuvarlaması "bugün doldu"yu gizlerdi.
       case when a.yazili_son is null then 0
            else greatest(0, floor(extract(epoch from now() - a.yazili_son) / 3600)::int)
       end                                    as gecikme_saat,
       case when a.yazili_son is not null and a.yazili_son < now() then 1 else 0 end
                                              as gecikti,
       n.durum                                as zincir_durum
  from public.onay_adim a
  join public.onay n on n.id = a.onay_id
  left join public.onay_akis k on k.id = n.akis_id
  left join public.taraf t on t.id = a.karar_veren_id
  left join public.taraf_kullanici ku on ku.id = a.karar_veren_id
 where a.durum = 4;

comment on view public.v_onay_sozlu is
  '763: yazili teyidi bekleyen SOZLU onaylar (onay_adim.durum = 4). Zincir '
  'kapanmis olsa da satir kalir - teyit zincire degil verilmis soze baglidir.';

-- ---------------------------------------------------------------------------
--  2) HATIRLATMA ŞABLONU
--     Alıcı sözlü onayı VEREN kişidir: teyidi ondan başkası veremez.
-- ---------------------------------------------------------------------------
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, ekleyen)
select 'onay.sozlu_gecikti', 'Sözlü onayın yazılı teyidi gecikti', 2,
       'Yazılı teyit bekleniyor: {{kayitNo}}',
       'Sayın {{alici}},' || chr(10) || chr(10) ||
       '{{kayitNo}} kaydında verdiğiniz SÖZLÜ onayın yazılı teyidi ' ||
       '{{gecikmeSaat}} saattir bekliyor.' || chr(10) ||
       'Basamak: {{adimAd}}' || chr(10) || 'Konu: {{konu}}' || chr(10) ||
       'Son teyit zamanı: {{yaziliSon}}' || chr(10) || chr(10) ||
       'Onay kaydı sözlü olarak duruyor; teyit edilmezse dayanağı ' ||
       'yalnız bir konuşma olarak kalır.',
       jsonb_build_object(
           'alici', 'Alıcının adı', 'kayitNo', 'Kayıt no',
           'konu', 'Kaydın konusu', 'adimAd', 'Basamak adı',
           'gecikmeSaat', 'Kaç saat gecikti', 'yaziliSon', 'Son teyit zamanı'),
       0
 where not exists (select 1 from public.bildirim_sablon
                    where kod = 'onay.sozlu_gecikti');

-- ---------------------------------------------------------------------------
--  3) GÜNLÜK İŞ
--     Saat 09:30: onay hatırlatmasından (09:00) YARIM SAAT SONRA. İkisi aynı
--     dakikada koşsaydı aynı kişiye iki ayrı mesaj aynı anda düşer, ikisi de
--     okunmazdı.
--
--     AKTİF: 746'daki hatırlatma kapalı doğmuştu çünkü bildirim yolu
--     denenmemişti; 761/762'den sonra yol çalışıyor, bu iş açık doğuyor.
-- ---------------------------------------------------------------------------
insert into public.zamanli_is (kod, ad, aktif, periyot, saat, dakika, aciklama, ekleyen)
select 'onay.sozlu_takip', 'Sözlü Onay Yazılı Teyit Takibi', 1, 2, 9, 30,
       'Yazili teyit suresi gecmis sozlu onaylari (onay_adim.durum = 4) '
       'karar verene hatirlatir. Gunde bir kez. Basamagi GERI ALMAZ - '
       'zincir ilerlemis olabilir, geri almak kaydi tutarsiz yapardi.', 0
 where not exists (select 1 from public.zamanli_is where kod = 'onay.sozlu_takip');

do $$
declare v_sozlu int; v_gecikmis int;
begin
    select count(*) into v_sozlu     from public.v_onay_sozlu;
    select count(*) into v_gecikmis  from public.v_onay_sozlu where gecikti = 1;
    raise notice '763 tamam: sozlu onay % basamak (% tanesi gecikmis).',
                 v_sozlu, v_gecikmis;
end $$;
