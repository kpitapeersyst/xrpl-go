package server

import "errors"

// ErrNoFeature is returned when no feature ID is specified in a request.
var ErrNoFeature = errors.New("no feature specified")

// ErrNoPublicKey is returned when no public key is specified in a request.
var ErrNoPublicKey = errors.New("no public key specified")

// ErrInvalidPublicKey is returned when the public key is not a valid validator public key.
var ErrInvalidPublicKey = errors.New("invalid public key")
