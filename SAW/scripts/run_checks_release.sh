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

export SAW_RTS_FLAGS="-l-agu"

# If |*_SELECTCHECK| env variable does not exist, run quick check of all algorithms.
(cd proof/SHA512 && go run SHA512-384-check-entrypoint.go)
saw proof/SHA512/verify-SHA512-512-quickcheck.saw +RTS ${SAW_RTS_FLAGS} -olverify-SHA512-512-quickcheck.saw.eventlog -RTS
(cd proof/HMAC && go run HMAC-check-entrypoint.go)
(cd proof/AES && go run AES-GCM-check-entrypoint.go)
saw proof/AES_KW/verify-AES_KW.saw +RTS ${SAW_RTS_FLAGS} -olverify-AES_KW.saw.eventlog -RTS
saw proof/AES_KW/verify-AES_KWP.saw +RTS ${SAW_RTS_FLAGS} -olverify-AES_KWP.saw.eventlog -RTS
saw proof/ECDSA/verify-ECDSA.saw +RTS ${SAW_RTS_FLAGS} -olverify-ECDSA.saw.eventlog -RTS
saw proof/ECDH/verify-ECDH.saw +RTS ${SAW_RTS_FLAGS} -olverify-ECDH.saw.eventlog -RTS
