# not really correct
include common.mk

test_csr: test_csr.cu ../rt/include/csr_graph.h
	nvcc -g $(CUDA_ARCH) $(INCLUDES) -o $@ $<
