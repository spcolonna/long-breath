#!/usr/bin/env python3
"""Genera todo el sonido del juego por síntesis (sin muestras ni IA).

Uso:
  python3 tool/make_audio.py            # efectos, voces y música
  python3 tool/make_audio.py sfx        # solo efectos y voces
  python3 tool/make_audio.py music      # solo música y jingles
  python3 tool/make_audio.py <id> ...   # solo esos ids (p. ej. hit_heavy music_boss)

Identidad (docs/arte/sonido.md): kung fu luminoso. Percusión china seca
(dagu, bloque de madera, platillos bo, gong chico), cuerdas pulsadas
(guzheng, pipa) y flauta dizi, en pentatónica. Sin reverb larga ni nada
oscuro. Efectos: WAV mono 44,1 kHz 16 bit, pico −1 dB. Música: OGG Vorbis
estéreo con loop sin corte. La semilla es fija: el resultado se repite.
"""

import json
import os
import sys

import numpy as np
import soundfile as sf
from scipy import signal

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX_DIR = os.path.join(ROOT, 'assets/audio/sfx')
MUSIC_DIR = os.path.join(ROOT, 'assets/audio/music')
ENEMIES = os.path.join(ROOT, 'assets/data/enemies.json')
SR = 44100
PEAK = 10 ** (-1 / 20)  # −1 dB

# Pentatónica de Re (宫 en D): D E F# A B
PENTA = [0, 2, 4, 7, 9]
BASE_MIDI = 62  # D4


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def penta(step, base=BASE_MIDI):
    """Nota de la pentatónica: step 0 = base, 5 = una octava arriba."""
    o, d = divmod(step, 5)
    return base + 12 * o + PENTA[d]


def t_axis(dur):
    return np.arange(int(dur * SR)) / SR


def silence(dur):
    return np.zeros(int(dur * SR))


def exp_env(dur, decay, attack=0.002):
    t = t_axis(dur)
    env = np.exp(-t / max(decay, 1e-4))
    a = int(attack * SR)
    if a > 1:
        env[:a] *= np.linspace(0, 1, a)
    return env


def bp(x, lo, hi, order=2):
    lo = max(lo, 20)
    hi = min(hi, SR / 2 - 100)
    sos = signal.butter(order, [lo, hi], 'bandpass', fs=SR, output='sos')
    return signal.sosfilt(sos, x)


def lp(x, f, order=2):
    sos = signal.butter(order, min(f, SR / 2 - 100), 'lowpass', fs=SR, output='sos')
    return signal.sosfilt(sos, x)


def hp(x, f, order=2):
    sos = signal.butter(order, f, 'highpass', fs=SR, output='sos')
    return signal.sosfilt(sos, x)


def mix(*parts):
    """Suma señales (o tuplas (señal, offset_s)) alineadas por su inicio."""
    items = [p if isinstance(p, tuple) else (p, 0.0) for p in parts]
    n = max(int(o * SR) + len(s) for s, o in items)
    out = np.zeros(n)
    for s, o in items:
        i = int(o * SR)
        out[i:i + len(s)] += s
    return out


def fade_out(x, dur=0.03):
    n = min(len(x), int(dur * SR))
    if n > 1:
        x = x.copy()
        x[-n:] *= np.linspace(1, 0, n) ** 2
    return x


def room(x, size=0.12, wet=0.12, seed=1):
    """Sala chica: respuesta de ruido que decae rápido (no es reverb larga)."""
    r = np.random.default_rng(seed)
    n = int(size * SR)
    ir = r.standard_normal(n) * np.exp(-np.arange(n) / (n / 5))
    ir = lp(ir, 6000)
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    wetsig = signal.fftconvolve(x, ir)[:len(x) + n]
    out = np.zeros(len(wetsig))
    out[:len(x)] += x
    return out + wet * wetsig


# ---------------------------------------------------------------- instrumentos

def pluck(freq, dur=0.8, bright=1.0, decay=0.6, amp=1.0, rng=None):
    """Guzheng/pipa aditivo: armónicos que decaen más rápido cuanto más agudos,
    con una leve inarmonicidad de cuerda y un ataque de púa."""
    t = t_axis(dur)
    out = np.zeros_like(t)
    for k in range(1, 13):
        f = freq * k * (1 + 0.0004 * k * k)
        if f > SR / 2.2:
            break
        a = (1 / k ** (1.6 - 0.5 * bright)) * (1 if k % 5 else 0.4)
        out += a * np.sin(2 * np.pi * f * t + (k * 1.3)) * np.exp(-t * (1 / decay) * (1 + 0.35 * k))
    pick = np.random.default_rng(int(freq)).standard_normal(int(0.006 * SR))
    pick = hp(pick, 2500) * np.linspace(1, 0, len(pick)) * 0.25 * bright
    out[:len(pick)] += pick
    a = int(0.0015 * SR)
    out[:a] *= np.linspace(0, 1, a)
    return fade_out(out * amp / (np.max(np.abs(out)) + 1e-9), 0.02)


def dizi(freq, dur=0.6, vib=5.5, amp=1.0, breath=0.12, glide=0.0):
    """Flauta: fundamental + armónicos suaves, vibrato que entra de a poco y
    soplo de ruido filtrado alrededor de la nota."""
    t = t_axis(dur)
    vib_amt = 0.006 * np.clip((t - 0.12) / 0.2, 0, 1)
    f = freq * (1 + glide * np.clip(1 - t / 0.08, 0, 1) * -1) * (1 + vib_amt * np.sin(2 * np.pi * vib * t))
    ph = 2 * np.pi * np.cumsum(f) / SR
    tone = np.sin(ph) + 0.35 * np.sin(2 * ph) + 0.12 * np.sin(3 * ph) + 0.05 * np.sin(4 * ph)
    air = bp(np.random.default_rng(int(freq * 7)).standard_normal(len(t)), freq * 0.8, freq * 3.5)
    air /= np.max(np.abs(air)) + 1e-9
    a, r = min(0.05, dur / 3), min(0.12, dur / 3)
    env = np.ones_like(t)
    na, nr = int(a * SR), int(r * SR)
    env[:na] = np.linspace(0, 1, na) ** 0.7
    env[-nr:] *= np.linspace(1, 0, nr)
    sig = (tone / 1.5 + breath * air * (0.6 + 0.4 * np.exp(-t / 0.06))) * env
    return sig * amp


