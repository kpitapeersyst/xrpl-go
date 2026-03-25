.PHONY: lint lint-fix
.PHONY: test-all test-binary-codec test-address-codec test-keypairs test-xrpl test-ci
.PHONY: run-localnet run-localnet-linux/amd64 run-localnet-linux/arm64 stop-localnet integration-localnet
.PHONY: test-integration-localnet test-integration-devnet test-integration-testnet
.PHONY: coverage-unit benchmark
.PHONY: test-confidential test-confidential-nocgo run-confidential-localnet test-integration-confidential-localnet stop-confidential-localnet

UNIT_TEST_PACKAGES = $(shell go list ./... | grep -v /faucet | grep -v /examples | grep -v /testutil | grep -v /interfaces) ./xrpl/testutil/integration/...
EXCLUDED_TEST_PACKAGES = $(shell go list ./... | grep -v /faucet | grep -v /examples | grep -v /testutil | grep -v /interfaces | grep -v /confidential)
EXCLUDED_COVERAGE_PACKAGES = $(shell go list ./... | grep -v /faucet | grep -v /examples | grep -v /testutil | grep -v /interfaces | grep -v /confidential)

INTEGRATION_TEST_PACKAGES = ./xrpl/transaction/integration/...

PARALLEL_TESTS = 4
TEST_TIMEOUT = 5m

GOTEST := $(shell command -v gotest 2>/dev/null || echo "go test")

GOLANGCI_LINT_MAJOR_VERSION = 2
GOLANGCI_LINT_VERSION = v2.11.3

XRPLD_IMAGE ?= rippleci/xrpld:develop
XRPLD_CONFIG ?= /etc/xrpld/xrpld.cfg
LOCALNET_CONTAINER ?= xrpld_standalone
CONFIDENTIAL_XRPLD_IMAGE ?= rippleci/xrpld@sha256:595a2ed598dad35737e4423538e7cdb2e26b8535d78c255ed9b9dbebeb2e9c4c
CONFIDENTIAL_XRPLD_COMMIT = 26cc683ec143e8a5fcc6dd09c2c1fe25ac08b94c
CONFIDENTIAL_LOCALNET_CONTAINER ?= xrpld_confidential_standalone

################################################################################
############################### LINTING ########################################
################################################################################

lint:
	@echo "Linting Go code..."
	@go install github.com/golangci/golangci-lint/v$(GOLANGCI_LINT_MAJOR_VERSION)/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)
	@golangci-lint run
	@echo "Linting complete!"

lint-fix:
	@echo "Fixing Go code..."
	@go install github.com/golangci/golangci-lint/v$(GOLANGCI_LINT_MAJOR_VERSION)/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)
	@golangci-lint run --fix
	@echo "Fixing complete!"

################################################################################
############################### TESTING ########################################
################################################################################

test-all:
	@echo "Running Go tests..."
	@$(GOTEST) $(UNIT_TEST_PACKAGES)
	@echo "Tests complete!"

test-binary-codec:
	@echo "Running Go tests for binary codec package..."
	@$(GOTEST) ./binary-codec/...
	@echo "Tests complete!"

test-address-codec:
	@echo "Running Go tests for address codec package..."
	@$(GOTEST) ./address-codec/...
	@echo "Tests complete!"

test-keypairs:
	@echo "Running Go tests for keypairs package..."
	@$(GOTEST) ./keypairs/...
	@echo "Tests complete!"

test-xrpl:
	@echo "Running Go tests for xrpl package..."
	@$(GOTEST) ./xrpl/...
	@echo "Tests complete!"

test-ci:
	@echo "Running Go tests..."
	@go clean -testcache
	@$(GOTEST) $(UNIT_TEST_PACKAGES) -parallel $(PARALLEL_TESTS) -timeout $(TEST_TIMEOUT)
	@echo "Tests complete!"

run-localnet: run-localnet-linux/amd64

run-localnet-linux/amd64:
	@echo "Running localnet..."
	@docker run --rm -d --platform linux/amd64 -p 5005:5005 -p 6006:6006 --name $(LOCALNET_CONTAINER) --volume $(PWD)/.ci-config/xrpld.cfg:$(XRPLD_CONFIG):ro --entrypoint bash $(XRPLD_IMAGE) -c 'mkdir -p /var/lib/xrpld/db/ && xrpld --conf $(XRPLD_CONFIG) -a --start & sleep 5 && while true; do xrpld --conf $(XRPLD_CONFIG) ledger_accept; sleep 1; done'
	@echo "Localnet running!"

