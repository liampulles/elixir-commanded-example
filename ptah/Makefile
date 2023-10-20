run:
	mix deps.get
	mix ecto.create
	mix ecto.migrate
	-mix do event_store.create, event_store.init
	mix phx.server