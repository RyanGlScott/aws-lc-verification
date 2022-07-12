#!/bin/sh

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -ex

# The following proofs use Release settings in CMake.

# TODO: reenable proof on SHA-256 when resolved https://github.com/awslabs/aws-lc-verification/issues/32
# If |*_SELECTCHECK| env variable exists, skip quick check of other algorithms.
if [ -n "${SHA512_384_SELECTCHECK}" ]; then
  (cd proof/SHA512 && go run SHA512-384-check-entrypoint.go)
  return
fi
if [ -n "${HMAC_SELECTCHECK}" ]; then
  (cd proof/HMAC && go run HMAC-check-entrypoint.go)
  return
fi
if [ -n "${AES_GCM_SELECTCHECK}" ]; then
  (cd proof/AES && go run AES-GCM-check-entrypoint.go)
  return
fi

export SAW_RTS_FLAGS="-l -hi -i0.5"

# If |*_SELECTCHECK| env variable does not exist, run quick check of all algorithms.
(cd proof/SHA512 && go run SHA512-384-check-entrypoint.go)
mv proof/SHA512/saw.hp proof/SHA512/verify-SHA512-384-quickcheck.saw.hp
saw proof/SHA512/verify-SHA512-512-quickcheck.saw +RTS ${SAW_RTS_FLAGS} -RTS
mv saw.hp verify-SHA512-512-quickcheck.saw.hp
(cd proof/HMAC && go run HMAC-check-entrypoint.go)
mv proof/HMAC/saw.hp proof/HMAC/verify-HMAC-SHA384-quickcheck.saw.hp
(cd proof/AES && go run AES-GCM-check-entrypoint.go)
mv proof/AES/saw.hp proof/AES/verify-AES-GCM-quickcheck.saw.hp
saw proof/AES_KW/verify-AES_KW.saw +RTS ${SAW_RTS_FLAGS} -RTS
mv saw.hp verify-AES_KW.saw.hp
saw proof/AES_KW/verify-AES_KWP.saw +RTS ${SAW_RTS_FLAGS} -RTS
mv saw.hp verify-AES_KWP.saw.hp
saw proof/ECDSA/verify-ECDSA.saw +RTS ${SAW_RTS_FLAGS} -RTS
mv saw.hp verify-ECDSA.saw.hp
saw proof/ECDH/verify-ECDH.saw +RTS ${SAW_RTS_FLAGS} -RTS
mv saw.hp verify-ECDH.saw.hp
