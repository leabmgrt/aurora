# Aurora

This is an unofficial iOS app for the Hetzner Cloud. It's currently mostly read-only but I plan to add write actions in the future.

If you want to know what I'm working on, check out the issues and projects on this repo. :D

## Help

### How to add a project

You can add a project using the "+" button at the top on the main view. But first you need to get an API key:

1. Go to the [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. Select a project
3. Go to "Security"
4. Select "API tokens"
5. Click "Generate API token"
6. Enter a name, select the right permissions ("Read" should be fine for now) and generate the API token
7. Copy the shown token into the "API key" field inside the app
8. Done 🎉

### Other

If you need help, you can either contact me on [Twitter](https://twitter.com/leabmgrt) or via [email](mailto:lea@abmgrt.dev).

## Notice

If you want to compile and run the project on your own, please note that there's a "Developer mode". It uses the `cloudAppPreventNetworkActivityUseSampleData` variable inside `SceneDelegate.swift`.

This variable prevents caching and any network communication with the Hetzner Cloud API. It's intended for development because the data doesn't change and afaik, the API has ratelimiting. If you want to add a real project, disable Developer mode inside the app settings. If you later enable it, no data will be lost (hopefully... But that said, I'm not responsible for any data loss ^.^ )

## License

This project is licensed under the MIT license. Please read ["LICENSE"](LICENSE) for more information.
