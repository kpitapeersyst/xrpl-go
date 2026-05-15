package transactions

import "errors"

// ErrNoTxBlob is returned when no TxBlob is defined in the SubmitRequest.
var ErrNoTxBlob = errors.New("no TxBlob defined")

// ErrNoTxJSON is returned when no tx_json is defined in the SubmitMultisignedRequest.
var ErrNoTxJSON = errors.New("no tx_json defined")

// ErrMissingTxLookupParam is returned when no tx lookup selector is defined in the TxRequest.
var ErrMissingTxLookupParam = errors.New("no transaction or ctid defined")

// ErrConflictingTxLookupParams is returned when both tx lookup selectors are defined in the TxRequest.
var ErrConflictingTxLookupParams = errors.New("both transaction and ctid defined")
