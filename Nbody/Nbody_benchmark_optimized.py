import pyperf

__contact__ = "collinwinter@google.com (Collin Winter)"
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
                5.15138902046611451e-05 * SOLAR_MASS)
}


# Convert the nested body representation into separate arrays.
# This representation is independent of the number of bodies.
SYSTEM = list(BODIES.values())

X = [body[0][0] for body in SYSTEM]
Y = [body[0][1] for body in SYSTEM]
Z = [body[0][2] for body in SYSTEM]

VX = [body[1][0] for body in SYSTEM]
VY = [body[1][1] for body in SYSTEM]
VZ = [body[1][2] for body in SYSTEM]

MASS = [body[2] for body in SYSTEM]

PAIRS = []
num_bodies = len(SYSTEM)

for i in range(num_bodies - 1):
    for j in range(i + 1, num_bodies):
        PAIRS.append((i, j))


def advance(dt, n):
    for _ in range(n):

        for i, j in PAIRS:
            dx = X[i] - X[j]
            dy = Y[i] - Y[j]
            dz = Z[i] - Z[j]

            mag = dt * (
                (dx * dx + dy * dy + dz * dz) ** (-1.5)
            )

            b1m = MASS[i] * mag
            b2m = MASS[j] * mag

            VX[i] -= dx * b2m
            VY[i] -= dy * b2m
            VZ[i] -= dz * b2m

            VX[j] += dx * b1m
            VY[j] += dy * b1m
            VZ[j] += dz * b1m

        for i in range(num_bodies):
            X[i] += dt * VX[i]
            Y[i] += dt * VY[i]
            Z[i] += dt * VZ[i]


def report_energy():
    e = 0.0

    for i, j in PAIRS:
        dx = X[i] - X[j]
        dy = Y[i] - Y[j]
        dz = Z[i] - Z[j]

        e -= (
            MASS[i] * MASS[j]
        ) / ((dx * dx + dy * dy + dz * dz) ** 0.5)

    for i in range(num_bodies):
        e += (
            MASS[i] *
            (VX[i] * VX[i] +
             VY[i] * VY[i] +
             VZ[i] * VZ[i])
            / 2.0
        )

    return e


def offset_momentum(reference):
    px = 0.0
    py = 0.0
    pz = 0.0

    for i in range(num_bodies):
        px -= VX[i] * MASS[i]
        py -= VY[i] * MASS[i]
        pz -= VZ[i] * MASS[i]

    VX[reference] = px / MASS[reference]
    VY[reference] = py / MASS[reference]
    VZ[reference] = pz / MASS[reference]


def bench_nbody(loops, reference, iterations):
    offset_momentum(reference)

    t0 = pyperf.perf_counter()

    for _ in range(loops):
        report_energy()
        advance(0.01, iterations)
        report_energy()

    return pyperf.perf_counter() - t0


def add_cmdline_args(cmd, args):
    cmd.extend(("--iterations", str(args.iterations)))


if __name__ == '__main__':
    runner = pyperf.Runner(add_cmdline_args=add_cmdline_args)

    runner.metadata['description'] = "optimized n-body benchmark"

    runner.argparser.add_argument(
        "--iterations",
        type=int,
        default=DEFAULT_ITERATIONS,
        help="Number of nbody advance() iterations "
             "(default: %s)" % DEFAULT_ITERATIONS
    )

    runner.argparser.add_argument(
        "--reference",
        type=str,
        default=DEFAULT_REFERENCE,
        help="nbody reference (default: %s)" % DEFAULT_REFERENCE
    )

    args = runner.parse_args()

    reference_index = list(BODIES.keys()).index(args.reference)

    runner.bench_time_func(
        'nbody_optimized',
        bench_nbody,
        reference_index,
        args.iterations
    )
