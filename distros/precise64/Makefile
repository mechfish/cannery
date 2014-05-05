# EDIT ME: Change the BOXNAME if you are building a different distro.
BOXNAME=precise64_distro_virtualbox.box

PACKER=packer

# Build the box
$(BOXNAME): distro.json
	rm -f *.box
	$(PACKER) build distro.json

# Clean up output files
.PHONY: clean
clean:
	rm -f *.box

# Upload box to S3
.PHONY: upload
upload:
	../../bin/upload-box $(BOXNAME)

