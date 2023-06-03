.PHONY:nostril
nostril:
	@cd  $(PWD)/src && $(MAKE) nostril && cd ..
	@cd  $(PWD)/src && $(MAKE) nostril install && cd ..
nostril-clean:
	@make clean -C $(PWD)/src/

# vim: set noexpandtab:
# vim: set setfiletype make
