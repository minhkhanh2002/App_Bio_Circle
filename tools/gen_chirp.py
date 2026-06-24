"""Tổng hợp âm thông báo "pi-o" — tiếng chim non dễ thương, mềm, ngọt.
Xuất WAV mono 44.1kHz 16-bit. Stdlib thuần (math, struct, wave)."""
import math, struct, wave, os

SR = 44100
TOTAL = 0.50
N = int(TOTAL * SR)
buf = [0.0] * N


def env(t, dur, attack, release):
    if t < attack:
        return (t / attack) ** 1.2  # vào mượt
    if t > dur - release:
        x = max(0.0, (dur - t) / release)
        return x * x  # tắt mượt (ngân nhẹ)
    return 1.0


def tone(start, dur, f0, f1, amp, harmonics, attack, release,
         fexp=1.0, vib_hz=0.0, vib_depth=0.0):
    n0 = int(start * SR)
    n = int(dur * SR)
    phase = {h: 0.0 for h, _ in harmonics}
    for i in range(n):
        t = i / SR
        frac = (i / n) ** fexp
        f = f0 + (f1 - f0) * frac
        if vib_hz:
            f += vib_depth * math.sin(2 * math.pi * vib_hz * t)
        e = amp * env(t, dur, attack, release)
        s = 0.0
        for h, ha in harmonics:
            phase[h] += 2 * math.pi * f * h / SR
            s += ha * math.sin(phase[h])
        idx = n0 + i
        if 0 <= idx < N:
            buf[idx] += e * s


# Âm 1 "Pi-": cao, ngắn, hơi nhướn lên.
tone(0.000, 0.080, 2700, 3550, 0.55,
     [(1, 1.0), (2, 0.28), (3, 0.08)], attack=0.006, release=0.028, fexp=0.6)

# Âm 2 "-o": hạ tông, ngân nhẹ + warble nhẹ cho cảm giác nũng nịu.
tone(0.125, 0.195, 3300, 2120, 0.60,
     [(1, 1.0), (2, 0.32), (3, 0.06)], attack=0.009, release=0.080,
     fexp=1.25, vib_hz=33.0, vib_depth=55.0)

# Chuẩn hóa biên độ về ~0.9 đỉnh.
peak = max(1e-9, max(abs(x) for x in buf))
g = 0.9 / peak
buf = [x * g for x in buf]

# Fade tổng 2ms hai đầu chống click.
fn = int(0.002 * SR)
for i in range(fn):
    buf[i] *= i / fn
    buf[N - 1 - i] *= i / fn

out = os.path.join(os.path.dirname(__file__), "pio_chirp.wav")
with wave.open(out, "w") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(b"".join(
        struct.pack("<h", max(-32767, min(32767, int(x * 32767)))) for x in buf))
print("wrote", out)
