-- =====================================================================
--  887_lab_antibiyogram_kisit.sql
--  ANTİBİYOGRAM KISITLAMASI: ORGANİZMA KURALLARI ARTIK İŞLİYOR
--  (KTS denetim maddesi L5: "Bakteriyoloji sonuçlarında antibiyogram
--   kısıtlaması yapılabiliyor mu?")
--
--  DURUM TESPİTİ - kısıtlamanın BÜYÜK KISMI ZATEN VARDI:
--    * 436/437 kademeli (basamaklı) bildirimi kuruyor: 1. basamak her
--      zaman, 2. basamak 1'de duyarlı seçenek yoksa, 3. basamak ikisinde
--      de yoksa. Üriner-özel ajan idrar dışı numunede raporlanmaz;
--      kombinasyon ajanı "seçenek var" saymaz; uzmanın elle verdiği karar
--      (kaynak 4) ezilmez. Rapor yalnız `bildir = 1` yazıyor.
--    * 509 organizma kurallarını TANIMLIYOR: `lab_organizma_direnc`
--      (doğal/intrinsik direnç - "bu ajan bu organizmada raporlanmaz") ve
--      `lab_organizma_panel` (organizmaya özel panel, genel basamağı ezer).
--
--  İKİ GERÇEK BOŞLUK VAR, BU DOSYA ONLARI KAPATIYOR:
--
--  1. 509'un ORGANİZMA KURALLARI HİÇBİR YERDE İŞLEMİYOR. Kurallar yalnız
--     `fn_lab_antibiyogram_paneli` içinde okunuyor ve o fonksiyonu ne API
--     ne ekran çağırıyor - kartlardan girilen doğal direnç ve organizmaya
--     özel basamak, rapora hiç yansımıyordu. Kademeli bildirim genel
--     `lab_antibiyotik.basamak` ile karar veriyordu: laboratuvar
--     "E. coli'de bu ajanı 3. basamağa al" dese bile ajan 1. basamak gibi
--     raporlanıyordu. DOĞAL DİRENÇ hepsinden önemlisi: rapordaki "R" bile
--     klinisyene o ilacın denenebilir olduğunu düşündürür; doğal dirençli
--     ajan hiç yazılmamalıdır.
--
--  2. "NEDEN GİZLENDİ" GÖRÜNMÜYORDU. Ekran "Kademeli" rozetini gösteriyor
--     ama sebebini söylemiyordu; uzman, ajanın üst basamak olduğu için mi,
--     numune uygun olmadığı için mi, yoksa doğal direnç yüzünden mi
--     gizlendiğini bilmeden karar vermek zorundaydı. Denetimde de
--     "kısıtlama var" demek yetmez, hangi kuralın kısıtladığı gösterilmeli.
--
--  KURAL SIRASI: uzman kararı > doğal direnç > numune uygunluğu > basamak.
--  Doğal direnç, üst basamakta hiç seçenek kalmasa bile açılmaz - olmayan
--  bir tedaviyi önermek olurdu.
--
--  NOT: yeni kural TABLOSU AÇILMADI. 509'un iki tablosu bu işi zaten
--  karşılıyor; üçüncü bir kısıt tablosu aynı kuralın ikinci yerde
--  tanımlanmasına ve iki yerin sessizce ayrışmasına yol açardı.
-- =====================================================================

-- ---------------------------------------------------- gizleme gerekçesi ----
alter table public.lab_antibiyogram
  add column if not exists kisit_neden varchar(120) not null default '';

comment on column public.lab_antibiyogram.kisit_neden is
  '887: satir neden raporlanmiyor - dogal direnc sebebi, "yalniz idrar", '
  '"1. basamakta duyarli secenek var" ya da "uzman karari". Bos = raporlanir.';

-- --------------------------------------------------- bildirim motoru ----
--  436/437'nin kademeli mantığı KORUNUR; üstüne 509 organizma kuralları ve
--  gerekçe yazımı eklenir. Organizma kuralı tanımlı değilse davranış bire
--  bir eskisi gibidir.
create or replace function public.fn_lab_antibiyogram_bildirim(p_ureme_id integer)
returns integer language plpgsql as $$
declare
    v_uriner    boolean;
    v_organizma integer;
    v_s1        integer;
    v_s2        integer;
    v_etkilenen integer;
begin
    -- Numune tipi 4 = idrar (db/433 kod uzayı).
    select coalesce(n.numune_tipi, 0) = 4, u.organizma_id
      into v_uriner, v_organizma
      from public.lab_kultur_ureme u
      join public.lab_kultur k on k.id = u.kultur_id
      left join public.lab_numune n on n.id = k.numune_id
     where u.id = p_ureme_id;

    -- SAYIMA GİRMEYENLER: kombinasyon ajanları, numuneye uymayan
    --   üriner-özel ajanlar ve DOĞAL DİRENÇLİ ajanlar. Üçü de "kullanılabilir
    --   tedavi seçeneği var" anlamına gelmez; sayılırsa üst basamak haksız
    --   yere kapanır - hastaya gerçekte açık olan tek seçenek gizlenir.
    --   Basamak, organizmaya özel panel varsa ondan okunur.
    select count(*) filter (where coalesce(p.basamak, a.basamak) = 1 and g.yorum = 'S'),
           count(*) filter (where coalesce(p.basamak, a.basamak) = 2 and g.yorum = 'S')
      into v_s1, v_s2
      from public.lab_antibiyogram g
      join public.lab_antibiyotik a on a.id = g.antibiyotik_id
      left join public.lab_organizma_panel p
             on p.organizma_id = v_organizma and p.antibiyotik_id = a.id
     where g.ureme_id = p_ureme_id
       and a.tek_basina_yetersiz = 0
       and (a.yalniz_uriner = 0 or coalesce(v_uriner, false))
       and not exists (select 1 from public.lab_organizma_direnc d
                        where d.organizma_id = v_organizma
                          and d.antibiyotik_id = a.id);

    update public.lab_antibiyogram g
       set bildir = case
             when g.kaynak = 4 then g.bildir                    -- uzman kararı
             when direnc.id is not null then 0                  -- doğal direnç
             when a.yalniz_uriner = 1 and not coalesce(v_uriner, false) then 0
             when coalesce(p.basamak, a.basamak) = 1 then 1
             when coalesce(p.basamak, a.basamak) = 2
                  then case when coalesce(v_s1, 0) = 0 then 1 else 0 end
             else case when coalesce(v_s1, 0) = 0 and coalesce(v_s2, 0) = 0
                       then 1 else 0 end
           end,
           -- GEREKÇE: hangi kuralın gizlediği ekranda ve kayıtta görünsün.
           kisit_neden = case
             when g.kaynak = 4
                  then case when g.bildir = 1 then '' else 'Uzman kararı' end
             when direnc.id is not null
                  then coalesce(nullif(direnc.sebep, ''), 'Doğal (intrinsik) direnç')
             when a.yalniz_uriner = 1 and not coalesce(v_uriner, false)
                  then 'Yalnız idrar kültüründe raporlanır'
             when coalesce(p.basamak, a.basamak) = 2 and coalesce(v_s1, 0) > 0
                  then '1. basamakta duyarlı seçenek var'
             when coalesce(p.basamak, a.basamak) > 2
                  and (coalesce(v_s1, 0) > 0 or coalesce(v_s2, 0) > 0)
                  then 'Alt basamakta duyarlı seçenek var'
             else ''
           end
      from public.lab_antibiyotik a
      left join public.lab_organizma_panel p
             on p.organizma_id = v_organizma and p.antibiyotik_id = a.id
      left join public.lab_organizma_direnc direnc
             on direnc.organizma_id = v_organizma and direnc.antibiyotik_id = a.id
     where a.id = g.antibiyotik_id and g.ureme_id = p_ureme_id;

    get diagnostics v_etkilenen = row_count;
    return v_etkilenen;
end $$;

comment on function public.fn_lab_antibiyogram_bildirim(integer) is
  '887 (436/437 uzerine): kademeli bildirim + 509 organizma kurallari '
  '(dogal direnc hic raporlanmaz, organizmaya ozel panel genel basamagi '
  'ezer) + gizleme gerekcesi. Uzman karari (kaynak 4) ezilmez.';

-- MEVCUT ANTİBİYOGRAMLAR YENİDEN HESAPLANIR: organizma kuralları ilk kez
--   uygulanıyor ve gerekçe alanı dolsun.
do $$
declare v_id integer; v_adet integer := 0;
begin
    for v_id in select distinct ureme_id from public.lab_antibiyogram loop
        perform public.fn_lab_antibiyogram_bildirim(v_id);
        v_adet := v_adet + 1;
    end loop;
    raise notice '887 tamam: % izolat yeniden hesaplandi (% dogal direnc, % panel kurali)',
        v_adet,
        (select count(*) from public.lab_organizma_direnc),
        (select count(*) from public.lab_organizma_panel);
end $$;
