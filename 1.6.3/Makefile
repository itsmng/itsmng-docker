CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="itsmng"
REPO="itsmng"
VVERSION="1.6.3"


all: 
	make -B itsmng

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

itsmng:
	$(CTN) build --build-arg VERSION="$(VVERSION)" --build-arg REPO="$(REPO)" -t $(IMAGENAME):$(VVERSION) .
