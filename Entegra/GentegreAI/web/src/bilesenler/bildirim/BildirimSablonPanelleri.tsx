import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { BildirimSablonOzeti } from '../../api/uclar/bildirimSablon';
import { GenGrid } from '../GenGrid';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';
import { c } from '../../dil/ceviri';
import { metindekiDegiskenler, sablonDoldur, smsOlc } from './smsSayaci';

/**
 * BİLDİRİM ŞABLONU KARTI PANELLERİ (1354, mockup Ekranlar/Ayarlar/bildirim_sablonu_karti.html, 17.11.2026).
 *  · BildirimMetinPaneli      - Metin sekmesi: alanlar (GenForm) + değişken çipleri + SMS sayacı + denetim + kullanıldığı
 *                               yer; sağda telefon (SMS) / e-posta önizlemesi. Kartın KAYDEDİLMEMİŞ metni üzerinden canlı.
 *  · DegiskenlerSekmesi       - şablonun değişkenleri, yazımı, örnek değer, metinde var mı
 *  · GonderimGecmisiSekmesi   - bu şablonla kuyruğa giren bildirimler (kaynak `bildirim`, sablonId süzgeci)
 *  · DegisiklikGecmisiSekmesi - islem_log (tablo 1287)
 *  · DenemeGonderDugmesi      - araç çubuğu: kendi numarana / adresine örnek değerlerle gerçek gönderim
 */

type Deger = Record<string, unknown>;

/** Kodun programda kullanıldığı yer (mockup "Kullanıldığı yer"). Listede yoksa genel cümle. */
const KULLANIM: Record<string, string> = {
  'basvuru.kvkk_sms': 'Başvuru Kartı › 📱 KVKK Onay › SMS Gönder — alıcı: hastanın cep telefonu',
  'kimlik.parola_sifirlama': 'Giriş ekranı › Şifremi Unuttum — alıcı: kullanıcının cep telefonu',
  'kimlik.parola_sifirlama.eposta': 'Giriş ekranı › Şifremi Unuttum — alıcı: kullanıcının e-postası',
  'onam.istek': 'Onam formu gönderimi — alıcı: hasta',
  'hatirlatma.kisisel': 'Kişisel hatırlatıcı — alıcı: hatırlatmayı kuran kullanıcı',
};

/** Değişken adından örnek değer - önizleme ve deneme gönderimi için. */
export function ornekDeger(ad: string): string {
  const a = ad.toLowerCase();
  if (a.includes('kod')) return '482913';
  if (a.includes('baglanti') || a.includes('link')) return 'https://ornek.genotip.com/f/ab12';
  if (a.includes('tarih')) return new Date().toLocaleDateString('tr-TR');
  if (a.includes('saat')) return '14:30';
  if (a.includes('dakika')) return '10';
  if (a.includes('kurum') || a.includes('sube')) return 'Koşuyolu';
  if (a.includes('hasta') || a.includes('kisi') || a.includes('alici') || a === 'ad') return 'Ayşe Kaya';
  return `‹${ad}›`;
}

/** Değişken çipinin yazımı: büyük harfli ad @AD, diğerleri {{ad}}. */
const yazim = (ad: string) => (ad === ad.toUpperCase() ? `@${ad}` : `{{${ad}}}`);

