-- =====================================================================
--  735_kabul_sonuc_bekleyen.sql
--  DÜZELTME: muayenesi yapılmamış tutanak "Kabul" görünüyordu.
--
--  NE OLUYORDU. 733'ün `fn_satinalma_kabul_sonuc` tetiği yalnız RET (3) ve
--    KISMİ (2) satırları sayıyordu; ikisi de yoksa başlığı `greatest(mevcut,
--    1)` ile "kabul"e çekiyordu. Oysa yeni açılan tutanağın bütün satırları
--    `sonuc = 0` (bekliyor) olur - hiç ret, hiç kısmi yok. Sonuç: tutanak
--    daha hiçbir kalem sayılmadan **Kabul** oluyordu.
--
--  ETKİSİ GÖRÜNMEZDİ, çünkü tutanağı açan uç yanıtında İSTEKTEKİ sonucu
--    yansıtıyordu (0), veritabanındakini değil. Hata ancak karekod ucu
--    "Kararı verilmiş tutanağa karekod eklenemez" deyince ortaya çıktı -
--    yeni açılmış bir tutanakta.
--
--  DÜZELTME: bekleyen satır varken başlık "kabul"e ÇEKİLMEZ. Muayenesi
--    bitmemiş bir tutanağın sonucu yoktur; "açık" (0) kalır.
--
--  YÖN KURALI KORUNUYOR (733): satırlar başlığı aşağı çeker, yukarı çekmez -
--    komisyon "hepsi kabul" satırlarıyla tutanağı yine de reddedebilir
--    (belge eksikliği, sözleşme ihlali gibi kalem dışı sebepler).
-- =====================================================================

create or replace function public.fn_satinalma_kabul_sonuc()
returns trigger language plpgsql as $tg$
declare
  v_kabul    bigint := coalesce(new.kabul_id, old.kabul_id);
  v_ret      integer;
  v_kismi    integer;
  v_bekleyen integer;
  v_var      integer;
  v_mevcut   smallint;
begin
    select count(*) filter (where sonuc = 3),
           count(*) filter (where sonuc = 2),
           count(*) filter (where sonuc = 0),
           count(*)
      into v_ret, v_kismi, v_bekleyen, v_var
      from public.satinalma_kabul_satir where kabul_id = v_kabul;

    if v_var = 0 then return coalesce(new, old); end if;

    select sonuc into v_mevcut from public.satinalma_kabul where id = v_kabul;

    update public.satinalma_kabul
       set sonuc = case
                     when v_ret = v_var then 3                 -- hepsi ret
                     when v_ret > 0 or v_kismi > 0 then 2      -- kısmi
                     -- MUAYENESİ BİTMEMİŞSE SONUÇ YOK: bekleyen satır varken
                     --   "kabul" demek, sayılmamış kalemi kabul etmektir.
                     when v_bekleyen > 0 then coalesce(v_mevcut, 0)
                     else greatest(coalesce(v_mevcut, 0), 1)   -- tam kabul
                   end
     where id = v_kabul
       -- Komisyonun REDDİNE dokunma (tek taraflılık).
       and coalesce(sonuc, 0) <> 3;

    return coalesce(new, old);
end;
$tg$;

comment on function public.fn_satinalma_kabul_sonuc() is
  '733/735: tutanak sonucu satirlardan turer. Bekleyen satir varken basliga '
  'dokunulmaz; satirlar basligi ASAGI ceker, yukari cekmez.';

-- Hatalı tetikle "kabul" olmuş ama muayenesi bitmemiş tutanakları geri al.
--   DAR KAPSAM: yalnız bütün satırları hâlâ "bekliyor" olanlar - komisyonun
--   bilerek verdiği bir karara dokunulmaz.
update public.satinalma_kabul k
   set sonuc = 0
 where k.sonuc = 1
   and exists (select 1 from public.satinalma_kabul_satir s where s.kabul_id = k.id)
   and not exists (select 1 from public.satinalma_kabul_satir s
                    where s.kabul_id = k.id and s.sonuc <> 0)
   -- Komisyon kararı yazılmışsa dokunma: o karar insan kararıdır.
   --   `satinalma_kabul`da karar damgası kolonu yok; kararın izi
   --   `uygunsuzluk` ve `kullanici_birim_onay` alanlarında (karar ucu ikisini
   --   de doldurur) ve işlem günlüğünde durur.
   and coalesce(k.uygunsuzluk, '') = ''
   and coalesce(k.kullanici_birim_onay, 0) = 0;
