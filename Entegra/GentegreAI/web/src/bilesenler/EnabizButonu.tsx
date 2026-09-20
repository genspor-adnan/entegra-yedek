import { useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { mesaj } from './mesaj';
import { useOturum } from '../kimlik/OturumBaglami';
import { c as cev } from '../dil/ceviri';

/**
 * e-NABIZ BUTONU — BAKANLIK STANDARDI (KTS denetim maddesi H8).
 *
 * <para>Denetim üç şeye bakar: <b>resim</b>, <b>yer</b> ve <b>hint</b>.
 * Düğme iki ekranda ayrı ayrı yazılmıştı (istem/muayene kartı ve diş hasta
 * kartı): biri emoji + metin, öteki başka konumda, ikisinde de ipucu yok ve
 * pop-up mantığı kopyalanmış. Aynı düğmenin iki görünümü, denetimde "standarda
 * uygun mu" sorusunu cevapsız bırakır.</para>
 *
 * <b>Tek kaynak buradadır.</b> Hasta bağlamı olan her ekran bu bileşeni
 * çağırır; görünüm, konum sınıfı, ipucu metni ve yetki kuralı tek yerde
 * değişir.
 *
 * <b>Logo:</b> e-Nabız markası Bakanlığındır - çizip taklit etmeyiz. Kurum
 * resmî görseli <c>public/enabiz-logo.png</c> olarak koyarsa düğme onu
 * gösterir; yoksa metin + kilit işaretiyle çalışır. Görsel yüklenemezse
 * düğme metne düşer, hiçbir durumda kırık resim görünmez.
 *
 * <b>Pop-up kuralı:</b> sekme İSTEKTEN ÖNCE açılır. Tarayıcı yalnız
 * kullanıcı tıklamasının hemen ardından gelen <c>window.open</c>'a izin
 * verir; <c>await</c> sonrası açılan pencere engelleniyor ve hekim "bir şey
 * olmadı" diyordu.
 */
export type EnabizButonuTuru = 'erisim' | 'mesaj';

/** Denetimde sorulan İPUÇLARI (hint) - tek yerde, iki ekranda aynı. */
const IPUCU: Record<EnabizButonuTuru, string> = {
  erisim: 'Hastanın e-Nabız kişisel sağlık kaydını açar. '
        + 'Erişim hastanın e-Devlet / SMS onayıyla tamamlanır ve kayda geçer.',
  mesaj: 'Hastanın e-Nabız profiline hekim mesajı yazar. '
       + 'Mesaj Bakanlık kuyruğuna girer, gönderimi sistem yapar.',
};

const ETIKET: Record<EnabizButonuTuru, string> = {
  erisim: 'e-Nabız Kayıtları',
  mesaj: 'e-Nabız Mesajı',
};

/** Yetki kodu da türle birlikte gelir: iki düğme iki ayrı aksiyondur. */
const AKSIYON: Record<EnabizButonuTuru, string> = {
  erisim: 'enabiz.erisim',
  mesaj: 'enabiz.mesaj',
};

export function EnabizButonu({ tur, hastaId, muayeneId, belgeId, onMesaj, kucuk }: {
  tur: EnabizButonuTuru;
  hastaId: number;
  muayeneId?: number | null;
  belgeId?: number | null;
  /** Mesaj türünde pencereyi AÇAN taraf ekrandır - içerik ekranın state'i. */
  onMesaj?: () => void;
  kucuk?: boolean;
}) {
  const { aksiyonVar } = useOturum();
  const [calisiyor, setCalisiyor] = useState(false);

  // YETKİSİZ KULLANICIDA DÜĞME HİÇ ÇİZİLMEZ: tıklanınca "yetkiniz yok"
  //   demek, olmayan bir kapıyı göstermektir.
  if (!aksiyonVar(AKSIYON[tur]) || !(hastaId > 0)) return null;

  const erisimAc = async () => {
    const sekme = window.open('', '_blank');
    setCalisiyor(true);
    try {
      const y = await api.enabizErisimAc({
        hastaId, muayeneId: muayeneId ?? null, belgeId: belgeId ?? null });
      if (sekme) sekme.location.href = y.adres;
      else window.open(y.adres, '_blank');
    } catch (h) {
      sekme?.close();
      mesaj(hataMetni(h));
    } finally { setCalisiyor(false) }
  };

  return (
    <button type="button"
            className={`d enabiz-dugme${kucuk ? ' kucuk' : ''}`}
            title={cev(IPUCU[tur])}
            disabled={calisiyor}
            onClick={() => (tur === 'erisim' ? void erisimAc() : onMesaj?.())}>
      <EnabizIsareti tur={tur} />
      {cev(ETIKET[tur])}
    </button>
  );
}

/**
 * Düğmenin görseli. Kurum resmî logoyu koyduysa o, koymadıysa yazı tipinden
 * bağımsız bir işaret - emoji kullanmıyoruz, Windows'ta boy ve renk
 * tutarsızlığı yapıyor (bayrak emojisinde yaşanan sorunun aynısı).
 */
function EnabizIsareti({ tur }: { tur: EnabizButonuTuru }) {
  const [logoYok, setLogoYok] = useState(false);

  if (!logoYok) {
    return (
      <img src="/enabiz-logo.png" alt="" aria-hidden="true" className="enabiz-logo"
           onError={() => setLogoYok(true)} />
    );
  }
  return (
    <span aria-hidden="true" className="enabiz-isaret">
      {tur === 'erisim' ? '⌸' : '✉'}
    </span>
  );
}