def dagu(freq=110, dur=0.5, amp=1.0, slap=0.5, decay=0.18):
    """Tambor dagu: seno que cae de tono + golpe de parche."""
    t = t_axis(dur)
    f = freq * (1 + 0.9 * np.exp(-t / 0.025))
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / decay)
    body += 0.3 * np.sin(2 * np.pi * np.cumsum(f * 1.5) / SR) * np.exp(-t / (decay * 0.5))
    n = np.random.default_rng(int(freq * 3)).standard_normal(len(t))
    skin = bp(n, 300, 3000) * np.exp(-t / 0.018) * slap
    return fade_out((body + skin) * amp, 0.02)


def woodblock(freq=900, dur=0.12, amp=1.0, decay=0.035):
    t = t_axis(dur)
    s = (np.sin(2 * np.pi * freq * t) + 0.5 * np.sin(2 * np.pi * freq * 2.57 * t)
         + 0.25 * np.sin(2 * np.pi * freq * 4.1 * t)) * np.exp(-t / decay)
    click = np.random.default_rng(int(freq)).standard_normal(len(t)) * np.exp(-t / 0.002) * 0.3
    return fade_out((s + hp(click, 2000)) * amp / 1.6, 0.01)


def cymbal(dur=0.8, amp=1.0, decay=0.25, tone=6000, seed=3):
    t = t_axis(dur)
    n = np.random.default_rng(seed).standard_normal(len(t))
    metal = sum(np.sign(np.sin(2 * np.pi * f * t)) for f in (523, 811, 1293, 1677, 2311)) / 5
    s = hp(n * 0.8 + metal * 0.4, tone * 0.6) * np.exp(-t / decay)
    return fade_out(s * amp, 0.05)


def gong(freq=330, dur=1.4, amp=1.0, decay=0.7, bend=0.015):
    """Gong chico (luo): parciales inarmónicos con un glissando apenas."""
    t = t_axis(dur)
    out = np.zeros_like(t)
    for ratio, a, d in ((1, 1, 1), (1.47, 0.6, 0.7), (2.09, 0.45, 0.55), (2.56, 0.3, 0.4),
                        (3.3, 0.2, 0.3), (4.2, 0.12, 0.2)):
        f = freq * ratio * (1 + bend * (1 - np.exp(-t / 0.3)))
        out += a * np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / (decay * d))
    hit = bp(np.random.default_rng(int(freq)).standard_normal(len(t)), 500, 4000) * np.exp(-t / 0.01) * 0.4
    return fade_out((out / 2.5 + hit) * amp, 0.1)


def bell(freq=1760, dur=0.8, amp=1.0, decay=0.35, ratio=3.5, index=2.0):
    """Campanilla FM."""
    t = t_axis(dur)
    idx = index * np.exp(-t / (decay * 0.4))
    s = np.sin(2 * np.pi * freq * t + idx * np.sin(2 * np.pi * freq * ratio * t)) * np.exp(-t / decay)
    a = int(0.001 * SR)
    s[:a] *= np.linspace(0, 1, a)
    return fade_out(s * amp, 0.05)


def whoosh(dur=0.3, f0=400, f1=4000, amp=1.0, seed=5, q=1.6):
    """Ruido con banda que barre de f0 a f1 (filtro de estado variable)."""
    t = t_axis(dur)
    n = np.random.default_rng(seed).standard_normal(len(t))
    fc = f0 * (f1 / f0) ** (t / dur)
    out = np.zeros_like(n)
    low = band = 0.0
    damp = 1 / q
    for i in range(len(n)):
        f = 2 * np.sin(np.pi * fc[i] / SR)
        high = n[i] - low - damp * band
        band += f * high
        low += f * band
        out[i] = band
    env = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 1.5
    out = out * env
    return out * amp / (np.max(np.abs(out)) + 1e-9)


def thump(freq=90, dur=0.18, amp=1.0):
    t = t_axis(dur)
    f = freq * (1 + 1.5 * np.exp(-t / 0.012))
    return fade_out(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.05) * amp, 0.02)


def slap(dur=0.06, lo=800, hi=3500, amp=1.0, seed=7):
    t = t_axis(dur)
    n = np.random.default_rng(seed).standard_normal(len(t))
    return bp(n, lo, hi) * np.exp(-t / 0.012) * amp


def paper(dur=0.12, amp=1.0, seed=11, lo=1800, hi=7000):
    """Papel: ruido granulado de banda media-alta."""
    t = t_axis(dur)
    r = np.random.default_rng(seed)
    n = r.standard_normal(len(t))
    grain = (r.random(len(t)) < 0.08) * r.standard_normal(len(t)) * 3
    s = bp(n + grain, lo, hi) * np.sin(np.pi * t / dur) ** 0.6
    return s * amp / (np.max(np.abs(s)) + 1e-9)


def voice_formant(f0=180, dur=0.3, vowel='a', amp=1.0, fall=0.25, seed=13, rough=0.0):
    """Grito corto tipo kiai: pulso glotal por formantes (sin palabras)."""
    formants = {'a': (800, 1200, 2600), 'o': (500, 900, 2500), 'e': (500, 1800, 2600),
                'u': (350, 700, 2400), 'i': (300, 2200, 3000)}[vowel]
    t = t_axis(dur)
    f = f0 * (1 + 0.15 * np.exp(-t / 0.04)) * (1 - fall * t / dur)
    if rough:
        f *= 1 + rough * np.sin(2 * np.pi * 31 * t)
    ph = np.cumsum(f) / SR
    src = 2 * (ph % 1) - 1  # diente de sierra
    src += 0.15 * np.random.default_rng(seed).standard_normal(len(t))
    out = sum(bp(src, fm * 0.85, fm * 1.15) * g for fm, g in zip(formants, (1, 0.6, 0.25)))
    env = np.minimum(1, t / 0.015) * np.exp(-np.maximum(0, t - dur * 0.35) / (dur * 0.25))
    return fade_out(out * env * amp / (np.max(np.abs(out)) + 1e-9), 0.03)


