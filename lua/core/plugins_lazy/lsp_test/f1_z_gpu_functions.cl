
#define TS 16
/*
    Calculate the squared euclidian norm (distance) between two List of vectors.
    || A - B ||²_2

    Points in that vector space have dimension LATENT_DIM.


    A:  [M x LATENT_DIM] matrix (companies). There are M companies. One Company takes D number to represent
    B:  [N x LATENT_DIM] matrix (resources). There are N ressources. One ressource takes D number to represent
    output:  [M x N] output. output[i,j] = distance_sq(company[i], ressource[j])
    LATENT_DIM: The minimal dimensionality of the vector space for a "good enough" representation
*/
__kernel void distance_sq_matrix(
    __global const float* A, // [M x D] matrix (companies)
    __global const float* B, // [N x D] matrix (resources)
    __global float* output,  // [M x N] output
    const int M,
    const int N,
    const int LATENT_DIM) {
	// new
	// new 2

	// Using row major storage: Move left to right, then down.

	// Thread identifiers
	const int group_id_i = get_group_id(0); // [0..4) Which 32x32 square. The i index.
	const int group_id_j = get_group_id(1); // [0..3] Which 32x32 square. The j index.

	const int localRow = get_local_id(0);             // Local row ID (max: TS) : The i position in the tile.
	const int localCol = get_local_id(1);             // Local col ID (max: TS) : The j position in the tile
	const int globalRow = TS * group_id_i + localRow; // Row ID of C (0..M)
	const int globalCol = TS * group_id_j + localCol; // Col ID of C (0..N)

	// Local memory to fit a tile of TS*TS elements of A and B
	__local float Asub[TS][TS];
	__local float Bsub[TS][TS];

	const int T = (LATENT_DIM + TS - 1) / TS;
	// = floor ({LATENT_DIM - 1}/TS) + 1
	// Add one cause we do t < T. if <= no need for +1
	// L £ [0, 1[ : 0
	// L £ [1, 33[ : 1
	// L $ [33, 65[ : 2
	// L(1) = 1, L(32) = 1, L(33) = 2, ...
	float sum = 0.0f;
	for (int t = 0; t < T; t++) {

		int tiled_k = t * TS + localCol;

		if (globalRow < M && tiled_k < LATENT_DIM) {
			Asub[localRow][localCol] = A[globalRow * LATENT_DIM + tiled_k];
		} else {
			Asub[localRow][localCol] = 0.0f;
		}

		if (globalCol < N && tiled_k < LATENT_DIM) {
			Bsub[localRow][localCol] = B[globalCol * LATENT_DIM + tiled_k];
		} else {
			Bsub[localRow][localCol] = 0.0f;
		}

		barrier(CLK_LOCAL_MEM_FENCE);

		// Compute partial sum for this tile
		for (int k = 0; k < TS; ++k) {
			float diff = Asub[localRow][k] - Bsub[localCol][k]; // Bsub is transposed
			sum += diff * diff;
		}

		barrier(CLK_LOCAL_MEM_FENCE);

		/* float diff = A[i * LATENT_DIM + k] - B[j * LATENT_DIM + k]; */
		// diff =  A[i,k] - B[j,k]
	}

	if (globalRow < M && globalCol < N) {
		output[globalRow * N + globalCol] = sum;
	}
}

__kernel void distance_sq_matrix_simple(
    __global const float* A, // [M x D] matrix (companies)
    __global const float* B, // [N x D] matrix (resources)
    __global float* output,  // [M x N] output
    const int M,
    const int N,
    const int LATENT_DIM) {

	// start of the function
	int i = get_global_id(0); // Company index (0..M-1)
	int j = get_global_id(1); // Resource index (0..N-1)
	// Using row major storage: Move left to right, then down.

	float sum = 0.0f;
	for (int k = 0; k < LATENT_DIM; k++) {
		float diff = A[i * LATENT_DIM + k] - B[j * LATENT_DIM + k];
		// diff =  A[i,k] - B[j,k]
		sum += diff * diff;
	}

	output[i * N + j] = sum; // Store squared distance
	                         // ./gpucore.3106979
}

/*
Takes an incidence matrix of distance between points, and return an incidence matrix of probabilities.
Aka: Distance between Element M and Element N, to probability of Connecting element M and element N.

squared_diff: [M x N] matrix
probablities: [M x N] matrix
M: Matrix dimension vv
N: Matrix dimension -->
SIGMA_SQ = the LATENT_DIM/6 * SIGMA_RATIO²
Tune SIGMA_RATIO.

ONE_OVER_SIGMA_SQRT_2PI: the normalisation of gaussian for sum prob = 1.
 */
