CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="itsmng"
VVERSION="1.5.1"


all: 
	make -B itsmng

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

itsmng:
	$(CTN) build --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