def growl(f0=70, dur=0.6, amp=1.0, seed=17, bright=900):
    t = t_axis(dur)
    r = np.random.default_rng(seed)
    am = 0.6 + 0.4 * np.sin(2 * np.pi * (24 + 6 * r.random()) * t)
    ph = np.cumsum(f0 * (1 + 0.08 * np.sin(2 * np.pi * 3 * t))) / SR
    saw = 2 * (ph % 1) - 1
    n = r.standard_normal(len(t))
    s = lp(saw * 0.7 + n * 0.5, bright) * am
    env = np.minimum(1, t / 0.05) * np.minimum(1, (dur - t) / 0.15)
    return s * env * amp / (np.max(np.abs(s)) + 1e-9)


def chirp(f0=3000, f1=5000, dur=0.08, amp=1.0):
    t = t_axis(dur)
    f = f0 * (f1 / f0) ** (t / dur)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * t / dur)
    return s * amp


def arp(steps, gap=0.06, dur=0.7, base=BASE_MIDI, bright=1.0, amp=1.0, decay=0.5):
    return mix(*[(pluck(hz(penta(s, base)), dur, bright, decay, amp * (0.85 + 0.15 * (i % 2))), i * gap)
                 for i, s in enumerate(steps)])


# ---------------------------------------------------------------- efectos

def sfx_card_deal(v):
    return mix(paper(0.09, 0.7, seed=20 + v), (woodblock(1700 + 180 * v, 0.06, 0.35, 0.012), 0.05))


def sfx_card_select(v):
    return mix(woodblock(2200, 0.05, 0.5, 0.008), (pluck(hz(penta(7)), 0.25, 1.2, 0.12, 0.45), 0.005))


def sfx_card_deny(v):
    k = lp(woodblock(420, 0.1, 1, 0.025), 1400)
    return mix(k, (k * 0.8, 0.11))


def sfx_card_play(v):
    return mix(whoosh(0.16, 700, 5000, 0.6, seed=31), (slap(0.04, 1500, 6000, 0.5), 0.13))


def sfx_hit_light(v):
    f = [130, 115, 145][v]
    return room(mix(thump(f, 0.16, 1.0), slap(0.05, 900, 3200, 0.7, seed=40 + v),
                    woodblock([700, 640, 760][v], 0.07, 0.35, 0.015)), 0.08, 0.1)


def sfx_hit_heavy(v):
    return room(mix(dagu([85, 75][v], 0.55, 1.0, 0.9, 0.16), thump(60, 0.25, 0.9),
                    slap(0.08, 600, 2500, 0.8, seed=50 + v),
                    (cymbal(0.35, 0.35, 0.09, seed=51 + v), 0.005)), 0.1, 0.12)


def sfx_block(v):
    return room(mix(lp(woodblock(380, 0.15, 1, 0.04), 2200), thump(100, 0.12, 0.6),
                    slap(0.04, 400, 1500, 0.4, seed=60)), 0.06, 0.08)


def sfx_player_hurt(v):
    return room(mix(thump([95, 85][v], 0.25, 1), lp(slap(0.08, 300, 1800, 0.9, seed=70 + v), 2000),
                    (dagu(70, 0.3, 0.5, 0.2, 0.1), 0.01)), 0.08, 0.1)


def sfx_deflect(v):
    return mix(whoosh(0.12, 1500, 7000, 0.5, seed=80), (bell(2637, 0.6, 0.7, 0.22, 2.76, 1.5), 0.06),
               (bell(3520, 0.4, 0.3, 0.15, 3.1, 1), 0.07))


def sfx_guard_up(v):
    return mix(woodblock(600, 0.1, 0.8, 0.03), (pluck(hz(penta(2)), 0.4, 1, 0.25, 0.5), 0.03),
               (pluck(hz(penta(4)), 0.45, 1, 0.3, 0.55), 0.1))


def sfx_enemy_windup(v):
    return mix(whoosh(0.4, 250, 2500, 0.7, seed=90, q=2.5),
               *[(woodblock(500 + 90 * i, 0.05, 0.2 + 0.08 * i, 0.012), 0.06 * i) for i in range(5)])


def sfx_turn_start(v):
    return mix(woodblock(1100, 0.08, 0.7), (woodblock(1450, 0.1, 0.8), 0.09), (gong(660, 0.8, 0.35, 0.3), 0.16))


def sfx_victory_stamp(v):
    return room(mix(dagu(80, 0.8, 1, 1, 0.25), thump(55, 0.3, 0.8), (gong(392, 1.2, 0.6, 0.6), 0.01),
                    (cymbal(0.7, 0.45, 0.25, seed=100), 0.01)), 0.12, 0.15)


def sfx_defeat_stamp(v):
    return room(mix(lp(dagu(70, 0.8, 1, 0.4, 0.3), 1500), (lp(gong(220, 1.1, 0.5, 0.5, -0.02), 2500), 0.02)),
                0.12, 0.12)


def sfx_fight_start(v):
    return room(mix(dagu(100, 0.3, 0.6), (dagu(105, 0.3, 0.7), 0.12), (dagu(95, 0.6, 1, 0.8, 0.22), 0.22),
                    (cymbal(0.7, 0.55, 0.25, seed=110), 0.23)), 0.1, 0.12)


def sfx_enemy_drop(v):
    return mix(thump(70, 0.3, 1), (lp(paper(0.25, 0.3, seed=120, lo=300, hi=2000), 2500), 0.02))


def sfx_break(v):
    crack = mix(slap(0.05, 1500, 7000, 1, seed=130), lp(woodblock(300, 0.12, 0.9, 0.03), 3000))
    stars = mix(*[(bell(hz(penta(12 - i * 2)), 0.35, 0.3, 0.12, 2, 1), 0.12 + 0.07 * i) for i in range(4)])
    return mix(crack, thump(80, 0.2, 0.7), stars)


def sfx_enemy_guard(v):
    return mix(lp(woodblock(450, 0.12, 1, 0.03), 2500), (woodblock(520, 0.1, 0.5, 0.02), 0.07))


def sfx_enemy_charge(v):
    roll = mix(*[(dagu(120 + 6 * i, 0.15, 0.25 + 0.06 * i, 0.4, 0.06), 0.11 - 0.008 * i + sum(0.11 - 0.009 * j for j in range(i)))
                 for i in range(6)])
    t = t_axis(0.6)
    rise = np.sin(2 * np.pi * np.cumsum(180 * 2 ** (t / 0.6)) / SR) * np.minimum(1, t / 0.4) * 0.25
    return mix(roll, lp(rise, 1500))


