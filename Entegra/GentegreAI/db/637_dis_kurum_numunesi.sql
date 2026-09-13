-- =====================================================================
--  637_dis_kurum_numunesi.sql
--  BAŞVURUSUZ LABORATUVAR İSTEMİ - DIŞ KURUM NUMUNESİ (kullanici: "dis
--  kurum numunesi icin basvurusuz istem yolunu kur").
--
--  İki farklı "dışarıdan gelen" vardı, sistem birini tanımıyordu:
--    * HASTA gelir (kaynak 3 "Banko") - bu bir BAŞVURUDUR: kayıt kabul,
--      protokol, ücret, gerekirse provizyon. Başvuru önce açılır.
--    * NUMUNE gelir (kaynak 4 "Dış kurum") - hasta burada değil. Başvuru
--      açmak yapay olurdu: hasta kabul edilmedi, muayenesi yok, e-Nabız'a
--      "hasta kabul" bildirmek yanlış olur ve fatura hastaya değil GÖNDEREN
--      KURUMA kesilir.
--
--  Kart alanları (Kaynak, Dış Kurum) zaten vardı ama istem açma yolu
--  başvuruyu ŞART koşuyordu: dış kurum numunesi için ya yapay bir başvuru
--  açılıyor ya hiç girilemiyordu.
--
--  KISIT DAR TUTULDU: "belgesiz istem yasak" diye bir kural KONULAMAZ -
--  sistemde zaten 134 belgesiz istem var (göç verisi) ve mikrobiyoloji /
--  genetik test düzenekleri de belgesiz istem kuruyor. Onları geriye dönük
--  reddetmek göçü ve 22 testi düşürüyordu.
--
--  Konulan kural YENİ olanı koruyor: KAYNAK "dış kurum" (4) ise gönderen
--  kurum YAZILMIŞ olmalı. Kaynağı 4 deyip kurumu boş bırakmak, faturanın
--  kime kesileceğini ve sonucun kime teslim edileceğini cevapsız bırakırdı.
--  "Başvuru mu dış kurum mu" kararı servis katmanında (`IstemAcAsync`):
--  orada ikisinden biri zorunlu.
-- =====================================================================

alter table public.lab_istem
    drop constraint if exists ck_lab_istem_kaynak_baglanti;
alter table public.lab_istem
    drop constraint if exists ck_lab_istem_dis_kurum;

alter table public.lab_istem
    add constraint ck_lab_istem_dis_kurum
    check (kaynak <> 4 or dis_kurum_id is not null);

comment on constraint ck_lab_istem_dis_kurum on public.lab_istem is
  '637: kaynak 4 (dis kurum) ise gonderen kurum zorunlu - fatura ve sonuc '
  'teslimi ona yapilir.';

comment on column public.lab_istem.dis_kurum_id is
  '637: numuneyi GONDEREN kurum (kaynak 4). Basvurusuz istemde zorunlu - '
  'faturalama ve sonuc teslimi bu kuruma yapilir.';

do $kontrol$
begin
    raise notice '637 tamam: kaynak 4 kisiti kurulu; % belgesiz istem (goc) dokunulmadi',
        (select count(*) from public.lab_istem where belge_id is null);
end $kontrol$;
