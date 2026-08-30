"""
N-body benchmark optimized with Numba (JIT compilation).
Eliminates Python interpreter overhead entirely.
"""

import math
import numpy as np
import numba
import pyperf

DEFAULT_ITERATIONS = 20000
DEFAULT_REFERENCE = 'sun'

PI = 3.14159265358979323
SOLAR_MASS = 4 * PI * PI
DAYS_PER_YEAR = 365.24

BODIES = {
    'sun': ([0.0, 0.0, 0.0], [0.0, 0.0, 0.0], SOLAR_MASS),

    'jupiter': ([4.84143144246472090e+00,
                 -1.16032004402742839e+00,
                 -1.03622044471123109e-01],
                [1.66007664274403694e-03 * DAYS_PER_YEAR,
                 7.69901118419740425e-03 * DAYS_PER_YEAR,
                 -6.90460016972063023e-05 * DAYS_PER_YEAR],
                9.54791938424326609e-04 * SOLAR_MASS),

    'saturn': ([8.34336671824457987e+00,
                4.12479856412430479e+00,
                -4.03523417114321381e-01],
               [-2.76742510726862411e-03 * DAYS_PER_YEAR,
                4.99852801234917238e-03 * DAYS_PER_YEAR,
                2.30417297573763929e-05 * DAYS_PER_YEAR],
               2.85885980666130812e-04 * SOLAR_MASS),

    'uranus': ([1.28943695621391310e+01,
                -1.51111514016986312e+01,
                -2.23307578892655734e-01],
               [2.96460137564761618e-03 * DAYS_PER_YEAR,
                2.37847173959480950e-03 * DAYS_PER_YEAR,
                -2.96589568540237556e-05 * DAYS_PER_YEAR],
               4.36624404335156298e-05 * SOLAR_MASS),

    'neptune': ([1.53796971148509165e+01,
                 -2.59193146099879641e+01,
                 1.79258772950371181e-01],
                [2.68067772490389322e-03 * DAYS_PER_YEAR,
                 1.62824170038242295e-03 * DAYS_PER_YEAR,
                 -9.51592254519715870e-05 * DAYS_PER_YEAR],
                5.15138902046611451e-05 * SOLAR_MASS)}


# ליבת החישוב המקומפלת לשפת מכונה (C-level execution)
@numba.njit(fastmath=True)
def _advance_jit(r, v, m, dt, n):
    num_bodies = len(m)
    for _ in range(n):
        # O(n^2) לולאות זוגות רצות בזיכרון רציף ללא Overhead של פייתון
        for i in range(num_bodies):
            for j in range(i + 1, num_bodies):
                dx = r[i, 0] - r[j, 0]
                dy = r[i, 1] - r[j, 1]
                dz = r[i, 2] - r[j, 2]

                d2 = dx * dx + dy * dy + dz * dz
                mag = dt / (d2 * math.sqrt(d2))

                b1m = m[i] * mag
                b2m = m[j] * mag

                v[i, 0] -= dx * b2m
                v[i, 1] -= dy * b2m
                v[i, 2] -= dz * b2m
                v[j, 0] += dx * b1m
                v[j, 1] += dy * b1m
                v[j, 2] += dz * b1m

        for i in range(num_bodies):
            r[i, 0] += dt * v[i, 0]
            r[i, 1] += dt * v[i, 1]
            r[i, 2] += dt * v[i, 2]


@numba.njit(fastmath=True)
def _report_energy_jit(r, v, m):
    e = 0.0
    num_bodies = len(m)
    for i in range(num_bodies):
        for j in range(i + 1, num_bodies):
            dx = r[i, 0] - r[j, 0]
            dy = r[i, 1] - r[j, 1]
            dz = r[i, 2] - r[j, 2]
            d = math.sqrt(dx * dx + dy * dy + dz * dz)
            e -= (m[i] * m[j]) / d

        vx = v[i, 0]
        vy = v[i, 1]
        vz = v[i, 2]
        e += m[i] * (vx * vx + vy * vy + vz * vz) * 0.5
    return e


def offset_momentum(ref_idx, v, m):
    px = np.sum(v[:, 0] * m)
    py = np.sum(v[:, 1] * m)
    pz = np.sum(v[:, 2] * m)
    v[ref_idx, 0] = -px / m[ref_idx]
    v[ref_idx, 1] = -py / m[ref_idx]
    v[ref_idx, 2] = -pz / m[ref_idx]


def bench_nbody(loops, reference, iterations):
    keys = list(BODIES.keys())
    ref_idx = keys.index(reference)

    r_init = np.array([BODIES[k][0] for k in keys], dtype=np.float64)
    v_init = np.array([BODIES[k][1] for k in keys], dtype=np.float64)
    m_init = np.array([BODIES[k][2] for k in keys], dtype=np.float64)

    offset_momentum(ref_idx, v_init, m_init)

    # Warmup קומפילציה (כדי לא למדוד את זמן ה-JIT עצמו)
    _advance_jit(r_init.copy(), v_init.copy(), m_init, 0.01, 1)
    _report_energy_jit(r_init, v_init, m_init)

    t0 = pyperf.perf_counter()
    for _ in range(loops):
        r = r_init.copy()
        v = v_init.copy()
        _report_energy_jit(r, v, m_init)
        _advance_jit(r, v, m_init, 0.01, iterations)
        _report_energy_jit(r, v, m_init)

    return pyperf.perf_counter() - t0


def add_cmdline_args(cmd, args):
    cmd.extend(("--iterations", str(args.iterations)))


if __name__ == '__main__':
    runner = pyperf.Runner(add_cmdline_args=add_cmdline_args)
    runner.metadata['description'] = "Numba-optimized n-body benchmark"
    runner.argparser.add_argument("--iterations",
                                  type=int, default=DEFAULT_ITERATIONS,
                                  help="Number of nbody advance() iterations (default: %s)" % DEFAULT_ITERATIONS)
    runner.argparser.add_argument("--reference",
                                  type=str, default=DEFAULT_REFERENCE,
                                  help="nbody reference (default: %s)" % DEFAULT_REFERENCE)

    args = runner.parse_args()
    runner.bench_time_func('nbody', bench_nbody, args.reference, args.iterations)