def sfx_enemy_skip(v):
    return mix(pluck(hz(penta(4)), 0.3, 0.8, 0.15, 0.6), (pluck(hz(penta(1)), 0.4, 0.7, 0.2, 0.55), 0.12),
               (woodblock(380, 0.08, 0.3), 0.24))


def sfx_enemy_death(v):
    t = t_axis(1.0)
    shimmer = mix(*[(bell(hz(penta(14 - i)), 0.5, 0.25, 0.2, 2.5, 1.2), 0.08 * i) for i in range(8)])
    ink = whoosh(1.0, 3000, 300, 0.6, seed=140, q=1.2)
    return mix(ink, shimmer, thump(70, 0.2, 0.4))


def sfx_hero_victory(v):
    return mix(arp([0, 2, 4, 5, 7, 9, 10], 0.05, 0.6, bright=1.2, decay=0.35), (cymbal(0.5, 0.3, 0.2, seed=150), 0.33))


def sfx_hero_fall(v):
    return mix(arp([7, 5, 4, 2, 0], 0.09, 0.6, bright=0.6, decay=0.35, amp=0.7), (thump(75, 0.3, 0.8), 0.45),
               (lp(paper(0.3, 0.2, seed=160, lo=200, hi=1500), 2000), 0.45))


def sfx_stance_change(v):
    return mix(paper(0.14, 0.6, seed=170, lo=500, hi=4000), (woodblock(820, 0.08, 0.6, 0.02), 0.08))


def sfx_form_step(v):
    return mix(pluck(hz(penta(5 + v)), 0.55, 1.1, 0.35, 0.9), (woodblock(1600, 0.04, 0.2, 0.008), 0.0))


def sfx_form_complete(v):
    gl = arp([5, 6, 7, 8, 9, 10, 11, 12], 0.035, 0.8, bright=1.3, decay=0.4, amp=0.7)
    return room(mix(gl, (gong(523, 1.2, 0.6, 0.6), 0.26), (dagu(100, 0.5, 0.7), 0.26),
                    (bell(hz(penta(17)), 0.9, 0.35, 0.4), 0.3), (bell(hz(penta(19)), 0.9, 0.25, 0.4), 0.36)), 0.12, 0.15)


def sfx_form_broken(v):
    return mix(lp(woodblock(500, 0.1, 0.8), 2500), (pluck(hz(penta(3)), 0.3, 0.6, 0.12, 0.5), 0.05),
               (pluck(hz(penta(1)) * 0.97, 0.35, 0.6, 0.15, 0.45), 0.13))


def sfx_breath_gain(v):
    return mix(dizi(hz(penta(7)), 0.55, amp=0.55, breath=0.35, glide=0.06), (bell(hz(penta(12)), 0.5, 0.15, 0.25), 0.2))


def sfx_breath_spend(v):
    t = t_axis(0.25)
    puff = bp(np.random.default_rng(180).standard_normal(len(t)), 600, 2500) * np.sin(np.pi * t / 0.25) ** 2
    return mix(puff / (np.max(np.abs(puff)) + 1e-9) * 0.6, dizi(hz(penta(2)), 0.2, amp=0.25, breath=0.4))


def sfx_phase_two(v):
    roll = mix(*[(dagu(70 + 2 * i, 0.25, 0.3 + 0.05 * i, 0.5, 0.1), 0.07 * i) for i in range(10)])
    return room(mix(roll, (gong(196, 1.5, 1, 0.9), 0.7), (dagu(60, 0.8, 1, 1, 0.3), 0.7),
                    (cymbal(0.9, 0.5, 0.35, seed=190), 0.7)), 0.15, 0.15)


def sfx_end_rays(v):
    return mix(*[(bell(hz(penta(10 + i)), 0.6, 0.35, 0.3, 2.0, 0.8), 0.06 * i) for i in range(8)])


def sfx_ui_button(v):
    return mix(woodblock(1300, 0.06, 0.8, 0.012), (pluck(hz(penta(9)), 0.18, 1, 0.08, 0.25), 0.0))


def sfx_tap(v):
    return woodblock(1900, 0.035, 0.5, 0.006)


def sfx_screen_transition(v):
    return whoosh(0.4, 500, 2500, 0.5, seed=200, q=1.0)


def sfx_map_node(v):
    return mix(woodblock(1500, 0.06, 0.6, 0.01), (pluck(hz(penta(5)), 0.4, 1, 0.25, 0.6), 0.02))


def sfx_reward_flip(v):
    return mix(paper(0.1, 0.6, seed=210 + v), (pluck(hz(penta([7, 8, 9][v])), 0.35, 1.2, 0.2, 0.45), 0.07))


def sfx_reward_take(v):
    return mix(pluck(hz(penta(7)), 0.4, 1, 0.25, 0.6), (pluck(hz(penta(10)), 0.6, 1.1, 0.35, 0.7), 0.08),
               (bell(hz(penta(15)), 0.6, 0.3, 0.3), 0.12))


def sfx_fountain_heal(v):
    r = np.random.default_rng(220)
    blips = []
    for i in range(14):
        f = 700 + r.random() * 900
        t = t_axis(0.06)
        s = np.sin(2 * np.pi * np.cumsum(f * (1 + 0.8 * t / 0.06)) / SR) * np.sin(np.pi * t / 0.06)
        blips.append((s * (0.2 + 0.15 * r.random()), i * 0.07 + r.random() * 0.03))
    return mix(*blips, *[(bell(hz(penta(10 + i)), 0.6, 0.2, 0.3), 0.15 + 0.12 * i) for i in range(5)])


def sfx_shrine_oath(v):
    return room(mix(gong(294, 1.3, 0.9, 0.7), dagu(90, 0.6, 0.7, 0.5, 0.2),
                    (dizi(hz(penta(7)), 0.7, amp=0.35, breath=0.15), 0.15)), 0.15, 0.15)


def sfx_legacy_seal(v):
    return mix(thump(80, 0.25, 1), lp(slap(0.05, 300, 2000, 0.6, seed=230), 3000), (bell(hz(penta(12)), 0.8, 0.4, 0.35), 0.05))


