-- 1352 - Başvuru: KVKK / ETK onayı SMS kodu ile (17.11.2026).
--   Kullanıcı: "acil başvuru butonu sağında separator sağına 'KVK SMS gönder' butonu ekle.. hastanın cep telefonuna sms
--   gitsin.. sms metnini opsiyona yaz müşteri oradan değiştirebilsin.. @ONAYKODU senin tarafından tekil olarak verilecek
--   (random).. hasta onu bize söyleyecek biz de başvuruya sms combo sağına kaydedeceğiz".
--
--   * ŞABLON `basvuru.kvkk_sms` (bildirim_sablon, SMS): Yönetim › Bildirim Şablonu Listesi'nden değiştirilir.
--     `@ONAYKODU` (ya da {{onay_kodu}}) gönderimde başvuruya üretilen kodla değişir. Kurulumda varsa DOKUNULMAZ.
--     Varsayılan metin kuruma özel bağlantı İÇERMEZ - aydınlatma metni linki kurumun kendi şablonuna yazılır.
--   * belge_basvuru.kvkk_sms_kod / kvkk_sms_tarihi: gönderilen kod ve zamanı (sunucu yazar, istemci yazamaz).
--     belge_basvuru.kvkk_onay_kodu: hastanın söylediği kod (kayıt kabul yazar).
--   * TETİK: girilen kod gönderilenle eşleşmezse kayıt reddedilir (GK422); eşleşince KVKK ve ETK onayı
--     "4 = SMS ile onay alındı" olur (1351 kodları).
alter table public.belge_basvuru
    add column if not exists kvkk_sms_kod    varchar(10),
    add column if not exists kvkk_sms_tarihi timestamptz,
    add column if not exists kvkk_onay_kodu  varchar(10);
comment on column public.belge_basvuru.kvkk_sms_kod    is '1352: KVKK/ETK onay SMS''inde gönderilen tek kullanımlık kod (sunucu üretir)';
comment on column public.belge_basvuru.kvkk_sms_tarihi is '1352: KVKK/ETK onay SMS''inin kuyruğa alındığı an';
comment on column public.belge_basvuru.kvkk_onay_kodu  is '1352: hastanın söylediği onay kodu - kvkk_sms_kod ile eşleşmeli';

create or replace function public.tg_belge_basvuru_kvkk_kod()
returns trigger language plpgsql as $$
begin
  new.kvkk_onay_kodu := nullif(btrim(coalesce(new.kvkk_onay_kodu, '')), '');
  if new.kvkk_onay_kodu is null then return new; end if;
  if tg_op = 'UPDATE' and new.kvkk_onay_kodu is not distinct from old.kvkk_onay_kodu
     and new.kvkk_sms_kod is not distinct from old.kvkk_sms_kod then
    return new;
  end if;
  if new.kvkk_sms_kod is null then
    raise exception using errcode = 'GK422',
      message = 'Bu başvuru için KVKK onay SMS''i gönderilmemiş - önce "KVKK SMS Gönder".';
  end if;
  if new.kvkk_onay_kodu <> new.kvkk_sms_kod then
    raise exception using errcode = 'GK422',
      message = 'SMS onay kodu hatalı - hastaya gönderilen kodla eşleşmiyor.';
  end if;
  new.kvkk_onay := 4;
  new.etk_onay  := 4;
  return new;
end $$;
comment on function public.tg_belge_basvuru_kvkk_kod() is
  '1352: SMS onay kodu doğrulaması; eşleşince KVKK ve ETK onayı 4 (SMS ile onay alındı).';

drop trigger if exists tr_belge_basvuru_kvkk_kod on public.belge_basvuru;
create trigger tr_belge_basvuru_kvkk_kod
  before insert or update of kvkk_onay_kodu, kvkk_sms_kod on public.belge_basvuru
  for each row execute function public.tg_belge_basvuru_kvkk_kod();

insert into public.bildirim_sablon (kod, ad, kanal, govde, degiskenler, aciklama)
values ('basvuru.kvkk_sms', 'Başvuru KVKK / ETK onay SMS''i', 1,
        '@ONAYKODU numaralı onay kodunu ilgiliye söyleyerek, kurumumuzun KVKK Aydınlatma Metnine göre kişisel verilerinizin işlenmesine ve sistemlerimizde kayıtlı iletişim adresleriniz üzerinden SMS, e-posta ve aramalar vasıtasıyla ticari elektronik ileti gönderimine izin vermiş olacaksınız.',
        '{"ONAYKODU": "Tek kullanımlık onay kodu (@ONAYKODU ya da {{onay_kodu}})"}'::jsonb,
        'Başvuru kartı › KVKK SMS Gönder. Hasta kodu söyler, Başvuru sekmesinde SMS onay kodu kutusuna yazılır (1352).')
on conflict (kod) do nothing;
