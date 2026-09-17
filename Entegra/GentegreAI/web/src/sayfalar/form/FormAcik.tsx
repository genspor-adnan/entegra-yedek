import { useCallback, useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';
import { formAcik, type AcikOturum, type AcikOzet, type FormCevap, type FormImza } from '../../api/uclar/form';
import { FormCizici, skorHesapla, zorunluEksikler } from '../../bilesenler/form/FormCizici';
import { ImzaKanvas } from '../../bilesenler/form/ImzaKanvas';

/**
 * AÇIK FORM SAYFASI `/f/{kod}` (form motoru 740) — hastanın / çalışanın
 * telefonunda ya da kioskta açılan bağlantı. Oturum YOK; kimlik kanıtı TCKN
 * son 4 + doğum yılı, ardından 30 dk oturum anahtarı. Adımlar: karşılama &
 * doğrulama → bölümler (biri bir ekran, taslak otomatik) → özet & beyan →
 * teşekkür. Mockup Ekranlar/ISG/isg_calisan_formu.html (telefon sütunu).
 */
export function FormAcik() {
  const { kod = '' } = useParams();
  const [ozet, setOzet] = useState<AcikOzet | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [son4, setSon4] = useState('');
  const [yil, setYil] = useState('');
  const [riza, setRiza] = useState(false);
  const [ot, setOt] = useState<AcikOturum | null>(null);
  const [adim, setAdim] = useState(0);            // 0..n-1 bölüm, n = özet
  const [cevap, setCevap] = useState<FormCevap>({});
  const [imza, setImza] = useState<string | undefined>();
  const [beyan, setBeyan] = useState(false);
  const [bitti, setBitti] = useState<{ durum: number; skor?: number | null; sonuc?: string } | null>(null);
  const [mesajM, setMesajM] = useState<string | null>(null);
  const [kaydediliyor, setKaydediliyor] = useState(false);
  const zamanlayici = useRef<number | null>(null);

  useEffect(() => {
    document.title = 'GenoTIP AI · Form';
    formAcik.ozet(kod).then(setOzet).catch(h => setHata(h instanceof Error ? h.message : String(h)));
  }, [kod]);

  const dogrula = async () => {
    setHata(null);
    try {
      const y = await formAcik.dogrula(kod, son4, yil);
      setOt(y); setCevap(y.taslak ?? {}); setAdim(0);
    } catch (h) { setHata(h instanceof Error ? h.message : String(h)) }
  };

  // Taslak: her değişiklikten 1,5 sn sonra sunucuya (kaldığı yerden devam).
  const taslakKaydet = useCallback((c: FormCevap) => {
    if (!ot) return;
    if (zamanlayici.current) window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => { void formAcik.taslak(kod, ot.oturum, c).catch(() => {}) }, 1500);
  }, [kod, ot]);
  const degistir = (k: string, v: unknown) => setCevap(c => { const y = { ...c, [k]: v }; taslakKaydet(y); return y });

  const bolumler = ot?.tanim.bolumler ?? [];
  const ozetAdimi = bolumler.length;
  const imzaZorunlu = ot?.tanim.imzalar?.some(i => (i.rol === 'hasta' || i.rol === 'calisan') && i.yontem.includes(1) && i.zorunlu);

  const ileri = () => {
    if (!ot) return;
    const b = bolumler[adim];
    const eksik = zorunluEksikler([b], cevap);
    if (eksik.length) { setMesajM('Zorunlu alanlar boş: ' + eksik.join(', ')); return }
    setMesajM(null); setAdim(a => a + 1); window.scrollTo(0, 0);
  };
  const gonder = async () => {
    if (!ot) return;
    const eksik = zorunluEksikler(bolumler, cevap);
    if (eksik.length) { setMesajM('Zorunlu alanlar boş: ' + eksik.join(', ')); return }
    if (!beyan) { setMesajM('Doğruluk beyanını onaylayın.'); return }
    if (imzaZorunlu && !imza) { setMesajM('İmza gerekli.'); return }
    setKaydediliyor(true); setMesajM(null);
    try {
      const imzalar: FormImza[] = imza ? [{ rol: 'hasta', ad: ot.hasta, yontem: 1, zaman: new Date().toISOString(), veri: imza }] : [];
      const y = await formAcik.gonder(kod, ot.oturum, cevap, imzalar);
      setBitti(y);
    } catch (h) { setMesajM(h instanceof Error ? h.message : String(h)) }
    finally { setKaydediliyor(false) }
  };
  const reddet = async () => {
    if (!ot) return;
    if (!window.confirm('Formu doldurmayı reddediyorsunuz. Kurumunuz bilgilendirilecek. Emin misiniz?')) return;
    try { const y = await formAcik.reddet(kod, ot.oturum); setBitti(y) } catch (h) { setMesajM(h instanceof Error ? h.message : String(h)) }
  };

  const kurum = ot?.kurum ?? ozet?.kurum ?? '';

  if (hata && !ot) return <Kabuk kurum={kurum}><div className="fm-kutu"><b>Bağlantı açılamadı</b><p>{hata}</p></div></Kabuk>;
  if (!ozet) return <Kabuk kurum={kurum}><div className="fm-kutu sonuk">Yükleniyor…</div></Kabuk>;
  if (!ozet.gecerli) return <Kabuk kurum={kurum}><div className="fm-kutu"><b>Bu bağlantı kullanılamıyor</b><p>{ozet.neden}</p></div></Kabuk>;

  if (bitti) return (
    <Kabuk kurum={kurum} alt="Bu bağlantı artık kullanılamaz.">
      <div className="fm-kutu fm-kutu-ok">
        <b>{bitti.durum === 7 ? 'Formu doldurmayı reddettiniz.' : 'Teşekkürler, formunuz iletildi.'}</b>
        {bitti.durum === 4 && <p>{ot?.form} · {new Date().toLocaleString('tr-TR')}{bitti.sonuc ? ` · ${bitti.sonuc}` : ''}</p>}
        <p className="sonuk">Kurumunuz muayenede sizinle birlikte gözden geçirecek.</p>
      </div>
    </Kabuk>
  );

  if (!ot) return (
    <Kabuk kurum={kurum}>
      <div className="fm-kutu">
        <b>{ozet.form}</b>
        <p>Sayın <strong>{ozet.hasta}</strong>, {ozet.kurum} sizden bu formu doldurmanızı istiyor. Birkaç dakika sürer; kaldığınız yerden devam edebilirsiniz.</p>
      </div>
      <div className="fm-kutu">
        <b>Kimlik doğrulama</b>
        <div className="sonuk" style={{ fontSize: 12 }}>Bilgilerin size ait olduğundan emin olmak için:</div>
        <label className="fm-etiket">TC kimlik numaranızın son 4 hanesi</label>
        <input className="fm-giris fm-buyuk-giris" inputMode="numeric" maxLength={4} value={son4} onChange={e => setSon4(e.target.value.replace(/\D/g, ''))} />
        <label className="fm-etiket">Doğum yılınız</label>
        <input className="fm-giris fm-buyuk-giris" inputMode="numeric" maxLength={4} value={yil} onChange={e => setYil(e.target.value.replace(/\D/g, ''))} />
        <label className={`fm-onay${riza ? ' on' : ''}`}>
          <input type="checkbox" checked={riza} onChange={e => setRiza(e.target.checked)} />
          <span>Sağlık verilerimin {ozet.kurum} tarafından sağlık hizmeti / sağlık gözetimi amacıyla işlenmesine açık rıza veriyorum.</span>
        </label>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <button type="button" className="fm-dbtn" disabled={son4.length !== 4 || !riza} onClick={() => void dogrula()}>Devam et →</button>
        <div className="sonuk" style={{ textAlign: 'center', fontSize: 11, marginTop: 6 }}>Kalan deneme: {ozet.kalanDeneme}</div>
      </div>
    </Kabuk>
  );

  const b = bolumler[adim];
  const hesap = skorHesapla(ot.tanim, cevap);
  return (
    <Kabuk kurum={kurum} alt={<span>{bolumler.map((x, i) => <span key={x.kod} className={i === adim ? 'fm-adim-on' : ''}>{i + 1} {x.ad}{i < bolumler.length - 1 || true ? ' · ' : ''}</span>)}<span className={adim === ozetAdimi ? 'fm-adim-on' : ''}>{bolumler.length + 1} Onay</span></span>}>
      <div className="fm-adim-cubuk">
        {bolumler.map((x, i) => <i key={x.kod} className={i < adim ? 'ok' : i === adim ? 'on' : ''} />)}
        <i className={adim === ozetAdimi ? 'on' : ''} />
      </div>
      {adim < ozetAdimi ? (
        <>
          <div className="fm-kutu">
            <FormCizici bolumler={[b]} cevap={cevap} onChange={degistir} parametreler={ot.parametreler} buyuk />
          </div>
          {mesajM && <div className="hata-kutusu">{mesajM}</div>}
          <div className="fm-dbtn-sira">
            {adim > 0 && <button type="button" className="fm-dbtn gri" onClick={() => { setAdim(a => a - 1); window.scrollTo(0, 0) }}>← Geri</button>}
            <button type="button" className="fm-dbtn" onClick={ileri}>Devam et →</button>
          </div>
          <div className="sonuk" style={{ textAlign: 'center', fontSize: 11, marginTop: 6 }}>Taslak otomatik kaydedilir · {b.ad} ({adim + 1}/{bolumler.length + 1})</div>
        </>
      ) : (
        <>
          <div className="fm-kutu">
            <b>Özet</b>
            {bolumler.map(x => {
              const dolu = (x.alanlar ?? []).filter(a => a.tip !== 'metinblok' && cevap[a.kod] !== undefined && cevap[a.kod] !== '' && cevap[a.kod] !== false).length;
              return <div key={x.kod} className="fm-ozet-satir"><span>{x.ad}</span><span className="rozet ok">{dolu} alan ✓</span></div>;
            })}
            {hesap.skor !== null && <div className="fm-ozet-satir"><span>Skor</span><b>{hesap.skor}{hesap.esik ? ` · ${hesap.esik.ad}` : ''}</b></div>}
          </div>
          {imzaZorunlu && (
            <div className="fm-kutu"><b>İmza</b><ImzaKanvas deger={imza} onChange={setImza} etiket={ot.hasta} /></div>
          )}
          <div className="fm-kutu">
            <b>Beyan</b>
            <p style={{ fontSize: 12.5, lineHeight: 1.5 }}>Verdiğim bilgilerin doğru ve eksiksiz olduğunu beyan ederim. Muayene sırasında hekimimle birlikte gözden geçirilecektir.</p>
            <label className={`fm-onay${beyan ? ' on' : ''}`}>
              <input type="checkbox" checked={beyan} onChange={e => setBeyan(e.target.checked)} />
              <span>Okudum, onaylıyorum — {ot.hasta}</span>
            </label>
          </div>
          {mesajM && <div className="hata-kutusu">{mesajM}</div>}
          <div className="fm-dbtn-sira">
            <button type="button" className="fm-dbtn gri" onClick={() => setAdim(a => a - 1)}>← Geri</button>
            <button type="button" className="fm-dbtn" disabled={kaydediliyor} onClick={() => void gonder()}>Gönder ✓</button>
          </div>
          <div style={{ textAlign: 'center', marginTop: 10 }}><button type="button" className="fm-baglanti" onClick={() => void reddet()}>Formu doldurmak istemiyorum</button></div>
        </>
      )}
    </Kabuk>
  );
}

/** Sayfa kabuğu bileşen DIŞINDA: içeride tanımlansa her tuşta remount olur, odak kaybolurdu. */
function Kabuk({ kurum, children, alt }: { kurum: string; children: React.ReactNode; alt?: React.ReactNode }) {
  return (
    <div className="fm-acik">
      <div className="fm-acik-ust">🩺 GenoTIP AI <span className="fm-acik-kurum">{kurum}</span></div>
      <div className="fm-acik-gov">{children}</div>
      <div className="fm-acik-alt">{alt ?? '🔒 Bağlantı tek kullanımlık · yalnız hekiminiz görür'}</div>
    </div>
  );
}
