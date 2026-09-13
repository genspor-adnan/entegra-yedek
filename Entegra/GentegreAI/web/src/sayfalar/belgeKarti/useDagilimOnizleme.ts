import { useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hamSayi } from '../../bilesenler/bicim';
import { type SatirDurumu, type SatirDagilimi, satirTutari } from '../belgeSatir';
import { type BasvuruBilgi } from '../../bilesenler/belge/BasvuruSekmesi';

/**
 * KAYDEDİLMEMİŞ SATIRLARIN KOVA DAĞILIMI — sunucudan önizleme.
 *
 * Ücret satırı girilir girilmez "bu tutarın ne kadarı hastadan, ne kadarı
 * kurumdan" sorusunun cevabı gerekir: açık tahsilat şeridi ve kalemdeki "+"
 * düğmesi onu gösterir. Kayıt beklenmez, sunucuya SORULUR - hesabın tek
 * sahibi sunucudur, istemci kova dağılımını kendi hesaplamaz.
 *
 * Kart içinde 70 satır tutuyordu ve üç parçası (imza, efekt, şerit
 * satırları) birbirinden uzaktı.
 */
export function useDagilimOnizleme(p: {
  basvuruMu: boolean;
  odeyenKurumId: number | null;
  satirlar: SatirDurumu[];
  basvuruBilgi: BasvuruBilgi;
}) {
  const { basvuruMu, odeyenKurumId, satirlar, basvuruBilgi } = p;

  const [dagilimOnizleme, setDagilimOnizleme] =
    useState<Record<string, SatirDagilimi>>({});

  const onizlemeGirdisi = useMemo(() => {
    if (!basvuruMu || !odeyenKurumId) return null;
    const eksik = satirlar.filter(r => !r.dagilim && (r.stokId || r.hizmetId)
                                    && hamSayi(r.adet) > 0);
    if (eksik.length === 0) return null;
    return eksik.map(r => ({
      // ANAHTAR METIN GIDER (602): gridin anahtari SAYI (belgeSatir.ts), ucun
      //   sozlesmesi ise METIN (DagilimOnizlemeSatiri.Anahtar). Sayi olarak
      //   gonderilince System.Text.Json bunu string alana baglayamiyor ve
      //   istek 400 donuyordu; hata asagidaki sessiz catch'te yutuldugu icin
      //   ekranda hicbir belirti yoktu - "+" dagilim dugmesi hic cizilmiyor,
      //   acik tahsilat/acik belge seridi de guncellenmiyordu. tsc yakalamadi
      //   cunku govde `JSON.parse` (any) uzerinden geciyor.
      anahtar: String(r.anahtar),
      stokId: r.stokId ?? null, hizmetId: r.hizmetId ?? null,
      miktar: hamSayi(r.adet),
      // Kovalar MATRAH tutar - grid tutari da matrahtan hesaplanir.
      tutar: satirTutari(hamSayi(r.adet), hamSayi(r.birimFiyat), r.iskonto, r.iskonto2),
      kdv: Number(r.kdv) || 0,
      iskonto: hamSayi(r.iskonto), iskonto2: hamSayi(r.iskonto2),
      sgkListe: r.sgkListe ? hamSayi(r.sgkListe) : null,
      katkiTutar: r.katkiTutar ? hamSayi(r.katkiTutar) : null,
    }));
  }, [basvuruMu, odeyenKurumId, satirlar]);

  const onizlemeImzasi = onizlemeGirdisi ? JSON.stringify(onizlemeGirdisi) : '';
  const basvuruImzasi = [odeyenKurumId, basvuruBilgi.sozlesmeId, basvuruBilgi.altKurum,
                         basvuruBilgi.sgkKullan, basvuruBilgi.emekli].join('|');

  useEffect(() => {
    if (!onizlemeImzasi || !odeyenKurumId) { setDagilimOnizleme({}); return }
    let iptal = false;
    const zamanlayici = setTimeout(() => {
      void (async () => {
        try {
          const y = await api.belgeDagilimOnizleme({
            odeyenKurumId,
            sozlesmeId: basvuruBilgi.sozlesmeId, altKurum: basvuruBilgi.altKurum,
            sgkKullan: basvuruBilgi.sgkKullan, emekli: basvuruBilgi.emekli,
            satirlar: JSON.parse(onizlemeImzasi),
          });
          if (iptal) return;
          const harita: Record<string, SatirDagilimi> = {};
          for (const x of y.satirlar ?? [])
            harita[x.anahtar] = {
              rota: Number(x.rota ?? 0),
              sgk: Number(x.sgk ?? 0), oss: Number(x.oss ?? 0),
              hastaProvizyon: Number(x.hastaProvizyon ?? 0),
              hastaEkKatki: Number(x.hastaEkKatki ?? 0),
              sgkKatilimPayi: Number(x.sgkKatilimPayi ?? 0),
              sgkKapatilan: 0, ossKapatilan: 0,
              hastaProvizyonKapatilan: 0, hastaEkKatkiKapatilan: 0,
              sgkTahsil: 0, ossTahsil: 0,
              hastaProvizyonTahsil: 0, hastaEkKatkiTahsil: 0, sgkKatilimTahsil: 0,
              sgkListe: Number(x.sgkListe ?? 0), huvListe: Number(x.huvListe ?? 0),
              sgkProvizyonNo: '', elle: 0, sgkListeElle: 0, huvListeElle: 0,
            } as SatirDagilimi;
          setDagilimOnizleme(harita);
        } catch (h) {
          // Onizleme KULLANICIYA hata gostermez - kayitta gercek hesap yapilir,
          //   yarim bir istek ucret girisini kesmemeli. Ama tamamen izsiz de
          //   kalmamali (602): anahtar tipi uyusmazligi bu blokta aylarca
          //   yutuldu, "+" dugmesi ve acik serit sessizce bos kaldi.
          console.warn('[dagilim-onizleme] alinamadi:', h);
        }
      })();
    }, 250);
    return () => { iptal = true; clearTimeout(zamanlayici) };
  }, [onizlemeImzasi, basvuruImzasi, odeyenKurumId, basvuruBilgi.sozlesmeId,
      basvuruBilgi.altKurum, basvuruBilgi.sgkKullan, basvuruBilgi.emekli]);

  /** Serit hesabi icin satirlar: kayitsiz satira ONIZLEME kovalari takilir. */
  const seritSatirlari = useMemo(() => satirlar.map(r => (
    r.dagilim || !dagilimOnizleme[r.anahtar]
      ? r : { ...r, dagilim: dagilimOnizleme[r.anahtar] })),
    [satirlar, dagilimOnizleme]);
  return { dagilimOnizleme, seritSatirlari };
}
