OUTPUT_DIR=lib/src/generated
PLUGIN_PATH=build/protoc-gen-dart
PROTO_DIR=proto
PROTOC_PLUGIN_DIR=../protoc_plugin

CONFORMANCE_PROTO_LIST = \
	conformance/conformance \
	google/protobuf/test_messages_proto2 \
	google/protobuf/test_messages_proto3 \
	google/protobuf/test_messages_edition2023 \
	google/protobuf/test_messages_proto2_editions \
	google/protobuf/test_messages_proto3_editions

WKT_PROTO_LIST = \
	google/protobuf/any \
	google/protobuf/api \
	google/protobuf/duration \
	google/protobuf/empty \
	google/protobuf/field_mask \
	google/protobuf/source_context \
	google/protobuf/struct \
	google/protobuf/timestamp \
	google/protobuf/type \
	google/protobuf/wrappers

ALL_PROTO_LIST = $(CONFORMANCE_PROTO_LIST) $(WKT_PROTO_LIST)

CONFORMANCE_PROTO_SRCS=$(foreach proto, $(CONFORMANCE_PROTO_LIST), \
	$(PROTO_DIR)/$(proto).proto)

WKT_PROTO_DIR=../protoc_plugin/test/protos
WKT_PROTO_SRCS=$(foreach proto, $(WKT_PROTO_LIST), \
	$(WKT_PROTO_DIR)/$(proto).proto)

extract-protos:
	@mkdir -p $(PROTO_DIR)
	@cp -r node_modules/protobuf-conformance/include/* $(PROTO_DIR)/

build-plugin:
	mkdir -p build
	cd $(PROTOC_PLUGIN_DIR) && dart compile exe bin/protoc_plugin.dart -o ../conformance_runner/build/protoc-gen-dart

generate: extract-protos build-plugin
	mkdir -p $(OUTPUT_DIR)
	protoc \
		--dart_out="$(OUTPUT_DIR)" \
		-I$(PROTO_DIR) \
		-I$(WKT_PROTO_DIR) \
		--plugin=protoc-gen-dart=$(realpath $(PLUGIN_PATH)) \
		$(CONFORMANCE_PROTO_SRCS) $(WKT_PROTO_SRCS)

all: generate

clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf $(PROTO_DIR)

clean-all: clean
	rm -rf build

.PHONY: clean clean-all extract-protos generate build-plugin all