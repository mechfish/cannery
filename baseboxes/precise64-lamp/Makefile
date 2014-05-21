BOXNAME=precise64-lamp
VAGRANT=vagrant

# Build the box
$(BOXNAME).box: Vagrantfile ansible/devbox.yml
	$(VAGRANT) up
	rm -f $(BOXNAME).box
	$(VAGRANT) package --output $(BOXNAME).box

# Install box locally
install: $(BOXNAME).box
	$(VAGRANT) box add --clean --force --name local-$(BOXNAME) $(BOXNAME).box

# Clean up output files
.PHONY: clean
clean:
	rm -f $(BOXNAME).box

# Upload to S3
.PHONY: upload
upload: $(BOXNAME).box
	../../bin/upload-box $(BOXNAME).box
