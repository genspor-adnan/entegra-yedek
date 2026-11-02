-- =============================================================================
--  1230  RADYOLOJİ - YÖNLÜ SUT KODU (SABİT YÖN)
--
--  SUT tek taraflı tetkiklerin çoğunu YÖNÜYLE kodlar ("R104040 MRG, DİZ - SAĞ, KONTRASTSIZ" / "R104060 ...
--  SOL ..."; radyoloji SUT'unun ~190 kodu). Bu hizmetlerde yön adın içindedir: kabulde ayrıca sorulmaz,
--  istemin yönü hizmetten gelir. 1229'un ad kuralı bunlara da "yön zorunlu" demişti - kaldırılır.
--  Yön zorunlu yalnız yönsüz (eski / kuruma özel "Diz MR") hizmette kalır.
--    hizmet.yon: 0 yok · 1 sağ · 2 sol · 3 bilateral (radyoloji_istem.yon ile aynı kodlar).
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.hizmet add column if not exists yon smallint not null default 0;
comment on column public.hizmet.yon is
  '1230: hizmetin SABİT yönü (yönlü SUT kodu: "- SAĞ" / "- SOL" / bilateral) - istem yönü buradan gelir.';

update public.hizmet set yon = case
         when upper(ad) ~ '(B[İI]LATERAL|İK[İI]\s+TARAF|HER\s+[İI]K[İI])' then 3
         when upper(ad) ~ '\mSAĞ\M' then 1
         when upper(ad) ~ '\mSOL\M' then 2 end
 where coalesce(modalite, 0) > 0 and yon = 0
   and upper(ad) ~ '(\mSAĞ\M|\mSOL\M|B[İI]LATERAL|İK[İI]\s+TARAF|HER\s+[İI]K[İI])';

update public.hizmet set yon_zorunlu = 0 where yon > 0 and yon_zorunlu = 1;

-- İstem yönü verilmediyse hizmetin sabit yönü (her yoldan açılan istem: kabul, muayene, kart, aktarım).
create or replace function public.tg_radyoloji_istem_yon()
returns trigger language plpgsql as $$
begin
  if coalesce(new.yon, 0) = 0 then
    select coalesce(h.yon, 0) into new.yon from public.hizmet h where h.id = new.hizmet_id;
    new.yon := coalesce(new.yon, 0);
  end if;
  return new;
end $$;

drop trigger if exists tg_radyoloji_istem_yon on public.radyoloji_istem;
create trigger tg_radyoloji_istem_yon
before insert on public.radyoloji_istem
for each row execute function public.tg_radyoloji_istem_yon();
