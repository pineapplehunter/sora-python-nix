# sora-python-sdkのnixパッケージ

現在python3.12用にのみパッケージングしています。

## 手法
1からビルドはせずにpypiからwheelをダウンロードする形で実装されています。

## 使い方

`flake.nix`をを使っている場合はinputsに次を追加

```nix
{
    inputs.sora-python-nix.url = "github:pineapplehunter/sora-python-nix";
}
```

また、overlayを適用しましょう。
{
    pkgs = import nixpkgs {overlays = [ sora-python-nix.overlays.default ];};
}

