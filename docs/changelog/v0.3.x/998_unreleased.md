---
title: Unreleased
---

### Added

#### binary-codec

- Added XLS-96 confidential MPT fields and transaction definitions for `ConfidentialMPTSend`, `ConfidentialMPTConvert`, `ConfidentialMPTConvertBack`, `ConfidentialMPTMergeInbox`, and `ConfidentialMPTClawback`.

#### confidential

- Added CGo bindings and vendored native libraries for XRPLF `mpt-crypto`, with a no-CGo fallback and maintainer tooling for dependency updates.
- Added hex-string APIs for ElGamal encryption, Pedersen commitments, context hashes, and zero-knowledge proof generation and verification.

#### confidential/builder

- Added online and offline helpers for confidential MPT send, convert, convert-back, clawback, and inbox-merge transactions.

#### docs

- Added confidential MPT documentation for package layout, supported platforms, transaction types, and high-level builders.

#### xrpl

- Added confidential MPT transaction and ledger-entry models, issuance flags and encryption keys, and ledger-entry index helpers.

### Fixed

#### confidential

- Tightened participant and fixed-size proof validation before invoking the native verifier.

#### xrpl/transaction

- Corrected confidential transaction key encoding and proof-size validation.