def sfx_offering(v):
    return mix(*[(bell(hz(penta(9 + i)), 0.5, 0.3, 0.25), 0.07 * i) for i in range(5)], (gong(440, 1.0, 0.4, 0.5), 0.35))


def sfx_run_result(v):
    return room(mix(dagu(85, 0.6, 1, 0.8, 0.22), (gong(330, 1.2, 0.8, 0.6), 0.02)), 0.12, 0.15)


def sfx_scroll_open(v):
    rustle = paper(0.55, 0.45, seed=240, lo=1200, hi=6000)
    rustle *= np.linspace(1, 0.4, len(rustle))
    return mix(woodblock(700, 0.08, 0.6, 0.02), (rustle, 0.04), (woodblock(560, 0.08, 0.5, 0.02), 0.55))


def sfx_realm_up(v):
    return room(mix(dizi(hz(penta(5)), 0.25, amp=0.5), (dizi(hz(penta(7)), 0.25, amp=0.5), 0.2),
                    (dizi(hz(penta(10)), 0.6, amp=0.55), 0.4), (gong(392, 1.2, 0.7, 0.6), 0.4),
                    (bell(hz(penta(15)), 0.8, 0.3, 0.4), 0.45)), 0.12, 0.15)


def sfx_achievement(v):
    return mix(arp([5, 7, 9, 10], 0.07, 0.6, bright=1.2, decay=0.35), (cymbal(0.4, 0.25, 0.15, seed=250), 0.21),
               *[(bell(hz(penta(15 + i)), 0.6, 0.25, 0.3), 0.25 + 0.05 * i) for i in range(3)])


def sfx_heal(v):
    return mix(bell(hz(penta(10)), 0.5, 0.45, 0.25, 2, 1.2), (bell(hz(penta(12)), 0.6, 0.45, 0.3, 2, 1.2), 0.09))


def sfx_talisman_trigger(v):
    return mix(bell(hz(penta(13)), 0.5, 0.6, 0.2, 3.5, 2), (woodblock(1800, 0.04, 0.2, 0.008), 0))


def sfx_weapon_trigger(v):
    return mix(whoosh(0.1, 2000, 8000, 0.5, seed=260), (bell(1975, 0.45, 0.5, 0.15, 2.76, 2.5), 0.05),
               (slap(0.03, 2000, 8000, 0.3), 0.05))


SFX = {  # id: (generador, variantes)
    'card_deal': (sfx_card_deal, 3), 'card_select': (sfx_card_select, 1),
    'card_deny': (sfx_card_deny, 1), 'card_play': (sfx_card_play, 1),
    'hit_light': (sfx_hit_light, 3), 'hit_heavy': (sfx_hit_heavy, 2),
    'block': (sfx_block, 1), 'player_hurt': (sfx_player_hurt, 2),
    'deflect': (sfx_deflect, 1), 'guard_up': (sfx_guard_up, 1),
    'enemy_windup': (sfx_enemy_windup, 1), 'turn_start': (sfx_turn_start, 1),
    'victory_stamp': (sfx_victory_stamp, 1), 'defeat_stamp': (sfx_defeat_stamp, 1),
    'fight_start': (sfx_fight_start, 1), 'enemy_drop': (sfx_enemy_drop, 1),
    'break': (sfx_break, 1), 'enemy_guard': (sfx_enemy_guard, 1),
    'enemy_charge': (sfx_enemy_charge, 1), 'enemy_skip': (sfx_enemy_skip, 1),
    'enemy_death': (sfx_enemy_death, 1), 'hero_victory': (sfx_hero_victory, 1),
    'hero_fall': (sfx_hero_fall, 1), 'stance_change': (sfx_stance_change, 1),
    'form_step': (sfx_form_step, 5), 'form_complete': (sfx_form_complete, 1),
    'form_broken': (sfx_form_broken, 1), 'breath_gain': (sfx_breath_gain, 1),
    'breath_spend': (sfx_breath_spend, 1), 'phase_two': (sfx_phase_two, 1),
    'end_rays': (sfx_end_rays, 1), 'ui_button': (sfx_ui_button, 1),
    'screen_transition': (sfx_screen_transition, 1), 'map_node': (sfx_map_node, 1),
    'reward_flip': (sfx_reward_flip, 3), 'reward_take': (sfx_reward_take, 1),
    'fountain_heal': (sfx_fountain_heal, 1), 'shrine_oath': (sfx_shrine_oath, 1),
    'legacy_seal': (sfx_legacy_seal, 1), 'offering': (sfx_offering, 1),
    'run_result': (sfx_run_result, 1),
    'tap': (sfx_tap, 1), 'scroll_open': (sfx_scroll_open, 1), 'realm_up': (sfx_realm_up, 1),
    'achievement': (sfx_achievement, 1), 'heal': (sfx_heal, 1),
    'talisman_trigger': (sfx_talisman_trigger, 1), 'weapon_trigger': (sfx_weapon_trigger, 1),
}


# ---------------------------------------------------------------- voces de enemigos

def _voice_kind(eid):
    """Arquetipo sonoro de cada enemigo, por palabras del id."""
    rules = [
        ('dragon', 'dragon'), ('dummy', 'wood'), ('golem', 'stone'), ('bronze', 'metal'),
        ('ox', 'wood_beast'), ('bat', 'bat'), ('salamander', 'lizard'), ('lion', 'beast'),
        ('ape', 'beast'), ('monkey', 'monkey'), ('pixiu', 'beast'), ('qilin', 'spirit_beast'),
        ('fox', 'spirit'), ('crane', 'bird'), ('fan', 'spirit'), ('mask', 'spirit'),
        ('puppet', 'spirit'), ('sword', 'blade'), ('bell', 'bellish'), ('guqin', 'strings'),
        ('lingzhi', 'plant'), ('lady', 'woman'), ('abbot', 'deep_man'), ('monk', 'man'),
        ('hermit', 'deep_man'), ('guard', 'man'), ('bandit', 'man'), ('disciple', 'young'),
    ]
    for key, kind in rules:
        if key in eid:
            return kind
    return 'man'


