
CC ?= gcc


CCFLAGS += -I$(NGX_SRC_DIR)/src/core
CCFLAGS += -I$(NGX_SRC_DIR)/src/http
CCFLAGS += -I$(NGX_SRC_DIR)/src/http/modules
CCFLAGS += -I$(NGX_SRC_DIR)/src/event
CCFLAGS += -I$(NGX_SRC_DIR)/objs
CCFLAGS += -I$(NGX_SRC_DIR)/src/os/unix

BUILD_DIR = $(shell pwd)

DOCKER_BUILD_IMAGE = nginx-dev:1.8
DOCKER_BUILD_WORKDIR = /go/src/github.com/yue9944882/k8s_ingress_module

DOCKER_RUN_OPT = --rm -v $(shell pwd):$(DOCKER_BUILD_WORKDIR)

K8S_INGRESS_IMAGE = nginx-k8s-ingress:0.0.0



default: build

build: build_dev build_go build_ngx

build_dev:
	docker build -f Dockerfile.nginx-dev -t $(DOCKER_BUILD_IMAGE) $(BUILD_DIR)

build_go:
	@mkdir -p $(BUILD_DIR)/objs
	docker run $(DOCKER_RUN_OPT) -w $(DOCKER_BUILD_WORKDIR) $(DOCKER_BUILD_IMAGE) go build -o objs/module.so -buildmode=c-shared module.go

build_ngx:
	@mkdir -p $(BUILD_DIR)/target
	@mkdir -p $(BUILD_DIR)/target/logs
	@mkdir -p $(BUILD_DIR)/target/conf
	docker run $(DOCKER_RUN_OPT) -w $(DOCKER_BUILD_WORKDIR) $(DOCKER_BUILD_IMAGE) ./init_workspace.sh
	docker run $(DOCKER_RUN_OPT) -w $(DOCKER_BUILD_WORKDIR)/third-party/nginx $(DOCKER_BUILD_IMAGE) ./configure \
			--add-module=$(DOCKER_BUILD_WORKDIR) \
			--add-module=$(DOCKER_BUILD_WORKDIR)/third-party/ndk \
			--prefix=$(DOCKER_BUILD_WORKDIR)/target
	docker run $(DOCKER_RUN_OPT) -w $(DOCKER_BUILD_WORKDIR)/third-party/nginx $(DOCKER_BUILD_IMAGE) bash -c "make " 

container:
	@cp test/nginx.conf target/conf/
	docker build -f Dockerfile.nginx-k8s-ingress -t $(K8S_INGRESS_IMAGE) $(BUILD_DIR)

clean:
	@rm -rf third-party/*
	@rm -rf target/*
	@rm -rf objs/*
