/**
 * Yerel saat damgasi (yyyy-MM-ddTHH:mm).
 *
 * `Date.toISOString()` UTC verir; TR'de kaydedilen saat 3 saat GERIYE duser.
 * Cekim zamani (istem->cekim bekleme suresi) ve basvuru saati bu damgadan
 * yaziliyor - UTC'ye kayarsa kalite gostergesi negatif bile cikabilir.
 */
export const yerelZamanDamgasi = () => {
  const d = new Date();
  return new Date(d.getTime() - d.getTimezoneOffset() * 60000)
    .toISOString().slice(0, 16);
};
