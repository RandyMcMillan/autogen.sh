.PHONY:nostril
nostril:
	@pushd nostril && $(MAKE) nostril && popd
	@pushd nostril && $(MAKE) nostril install && popd
nostril-clean:
	@make clean -C src/

# vim: set noexpandtab:
# vim: set setfiletype make
