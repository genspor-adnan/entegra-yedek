using System.Collections.Concurrent;
using Microsoft.Extensions.Logging;

namespace Gentegre.Aktarim.Ajan;

/// <summary>Günlük dosyası: &lt;klasör&gt;/ajan-yyyyMMdd.log, 30 günden eskisi silinir.</summary>
public sealed class DosyaGunlugu(string klasor) : ILoggerProvider
{
    private readonly object _kilit = new();
    private readonly ConcurrentDictionary<string, Gunlukcu> _liste = new();

    public ILogger CreateLogger(string kategori) => _liste.GetOrAdd(kategori, _ => new Gunlukcu(this));

    private void Yaz(LogLevel duzey, string mesaj, Exception? hata)
    {
        var simdi = DateTime.Now;
        var satir = $"{simdi:yyyy-MM-dd HH:mm:ss.fff} {Kisa(duzey)} {mesaj}" + (hata is null ? "" : Environment.NewLine + hata);
        lock (_kilit)
        {
            Directory.CreateDirectory(klasor);
            var yol = Path.Combine(klasor, $"ajan-{simdi:yyyyMMdd}.log");
            var yeni = !File.Exists(yol);
            File.AppendAllText(yol, satir + Environment.NewLine);
            if (yeni)
                foreach (var eski in Directory.GetFiles(klasor, "ajan-*.log").Where(f => File.GetLastWriteTime(f) < simdi.AddDays(-30)))
                    try { File.Delete(eski); } catch (IOException) { }
        }
    }

    private static string Kisa(LogLevel d) => d switch
    {
        LogLevel.Error or LogLevel.Critical => "HATA",
        LogLevel.Warning => "UYARI",
        LogLevel.Debug or LogLevel.Trace => "AYRINTI",
        _ => "BILGI",
    };

    public void Dispose() { }

    private sealed class Gunlukcu(DosyaGunlugu ana) : ILogger
    {
        public IDisposable? BeginScope<T>(T durum) where T : notnull => null;
        public bool IsEnabled(LogLevel d) => d >= LogLevel.Information;
        public void Log<T>(LogLevel d, EventId id, T durum, Exception? hata, Func<T, Exception?, string> bicim)
        {
            if (IsEnabled(d)) ana.Yaz(d, bicim(durum, hata), hata);
        }
    }
}
