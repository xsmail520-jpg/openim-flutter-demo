# libXray Android runtime

The generated `classes.dex` and ABI-specific `libgojni.so` files come from the
official [`XTLS/libXray`](https://github.com/XTLS/libXray) release `v26.7.28`.
They are loaded through an app-private class loader instead of the normal APK
class path because OpenIM SDK is also a gomobile library and ships its own
`go.Seq` classes and `libgojni.so`.

Official release ZIP SHA-256:
`28b7dc9d6cc8455fcca5cbd56e387003a7bfb558128651a64899dc3a8ccff666`.

- libXray wrapper license: MIT
- bundled Xray-core license: MPL-2.0
- minimum Android API: 21
- packaged ABIs: arm64-v8a and x86_64

When updating the runtime, regenerate `classes.dex` with D8, keep the Java and
native files from the same release, and repeat the VPN permission, TUN
lifecycle, VLESS Reality, IPv4/IPv6, and 16 KB page-size acceptance checks.