def enemy_voice(eid):
    kind = _voice_kind(eid)
    r = np.random.default_rng(sum(ord(c) * (i + 3) for i, c in enumerate(eid)))
    j = 0.92 + 0.16 * r.random()  # cada enemigo con su tono propio
    if kind == 'dragon':
        big = 'sleeping' in eid or 'dream' in eid
        return room(mix(growl(48 * j, 1.0 if big else 0.8, 1, seed=int(j * 100), bright=700),
                        (gong(150 * j, 1.0, 0.5, 0.6), 0.1), dagu(60, 0.6, 0.6)), 0.15, 0.15)
    if kind == 'wood':
        return mix(woodblock(420 * j, 0.12, 1, 0.04), (woodblock(360 * j, 0.15, 0.8, 0.05), 0.12))
    if kind == 'stone':
        return mix(lp(dagu(55 * j, 0.6, 1, 1, 0.2), 900), (lp(slap(0.2, 100, 900, 0.6, seed=5), 1000), 0.05))
    if kind == 'metal':
        return mix(gong(180 * j, 0.7, 0.7, 0.3), thump(70, 0.25, 0.8))
    if kind == 'wood_beast':
        return mix(growl(60 * j, 0.5, 0.7, bright=600), (woodblock(300 * j, 0.15, 0.8, 0.05), 0.05))
    if kind == 'bat':
        return mix(chirp(3200 * j, 5200 * j, 0.06, 0.6), (chirp(3600 * j, 5600 * j, 0.05, 0.5), 0.09),
                   (chirp(3000 * j, 4800 * j, 0.07, 0.4), 0.17), whoosh(0.25, 300, 1500, 0.3, seed=8))
    if kind == 'beast':
        return mix(growl(85 * j, 0.55, 1, seed=int(j * 50), bright=1300), voice_formant(140 * j, 0.4, 'o', 0.4, 0.4, rough=0.08))
    if kind == 'monkey':
        return mix(voice_formant(420 * j, 0.12, 'i', 0.8, 0.0), (voice_formant(500 * j, 0.12, 'i', 0.8, -0.2), 0.13),
                   (voice_formant(460 * j, 0.15, 'a', 0.7, 0.3), 0.26))
    if kind == 'spirit_beast':
        return room(mix(growl(110 * j, 0.5, 0.5, bright=1600), bell(hz(penta(12)), 0.8, 0.5, 0.35), (bell(hz(penta(14)), 0.7, 0.35, 0.3), 0.1)), 0.12, 0.2)
    if kind == 'spirit':
        return room(mix(dizi(hz(penta(9)) * j, 0.5, amp=0.5, breath=0.3, glide=-0.1), (bell(hz(penta(14)) * j, 0.6, 0.3, 0.3), 0.12)), 0.12, 0.2)
    if kind == 'bird':
        return mix(chirp(1800 * j, 2600 * j, 0.1, 0.6), (chirp(2000 * j, 1500 * j, 0.14, 0.5), 0.12), paper(0.2, 0.25, seed=9))
    if kind == 'blade':
        return mix(whoosh(0.25, 1500, 8000, 0.6, seed=12), (bell(2400 * j, 0.5, 0.5, 0.2, 2.76, 2), 0.15))
    if kind == 'bellish':
        return mix(bell(880 * j, 0.9, 0.7, 0.45, 2.4, 1.5), (bell(1320 * j, 0.7, 0.35, 0.3, 2.4, 1.2), 0.04))
    if kind == 'strings':
        return mix(*[(pluck(hz(penta(s)) * j, 0.6, 1, 0.35, 0.6), i * 0.06) for i, s in enumerate((4, 6, 8, 5))])
    if kind == 'plant':
        return mix(paper(0.3, 0.4, seed=14, lo=600, hi=3000), (bell(hz(penta(11)) * j, 0.5, 0.3, 0.3), 0.1))
    if kind == 'woman':
        return mix(voice_formant(330 * j, 0.32, 'a', 0.75, 0.2), (whoosh(0.3, 600, 3000, 0.3, seed=15), 0.05))
    if kind == 'deep_man':
        return voice_formant(105 * j, 0.38, 'o', 0.85, 0.3)
    if kind == 'young':
        return voice_formant(230 * j, 0.25, 'a', 0.85, 0.3)
    return voice_formant(160 * j, 0.3, 'a', 0.85, 0.3)


def sfx_lizard_fix(eid):
    """Salamandras: siseo con chasquido."""
    r = np.random.default_rng(len(eid) * 7)
    t = t_axis(0.42)
    hiss = bp(r.standard_normal(len(t)), 3000, 9000) * np.sin(np.pi * t / 0.42) ** 1.5
    hiss /= np.max(np.abs(hiss)) + 1e-9
    return mix(hiss * 0.6, (woodblock(1200, 0.05, 0.4, 0.01), 0.0))


# ---------------------------------------------------------------- escritura

def _norm(x, peak=PEAK):
    x = np.asarray(x, dtype=np.float64)
    m = np.max(np.abs(x))
    if m > 0:
        x = x / m * peak
    return x


def _trim(x):
    """Sin silencio al inicio."""
    idx = np.argmax(np.abs(x) > 1e-3)
    return x[idx:]


def write_sfx(name, x):
    x = fade_out(_norm(_trim(x)), 0.02)
    path = os.path.join(SFX_DIR, name + '.wav')
    sf.write(path, x.astype(np.float32), SR, subtype='PCM_16')
    return path


def make_sfx(only=None):
    os.makedirs(SFX_DIR, exist_ok=True)
    count = 0
    for sid, (gen, n) in SFX.items():
        if only and sid not in only:
            continue
        for v in range(n):
            name = sid if n == 1 else f'{sid}_{v + 1}'
            write_sfx(name, gen(v))
            count += 1
    with open(ENEMIES) as f:
        ids = [e['id'] for e in json.load(f)['enemies']]
    for eid in ids:
        name = f'enemy_{eid}'
        if only and name not in only:
            continue
        x = sfx_lizard_fix(eid) if _voice_kind(eid) == 'lizard' else enemy_voice(eid)
        write_sfx(name, x)
        count += 1
    print(f'efectos: {count} archivos en {os.path.relpath(SFX_DIR, ROOT)}')


# ---------------------------------------------------------------- música

def _pan(x, p):
    """p en -1..1 → estéreo de potencia constante."""
    a = (p + 1) * np.pi / 4
    return np.stack([x * np.cos(a), x * np.sin(a)], axis=1)


