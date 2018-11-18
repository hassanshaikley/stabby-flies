# Noob Quest

Multiplayer Browser Game in Elixir/Phoenix

![Screenshot](noob_quest_screenshot.png "Screenshot 1")

## Status

Still really early, feel free to contribute in any capacity as I am ultimately doing this to learn.

## Issues / To-Do

- Handle disconnect properly
- Render player names
- Get deployment working! There's some sort of strange bug.
- Currently a players name to uniquely identify them when it should be a socket id or something of the sort
- Write tests...

## Installation

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
  * Test with `MIX_ENV=test mix do coveralls.json`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Notes

-https://pixijs.io/pixi-lights/docs/index.html
-on dec the channel server should trigger the `terminate`  callback on the channel
