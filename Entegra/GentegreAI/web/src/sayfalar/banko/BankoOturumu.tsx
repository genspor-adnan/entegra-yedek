import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import {
  FARK_NEDENLERI, KUPURLER,
  type KupurSatiri, type OturumOzeti, type UygunBanko,
} from '../../api/uclar/bankoOturum';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * BANKO OTURUMU `/banko-oturum` (987) — mockup
 * Ekranlar/Kayıt Kabul/banko_oturum_akisi_v2.html.
 *
 * Altı adımın tamamı TEK sayfada, oturumun durumuna göre: açılış talebi →
 * (ops.) sorumlu onayı → devir sayımı → gün içi şerit → gün sonu sayımı →
 * teslim ve kapanış. Ayrı ekranlara bölmek, görevliyi "şimdi hangi ekranda
 * olmalıyım" sorusuyla baş başa bırakırdı; akış şeridi hangi adımda
 * olunduğunu söylüyor.
 *
 * DEVİR SUNUCUDAN GELİR ve yazılamaz (`fn_banko_devir`): önceki oturumun
 * kasada bıraktığı tutar. Görevli yalnız SAYIMI girer, farkı sunucu hesaplar.
 *
 * KUPÜR DÖKÜMÜ toplamı sayım alanını besler: "7.140 saydım" ile
 * "20x200 + 22x100 + …" denetimde aynı şey değil. Bankoda kupür dökümü
 * kapalıysa (banko ayarı) tutar elle girilir.
 */
const ADIMLAR = [
  'Oturum talebi', 'Sorumlu onayı', 'Devir sayımı',
  'Gün içi işlem', 'Gün sonu sayım', 'Teslim & kapanış',
];

/**
 * Oturum durumundan akış şeridindeki etkin adım (1 tabanlı). `gunSonu` formu
 * açıkken 5. adım gösterilir: durum hâlâ "açık" ama görevli artık sayımda.
 */
function etkinAdim(o: OturumOzeti | null, gunSonu = false): number {
  if (!o) return 1;
  if (o.durum === 1) return 2;
  if (o.durum === 2) return gunSonu ? 5 : 4;
  if (o.durum === 3) return 6;
  if (o.durum === 4) return 6;
  return 1;                                    // reddedildi: baştan
}

const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const saat = (t: string | null) =>
  t ? new Date(t).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';