run-localnet-linux/arm64:
	@echo "Running localnet..."
	@docker run --rm -d --platform linux/arm64 -p 5005:5005 -p 6006:6006 --name $(LOCALNET_CONTAINER) --volume $(PWD)/.ci-config/xrpld.cfg:$(XRPLD_CONFIG):ro --entrypoint bash $(XRPLD_IMAGE) -c 'mkdir -p /var/lib/xrpld/db/ && xrpld --conf $(XRPLD_CONFIG) -a --start & sleep 5 && while true; do xrpld --conf $(XRPLD_CONFIG) ledger_accept; sleep 1; done'
	@echo "Localnet running!"

stop-localnet:
	@docker stop $(LOCALNET_CONTAINER) >/dev/null 2>&1 || true

integration-localnet:
	@./scripts/localnet-integration.sh

test-integration-localnet:
	@echo "Running Go tests for integration package..."
	@go clean -testcache
	@INTEGRATION=localnet $(GOTEST) -p 1 $(INTEGRATION_TEST_PACKAGES) -timeout $(TEST_TIMEOUT) -v
	@echo "Tests complete!"

test-integration-devnet:
	@echo "Running Go tests for integration package..."
	@go clean -testcache
	@INTEGRATION=devnet $(GOTEST) $(INTEGRATION_TEST_PACKAGES) -timeout $(TEST_TIMEOUT) -v
	@echo "Tests complete!"

test-integration-testnet:
	@echo "Running Go tests for integration package..."
	@go clean -testcache
	@INTEGRATION=testnet $(GOTEST) $(INTEGRATION_TEST_PACKAGES) -timeout $(TEST_TIMEOUT) -v
	@echo "Tests complete!"

coverage-unit:
	@echo "Generating unit test coverage report..."
	@$(GOTEST) -coverprofile=coverage.out $(UNIT_TEST_PACKAGES)
	@go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated at coverage.html"

benchmark:
	@echo "Running Go benchmarks..."
	@$(GOTEST) -bench=. $(EXCLUDED_TEST_PACKAGES)
	@echo "Benchmarks complete!"

################################################################################
######################### CONFIDENTIAL MPT #####################################
################################################################################

test-confidential:
	@echo "Running confidential MPT tests (CGo required)..."
	@CGO_ENABLED=1 go test ./confidential/... ./binary-codec/... ./xrpl/transaction ./xrpl/rpc ./xrpl/websocket ./xrpl/wallet -timeout $(TEST_TIMEOUT)
	@echo "Confidential tests complete!"

test-confidential-nocgo:
	@echo "Running confidential MPT fallback tests without CGo..."
	@CGO_ENABLED=0 go test ./confidential/... ./binary-codec/... ./xrpl/transaction ./xrpl/rpc ./xrpl/websocket ./xrpl/wallet -timeout $(TEST_TIMEOUT)
	@echo "Confidential fallback tests complete!"

run-confidential-localnet:
	@docker pull --quiet --platform linux/amd64 "$(CONFIDENTIAL_XRPLD_IMAGE)" >/dev/null
	@image_commit=$$(docker image inspect --format '{{index .Config.Labels "com.ripple.commit_id"}}' "$(CONFIDENTIAL_XRPLD_IMAGE)"); \
		test "$$image_commit" = "$(CONFIDENTIAL_XRPLD_COMMIT)" || (echo "image source $$image_commit does not match $(CONFIDENTIAL_XRPLD_COMMIT)"; exit 1)
	@docker run --rm -d --platform linux/amd64 --name "$(CONFIDENTIAL_LOCALNET_CONTAINER)" \
		--label org.xrpl-go.confidential.platform=linux/amd64 \
		-p 5005:5005 -p 6006:6006 \
		--volume "$(PWD)/.ci-config-confidential:/etc/opt/xrpld:ro" \
		"$(CONFIDENTIAL_XRPLD_IMAGE)" \
		--conf /etc/opt/xrpld/rippled.cfg --standalone --start

stop-confidential-localnet:
	@docker stop "$(CONFIDENTIAL_LOCALNET_CONTAINER)" >/dev/null 2>&1 || true

test-integration-confidential-localnet:
	@actual_image=$$(docker inspect --format '{{.Config.Image}}' "$(CONFIDENTIAL_LOCALNET_CONTAINER)"); \
		test "$$actual_image" = "$(CONFIDENTIAL_XRPLD_IMAGE)" || (echo "running image $$actual_image does not match $(CONFIDENTIAL_XRPLD_IMAGE)"; exit 1)
	@XRPLD_CONFIDENTIAL_IMAGE="$(CONFIDENTIAL_XRPLD_IMAGE)" XRPLD_CONFIDENTIAL_PLATFORM=linux/amd64 \
		INTEGRATION=localnet CGO_ENABLED=1 $(GOTEST) ./xrpl/transaction/integration \
		-run '^TestIntegrationConfidentialMPT$$' -count=1 -timeout $(TEST_TIMEOUT) -v

update-mpt-crypto:
	@bash confidential/deps/update.sh
