BOXNAME=precise64-ruby

# Build the box
$(BOXNAME).box:
	vagrant up
	vagrant package --output $(BOXNAME).box
# now you can do:
# vagrant box add --name $(BOXNAME) $(BOXNAME).box

# Clean up output files
.PHONY: clean
clean:
	rm $(BOXNAME).box
	rm Gemfile.lock

# Upload to S3
.PHONY: upload
upload: $(BOXNAME).box
	../../bin/upload-box $(BOXNAME).box