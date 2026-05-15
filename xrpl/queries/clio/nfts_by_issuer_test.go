package clio

import (
	"testing"

	accounttypes "github.com/Peersyst/xrpl-go/xrpl/queries/account/types"
	cliotypes "github.com/Peersyst/xrpl-go/xrpl/queries/clio/types"
	"github.com/Peersyst/xrpl-go/xrpl/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNFTsByIssuerRequest(t *testing.T) {
	s := NFTsByIssuerRequest{
		Issuer:   "abc",
		Marker:   "123",
		Limit:    10,
		NftTaxon: 1,
	}

	j := `{
	"issuer": "abc",
	"marker": "123",
	"limit": 10,
	"nft_taxon": 1
}`

	if err := testutil.SerializeAndDeserialize(t, s, j); err != nil {
		t.Error(err)
	}
}

func TestNFTsByIssuerResponse(t *testing.T) {
	s := NFTsByIssuerResponse{
		Issuer: "abc",
		NFTs: []cliotypes.NFToken{
			{
				NFTokenID:       "123",
				LedgerIndex:     1,
				Owner:           "abc",
				IsBurned:        false,
				Flags:           0,
				TransferFee:     0,
				Issuer:          "abc",
				NFTokenTaxon:    1,
				NFTokenSequence: 1,
				URI:             "abc",
			},
		},
		Marker:       "123",
		Limit:        10,
		NFTokenTaxon: 1,
	}

	j := `{
	"issuer": "abc",
	"nfts": [
		{
			"nft_id": "123",
			"ledger_index": 1,
			"owner": "abc",
			"is_burned": false,
			"flags": 0,
			"transfer_fee": 0,
			"issuer": "abc",
			"nft_taxon": 1,
			"nft_sequence": 1,
			"uri": "abc"
		}
	],
	"marker": "123",
	"limit": 10,
	"nft_taxon": 1
}`

	if err := testutil.SerializeAndDeserialize(t, s, j); err != nil {
		t.Error(err)
	}
}

func TestNFTsByIssuerRequest_Validate(t *testing.T) {
	tests := []struct {
		name     string
		request  NFTsByIssuerRequest
		expected error
	}{
		{
			name: "pass - issuer provided",
			request: NFTsByIssuerRequest{
				Issuer: "abc",
			},
			expected: nil,
		},
		{
			name:     "fail - missing issuer",
			request:  NFTsByIssuerRequest{},
			expected: accounttypes.ErrNoAccountID,
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