class Track:
    def __init__(self, length, tail=3.0):
        self.length = length
        self.buf = np.zeros((int((length + tail) * SR), 2))

    def add(self, x, at, pan=0.0, gain=1.0):
        i = int(at * SR)
        if i >= len(self.buf):
            return
        s = _pan(x * gain, pan)
        n = min(len(s), len(self.buf) - i)
        self.buf[i:i + n] += s[:n]

    def render_loop(self):
        """Pliega la cola sobre el inicio: el final empalma sin corte."""
        n = int(self.length * SR)
        out = self.buf[:n].copy()
        tail = self.buf[n:]
        out[:len(tail)] += tail
        return out

    def render_once(self, fade=0.4):
        out = self.buf.copy()
        last = np.max(np.nonzero(np.max(np.abs(out), axis=1) > 1e-4)[0]) + 1
        out = out[:last]
        k = int(fade * SR)
        out[-k:] *= np.linspace(1, 0, k)[:, None]
        return out


def _stereo_room(x, size=0.6, wet=0.18, seed=9):
    """Espacio corto para la música (sala de madera, no catedral)."""
    out = np.zeros((len(x) + int(size * SR), 2))
    for ch in range(2):
        r = np.random.default_rng(seed + ch)
        n = int(size * SR)
        ir = r.standard_normal(n) * np.exp(-np.arange(n) / (n / 6))
        ir = lp(ir, 5000)
        ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
        out[:len(x), ch] += x[:, ch]
        w = signal.fftconvolve(x[:, ch], ir)[:len(out)]
        out[:len(w), ch] += wet * w
    return out


def _fold(x, n):
    out = x[:n].copy()
    tail = x[n:]
    out[:len(tail)] += tail
    return out


def _motif(r, length, center=7, span=5):
    """Frase pentatónica: paso a paso, saltos chicos, termina en nota estable."""
    steps, s = [], center
    for i in range(length):
        s += int(r.choice([-2, -1, -1, 1, 1, 2, 0, 3, -3], p=[.1, .2, .15, .2, .15, .07, .05, .04, .04]))
        s = int(np.clip(s, center - span, center + span))
        steps.append(s)
    steps[-1] = center + int(r.choice([0, 5, -5])) if length > 3 else steps[-1]
    return steps


def _rhythm(r, beats, dense):
    """Duraciones en beats que suman `beats`."""
    out, left = [], beats
    while left > 1e-6:
        opts = [0.5, 1, 1, 1.5, 2] if not dense else [0.25, 0.5, 0.5, 0.5, 1, 1]
        d = float(r.choice([o for o in opts if o <= left] or [left]))
        out.append(d)
        left -= d
    return out


# Progresiones en grados de la pentatónica (raíz del bajo por compás)
PROG_BRIGHT = [0, 0, 3, 3, 4, 4, 2, 3]
PROG_DRIVE = [0, 0, 4, 3, 0, 0, 2, 4]
PROG_YU = [4, 4, 2, 3, 4, 4, 0, 3]  # modo 羽 (más tenso, no oscuro)


