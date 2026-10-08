/**
 * Üst şerit: hangi sunucuya bağlı olduğumuz, kim olarak bağlandığımız ve
 * çıkış. Profil ekranından ayrı tutuluyor - orası artık yalnız içeriği
 * çiziyor.
 */
export function Ust({ adres, kullanici, kaydediyor, onKaydetCik, onCik }: {
  adres: string;
  kullanici?: string;
  kaydediyor?: boolean;
  /** Ana kaydeti tetikler, sonra çıkar. Ekran hazır değilse verilmez. */
  onKaydetCik?: () => void;
  onCik(): void;
}) {
  return (
    <div className="gp-ust">
      <span className="gp-marka">GenProfil</span>
      <span className="gp-sunucu">{adres}</span>
      <span className="gp-bosluk" />
      {kullanici && <span className="sonuk">{kullanici}</span>}
      {onKaydetCik && (
        <button type="button" className="d birincil" disabled={kaydediyor}
                onClick={onKaydetCik}>
          💾 {kaydediyor ? 'Kaydediliyor…' : 'Kaydet ve Çık'}
        </button>
      )}
      <button type="button" className="d" onClick={onCik}>
        {onKaydetCik ? 'Kaydetmeden Çık' : 'Sunucuyu Değiştir'}
      </button>
    </div>
  );
}
