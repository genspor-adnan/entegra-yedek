-- =============================================================================
--  1377 - İSKONTO ONAYINI GERİ AL
--
--  Kullanıcı (18.11.2026): "sözlü onaylandı ve kitlendi.. banko nasıl değişebilir?" - onaylı satır kilitli kalıyordu,
--  ekrandaki "talebi geri çekin / onayı kaldırın" mesajlarının karşılığı yoktu. Kararlar: SÖZLÜ onayı uygulayan
--  banko (ya da onaycı) geri alır, DİJİTAL onayı yalnız onaycı; belgeye DÖNÜŞMÜŞ satırda geri alma yok (önce oluşan
--  belge silinir), yalnız tahsilat varsa izin var (açık tutar artar).
--
--  Geri almak = satırın oranı onay ÖNCESİ değerine (iskonto_talep_satir.onceki_iskonto) döner, kilit açılır (aynı
--  satırı daha önce onaylamış başka talep varsa kilit kalır), talep durum 3 "Geri çekildi". Yetki C#'ta; tutar /
--  dağılım / dip toplam BelgeDeposu.IskontoSonrasiYenileAsync ile (para hesabı tek yerde).
-- =============================================================================

begin;

create or replace function public.fn_iskonto_talep_geri_al(p_talep_id integer, p_kullanici integer, p_neden varchar)
returns void
language plpgsql
as $function$
declare
  v_durum smallint;
begin
    select durum into v_durum from public.iskonto_talep where id = p_talep_id for update;
    if v_durum is null then
        raise exception 'İskonto talebi bulunamadı: %', p_talep_id using errcode = 'GK404';
    end if;
    if v_durum <> 1 then
        raise exception 'Yalnız onaylanmış iskonto geri alınabilir.' using errcode = 'GK422';
    end if;

    -- BELGEYE DÖNÜŞMÜŞ SATIR (kullanıcı kararı): fiş / fatura / tahakkuk o tutarla kesildi.
    if exists (select 1 from public.iskonto_talep_satir ts
                 join public.belge_satir s on s.id = ts.belge_satir_id
                where ts.talep_id = p_talep_id
                  and (coalesce(s.kapatilan_miktar, 0) > 0
                       or exists (select 1 from public.belge_satir h where h.kaynak_tur = 30 and h.kaynak_id = s.id))) then
        raise exception 'Satır belgeye (fiş / fatura / tahakkuk) dönüşmüş; önce oluşan belgeyi silin, sonra iskontoyu geri alın.'
              using errcode = 'GK422';
    end if;

    -- DAHA YENİ ONAY: aynı satırı sonra onaylanmış talep varsa önce o geri alınır (oran zinciri bozulmasın).
    if exists (select 1 from public.iskonto_talep_satir ts
                 join public.iskonto_talep_satir ts2 on ts2.belge_satir_id = ts.belge_satir_id and ts2.talep_id > ts.talep_id
                 join public.iskonto_talep t2 on t2.id = ts2.talep_id and t2.durum = 1
                where ts.talep_id = p_talep_id) then
        raise exception 'Bu satırlarda daha sonra verilmiş bir iskonto onayı var; önce onu geri alın.'
              using errcode = 'GK422';
    end if;

    -- İki adım (783 karar fonksiyonuyla aynı): kilit tetiği kilitli satırın oranını değiştirtmez.
    update public.belge_satir s
       set iskonto_kilit = 0
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.belge_satir s
       set iskonto  = coalesce(ts.onceki_iskonto, 0),
           iskonto2 = 0,
           iskonto_kilit = case when exists (
                               select 1 from public.iskonto_talep_satir o
                                 join public.iskonto_talep ot on ot.id = o.talep_id and ot.durum = 1
                                where o.belge_satir_id = s.id and o.talep_id < p_talep_id) then 1 else 0 end,
           degistiren = p_kullanici
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.iskonto_talep
       set durum = 3,
           karar_notu = left(trim(coalesce(karar_notu, '') || ' · Geri alındı: ' || coalesce(p_neden, '')), 300),
           degistiren = p_kullanici, degistirme_tarihi = now()
     where id = p_talep_id;
end $function$;

comment on function public.fn_iskonto_talep_geri_al(integer, integer, varchar) is
  '1377: onaylı iskontoyu geri alır - oran onay öncesine, kilit açılır (önceki onay varsa kalır), talep durum 3. '
  'Yetki ve tutar yenileme C#''ta.';

commit;
