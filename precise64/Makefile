BOXNAME=precise64_basebox_virtualbox.box
PACKER=packer

# Build the box
$(BOXNAME): basebox.json
	$(PACKER) build basebox.json

# Clean up output files
.PHONY: clean
clean:
	rm *.box


