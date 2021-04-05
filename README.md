# Hetzner Cloud App
(name pending)

This is an iOS app for the Hetzner Cloud. It's currently mostly read-only but I plan to add write actions in the future.

Oh and there's like not much right now, it's (very) early in development so things might change.

## Notice

If you want to compile and run the project on your own, please note that there's a `cloudAppPreventNetworkActivityUseSampleData` variable inside `SceneDelegate.swift`.

This variable prevents caching and any network communication with the Hetzner Cloud API. It's intended for development because the data doesn't change and afaik, the API has ratelimiting. If you want to add a real project, set the variable to `false`. If you later set it to `true`, no data will be lost (hopefully... But that said, I'm not responsible for any data loss ^.^ )


## License

This project is licensed under the MIT license. Please read ["LICENSE"](LICENSE) for more information.
