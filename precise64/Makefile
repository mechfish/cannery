PACKER=packer

# Build the box
precise64_basebox_virtualbox.box: output-basevm basebox.json
	$(PACKER) build basebox.json

# Build the VM
output-basevm: basevm.json
	$(PACKER) build basevm.json

# Clean up output files
.PHONY: clean
clean:
	rm -rf output-basevm
	rm *.box
	rm box
	rm -rf old-output

# Stash current output files in order to rebuild them.
.PHONY: trash
trash:
	mkdir -p old-output
	mv *.box old-output
	mv output-basevm old-output

# Get rid of the stashed old output files
.PHONY: empty-trash
empty-trash:
	rm -rf old-output
