package v1

import "errors"

// ErrMissingTakerGetsCurrency is returned when no taker_gets currency is defined in the BookOffersRequest.
var ErrMissingTakerGetsCurrency = errors.New("no taker_gets currency defined")

// ErrMissingTakerPaysCurrency is returned when no taker_pays currency is defined in the BookOffersRequest.
var ErrMissingTakerPaysCurrency = errors.New("no taker_pays currency defined")

// ErrMissingSourceAccount is returned when no source_account is defined in the DepositAuthorizedRequest.
var ErrMissingSourceAccount = errors.New("no source_account defined")

// ErrMissingDestinationAccount is returned when no destination_account is defined in the DepositAuthorizedRequest.
var ErrMissingDestinationAccount = errors.New("no destination_account defined")
