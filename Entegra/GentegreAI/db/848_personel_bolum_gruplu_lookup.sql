-- ============================================================================
--  Gentegre AI — YÖNETİCİ COMBOSU BÖLÜME GÖRE GRUPLU
--  848_personel_bolum_gruplu_lookup.sql
--
--  Kullanıcı: *"Yönetici combosunu da bölüme göre ağaç şeklinde yap"*.
--
--  104 personel düz alfabetik listede duruyordu; "Radyoloji'nin sorumlusu
--  kimdi" sorusu ancak adı bilerek cevaplanabiliyordu.
--
--  ============ NEDEN AĞAÇ DEĞİL, GRUP =================================
--  Jenerik ağaç combosu `ust_id`yi AYNI listede arar (rol -> üst rol, bölüm
--  -> üst bölüm). Buradaki üst BAŞKA bir varlık: bölüm. Personeli bölümün
--  altına asmak için listeye sahte bölüm satırları koymak gerekirdi ve o
--  satırlar SEÇİLEBİLİR olurdu - `yonetici_taraf_id`ye bölüm kimliği yazmak
--  yabancı anahtarı kırardı. Bu yüzden bölüm, seçilemeyen `optgroup`
--  başlığıdır; görünüm ağaçla aynı, yanlış seçim imkânsız.
--
--  Görünüm sözleşmesi: id · ad · aktif (+ `grup`). `grup` kolonu olan lookup
--  görünümleri arayüzde başlıklı çizilir (KartAlani.Gruplu).
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_personel_grup_lookup as
select t.id,
       t.unvan as ad,
       (case when t.durum = 1 then 1 else 0 end)::smallint as aktif,
       -- Bölümsüz personel listenin sonunda kendi başlığında toplanır -
       --   boş başlık altında görünmek "bölümü yok" bilgisini gizliyordu.
       coalesce(nullif(d.ad, ''), 'Bölümsüz') as grup
  from public.taraf t
  left join public.departman d on d.id = t.departman
 where t.personel = 1;

comment on view public.v_personel_grup_lookup is
  'Personel secim listesi, BOLUME gore gruplu (848). grup = optgroup basligi.';

do $$
declare v_kisi integer; v_grup integer;
begin
    select count(*), count(distinct grup) into v_kisi, v_grup
      from public.v_personel_grup_lookup where aktif = 1;
    raise notice '848 tamam: % aktif personel, % bolum basligi.', v_kisi, v_grup;
end $$;
