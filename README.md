# Aurora

This is an unofficial iOS app for the Hetzner Cloud. It's currently mostly read-only but I plan to add write actions in the future.

If you want to know what I'm working on, check out the issues and projects on this repo. :D

## Notice

If you want to compile and run the project on your own, please note that there's a "Developer mode". It uses the `cloudAppPreventNetworkActivityUseSampleData` variable inside `SceneDelegate.swift`.

This variable prevents caching and any network communication with the Hetzner Cloud API. It's intended for development because the data doesn't change and afaik, the API has ratelimiting. If you want to add a real project, disable Developer mode inside the app settings. If you later enable it, no data will be lost (hopefully... But that said, I'm not responsible for any data loss ^.^ )

## Help

If you need help, you can either contact me on [Twitter](https://twitter.com/leabmgrt) or via [email](mailto:lea@abmgrt.dev).


## License

This project is licensed under the MIT license. Please read ["LICENSE"](LICENSE) for more information.
