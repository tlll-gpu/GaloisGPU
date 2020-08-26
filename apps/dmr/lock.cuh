/*
 * The code is part of our project called TLLL, a thread-level locking library on GPUs. 
 * Copyright (C) 2020, Beihang University, Capital Normal Univeristy. All rights reserved.
 *
 * Author: Lan Gao
 *
 */
#ifndef LOCK_H_
#define LOCK_H_
#define MAX_THREADBLOCK_SIZE 1024
#define WARP_SIZE 32
#define NUM_GLOBALLOCKS 1024*1024
#define GLOBALLOCKMSK (NUM_GLOBALLOCKS-1)
#define GLOBALLOCKHASH(a)    ((((unsigned int)(a))>>2)&(unsigned int)(GLOBALLOCKMSK))
__constant__ unsigned int *g_globalLocks;
unsigned int *d_globalLocks;
void initLocks(){
	cudaMalloc((void **)&d_globalLocks, NUM_GLOBALLOCKS * sizeof(unsigned int));
	cudaMemset(d_globalLocks, 0, NUM_GLOBALLOCKS * sizeof(unsigned int));
	cudaMemcpyToSymbol(g_globalLocks, &d_globalLocks, sizeof(unsigned int *));
	printf("GPU-STM-HV, Num of global locks: %dMB\n", NUM_GLOBALLOCKS*sizeof(unsigned int)/(1024*1024));
}

void freeLocks(){
	cudaFree(d_globalLocks);
}

__device__ int lock(int *addr){
	__shared__ unsigned int failBits[MAX_THREADBLOCK_SIZE/WARP_SIZE];
	failBits[threadIdx.x/32] = 0;
	int tid = threadIdx.x + blockIdx.x*blockDim.x;
	unsigned int lockFor = GLOBALLOCKHASH(addr);
	unsigned int globalLock = atomicCAS(&g_globalLocks[lockFor],0,((tid<<1)+1));

        if((globalLock)==((tid<<1)+1)) return 1;
        if(globalLock!=0){//try to steal
          unsigned int mask =__ballot(1);
          //printf("%d try to steal RW lock!!\n",tid);
          unsigned int preOwner = globalLock>>1;
          if(((preOwner>>5) == (tid>>5))&&(preOwner>tid)&&(((mask >>(preOwner%32))& 1) == 1)){
          atomicOr(&failBits[threadIdx.x/32], 1<<(preOwner%32));
          if((failBits[threadIdx.x/32] & (1<<(tid%32))) == 0)
            atomicExch(&g_globalLocks[lockFor],((tid<<1)+1));
          if((atomicOr(&g_globalLocks[lockFor],0)>>1)!=tid){ //check whether steal success
            atomicOr(&failBits[threadIdx.x/32], 1<<(tid%32));
          }
        }else{
          atomicOr(&failBits[threadIdx.x/32], 1<<(tid%32));
        }
      }
      //__threadfence();
      if((failBits[threadIdx.x/32] & (1<<(tid%32))) == 0){
        return 1;
      }else{
        //printf("lock: %d, tread:%d\n",globalLock,tid);
        return 0;
      }
}

__device__ void unlock(int *addr){
	int tid = threadIdx.x + blockIdx.x*blockDim.x;
	unsigned int lockFor = GLOBALLOCKHASH(addr);
	if(g_globalLocks[lockFor]==((tid<<1)+1)){
		atomicExch(&g_globalLocks[lockFor], 0);
	}
	//__threadfence();
}

#endif /* LOCK_H_ */