def compose(tid, bpm, bars, prog, base, intensity, lead='dizi', seed=1):
    """Arma un loop: percusión, bajo pulsado, acompañamiento y melodía."""
    r = np.random.default_rng(seed)
    beat = 60 / bpm
    bar = 4 * beat
    length = bars * bar
    tr = Track(length)
    motifs = [(_motif(r, 8), _rhythm(r, 8, intensity > 1)) for _ in range(3)]
    for b in range(bars):
        t0 = b * bar
        root = prog[b % len(prog)]
        section = (b // 8) % 4  # A A' B A''
        # --- percusión
        if intensity >= 1:
            for k in range(4):
                if k in (0, 2) or (intensity >= 2 and k == 3 and b % 2):
                    tr.add(dagu(95 if k == 0 else 110, 0.4, 1.0 if k == 0 else 0.7, 0.6, 0.16), t0 + k * beat, -0.1, 0.55)
            sub = 4 if intensity >= 2 else 2
            for k in range(4 * sub // 2):
                acc = 0.5 if k % 2 == 0 else 0.3
                tr.add(woodblock(1250 if k % 2 == 0 else 1500, 0.06, 1, 0.012), t0 + k * beat * 2 / sub, 0.35, acc * 0.5)
            if b % 4 == 0:
                tr.add(cymbal(0.9, 1, 0.3, seed=b), t0, 0.2, 0.25 + 0.1 * intensity)
            if intensity >= 3 and b % 8 == 7:
                for k in range(8):
                    tr.add(dagu(120, 0.2, 0.6 + 0.05 * k, 0.6, 0.07), t0 + 2 * beat + k * beat / 4, 0, 0.5)
        else:
            if b % 2 == 0:
                tr.add(woodblock(900, 0.08, 1, 0.02), t0, 0.3, 0.25)
            tr.add(woodblock(1200, 0.06, 1, 0.012), t0 + 2 * beat, 0.3, 0.18)
            if b % 8 == 0:
                tr.add(gong(330, 1.6, 1, 0.8), t0, -0.2, 0.18)
        if intensity >= 3 and b % 8 == 0:
            tr.add(gong(196, 2.0, 1, 1.0), t0, -0.25, 0.35)
        # --- bajo (guzheng grave)
        bass_note = hz(penta(root, base - 24))
        pat = [0, 2] if intensity < 2 else [0, 1.5, 2, 3.5]
        for k in pat:
            tr.add(pluck(bass_note, 1.2, 0.6, 0.6), t0 + k * beat, -0.15, 0.55)
        # --- acompañamiento: arpegio de guzheng
        chord = [root, root + 2, root + 3, root + 5]
        step = beat / (2 if intensity < 2 else 4) if intensity else beat
        for k in range(int(round(bar / step))):
            if intensity == 0 and k % 2:
                continue
            s = chord[k % len(chord)] if (k // 4) % 2 == 0 else chord[-1 - k % len(chord)]
            tr.add(pluck(hz(penta(s, base - 12)), 0.7, 1.0, 0.35), t0 + k * step, 0.3, 0.16 if intensity else 0.2)
        if lead == 'pipa' and intensity >= 2 and b % 2 == 1:
            # trémolo de pipa sobre la quinta
            n = hz(penta(root + 3, base))
            for k in range(8):
                tr.add(pluck(n, 0.2, 1.3, 0.08), t0 + 2 * beat + k * beat / 4, 0.4, 0.13)
        # --- melodía (frases de 2 compases)
        if b % 2 == 0 and not (section == 0 and b % 8 < 2 and intensity == 0):
            mi = [0, 0, 1, 2][section] if b % 4 == 0 else [1, 0, 2, 1][section]
            notes, rhythm = motifs[mi]
            shift = root if section == 2 else 0
            tt = t0
            for s, d in zip(notes, rhythm):
                if r.random() < 0.08:
                    tt += d * beat
                    continue
                f = hz(penta(s + shift, base))
                if lead == 'dizi' or (lead == 'mix' and section in (0, 3)):
                    tr.add(dizi(f, d * beat * 0.95 + 0.05, amp=1, breath=0.1), tt, -0.25, 0.36)
                else:
                    tr.add(pluck(f, max(0.4, d * beat * 1.4), 1.2, 0.4), tt, -0.25, 0.42)
                    if intensity >= 2:
                        tr.add(pluck(f * 2, 0.3, 1.1, 0.15), tt + 0.01, 0.25, 0.12)
                tt += d * beat
    mixd = _stereo_room(tr.buf, 0.5, 0.16, seed)
    out = _fold(mixd, int(length * SR))
    return out


def jingle(kind):
    tr = Track(8, tail=0)
    if kind == 'victory':
        for i, s in enumerate([5, 7, 9, 10]):
            tr.add(pluck(hz(penta(s)), 0.9, 1.2, 0.45), i * 0.13, -0.2, 0.6)
        tr.add(dizi(hz(penta(12)), 1.4, amp=0.7), 0.52, 0.1, 0.55)
        tr.add(gong(392, 2.0, 1, 0.9), 0.52, 0.2, 0.4)
        tr.add(dagu(90, 0.6, 1, 0.7), 0.52, 0, 0.6)
        tr.add(cymbal(1.0, 1, 0.35, seed=4), 0.52, 0.3, 0.3)
        for i, s in enumerate([10, 12, 14, 15]):
            tr.add(bell(hz(penta(s)), 0.8, 0.3, 0.35), 0.9 + i * 0.09, 0.4, 1)
    elif kind == 'defeat':
        # melancólico pero cálido: desciende y resuelve en la tónica mayor
        for i, s in enumerate([9, 7, 5, 4, 2]):
            tr.add(pluck(hz(penta(s)), 1.2, 0.8, 0.6), i * 0.32, -0.15, 0.55)
        tr.add(dizi(hz(penta(5)), 1.8, amp=0.5, vib=4.5), 1.6, 0.1, 0.45)
        tr.add(pluck(hz(penta(0, BASE_MIDI - 12)), 2.0, 0.6, 1.0), 1.6, -0.2, 0.5)
        tr.add(gong(262, 2.2, 1, 1.0), 1.6, 0.2, 0.22)
    else:  # run_won
        roll = [(dagu(100 + 3 * k, 0.3, 0.4 + 0.04 * k, 0.6, 0.1), 0.08 * k) for k in range(10)]
        for x, at in roll:
            tr.add(x, at, 0, 0.55)
        t1 = 0.85
        tr.add(gong(196, 3.0, 1, 1.4), t1, -0.2, 0.5)
        tr.add(cymbal(1.5, 1, 0.5, seed=8), t1, 0.3, 0.35)
        tr.add(dagu(70, 0.9, 1, 1, 0.3), t1, 0, 0.7)
        melody = [(7, 0.4), (9, 0.4), (10, 0.8), (12, 0.4), (14, 0.4), (15, 1.6)]
        tt = t1
        for s, d in melody:
            tr.add(dizi(hz(penta(s)), d * 0.95 + 0.05, amp=0.8), tt, -0.1, 0.5)
            tr.add(pluck(hz(penta(s - 5)), 1.0, 1.0, 0.5), tt, 0.25, 0.35)
            tt += d
        for i, s in enumerate(range(10, 20)):
            tr.add(bell(hz(penta(s)), 0.9, 0.25, 0.4), tt - 1.2 + i * 0.07, 0.4, 1)
        tr.add(gong(262, 2.5, 1, 1.2), tt - 0.2, 0.2, 0.3)
    return _stereo_room(tr.render_once(0.6), 0.6, 0.18)


MUSIC = {  # id: parámetros de compose (bpm, compases ⇒ loop de ~70–80 s)
    'music_menu': dict(bpm=76, bars=24, prog=PROG_BRIGHT, base=BASE_MIDI, intensity=0, lead='mix', seed=11),
    'music_training': dict(bpm=96, bars=28, prog=PROG_BRIGHT, base=BASE_MIDI + 2, intensity=1, lead='guzheng', seed=23),
    'music_combat': dict(bpm=120, bars=36, prog=PROG_DRIVE, base=BASE_MIDI, intensity=2, lead='pipa', seed=37),
    'music_elite': dict(bpm=132, bars=40, prog=PROG_YU, base=BASE_MIDI - 2, intensity=2, lead='dizi', seed=41),
    'music_boss': dict(bpm=140, bars=44, prog=PROG_YU, base=BASE_MIDI - 3, intensity=3, lead='mix', seed=53),
}


def write_music(name, x):
    x = _norm(x, 10 ** (-1.5 / 20))
    path = os.path.join(MUSIC_DIR, name + '.ogg')
    sf.write(path, x.astype(np.float32), SR, format='OGG', subtype='VORBIS')
    print(f'  {name}: {len(x) / SR:.1f} s, {os.path.getsize(path) / 1e6:.2f} MB')


def make_music(only=None):
    os.makedirs(MUSIC_DIR, exist_ok=True)
    for mid, params in MUSIC.items():
        if only and mid not in only:
            continue
        write_music(mid, compose(mid, **params))
    for kind in ('victory', 'defeat', 'run_won'):
        name = f'jingle_{kind}'
        if only and name not in only:
            continue
        write_music(name, jingle(kind))


if __name__ == '__main__':
    args = sys.argv[1:]
    if not args:
        make_sfx()
        make_music()
    elif args == ['sfx']:
        make_sfx()
    elif args == ['music']:
        make_music()
    else:
        make_sfx(set(args))
        make_music(set(args))
