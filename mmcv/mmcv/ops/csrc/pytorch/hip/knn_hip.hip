// !!! This is a file automatically generated by hipify!!!
#include "hip/hip_runtime.h"
// Copyright (c) OpenMMLab. All rights reserved
// Modified from
// https://github.com/CVMI-Lab/PAConv/tree/main/scene_seg/lib/pointops/src/knnquery_heap

#include <cmath>
#include <cstdio>

#include "../hip/knn_hip_kernel.cuh"
#include "pytorch_hip_helper.hpp"

void KNNForwardCUDAKernelLauncher(int b, int n, int m, int nsample,
                                  const Tensor xyz, const Tensor new_xyz,
                                  Tensor idx, Tensor dist2) {
  // param new_xyz: (B, m, 3)
  // param xyz: (B, n, 3)
  // param idx: (B, m, nsample)

  at::hip::HIPGuardMasqueradingAsCUDA device_guard(new_xyz.device());
  hipStream_t stream = at::hip::getCurrentHIPStreamMasqueradingAsCUDA();

  // blockIdx.x(col), blockIdx.y(row)
  dim3 blocks(GET_BLOCKS(m, THREADS_PER_BLOCK), b);
  dim3 threads(THREADS_PER_BLOCK);

  AT_DISPATCH_FLOATING_TYPES_AND_HALF(
      new_xyz.scalar_type(), "knn_forward_cuda_kernel", [&] {
       hipLaunchKernelGGL(( knn_forward_cuda_kernel<scalar_t>), dim3(blocks), dim3(threads), 0, stream, 
            b, n, m, nsample, xyz.data_ptr<scalar_t>(),
            new_xyz.data_ptr<scalar_t>(), idx.data_ptr<int>(),
            dist2.data_ptr<scalar_t>());
      });

  AT_CUDA_CHECK(hipGetLastError());
}
