package clio

import (
	"testing"

	"github.com/Peersyst/xrpl-go/xrpl/testutil"
	"github.com/Peersyst/xrpl-go/xrpl/transaction"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNFTHistoryRequest(t *testing.T) {
	s := NFTHistoryRequest{
		NFTokenID:      "0000000000000000000000000000000000000000000000000000000000000000",
		LedgerIndexMin: 100,
		LedgerIndexMax: 200,
		Binary:         true,
		Forward:        true,
		Limit:          100,
		Marker:         "marker",
	}

	j := `{
	"nft_id": "0000000000000000000000000000000000000000000000000000000000000000",
	"ledger_index_min": 100,
	"ledger_index_max": 200,
	"binary": true,
	"forward": true,
	"limit": 100,
	"marker": "marker"
}`

	if err := testutil.SerializeAndDeserialize(t, s, j); err != nil {
		t.Fatal(err)
	}
}

func TestNFTHistoryRequest_Validate(t *testing.T) {
	tests := []struct {
		name     string
		request  NFTHistoryRequest
		expected error
	}{
		{
			name: "pass - valid NFTokenID",
			request: NFTHistoryRequest{
				NFTokenID: "0000000000000000000000000000000000000000000000000000000000000000",
			},
			expected: nil,
		},
		{
			name:     "fail - missing NFTokenID",
			request:  NFTHistoryRequest{},
			expected: transaction.ErrInvalidNFTokenID,
		},
		{
			name: "fail - short NFTokenID",
			request: NFTHistoryRequest{
				NFTokenID: "ABC123",
			},
			expected: transaction.ErrInvalidNFTokenID,
		},
		{
			name: "fail - non-hex NFTokenID",
			request: NFTHistoryRequest{
				NFTokenID: "ZZZ0000000000000000000000000000000000000000000000000000000000000",
			},
			expected: transaction.ErrInvalidNFTokenID,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()
			if tt.expected == nil {
				require.NoError(t, err)
			} else {
				assert.ErrorIs(t, err, tt.expected)
			}
		})
	}
}
