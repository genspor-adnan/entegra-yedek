-- =============================================================================
--  1375 - İSKONTO: SÖZLÜ ONAY (şube ayarı ile dijital / sözlü / ikisi)
--
--  Kullanıcı (18.11.2026): "bir çok müşterimiz sözlü onay kullanıyor.. banko ilgili yöneticinin sözüyle yüksek
--  oranlarda indirim yapabiliyor" · "sözlü onay / dijital onay opsiyonlu olabilmeli".
--  Kararlar: ŞUBE ayarı (1 Dijital · 2 Sözlü · 3 İkisi de); banko onay veren yöneticiyi seçer + gerekçe, iskonto
--  HEMEN uygulanır ve "sözlü" damgasıyla kayda geçer, yöneticiye bildirim (zil hatırlatması) gider; oran sınırı YOK.
--
--  Sözlü onay ayrı bir yazma yolu DEĞİL: talep açılır ve `fn_iskonto_talep_karar` seçilen yönetici adına onaylar -
--  oranı satırlara kilitli yazan tek yer o kalır. Burada yalnız iki kolon ve onaycı listesi var.
--  Betik idempotent.
-- =============================================================================

begin;

alter table public.sube add column if not exists iskonto_onay_yontemi smallint not null default 1;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ck_sube_iskonto_onay_yontemi') then
    alter table public.sube add constraint ck_sube_iskonto_onay_yontemi check (iskonto_onay_yontemi in (1, 2, 3));
  end if;
end $$;
comment on column public.sube.iskonto_onay_yontemi is
  '1375: limit üstü iskontonun onayı - 1 dijital (onay zinciri) · 2 sözlü (banko yöneticiyi seçer) · 3 ikisi de';

alter table public.iskonto_talep add column if not exists onay_yontemi smallint not null default 1;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ck_iskonto_talep_onay_yontemi') then
    alter table public.iskonto_talep add constraint ck_iskonto_talep_onay_yontemi check (onay_yontemi in (1, 2));
  end if;
end $$;
comment on column public.iskonto_talep.onay_yontemi is
  '1375: 1 dijital (onay zinciri) · 2 sözlü (isteyen = beyan eden banko, onay_id = sözünü veren yönetici)';

-- SÖZLÜ ONAY VEREBİLECEKLER: dijital zincirde iskonto onaylayabilenlerle AYNI küme (birim / mali / üst onay
--   aksiyonu, ek roller dahil - OnayBildirimi.AlicilarAsync ile aynı kural), şubeye erişimi olan, aktif, kendisi
--   hariç (kendi talebini onaylayamaz - 783).
create or replace function public.fn_iskonto_sozlu_onaycilar(p_sube integer, p_kullanici integer)
returns table (id integer, ad character varying)
language sql stable
as $$
  select distinct k.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), k.kod)::varchar
    from public.taraf_kullanici k
    join public.taraf t on t.id = k.id
    join public.rol_yetki ry
      on ry.rol_id = k.rol_id
      or ry.rol_id in (select kr.rol_id from public.kullanici_rol kr where kr.kullanici_id = k.id)
    join public.yetki y on y.id = ry.yetki_id
   where k.aktif = 1 and k.id <> p_kullanici
     and y.kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali', 'belge.iskonto_onay_ust')
     and coalesce(ry.gor, 0) = 1
     and (coalesce(p_sube, 0) = 0
          or exists (select 1 from public.fn_kullanici_subeleri(k.id) s where s.sube_id = p_sube))
   order by 2
$$;

comment on function public.fn_iskonto_sozlu_onaycilar(integer, integer) is
  '1375: sözlü iskonto onayında seçilebilecek yöneticiler (dijital zincirin onaycılarıyla aynı küme)';

commit;
