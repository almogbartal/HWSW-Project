import pyperf
import numpy as np

__contact__ = "collinwinter@google.com (Collin Winter)"
DEFAULT_ITERATIONS = 20000
DEFAULT_REFERENCE = 'sun'

PI = 3.14159265358979323
SOLAR_MASS = 4 * PI * PI
DAYS_PER_YEAR = 365.24

# Initial dictionary of bodies
BODIES_INIT = {
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

BODY_NAMES = list(BODIES_INIT.keys())


def get_system_arrays():
    positions = np.array([BODIES_INIT[name][0] for name in BODY_NAMES], dtype=np.float64)
    velocities = np.array([BODIES_INIT[name][1] for name in BODY_NAMES], dtype=np.float64)
    masses = np.array([BODIES_INIT[name][2] for name in BODY_NAMES], dtype=np.float64)
    return positions, velocities, masses


def advance(dt, n, positions, velocities, masses):
    num_bodies = len(masses)
    # Prepare indices for upper/lower triangle interactions to avoid redundant calculations
    i_indices, j_indices = np.triu_indices(num_bodies, k=1)

    for _ in range(n):
        # Vectorized coordinate differences for all pairs at once
        dx = positions[i_indices, 0] - positions[j_indices, 0]
        dy = positions[i_indices, 1] - positions[j_indices, 1]
        dz = positions[i_indices, 2] - positions[j_indices, 2]

        dist_sq = dx * dx + dy * dy + dz * dz
        mag = dt * (dist_sq ** (-1.5))

        b1m = masses[i_indices] * mag
        b2m = masses[j_indices] * mag

        # Update velocities using vectorized operations
        velocities[i_indices, 0] -= dx * b2m
        velocities[i_indices, 1] -= dy * b2m
        velocities[i_indices, 2] -= dz * b2m

        velocities[j_indices, 0] += dx * b1m
        velocities[j_indices, 1] += dy * b1m
        velocities[j_indices, 2] += dz * b1m

        # Update positions
        positions += dt * velocities


def report_energy(positions, velocities, masses):
    num_bodies = len(masses)
    i_idx, j_idx = np.triu_indices(num_bodies, k=1)
    
    dx = positions[i_idx, 0] - positions[j_idx, 0]
    dy = positions[i_idx, 1] - positions[j_idx, 1]
    dz = positions[i_idx, 2] - positions[j_idx, 2]
    
    potential = np.sum((masses[i_idx] * masses[j_idx]) / np.sqrt(dx * dx + dy * dy + dz * dz))
    kinetic = 0.5 * np.sum(masses * np.sum(velocities ** 2, axis=1))
    
    return kinetic - potential


def offset_momentum(reference_name, positions, velocities, masses):
    ref_idx = BODY_NAMES.index(reference_name)
    px = np.sum(velocities[:, 0] * masses)
    py = np.sum(velocities[:, 1] * masses)
    pz = np.sum(velocities[:, 2] * masses)
    
    velocities[ref_idx, 0] = -px / masses[ref_idx]
    velocities[ref_idx, 1] = -py / masses[ref_idx]
    velocities[ref_idx, 2] = -pz / masses[ref_idx]


def bench_nbody(loops, reference, iterations):
    positions, velocities, masses = get_system_arrays()
    offset_momentum(reference, positions, velocities, masses)

    t0 = pyperf.perf_counter()

    for _ in range(loops):
        report_energy(positions, velocities, masses)
        advance(0.01, iterations, positions, velocities, masses)
        report_energy(positions, velocities, masses)

    return pyperf.perf_counter() - t0


def add_cmdline_args(cmd, args):
    cmd.extend(("--iterations", str(args.iterations)))


if __name__ == '__main__':
    runner = pyperf.Runner(add_cmdline_args=add_cmdline_args)
    runner.metadata['description'] = "Fully vectorized NumPy n-body benchmark"
    runner.argparser.add_argument("--iterations",
                                  type=int, default=DEFAULT_ITERATIONS,
                                  help="Number of nbody advance() iterations "
                                       "(default: %s)" % DEFAULT_ITERATIONS)
    runner.argparser.add_argument("--reference",
                                  type=str, default=DEFAULT_REFERENCE,
                                  help="nbody reference (default: %s)"
                                       % DEFAULT_REFERENCE)

    args = runner.parse_args()
    runner.bench_time_func('nbody_vectorized', bench_nbody,
                           args.reference, args.iterations)
