-- ============================================================================
--  Gentegre AI — BAKANLIK PROFİLİ: EKSİK GÖNDERİM LİSTESİ
--  813_bakanlik_eksik_listesi.sql
--
--  812'deki `fn_telerad_bakanlik_eksik` tek isteği yanıtlıyor. Operasyonun
--  sorduğu soru ise çoğul: **"bugün Bakanlığa gidemeyecek kaç iş var, neden?"**
--
--  Bu görünüm listeyi veriyor ve LİSTE ALTYAPISINA bağlanıyor (KaynakKatalogu):
--  ayrı bir uç yazılsaydı yetki, şube süzgeci, sayfalama ve dışa aktarım
--  ikinci kez - ve eksik - yazılmış olurdu.
--
--  KAPALI KURUM LİSTEDE YOK: `bakanlik_gonderim = 0` olan kurumun işi burada
--  hiç görünmez; özel hastane müşterisinde liste boştur.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_telerad_bakanlik_eksik as
select i.id,
       i.istek_no,
       i.kurum_id,
       coalesce(tk.unvan, '')                         as kurum_adi,
       coalesce(i.dis_erisim_no, '')                  as dis_erisim_no,
       i.durum,
       i.oncelik,
       i.modalite,
       i.gelis_zamani,
       i.teslim_zamani,
       i.sube_id,
       public.fn_telerad_bakanlik_eksik(i.id)         as eksik,
       -- SATIR RENGİ (sunucuda, 798 deseni): teslim edilmiş ama Bakanlığa
       --   gidemeyecek iş KRİTİKTİR - kurum raporu aldı, kayıt eksik kaldı.
       case when i.teslim_zamani is not null then 'kritik'
            when i.durum >= 6                then 'uyari'
            else '' end                               as satir_rengi
  from public.telerad_istek i
  join public.telerad_kurum k on k.id = i.kurum_id
  join public.taraf tk        on tk.id = k.taraf_id
 where k.bakanlik_gonderim = 1
   and public.fn_telerad_bakanlik_eksik(i.id) <> '';

comment on view public.v_telerad_bakanlik_eksik is
  '813: Bakanlığa bildirilecek ama eksik alanı olan teleradyoloji istekleri.';

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi from public.v_telerad_bakanlik_eksik;
    raise notice '813 tamam: su an % eksik istek listeleniyor.', v_sayi;
end $$;
