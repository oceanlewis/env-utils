test:
	@nu ./run-tests.nu

watch:
	@fd | entr -c nu ./run-tests.nu