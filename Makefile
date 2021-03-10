SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= rancher
TAG ?= release-4.8$(BUILD_META)

ifneq ($(DRONE_TAG),)
TAG := $(DRONE_TAG)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build-operator
image-build-operator:
	docker build \
		--pull \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(ORG)/hardened-sriov-network-operator:$(TAG) \
		--tag $(ORG)/hardened-sriov-network-operator:$(TAG)-$(ARCH) \
	.

.PHONY: image-push-operator
image-push-operator:
	docker push $(ORG)/hardened-sriov-network-operator:$(TAG)-$(ARCH)

.PHONY: image-manifest-operator
image-manifest-operator:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-sriov-network-operator:$(TAG) \
		$(ORG)/hardened-sriov-network-operator:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-sriov-network-operator:$(TAG)

.PHONY: image-scan-operator
image-scan-operator:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-sriov-network-operator:$(TAG)

.PHONY: image-build-network-config-daemon
image-build-network-config-daemon:
	docker build \
		--pull \
		-f Dockerfile.sriov-network-config-daemon \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(ORG)/hardened-sriov-network-config-daemon:$(TAG) \
		--tag $(ORG)/hardened-sriov-network-config-daemon:$(TAG)-$(ARCH) \
	.

.PHONY: image-push-network-config-daemon
image-push-network-config-daemon:
	docker push $(ORG)/hardened-sriov-network-config-daemon:$(TAG)-$(ARCH)

.PHONY: image-manifest-network-config-daemon
image-manifest-network-config-daemon:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-sriov-network-config-daemon:$(TAG) \
		$(ORG)/hardened-sriov-network-config-daemon:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-sriov-network-config-daemon:$(TAG)

.PHONY: image-scan-network-config-daemon
image-scan-network-config-daemon:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-sriov-network-config-daemon:$(TAG)