function useOzet(id: number | null) {
  const [ozet, setOzet] = useState<BildirimSablonOzeti | null>(null);
  useEffect(() => {
    if (!id) { setOzet(null); return }
    let iptal = false;
    Promise.resolve().then(() => api.bildirimSablonOzet(id))
      .then(o => { if (!iptal) setOzet(o) }).catch(() => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [id]);
  return ozet;
}

/** Değişkenlerin örnek değerleri: şablonun tanımlı değişkenleri + metinde geçenler. */
function ornekler(ozet: BildirimSablonOzeti | null, govde: string): Record<string, string> {
  const adlar = new Set([...Object.keys(ozet?.degiskenler ?? {}), ...metindekiDegiskenler(govde)]);
  return Object.fromEntries([...adlar].map(a => [a, ornekDeger(a)]));
}

/** Önizleme balonu: değişkenler sarı vurgulu örnek değerle, bağlantılar mavi. */
function vurgula(govde: string, degerler: Record<string, string>): ReactNode[] {
  return govde.split(/(\{\{\s*[\w.]+\s*\}\}|@[A-ZÇĞİÖŞÜ][A-ZÇĞİÖŞÜ_0-9]+|https?:\/\/[^\s]+)/g).map((p, i) => {
    const d = p.match(/^\{\{\s*([\w.]+)\s*\}\}$/)?.[1] ?? p.match(/^@([A-ZÇĞİÖŞÜ][A-ZÇĞİÖŞÜ_0-9]+)$/)?.[1];
    if (d) {
      const anahtar = Object.keys(degerler).find(k => k.toLowerCase() === d.toLowerCase());
      return <span key={i} className="bsk-dg">{anahtar ? degerler[anahtar] : p}</span>;
    }
    if (/^https?:\/\//.test(p)) return <span key={i} className="bsk-link">{p}</span>;
    return p;
  });
}

export function BildirimMetinPaneli({ icerik, deger, id }: { icerik: ReactNode; deger: Deger; id: number | null }) {
  const ozet = useOzet(id);
  const kok = useRef<HTMLDivElement>(null);
  const govde = String(deger.govde ?? '');
  const konu = String(deger.konu ?? '');
  const kanal = Number(deger.kanal ?? 1);
  const sms = kanal === 1;
  const saatBas = Number(deger.saatBas ?? 0), saatBit = Number(deger.saatBit ?? 0);
  const degerler = useMemo(() => ornekler(ozet, govde), [ozet, govde]);
  const dolu = sablonDoldur(govde, degerler);
  const olcu = smsOlc(dolu);
  const tanimli = new Set(Object.keys(ozet?.degiskenler ?? {}).map(k => k.toLowerCase()));
  const tanimsiz = ozet ? metindekiDegiskenler(govde).filter(a => !tanimli.has(a.toLowerCase())) : [];
  const kullanilan = Object.keys(ozet?.degiskenler ?? {}).filter(a => metindekiDegiskenler(govde).some(m => m.toLowerCase() === a.toLowerCase()));
  const baglantilar = govde.match(/https?:\/\/[^\s]+/g) ?? [];
  const kullanim = ozet ? KULLANIM[ozet.kod] : undefined;

  /** Çip: imlecin olduğu yere eklenir (execCommand ile - React onChange tetiklenir, kayıt bunu görür). */
  const ekle = (metin: string) => {
    const t = kok.current?.querySelector<HTMLTextAreaElement>('.alan-govde textarea');
    if (!t || t.disabled || t.closest('[inert]')) return;
    t.focus();
    document.execCommand('insertText', false, metin);
  };

  return (
    <div className="bsk-metin" ref={kok}>
      <div className="bsk-sol">
        {icerik}
        {ozet && Object.keys(ozet.degiskenler).length > 0 && (
          <div className="bsk-cipler">
            <small>{c('Değişkenler')}:</small>
            {Object.entries(ozet.degiskenler).map(([ad, aciklama]) => (
              <button key={ad} type="button" className="bsk-cip" title={`${aciklama} - ${c('imlecin olduğu yere eklenir')}`}
                      onMouseDown={e => { e.preventDefault(); ekle(yazim(ad)) }}>{yazim(ad)}</button>
            ))}
          </div>
        )}
        {sms && (
          <div className="bsk-sayac">
            <div><small>{c('Karakter')}</small><b>{olcu.karakter}</b> <i>/ 1 SMS = {olcu.tekSms}</i></div>
            <div><small>{c('Kodlama')}</small><b className={olcu.ucs2 ? 'u' : ''}>{olcu.ucs2 ? 'UCS-2' : 'GSM 7-bit'}</b>
              <i>{olcu.ucs2 ? c('Türkçe harf var') : c('Türkçe harf yok')}</i></div>
            <div><small>{c('SMS adedi (her gönderim)')}</small><b className={olcu.adet > 1 ? 'u' : ''}>{olcu.adet}</b></div>
            <div><small>{c('Bu ay gönderim')}</small><b>{ozet?.buAy ?? '…'}</b>
              {ozet ? <i>≈ {ozet.buAy * olcu.adet} {c('kontör')}</i> : null}</div>
          </div>
        )}
        <div className="bsk-grp">
          <h6>{c('Denetim')}</h6>
          <div className="bsk-uyarilar">
            {tanimsiz.map(a => (
              <div key={a} className="bsk-uy k">✗ <span><b>{yazim(a)}</b> {c('tanımlı bir değişken değil: gönderimde olduğu gibi kalır, alıcıya bu yazı gider.')}</span></div>
            ))}
            {sms && olcu.adet > 1 && (
              <div className="bsk-uy s">⚠ <span><b>{c('Uzun mesaj')}:</b> {olcu.ucs2
                ? c('Türkçe harfler (ı, ş, ğ, İ, Ş, Ğ, ç) mesajı UCS-2 kodlamasına geçirir; her parça 67 karakter.')
                : c('Her parça 153 karakter.')} {c('Bu metin')} <b>{olcu.adet} SMS</b> {c('olarak ücretlenir.')}</span></div>
            )}
            {baglantilar.map(l => (
              <div key={l} className="bsk-uy b">ℹ <span><b>{c('Bağlantı')}:</b> {l.replace(/^https?:\/\//, '').split('/')[0]} — {c('kuruma özel; başka şube / kurum için şablon kopyalanıp düzenlenmeli.')}</span></div>
            ))}
            {kullanilan.map(a => (
              <div key={a} className="bsk-uy g">✓ <span><b>{yazim(a)}</b> {c('metinde var')} — {ozet?.degiskenler[a]}.</span></div>
            ))}
            {sms && (saatBas > 0 || saatBit > 0) && (
              <div className="bsk-uy b">🕘 <span><b>{c('Gönderim saati')} {String(saatBas).padStart(2, '0')}:00–{String(saatBit).padStart(2, '0')}:00:</b> {c('bu saat dışında kuyruğa giren SMS pencere açılınca gider.')}{ozet?.kod === 'basvuru.kvkk_sms' ? ` ${c('Onay kodu SMS’inde saat penceresini kaldırmak önerilir (kabul gece de yapılır).')}` : ''}</span></div>
            )}
            {ozet && tanimsiz.length === 0 && !(sms && olcu.adet > 1) && baglantilar.length === 0 && kullanilan.length === 0 && (
              <div className="bsk-uy g">✓ <span>{c('Sorun yok.')}</span></div>
            )}
          </div>
        </div>
        {ozet?.sistem && (
          <div className="bsk-grp">
            <h6>{c('Kullanıldığı yer')}</h6>
            <div className="bsk-kullanim">
              <div>{kullanim ?? c('Programın bir ekranı bu şablonu kodundan bulur.')}</div>
              <div className="sonuk">{c('Kod programda geçtiği için değiştirilemez, şablon silinemez; kullanılmasın isteniyorsa Durum Pasif yapılır.')}</div>
            </div>
          </div>
        )}
      </div>

      <div className="bsk-sag">
        <div className="bsk-grp">
          <h6>{c('Önizleme')} <span className="sonuk">{c('örnek değerlerle')}</span></h6>
          {sms ? (
            <div className="bsk-telefon">
              <div className="bsk-tel-ust"><b>{ozet?.gonderen || c('Gönderen')}</b>
                <small>{c('gönderen başlığı')}{ozet?.hesap ? ` · ${ozet.hesap}` : ''}</small></div>
              <div className="bsk-tel-ic">
                <div className="bsk-balon">{govde ? vurgula(govde, degerler) : <span className="sonuk">{c('Gövde boş')}</span>}</div>
                <div className="bsk-tel-alt">{olcu.adet} {c('parça')}</div>
              </div>
            </div>
          ) : (
            <div className="bsk-eposta">
              <div className="bsk-ep-konu"><small>{c('Konu')}</small><b>{konu ? vurgula(konu, degerler) : '—'}</b></div>
              <div className="bsk-ep-govde">{govde ? vurgula(govde, degerler) : <span className="sonuk">{c('Gövde boş')}</span>}</div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export function DegiskenlerSekmesi({ id, deger }: { id: number; deger: Deger }) {
  const ozet = useOzet(id);
  const govde = String(deger.govde ?? '') + ' ' + String(deger.konu ?? '');
  const metinde = metindekiDegiskenler(govde).map(a => a.toLowerCase());
  if (!ozet) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  const satirlar = Object.entries(ozet.degiskenler);
  return (
    <div className="bsk-degiskenler">
      <div className="not">{c('Şablonun kabul ettiği değişkenler. Değeri program üretir; kuruma özel değişken eklenemez.')}</div>
      <table className="detay-tablo">
        <thead><tr><th>{c('Değişken')}</th><th>{c('Yazımı')}</th><th>{c('Açıklama')}</th><th>{c('Örnek değer')}</th><th>{c('Metinde')}</th></tr></thead>
        <tbody>
          {satirlar.length === 0 && <tr><td colSpan={5} className="sonuk">{c('Bu şablonun değişkeni yok.')}</td></tr>}
          {satirlar.map(([ad, aciklama]) => (
            <tr key={ad}>
              <td><b>{ad}</b></td>
              <td className="mono">{ad === ad.toUpperCase() ? `@${ad} · {{${ad.toLowerCase()}}}` : `{{${ad}}}`}</td>
              <td>{aciklama}</td>
              <td className="mono">{ornekDeger(ad)}</td>
              <td>{metinde.includes(ad.toLowerCase())
                ? <span className="rozet olumlu">✓ {c('var')}</span> : <span className="rozet gri">{c('yok')}</span>}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function GonderimGecmisiSekmesi({ id }: { id: number }) {
  return (
    <GenGrid kaynak="bildirim" gomulu seritGizli boyut={50}
             sabitFiltre={{ alan: 'sablonId', op: 'esit', deger: id }}
             gizliKolonlar={['sablonAdi']} />
  );
}

export function DegisiklikGecmisiSekmesi({ id }: { id: number }) {
  return (
    <GenGrid kaynak="islem-log" gomulu seritGizli boyut={50}
             sabitFiltre={{ op: 'and', kosullar: [{ alan: 'tabloId', op: 'esit', deger: 1287 }, { alan: 'kayitId', op: 'esit', deger: id }] }}
             gizliKolonlar={['modul', 'kod', 'ad', 'ip', 'kayitId']} />
  );
}

/** Araç çubuğu: 🧪 Deneme Gönder + pencere. */
export function DenemeGonderDugmesi({ id, deger }: { id: number; deger: Deger }) {
  const [acik, setAcik] = useState(false);
  return (
    <>
      <button type="button" className="d" title={c('Kendi numarana / adresine örnek değerlerle gerçek gönderim')}
              onClick={() => setAcik(true)}>🧪 {c('Deneme Gönder')}</button>
      {acik && <DenemeGonderPenceresi id={id} deger={deger} onKapat={() => setAcik(false)} />}
    </>
  );
}

function DenemeGonderPenceresi({ id, deger, onKapat }: { id: number; deger: Deger; onKapat(): void }) {
  const ozet = useOzet(id);
  const govde = String(deger.govde ?? '');
  const sms = Number(deger.kanal ?? 1) === 1;
  const [alici, setAlici] = useState('');
  const [degerler, setDegerler] = useState<Record<string, string>>({});
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  useEffect(() => { setDegerler(ornekler(ozet, govde)) }, [ozet, govde]);
  const olcu = smsOlc(sablonDoldur(govde, degerler));

  const gonderIste = async () => {
    if (!alici.trim()) { setHata(sms ? c('Cep telefonunu girin.') : c('E-posta adresini girin.')); return }
    setMesgul(true); setHata(null);
    try {
      await api.bildirimSablonDeneme(id, alici.trim(), degerler);
      onKapat();
      mesaj(c('Deneme kuyruğa alındı; birkaç saniye içinde gider. Sonucu Gönderim Geçmişi sekmesinde görebilirsiniz.'));
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };

  return (
    <Modal baslik={`🧪 ${c('Deneme Gönder')} — ${String(deger.ad ?? '')}`} dar enUst onKapat={onKapat}
           alt={<>
             <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
             <button type="button" className="d bir" disabled={mesgul} onClick={() => void gonderIste()}>📤 {c('Gönder')}</button>
           </>}>
      <div className="alan-izgara" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <label className="alan">
          <span className="etiket">{sms ? c('Alıcı cep telefonu') : c('Alıcı e-posta')} *</span>
          <input value={alici} autoFocus onChange={e => setAlici(e.target.value)}
                 placeholder={sms ? '+90 5__ ___ __ __' : 'ad@ornek.com'} />
        </label>
        <label className="alan">
          <span className="etiket">{c('Hesap')}</span>
          <input value={ozet?.hesap || '—'} readOnly tabIndex={-1} className="salt-okunur" />
        </label>
        {Object.keys(degerler).map(ad => (
          <label className="alan" key={ad}>
            <span className="etiket">{yazim(ad)} {c('örnek değeri')}</span>
            <input value={degerler[ad]} onChange={e => setDegerler(d => ({ ...d, [ad]: e.target.value }))} />
          </label>
        ))}
      </div>
      <div className="bsk-uy s" style={{ marginTop: 10 }}>⚠ <span>{c('Gerçek gönderimdir')}{sms ? <>: <b>{olcu.adet} SMS</b> {c('kontörü düşer')}</> : ''}.
        {' '}{c('Saat penceresi deneme gönderiminde de uygulanır. Hiçbir kayda kod / onay yazılmaz.')}</span></div>
      {hata && <div className="hata-kutusu" style={{ marginTop: 8 }}>{hata}</div>}
    </Modal>
  );
}