__kernel void probability_matrix(
    __global const float* squared_diff,
    __global float* probablities,
    const int M,
    const int N,
    const float SCALE_FACTOR,
    const float ONE_OVER_SIGMA_SQRT_2PI) {

	// start of the function
	int i = get_global_id(0); // Company index (0..M-1)
	int j = get_global_id(1); // Resource index (0..N-1)
	                          // Using row major storage: Move left to right, then down.

	// Sigma_sq = (latent_dim/6) *sigma_ratio^2
	// 1/sigma_sq = scale_factor = 6 / ( latent_dim * sigma_ratio^2 )
	float norm_sq_diff = squared_diff[i * N + j] * SCALE_FACTOR;

	probablities[i * N + j] = ONE_OVER_SIGMA_SQRT_2PI * exp(-norm_sq_diff / 2);
	// one over sigma sqrt 2pi... idk if i should keep it.
}

inline float rand_float01(uint* state);

__kernel void generate_randoms(__global float* output) {
	int gid = get_global_id(0);
	uint state = (uint)(gid); // Simple per-thread seed

	float rnd = rand_float01(&state);
	output[gid] = rnd;
}

// global size is (M*N)
__kernel void probability_check(
    __global const float* probabilities,
    __global const float* probabilities_compare,
    __global int* probabilies_pass

) {

	int idx = get_global_id(0);
	probabilies_pass[idx] = probabilities_compare[idx] <= probabilities[idx];
}

__kernel void probability_check_2d(
    __global const float* probabilities,
    __global const float* random_vals,
    __global int* pass,
    const int M,
    const int N

) {

	int i = get_global_id(0);
	int j = get_global_id(1);
	int idx = i * N + j;
	if (i < M && j < N) {
		pass[idx] = random_vals[idx] <= probabilities[idx];
	}
}

#define ITEMS_PER_THREAD 4
__kernel void fast_compare(
    __global const float* probabilities,
    __global const float* probabilities_compare,
    __global uchar* probabilities_pass,
    const int N) {
	const int gid = get_global_id(0);
	const int work_per_thread = 16;
	const int base_idx = gid * work_per_thread;

	if (base_idx + work_per_thread > N)
		return; // bounds check

	// SIMD load
	float16 a = vload16(0, probabilities + base_idx);
	float16 b = vload16(0, probabilities_compare + base_idx);

	// Vectorized comparison and convert to uchar16 (0 or 1)
	uchar16 result = convert_uchar16(a <= b);
	// without loop, cause 255 for true.

	// SIMD store
	vstore16(result, 0, probabilities_pass + base_idx);
}

inline uint lcg_rand(uint* state) {
	*state = (*state) * 1664525u + 1013904223u;
	return *state;
}

inline float rand_float01(uint* state) {
	return (float)(lcg_rand(state)) / (float)0xFFFFFFFFu;
}

__kernel void probabilities_check_LGR(
    __global const float* probablities,
    __global int* probabilities_pass
    // global size is (M*N)
) {

	int idx = get_global_id(0);
	// Seed RNG based on unique ID
	uint state = (uint)(idx);         // deterministic seed per thread
	float rnd = rand_float01(&state); // random number in [0, 1)

	probabilities_pass[idx] = rnd <= probablities[idx];
}

__kernel void generate_random_incidence_tensor(
    __global const float* A, // [M x D] matrix (companies)
    __global const float* B, // [N x D] matrix (resources)
    __global float* output,  // [ M x N x 2] output
    const int M,
    const int N,
    const int LATENT_DIM,
    const float SCALE_FACTOR,
    const float ONE_OVER_SIGMA_SQRT_2PI) {

	// start of the function
	int i = get_global_id(0); // Company index (0..M-1)
	int j = get_global_id(1); // Resource index (0..N-1)

	float distance_sq = 0.0f;
	for (int k = 0; k < LATENT_DIM; k++) {
		float diff = A[i * LATENT_DIM + k] - B[j * LATENT_DIM + k];
		// diff =  A[i,k] - B[j,k]
		distance_sq += diff * diff;
	}

	float norm_sq_diff = distance_sq * SCALE_FACTOR;

	float probablity = ONE_OVER_SIGMA_SQRT_2PI * exp(-norm_sq_diff / 2);

	int idx = i * N + j;
	int base = idx * 2;
	uint state = (uint)(idx);         // deterministic seed per thread
	float rnd = rand_float01(&state); // random number in [0, 1)

	float connected = rnd <= probablity;

	output[base] = probablity;
	output[base + 1] = connected;
}

__kernel void count_ones(
    __global const int* matrix,
    __global int* result,
    const int size) {

	int i = get_global_id(0);

	if (i < size && matrix[i] == 1) {
		atomic_add(result, 1);
	}
}

__kernel void debug_copy_buffers(
    __global const float* probabilities,
    __global const float* random_vals,
    __global float* output_probabilities,
    __global float* output_random_vals) {
	int idx = get_global_id(0);
	output_probabilities[idx] = probabilities[idx];
	output_random_vals[idx] = random_vals[idx];
}
