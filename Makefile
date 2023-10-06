init:
	-asdf plugin add erlang
	-asdf plugin add elixir
	asdf install
	mix local.hex
	mix archive.install hex phx_new

run:
	docker compose up -d
	$(MAKE) -C ptah run