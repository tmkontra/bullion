# bullion/banker
poker banking automation

[Visit the App here](http://poker.tylerkontra.com)

# Purpose

Home poker games become tedious to track: who had how many chips, and how much are those chips worth?

# Overview

This app implements a minimal full-stack web app that allows the user to start a `table` specifying a `buyin` cash amount and corresponding chip count. `Players` can be added to the game. Each `buyin` can be tracked and players can `cashout` one or more times. Their corresponding balance is reported. 

Tables are assigned a `TableID` that can be used to return to a game if you navigate away from it.

# Architecture

V2 Architecture: 
- Bullion
    - Phoenix web layer (`BullionWeb.V2Controller`)
    - Ecto (Postgres) persistence layer (`Bullion.TableV2`)
- BullionCore
    - Purely functional `Table` struct
        - count of buyins for each player (i.e. Tyler has bought in 3 times)
        - list of cashouts for each player (i.e. 100 chips, and then later 75 more chips)
    - `TableServer` GenServer managing the state of a table
    - `TableSupervisor` Supervision managing each table as a process
    - `BullionCore` does not implement persistence, but accepts dependency-injected callbacks for each of the 5 persistence methods
      - create a table
      - add a player to a table
      - add a buyin to a player
      - record a cashout for a player
      - lookup the table state (to rehydrate a GenServer, for example)

Legacy Architecture (available at `/legacy` url prefix):
- Phoenix web application
- Ecto/Postgres persistence
- tight coupling of Ecto schemas and application logic

# Roadmap

- Read-only table view for the V2 application
  - alternatively, "close" a table so that it can no longer be modified, and then the game can be shared
- Client-side sessions (cookies) to provide a `Your Recent Games` section on the home page
  - this will make it easy to return to previously reviewed games (without remembering a table id).