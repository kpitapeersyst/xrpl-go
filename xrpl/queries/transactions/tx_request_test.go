package transactions

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestTxRequestValidate(t *testing.T) {
	tests := []struct {
		name     string
		request  TxRequest
		expected error
	}{
		{
			name:     "missing selector",
			request:  TxRequest{},
			expected: ErrMissingTxLookupParam,
		},
		{
			name: "conflicting selector",
			request: TxRequest{
				Transaction: "ABC",
				Ctid:        "C123",
			},
			expected: ErrConflictingTxLookupParams,
		},
		{
			name: "ctid only",
			request: TxRequest{
				Ctid: "C123",
			},
		},
		{
			name: "transaction only",
			request: TxRequest{
				Transaction: "ABC",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()
			if tt.expected == nil {
				require.NoError(t, err)
			} else {
				require.ErrorIs(t, err, tt.expected)
			}
		})
	}
}
