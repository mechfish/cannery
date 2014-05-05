# EDIT ME: Change the BOXNAME if you are building a different distro.
BOXNAME=precise64_distro_virtualbox.box
LOCAL_BOXNAME=local-precise64-distro

PACKER=packer
VAGRANT=vagrant

# Build the box
$(BOXNAME): distro.json
	rm -f *.box
	$(PACKER) build distro.json

# Clean up output files
.PHONY: clean
clean:
	rm -f *.box

# Install box locally
install: $(BOXNAME)
	$(VAGRANT) box add --clean --force --name $(LOCAL_BOXNAME) $(BOXNAME)

# Upload box to S3
.PHONY: upload
upload:
	../../bin/upload-box $(BOXNAME)

