.PHONY: build
build: protoc-plugin/generated/refcheck.pb.go ## generates the PGV binary and installs it into $$GOPATH/bin
	echo "done"

bin/protoc-gen-go: $(shell pwd)/build/bin
	GOBIN=$(shell pwd)/build/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1

protoc-plugin/generated/refcheck.pb.go: protoc-plugin/generated bin/protoc-gen-go protobuf/refcheck.proto
	protoc -I protobuf \
		--plugin=protoc-gen-go=${GOPATH}/bin/protoc-gen-go \
		--go_opt=paths=source_relative \
		--go_out="protoc-plugin/generated" refcheck.proto

$(shell pwd)/build/bin protoc-plugin/generated build/tests/generation:
	mkdir -p $@

.PHONY: clean
clean: ## clean up generated files
	rm -rf \
		build/* \
		protoc-plugin/generated/*

.PHONY: tests
tests: protoc-plugin/generated/refcheck.pb.go build/tests/generation/test.pb.go 
	echo "done"

build/tests/generation/test.pb.go: build/tests/generation tests/protobuf/test.proto
	protoc -I . -I tests/protobuf \
		--plugin=protoc-gen-go=${GOPATH}/bin/protoc-gen-go \
		--go_opt=paths=source_relative \
		--go_out="build/tests/generation" test.proto
