CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="docker.io/itsmng/itsmng"
REPO="itsmng"
VVERSION="v2.0.0"


all: 
	make -B itsmng

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

itsmng:
	$(CTN) build --build-arg VERSION="$(VVERSION)" --build-arg REPO="$(REPO)" -t $(IMAGENAME):$(VVERSION) .
