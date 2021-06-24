# Hook Echo

this is a simple echo server written in [Crystal](https://crystal-lang.org/) to demonstrate how to:

1. accept flowplayer webhooks via HTTP
2. properly verify that the webhook signature is correct

# Setup
1. install crystal
2. clone this repo
3. set up a webhook delivery endpoint using something like [ngrok](https://ngrok.com) so it is publicly reachable
4. in the project directory run `crystal run -d src/hook-echo.cr`
5. spin up your ngrok endpoint binding port 8080
6. watch the events come in

## Contributing

1. Fork it (<https://github.com/flowplayer/hook-echo/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Benjamin Clos](https://github.com/ondreian) - creator and maintainer
