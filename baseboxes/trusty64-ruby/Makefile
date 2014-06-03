BOXNAME=trusty64-ruby
VAGRANT=vagrant

# Build the box
$(BOXNAME).box: Gemfile Vagrantfile ansible/devbox.yml ansible/templates/bash_aliases.j2
	rm -f Gemfile.lock
	$(VAGRANT) up
	rm -f $(BOXNAME).box
	$(VAGRANT) package --output $(BOXNAME).box

# Install box locally
install: $(BOXNAME).box
	$(VAGRANT) box add --clean --force --name local-$(BOXNAME) $(BOXNAME).box

# Clean up output files
#
# NOTE: We remove the Gemfile.lock on each build to ensure that the
# build contains the latest versions of Rails-related Gems. This would
# be a terrible strategy for apps, because there's no guarantee that a
# given app will run if you arbitrarily update its gems. But all we're
# doing is priming the cache. Any individual app running inside this
# box should vendor its gems and pin their versions with a
# Gemfile.lock of its own.
.PHONY: clean
clean:
	rm -f $(BOXNAME).box
	rm -f Gemfile.lock

# Upload to S3
.PHONY: upload
upload: $(BOXNAME).box
	../../bin/upload-box $(BOXNAME).box
