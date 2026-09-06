-- =====================================================================
-- 437 - KADEMELİ BİLDİRİM: KOMBİNASYON AJANI DÜZELTMESİ
--
-- 436'daki kural "alt basamakta duyarlı (S) varsa üst basamağı gizle"
-- diyordu. Örnek çalışmada kusur çıktı: MRSA bakteriyemisinde tüm 1.
-- basamak dirençliyken 2. basamaktaki GENTAMİSİN duyarlı olduğu için
-- VANKOMİSİN GİZLENDİ. Aminoglikozid bakteriyemide tek başına tedavi
-- değildir; kombinasyonda kullanılır. Aynı kusur ESBL pozitif
-- Klebsiella'da amikasin duyarlı diye karbapenemi gizliyordu.
--
-- Çözüm: antibiyotiğe "tek başına yeterli değil" bayrağı. Bu ajanlar
-- KENDİ BASAMAĞINDA RAPORLANIR (klinisyen kombinasyon kurabilsin) ama
-- "duyarlı seçenek var" sayımına GİRMEZ - yani üst basamağı kapatmaz.
--
-- Kural klinik kararın yerine geçmiyor; yalnız varsayılanı doğru
-- tarafa alıyor: eksik raporlanan geniş spektrumlu ajan, gereksiz
-- raporlanandan daha tehlikelidir (hasta tedavisiz kalır).
-- =====================================================================

alter table public.lab_antibiyotik
    add column if not exists tek_basina_yetersiz smallint not null default 0;

comment on column public.lab_antibiyotik.tek_basina_yetersiz is
    'Kombinasyon ajani (aminoglikozid vb.): kendi basamaginda raporlanir '
    'ama kademeli bildirimde "duyarli secenek" sayilmaz - ust basamagi kapatmaz.';

update public.lab_antibiyotik
   set tek_basina_yetersiz = 1
 where upper(kod) in ('GEN', 'AMK')
   and tek_basina_yetersiz = 0;

create or replace function public.fn_lab_antibiyogram_bildirim(p_ureme_id integer)
returns integer language plpgsql as $$
declare
    v_uriner   boolean;
    v_s1       integer;
    v_s2       integer;
    v_etkilenen integer;
begin
    -- Numune tipi 4 = idrar (db/433 kod uzayı).
    select coalesce(n.numune_tipi, 0) = 4
      into v_uriner
      from public.lab_kultur_ureme u
      join public.lab_kultur k on k.id = u.kultur_id
      left join public.lab_numune n on n.id = k.numune_id
     where u.id = p_ureme_id;

    -- SAYIMA GİRMEYENLER: kombinasyon ajanları ve numuneye uymayan
    --   üriner-özel ajanlar. İkisi de "tedavi seçeneği var" anlamına
    --   gelmez; sayılırlarsa üst basamak haksız yere kapanır.
    select count(*) filter (where a.basamak = 1 and g.yorum = 'S'),
           count(*) filter (where a.basamak = 2 and g.yorum = 'S')
      into v_s1, v_s2
      from public.lab_antibiyogram g
      join public.lab_antibiyotik a on a.id = g.antibiyotik_id
     where g.ureme_id = p_ureme_id
       and a.tek_basina_yetersiz = 0
       and (a.yalniz_uriner = 0 or coalesce(v_uriner, false));

    update public.lab_antibiyogram g
       set bildir = case
             -- Uzman elle karar verdiyse (kaynak 4) dokunulmaz.
             when g.kaynak = 4 then g.bildir
             when a.yalniz_uriner = 1 and not coalesce(v_uriner, false) then 0
             when a.basamak = 1 then 1
             when a.basamak = 2 then case when coalesce(v_s1, 0) = 0 then 1 else 0 end
             else case when coalesce(v_s1, 0) = 0 and coalesce(v_s2, 0) = 0
                       then 1 else 0 end
           end
      from public.lab_antibiyotik a
     where a.id = g.antibiyotik_id and g.ureme_id = p_ureme_id;

    get diagnostics v_etkilenen = row_count;
    return v_etkilenen;
end $$;

-- Mevcut antibiyogramlar YENİDEN HESAPLANIR: kural düzeldiyse eski
--   raporun gizlediği ajan da açılmalı. (Onaylı rapor metni değişmez;
--   değişen yalnız hangi satırın gösterileceği.)
do $$
declare
    v_id integer;
    v_adet integer := 0;
begin
    for v_id in select distinct ureme_id from public.lab_antibiyogram loop
        perform public.fn_lab_antibiyogram_bildirim(v_id);
        v_adet := v_adet + 1;
    end loop;
    raise notice '437 tamam: kombinasyon ajani bayragi, % izolat yeniden hesaplandi',
                 v_adet;
end $$;
