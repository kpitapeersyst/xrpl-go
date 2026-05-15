package account

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestAccountRequestValidateRequiresAccount(t *testing.T) {
	tests := []struct {
		name    string
		request interface {
			Validate() error
		}
	}{
		{
			name:    "account_currencies",
			request: &CurrenciesRequest{},
		},
		{
			name:    "account_info",
			request: &InfoRequest{},
		},
		{
			name:    "account_lines",
			request: &LinesRequest{},
		},
		{
			name:    "account_nfts",
			request: &NFTsRequest{},
		},
		{
			name:    "account_objects",
			request: &ObjectsRequest{},
		},
		{
			name:    "account_offers",
			request: &OffersRequest{},
		},
		{
			name:    "account_tx",
			request: &TransactionsRequest{},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()

			require.ErrorIs(t, err, ErrNoAccountID)
		})
	}
}
