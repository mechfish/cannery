# EDIT ME: Change the BOXNAME if you are building a different distro.
BOXNAME=precise64_basebox_virtualbox.box

PACKER=packer

# Build the box
$(BOXNAME): basebox.json
	$(PACKER) build basebox.json

# Clean up output files
.PHONY: clean
clean:
	rm *.box

# Upload box to S3
.PHONY: upload
upload:
	../../bin/upload-box $(BOXNAME)

