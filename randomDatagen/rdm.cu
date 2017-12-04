#include <stdio.h>
#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include <assert.h>
#define MIN 500
#define MAX 600

// #define ITER 10000000

#define DSIZE 72
#define nTPB 256


__global__ void setup_kernel(curandState *state,unsigned long seed){

  int idx = threadIdx.x+blockDim.x*blockIdx.x;
  curand_init(seed, idx, 0, &state[idx]);
}
// __global__ void generate_kernel(curandState *my_curandstate, const unsigned int n, 
// const unsigned *max_rand_int, const unsigned *min_rand_int,  unsigned int *result){

__global__ void randfloat(curandState *state,const unsigned *min_rand_int,
			const unsigned *max_rand_int, float *result)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	
  	
		float myrandf = curand_uniform(state);
		myrandf *= (max_rand_int[idx] - min_rand_int[idx]+ 0.999999);
		myrandf += min_rand_int[idx];
		
	    result[idx]=myrandf;
	
}

int main(){

  curandState *d_state;
  cudaMalloc(&d_state, sizeof(curandState));
  float *d_result, *h_result;
  unsigned *d_max_rand_int, *h_max_rand_int, *d_min_rand_int, *h_min_rand_int;

  cudaMalloc(&d_result, (MAX-MIN+1)* sizeof(float));
  h_result = (float *)malloc(((MAX-MIN+1))*sizeof(float));

    
  cudaMalloc(&d_max_rand_int, sizeof(unsigned));
  h_max_rand_int = (unsigned *)malloc(sizeof(unsigned));
  cudaMalloc(&d_min_rand_int, sizeof(unsigned));
  h_min_rand_int = (unsigned *)malloc(sizeof(unsigned));

  cudaMemset(d_result, 0, (MAX-MIN+1)*sizeof(float));
  setup_kernel<<<5,5>>>(d_state,time(NULL));
  *h_max_rand_int = MAX;
  *h_min_rand_int = MIN;

  cudaMemcpy(d_max_rand_int, h_max_rand_int, sizeof(unsigned), cudaMemcpyHostToDevice);
  cudaMemcpy(d_min_rand_int, h_min_rand_int, sizeof(unsigned), cudaMemcpyHostToDevice);

  randfloat<<<2,18>>>(d_state,d_min_rand_int,d_max_rand_int, d_result);

  cudaMemcpy(h_result, d_result,(MAX-MIN+1) * sizeof(float), cudaMemcpyDeviceToHost);
  int index=0;
  for (int i = 0; i < (MAX-MIN+1);index++)
  {
    printf("%d %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f \n" ,index,
     h_result[i], h_result[i+1], h_result[i+2],
     h_result[i+3], h_result[i+4], h_result[i+5],
     h_result[i+6], h_result[i+7], h_result[i+9]);
    i=i+9;

  }



/* 
  curandState *d_state;
  cudaMalloc(&d_state, sizeof(curandState));
  unsigned *d_result, *h_result;
  unsigned *d_max_rand_int, *h_max_rand_int, *d_min_rand_int, *h_min_rand_int;
  cudaMalloc(&d_result, (MAX-MIN+1) * sizeof(unsigned));
  h_result = (unsigned *)malloc((MAX-MIN+1)*sizeof(unsigned));
  cudaMalloc(&d_max_rand_int, sizeof(unsigned));
  h_max_rand_int = (unsigned *)malloc(sizeof(unsigned));
  cudaMalloc(&d_min_rand_int, sizeof(unsigned));
  h_min_rand_int = (unsigned *)malloc(sizeof(unsigned));
  cudaMemset(d_result, 0, (MAX-MIN+1)*sizeof(unsigned));
  setup_kernel<<<1,1>>>(d_state,time(NULL));

  *h_max_rand_int = MAX;
  *h_min_rand_int = MIN;
  cudaMemcpy(d_max_rand_int, h_max_rand_int, sizeof(unsigned), cudaMemcpyHostToDevice);
  cudaMemcpy(d_min_rand_int, h_min_rand_int, sizeof(unsigned), cudaMemcpyHostToDevice);
  generate_kernel<<<1,1>>>(d_state, ITER, d_max_rand_int, d_min_rand_int, d_result);
  cudaMemcpy(h_result, d_result, (MAX-MIN+1) * sizeof(unsigned), cudaMemcpyDeviceToHost);
  printf("Bin:    Count: \n");
  for (int i = MIN; i <= MAX; i++)
    printf("%d    %d\n", i, h_result[i-MIN]);

  return 0;*/
}


// $ nvcc -arch=sm_20 -o t527 t527.cu -lcurand
// $ cuda-memcheck ./t527
// ========= CUDA-MEMCHECK
// Bin:    Count:
// 2    1665496
// 3    1668130
// 4    1667644
// 5    1667435
// 6    1665026
// 7    1666269
// ========= ERROR SUMMARY: 0 errors
// $