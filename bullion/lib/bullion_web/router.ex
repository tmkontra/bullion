defmodule BullionWeb.Router do
  use BullionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/legacy", BullionWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/game/new", GameController, :new
    post "/game/create", GameController, :create
    get "/game/list-players", GameController, :list_players
    post "/game/add-player", GameController, :add_player
    get "/game/view", GameController, :view_game

    post "/player/:player_id/buyin", PlayerController, :add_buyin

    get "/player/:player_id/cashout", PlayerController, :cash_out
    post "/player/:player_id/cashout", PlayerController, :cash_out
  end

  scope "/", BullionWeb do
    pipe_through :browser

    get "/", V2Controller, :index
    post "/start", V2Controller, :start_game
    get "/game/:game_id", V2Controller, :view_game
    post "/game/:game_id/player", V2Controller, :add_player
    post "/game/:game_id/buyin/:player_id", V2Controller, :add_buyin
    get "/game/:game_id/cashout/:player_id", V2Controller, :cashout_form
    post "/game/:game_id/cashout/:player_id", V2Controller, :cashout
  end

  # Other scopes may use custom stacks.
  # scope "/api", BullionWeb do
  #   pipe_through :api
  # end
end