export function BankoOturumu() {
  const { yetki } = useOturum();
  const [oturum, setOturum] = useState<OturumOzeti | null>(null);
  const [bankolar, setBankolar] = useState<UygunBanko[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);

  // açılış formu
  const [bankoId, setBankoId] = useState(0);
  const [vardiya, setVardiya] = useState('');
  const [acilisKupur, setAcilisKupur] = useState<Record<number, string>>({});
  const [acilisTutar, setAcilisTutar] = useState('');
  const [acilisNot, setAcilisNot] = useState('');

  // gün sonu formu
  const [gunSonu, setGunSonu] = useState(false);
  const [kapanisKupur, setKapanisKupur] = useState<Record<number, string>>({});
  const [kapanisTutar, setKapanisTutar] = useState('');
  const [farkNeden, setFarkNeden] = useState(0);
  const [farkAciklama, setFarkAciklama] = useState('');
  const [birakilan, setBirakilan] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.bankoOturumAktif();
      setOturum(y.oturum);
      if (!y.oturum) {
        const b = await api.bankoOturumUygun();
        setBankolar(b);
        setBankoId(p => (p && b.some(x => x.id === p) ? p : b[0]?.id ?? 0));
      }
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);
  // ONAY BEKLERKEN KENDİLİĞİNDEN TAZELENİR: görevli ekranı yenilemek için
  //   beklemesin - onay gelince gün içi şeride kendisi geçer.
  useEffect(() => {
    if (oturum?.durum !== 1 && oturum?.durum !== 3) return;
    const t = setInterval(() => void yukle(), 15000);
    return () => clearInterval(t);
  }, [oturum?.durum, yukle]);

  const secili = useMemo(() => bankolar.find(b => b.id === bankoId) ?? null, [bankolar, bankoId]);

  const kupurToplam = (k: Record<number, string>) =>
    KUPURLER.reduce((t, b) => t + b * (parseInt(k[b] ?? '', 10) || 0), 0);
  const kupurListe = (k: Record<number, string>): KupurSatiri[] =>
    KUPURLER.map(b => ({ birim: b, adet: parseInt(k[b] ?? '', 10) || 0 })).filter(x => x.adet > 0);

  const acilisSayim = secili?.kupurDokumu ? kupurToplam(acilisKupur) : (parseFloat(acilisTutar.replace(',', '.')) || 0);
  const acilisFark = secili ? acilisSayim - secili.devir : 0;

  const kapanisSayim = oturum?.kupurDokumu ? kupurToplam(kapanisKupur) : (parseFloat(kapanisTutar.replace(',', '.')) || 0);
  const beklenen = oturum?.beklenenNakit ?? 0;
  const kapanisFark = kapanisSayim - beklenen;
  const birakilanSayi = parseFloat((birakilan || '').replace(',', '.')) || 0;

  const ac = () => guvenli(async () => {
    const y = await api.bankoOturumAc({
      bankoId, vardiya, acilisSayim, not: acilisNot,
      kupurler: secili?.kupurDokumu ? kupurListe(acilisKupur) : undefined,
    });
    setOturum(y.oturum); if (y.mesaj) mesaj(y.mesaj);
  });

  const gunSonuGonder = () => guvenli(async () => {
    if (!oturum) return;
    const y = await api.bankoOturumGunSonu(oturum.id, {
      kapanisSayim,
      farkNeden: kapanisFark !== 0 ? farkNeden : undefined,
      farkAciklama: kapanisFark !== 0 ? farkAciklama : undefined,
      kasadaBirakilan: birakilanSayi,
      kupurler: oturum.kupurDokumu ? kupurListe(kapanisKupur) : undefined,
    });
    setOturum(y.oturum); setGunSonu(false); if (y.mesaj) mesaj(y.mesaj);
  });

  const yenidenAc = () => guvenli(async () => {
    if (!oturum) return;
    if (!(await onay('Kapanmış oturum yeniden açılacak. Gerekçe loga yazılır.'))) return;
    const y = await api.bankoOturumYenidenAc(oturum.id, 'Yanlış kapatıldı');
    setOturum(y.oturum);
  });

  if (yukleniyor) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;

  const adim = etkinAdim(oturum, gunSonu);
  return (
    <div className="fm-sayfa bo-sayfa">
      <style>{bostil}</style>
      <div className="bo-baslik">
        <h2>🏦 Banko Oturumu</h2>
        {oturum && (
          <span className="bo-ust">
            {oturum.bankoKod} · {oturum.bankoAd} · {oturum.gorevli}
            {oturum.vardiya ? ` · ${oturum.vardiya}` : ''}
          </span>
        )}
      </div>

      <div className="bo-akis">
        {ADIMLAR.map((a, i) => (
          <div key={a} className={'bo-ad' + (i + 1 === adim ? ' simdi' : i + 1 < adim ? ' bitti' : '')}>
            <span className="no">{i + 1}</span>{a}
            {i === 1 && <span className="bo-rz mavi">ops.</span>}
          </div>
        ))}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* ---------------------------------------------------- 1 · AÇILIŞ --- */}
      {!oturum && (
        bankolar.length === 0 ? (
          <div className="bo-bos">
            Bu şubede oturum açılabilecek banko yok. Bankolar pasif olabilir, hepsinde
            açık oturum olabilir ya da yalnız danışma bankosu tanımlıdır (danışmada
            kasa yoktur, oturum beklenmez).
          </div>
        ) : (
          <div className="bo-kutu">
            <div className="bo-kb">Açılış talebi</div>
            <div className="bo-izgara">
              <label>Banko *
                <select value={bankoId} onChange={e => setBankoId(Number(e.target.value))}>
                  {bankolar.map(b => (
                    <option key={b.id} value={b.id}>
                      {b.kod} — {b.ad}{b.konum ? ` (${b.konum})` : ''}
                    </option>
                  ))}
                </select>
              </label>
              <label>Vardiya
                <input value={vardiya} onChange={e => setVardiya(e.target.value)}
                       placeholder="Sabah · 08:00–16:00" />
              </label>
              <label>Kasa hesabı
                <input readOnly value={secili?.hesap || '—'} />
              </label>
              <label>Sistem devri
                <input readOnly className="bo-buyuk" value={para(secili?.devir ?? 0) + ' ₺'} />
              </label>
            </div>
            <div className="bo-not">
              Sistem devri <b>önceki oturumun kapanış bakiyesidir</b> ve elle
              değiştirilemez. Sayım farklıysa fark kapanışta değil <b>açılışta</b>
              yazılır - sonraki görevli başkasının farkını devralmasın.
            </div>

            {secili?.kupurDokumu ? (
              <KupurTablosu deger={acilisKupur} degistir={setAcilisKupur} toplam={acilisSayim} />
            ) : (
              <div className="bo-izgara">
                <label>Kasada bulunan (sayım)
                  <input value={acilisTutar} onChange={e => setAcilisTutar(e.target.value)}
                         className="bo-buyuk" placeholder="0,00" />
                </label>
              </div>
            )}

            <div className="bo-izgara">
              <label>Fark
                <input readOnly className={'bo-buyuk' + (acilisFark !== 0 ? ' bo-kir' : '')}
                       value={para(acilisFark) + ' ₺'} />
              </label>
              <label className="bo-genis">Not{acilisFark !== 0 ? ' (fark var - açıklayın)' : ''}
                <input value={acilisNot} onChange={e => setAcilisNot(e.target.value)} />
              </label>
            </div>

            <div className="bo-dugmeler">
              <button className="bo-ana" onClick={ac} disabled={!bankoId}>
                {secili?.acilisOnay ? '📨 Onaya Gönder' : '🔓 Oturumu Aç'}
              </button>
              <span className="bo-not">
                {secili?.acilisOnay
                  ? 'Bu bankoda açılış sorumlu onayı istiyor; onay gelene kadar tahsilat girilemez.'
                  : 'Bu bankoda açılış onayı kapalı - devri sayıp doğrudan açılır.'}
              </span>
            </div>
          </div>
        )
      )}

      {/* ------------------------------------- 2 · AÇILIŞ ONAYI BEKLENİYOR -- */}
      {oturum?.durum === 1 && (
        <div className="bo-kutu bo-bekle">
          <div className="bo-kb">⏳ Açılış onayı bekleniyor</div>
          <div className="bo-ic">
            Oturum <b>#{oturum.id}</b> sorumluya gönderildi ({saat(oturum.acilisTalepTs)}).
            Onay gelene kadar bu bankoda
            <b> tahsilat ve başvuru kaydı yapılamaz</b>; hasta kaydı ve randevu
            görüntüleme açık kalır - para hareketi olmayan işler beklemesin.
            <div className="bo-not">Devir {para(oturum.devirTutar)} · sayım{' '}
              {para(oturum.acilisSayim)} · fark{' '}
              <b className={oturum.acilisFark !== 0 ? 'bo-kir' : ''}>{para(oturum.acilisFark)}</b>
            </div>
          </div>
        </div>
      )}

      {oturum?.durum === 5 && (
        <div className="bo-kutu">
          <div className="bo-kb bo-kir">✖ Açılış reddedildi</div>
          <div className="bo-ic">{oturum.redNeden || '—'}
            <div className="bo-not">Yeni talep için sayfayı yenileyin.</div></div>
        </div>
      )}

      {/* ------------------------------------------------- 3 · GÜN İÇİ ----- */}
      {oturum && (oturum.durum === 2 || oturum.durum === 3 || oturum.durum === 4) && (
        <div className="bo-serit">
          <span>🔓 Oturum <b>#{oturum.id}</b></span>
          <div className="bo-k"><span>devir</span><b>{para(oturum.devirTutar)}</b></div>
          {oturum.acilisFark !== 0 && (
            <div className="bo-k"><span>açılış farkı</span><b>{para(oturum.acilisFark)}</b></div>
          )}
          <div className="bo-k"><span>nakit tahsilat</span><b>+{para(oturum.nakitTahsilat)}</b></div>
          <div className="bo-k"><span>nakit iade</span><b>−{para(oturum.nakitIade)}</b></div>
          <div className="bo-k vurgu"><span>kasada olması gereken</span><b>{para(oturum.beklenenNakit)}</b></div>
          <div className="bo-k"><span>POS</span><b>{para(oturum.posTutar)}</b></div>
          <div className="bo-k"><span>işlem</span><b>{oturum.islemAdet}</b></div>
          {oturum.durum === 2 && (
            <button className="bo-ana bo-sag" onClick={() => {
              setGunSonu(true);
              // Önerilen bırakma tutarı banko tanımından gelir; görevli değiştirebilir.
              // ÖNERİ SAYIMI AŞMAZ: hedef 1.000 ama kasada 400 varsa öneri 400.
              //   Aşan öneri her gün elle düzeltilmek zorunda kalırdı.
              setBirakilan(String(Math.min(oturum.bankoDevirHedef || 0,
                                           oturum.beklenenNakit || 0)));
            }}>🔒 Gün Sonu</button>
          )}
        </div>
      )}

      {oturum?.durum === 2 && !gunSonu && (
        <div className="bo-not bo-ic">
          POS ve havale kasada <b>para olarak durmaz</b>: gün sonu sayımı yalnız nakit
          üzerindendir, mutabakatı banka ekstresi yapar.
        </div>
      )}

      {/* ------------------------------------------------ 4 · GÜN SONU ----- */}
      {oturum?.durum === 2 && gunSonu && (
        <div className="bo-kutu">
          <div className="bo-kb">Gün sonu — kasa sayımı</div>
          <div className="bo-iki">
            <div>
              <div className="bo-kb2">Sistem — kasada olması gereken</div>
              <table className="bo-tablo">
                <tbody>
                  <tr><td>Devir (açılış)</td><td>{para(oturum.devirTutar)}</td></tr>
                  {oturum.acilisFark !== 0 && (
                    <tr><td>Açılış farkı</td><td>{para(oturum.acilisFark)}</td></tr>
                  )}
                  <tr><td>Nakit tahsilat</td><td>+{para(oturum.nakitTahsilat)}</td></tr>
                  <tr><td>Nakit iade</td><td>−{para(oturum.nakitIade)}</td></tr>
                  <tr className="top"><td>Olması gereken nakit</td><td>{para(beklenen)}</td></tr>
                  <tr className="sonuk"><td>POS (bilgi — kasada değil)</td><td>{para(oturum.posTutar)}</td></tr>
                  <tr className="sonuk"><td>Havale / EFT</td><td>{para(oturum.bankaTutar)}</td></tr>
                </tbody>
              </table>
            </div>
            <div>
              <div className="bo-kb2">Sayım{oturum.kupurDokumu ? ' — kupür dökümü' : ''}</div>
              {oturum.kupurDokumu
                ? <KupurTablosu deger={kapanisKupur} degistir={setKapanisKupur} toplam={kapanisSayim} />
                : <label className="bo-tek">Sayılan nakit
                    <input value={kapanisTutar} onChange={e => setKapanisTutar(e.target.value)}
                           className="bo-buyuk" placeholder="0,00" /></label>}
              <div className="bo-izgara">
                <label>Sayılan<input readOnly className="bo-buyuk" value={para(kapanisSayim)} /></label>
                <label>Olması gereken<input readOnly className="bo-buyuk" value={para(beklenen)} /></label>
                <label>Fark
                  <input readOnly className={'bo-buyuk' + (kapanisFark !== 0 ? ' bo-kir' : '')}
                         value={para(kapanisFark)} /></label>
              </div>
            </div>
          </div>

          {kapanisFark !== 0 && (
            <div className="bo-uyari">
              ⚠ <b>Fark var: {para(Math.abs(kapanisFark))} ₺ {kapanisFark < 0 ? 'noksan' : 'fazla'}.</b>{' '}
              Teslim için <b>neden ve açıklama zorunlu</b> - fark ayrı fişle muhasebeleşir,
              kasa bakiyesi sayımla eşitlenir ve fark geçmişi bozulmaz.
            </div>
          )}
          {kapanisFark !== 0 && (
            <div className="bo-izgara">
              <label>Fark nedeni *
                <select value={farkNeden} onChange={e => setFarkNeden(Number(e.target.value))}>
                  <option value={0}>— seçin —</option>
                  {FARK_NEDENLERI.map(f => <option key={f.kod} value={f.kod}>{f.ad}</option>)}
                </select>
              </label>
              <label className="bo-genis">Açıklama *
                <input value={farkAciklama} onChange={e => setFarkAciklama(e.target.value)} />
              </label>
            </div>
          )}

          <div className="bo-izgara">
            <label>Kasada bırakılan (yarının devri)
              <input value={birakilan} onChange={e => setBirakilan(e.target.value)} className="bo-buyuk" />
            </label>
            <label>Teslim edilecek
              <input readOnly className="bo-buyuk"
                     value={para(Math.max(0, kapanisSayim - birakilanSayi))} />
            </label>
          </div>
          <div className="bo-not">
            Bırakılan tutar <b>sonraki oturumun devri</b> olur; kalanı için kasa çıkış
            fişi üretilir. Sayılan nakitten fazla bırakılamaz - olmayan parayı yarına
            devretmek ertesi gün hazır fark üretirdi.
            {birakilanSayi > kapanisSayim && (
              <b className="bo-kir"> Bırakılan ({para(birakilanSayi)}) sayılandan
                ({para(kapanisSayim)}) fazla; önce sayımı ya da bu tutarı düzeltin.</b>
            )}
          </div>

          <div className="bo-dugmeler">
            <button className="bo-ana" onClick={gunSonuGonder}
                    disabled={(kapanisFark !== 0 && (!farkNeden || !farkAciklama.trim()))
                              || birakilanSayi > kapanisSayim}>
              {oturum.gunSonuOnay ? '📨 Teslime Gönder (onaya)' : '🔒 Oturumu Kapat'}
            </button>
            <button onClick={() => setGunSonu(false)}>↻ Vazgeç</button>
            <span className="bo-not">
              {oturum.gunSonuOnay
                ? 'Sayım kaydedilir ve sorumlu onayına gider; onaya kadar tahsilat girilemez.'
                : 'Bu bankoda gün sonu onayı kapalı - sayım kaydedilince oturum kapanır.'}
            </span>
          </div>
        </div>
      )}

      {/* ----------------------------------- 5-6 · TESLİM VE KAPANIŞ ------- */}
      {oturum && (oturum.durum === 3 || oturum.durum === 4) && (
        <div className="bo-kutu">
          <div className="bo-kb">
            {oturum.durum === 3 ? '⏳ Teslim tutanağı — kapanış onayı bekliyor' : '✔ Oturum kapandı'}
            {oturum.tutanakNo && <span className="bo-rz mavi">{oturum.tutanakNo}</span>}
          </div>
          <div className="bo-izgara">
            <label>Teslim eden<input readOnly value={`${oturum.gorevli} · ${saat(oturum.kapanisTalepTs)}`} /></label>
            <label>Teslim edilen nakit<input readOnly className="bo-buyuk" value={para(oturum.teslimEdilen) + ' ₺'} /></label>
            <label>Kasada bırakılan<input readOnly className="bo-buyuk" value={para(oturum.kasadaBirakilan) + ' ₺'} /></label>
            <label>Fark
              <input readOnly className={'bo-buyuk' + (oturum.kapanisFark !== 0 ? ' bo-kir' : '')}
                     value={para(oturum.kapanisFark) + ' ₺'} /></label>
          </div>
          <div className="bo-iki">
            <div>
              <div className="bo-kb2">Oturum özeti</div>
              <div className="bo-ic">
                <div>Açılış · {saat(oturum.acilisTs)} {oturum.acilisOnayId ? <span className="bo-rz ok">onaylı</span> : null}</div>
                <div>Devir <b>{para(oturum.devirTutar)}</b> · işlem <b>{oturum.islemAdet}</b></div>
                <div>Nakit <b>{para(oturum.nakitTahsilat)}</b> · iade <b>−{para(oturum.nakitIade)}</b></div>
                <div>POS <b>{para(oturum.posTutar)}</b> · havale <b>{para(oturum.bankaTutar)}</b></div>
                <div>Sayım <b>{para(oturum.kapanisSayim)}</b> · beklenen <b>{para(oturum.kapanisBeklenen)}</b></div>
                {oturum.farkAciklama && <div className="bo-not">Fark: {oturum.farkAciklama}</div>}
              </div>
            </div>
            <div>
              <div className="bo-kb2">İmza / onay</div>
              <div className="bo-ic">
                <div><span className="bo-rz ok">✔</span> Teslim eden · {oturum.gorevli}</div>
                <div>
                  {oturum.kapanisOnayId
                    ? <><span className="bo-rz ok">✔</span> Teslim alan · onaylandı {saat(oturum.kapanisTs)}</>
                    : <><span className="bo-rz sari">⏳</span> Teslim alan · bekliyor</>}
                </div>
                <div className="bo-not">
                  {oturum.durum === 3
                    ? 'Onay gelince oturum kapanır; bankoda tahsilat girilemez, yeni gün yeni oturumla başlar.'
                    : 'Kapanan oturum düzeltilmez: hatalı tahsilat iade/düzeltme fişiyle çözülür.'}
                </div>
              </div>
            </div>
          </div>
          {oturum.durum === 4 && yetki('banko_oturum.yeniden_ac') && (
            <div className="bo-dugmeler">
              <button onClick={yenidenAc}>🔓 Yeniden Aç</button>
              <span className="bo-not">Ayrı yetki ister; gerekçe loga yazılır.</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

/** Kupür dökümü: adet girilir, tutar ve toplam kendiliğinden hesaplanır. */
function KupurTablosu({ deger, degistir, toplam }: {
  deger: Record<number, string>;
  degistir: (f: (o: Record<number, string>) => Record<number, string>) => void;
  toplam: number;
}) {
  return (
    <table className="bo-tablo bo-kupur">
      <thead><tr><th>Kupür</th><th>Adet</th><th>Tutar</th></tr></thead>
      <tbody>
        {KUPURLER.map(b => {
          const adet = parseInt(deger[b] ?? '', 10) || 0;
          return (
            <tr key={b}>
              <td>{b === 1 ? 'Bozuk (₺)' : `${b} ₺`}</td>
              <td><input value={deger[b] ?? ''} inputMode="numeric"
                         onChange={e => degistir(o => ({ ...o, [b]: e.target.value }))} /></td>
              <td>{para(b * adet)}</td>
            </tr>
          );
        })}
        <tr className="top"><td>Toplam</td><td /><td>{para(toplam)}</td></tr>
      </tbody>
    </table>
  );
}

const bostil = `
/* KIRPILMA (kullanici: "alt taraf kirpilmis goremiyorum"): .fm-sayfa
   display:flex / column. Flex cocuklarin varsayilan flex-shrink:1 degeri
   kutulari pencereye SIGDIRMAYA calisiyor, kutu kendi icerigini kirpiyor ve
   toplam tasma olusmadigi icin scroll da cikmiyordu - alt kisim erisilemez
   kaliyordu. Bu akis ekrani uzun formlardan olusuyor; blok akisa dondurup
   kaydirmayi sayfanin kendisine veriyoruz. */
.bo-sayfa { display: block; height: 100%; overflow-y: auto; padding: 14px 16px 24px; }
.bo-baslik { display:flex; align-items:baseline; gap:12px; flex-wrap:wrap; margin-bottom:10px; }
.bo-baslik h2 { margin:0; font-size:17px; }
.bo-ust { color: var(--ikincil-metin, #6b7a8b); font-size:12px; }
.bo-akis { display:flex; gap:6px; flex-wrap:wrap; margin-bottom:12px; }
.bo-ad { display:flex; align-items:center; gap:6px; border:1px solid var(--cizgi, #cdd6e0);
  border-radius:14px; padding:3px 11px; font-size:11.5px; background:var(--kart, #fff);
  color: var(--ikincil-metin, #6b7a8b); }
.bo-ad .no { width:16px; height:16px; border-radius:50%; background:#e7edf4; color:#4d5d6e;
  display:inline-flex; align-items:center; justify-content:center; font-size:10px; }
.bo-ad.simdi { border-color:#2f6db3; color:#1b4f87; font-weight:bold; background:#eef4fc; }
.bo-ad.simdi .no { background:#2f6db3; color:#fff; }
.bo-ad.bitti .no { background:#cfe6d6; color:#2e7d46; }
.bo-rz { display:inline-block; border-radius:9px; padding:0 7px; font-size:10.5px;
  border:1px solid var(--cizgi, #cdd6e0); }
.bo-rz.mavi { background:#eef4fc; color:#2f6db3; border-color:#cfe0f5; }
.bo-rz.ok { background:#e2f3e8; color:#2e7d46; border-color:#bfe3cb; }
.bo-rz.sari { background:#fdf6e3; color:#8a6218; border-color:#f2ddbf; }
.bo-kutu { border:1px solid var(--cizgi, #cdd6e0); border-radius:6px; background:var(--kart, #fff);
  margin-bottom:12px; }
.bo-kb { background:var(--baslik-arka, #f3f6fa); border-bottom:1px solid var(--cizgi, #cdd6e0);
  padding:7px 11px; font-weight:bold; font-size:12.5px; display:flex; gap:10px; align-items:center; }
.bo-kb2 { font-weight:bold; font-size:12px; margin:8px 0 4px; color:#2c4a6b; }
.bo-ic { padding:9px 11px; font-size:12px; line-height:1.7; }
.bo-izgara { display:grid; grid-template-columns:repeat(auto-fit, minmax(190px, 1fr)); gap:8px 12px;
  padding:9px 11px; }
.bo-izgara label, .bo-tek { display:flex; flex-direction:column; gap:3px; font-size:11px;
  color: var(--ikincil-metin, #6b7a8b); }
.bo-izgara .bo-genis { grid-column: span 2; }
.bo-izgara input, .bo-izgara select, .bo-tek input { border:1px solid var(--cizgi, #cdd6e0);
  border-radius:4px; padding:5px 7px; font-size:12.5px; background:var(--giris-arka, #fff);
  color: var(--metin, #1f2d3a); }
.bo-izgara input[readonly], .bo-tek input[readonly] { background:#f6f8fa; }
.bo-buyuk { font-family: Consolas, monospace; font-weight:bold; text-align:right; }
.bo-kir { color:#b3261e; }
.bo-not { color: var(--ikincil-metin, #6b7a8b); font-size:11px; line-height:1.6; padding:0 11px 9px; }
.bo-dugmeler { display:flex; gap:8px; align-items:center; padding:9px 11px; flex-wrap:wrap;
  border-top:1px solid var(--cizgi-ince, #e3e9f0); }
.bo-dugmeler button { border:1px solid var(--cizgi, #cdd6e0); border-radius:4px; padding:6px 12px;
  font-size:12px; background:var(--kart, #fff); cursor:pointer; }
.bo-ana { border-color:#2f6db3 !important; background:linear-gradient(#4d8fd6,#2f6db3) !important;
  color:#fff !important; font-weight:bold; }
.bo-ana:disabled { opacity:.5; cursor:default; }
.bo-serit { display:flex; gap:10px; align-items:center; flex-wrap:wrap; padding:8px 11px;
  border:1px solid #cfe0f5; background:#eef4fc; border-radius:6px; margin-bottom:10px; font-size:12px; }
.bo-k { display:flex; flex-direction:column; border-left:1px solid #cfe0f5; padding-left:10px; }
.bo-k span { font-size:10.5px; color:#5c7ba3; }
.bo-k b { font-family: Consolas, monospace; }
.bo-k.vurgu b { color:#1b4f87; font-size:14px; }
.bo-sag { margin-left:auto; }
.bo-iki { display:grid; grid-template-columns:repeat(auto-fit, minmax(300px, 1fr)); gap:12px;
  padding:0 11px 9px; }
.bo-tablo { border-collapse:collapse; width:100%; font-size:12px; }
.bo-tablo td, .bo-tablo th { border-bottom:1px solid var(--cizgi-ince, #e3e9f0); padding:4px 7px; }
.bo-tablo td:last-child, .bo-tablo th:last-child { text-align:right; font-family:Consolas, monospace; }
.bo-tablo tr.top td { font-weight:bold; background:#f7f9fc; }
.bo-tablo tr.sonuk td { color: var(--ikincil-metin, #6b7a8b); }
.bo-kupur input { width:70px; border:1px solid var(--cizgi, #cdd6e0); border-radius:3px;
  padding:3px 6px; text-align:right; font-family:Consolas, monospace;
  background:var(--giris-arka, #fff); color: var(--metin, #1f2d3a); }
.bo-uyari { display:flex; gap:8px; align-items:center; padding:7px 11px; background:#fbe9e7;
  border-top:1px solid #f3c4bf; border-bottom:1px solid #f3c4bf; color:#8c1d18; font-size:12px; }
.bo-bekle .bo-kb { background:#fdf6e3; border-color:#f2ddbf; color:#7a5612; }
.bo-bos { border:1px dashed var(--cizgi, #cdd6e0); border-radius:6px; padding:16px;
  color: var(--ikincil-metin, #6b7a8b); font-size:12.5px; line-height:1.7; }
@media (prefers-color-scheme: dark) {
  :root:not([data-tema="acik"]) .bo-tablo tr.top td { background: rgba(255,255,255,.04); }
  :root:not([data-tema="acik"]) .bo-izgara input[readonly] { background: rgba(255,255,255,.04); }
  :root:not([data-tema="acik"]) .bo-serit { background: rgba(79,140,210,.12); border-color:#2f5882; }
  :root:not([data-tema="acik"]) .bo-kb { background: rgba(255,255,255,.04); }
}
`;

export default BankoOturumu;
