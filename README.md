# Janus-backend

## これは何？

このリポジトリは、Janusのバックエンド部分のリポジトリです。

## 技術スタック

- Ruby on Rails
- Auth0(認証プラットフォーム)

## 環境構築

まず、[GitHubのリポジトリ](https://github.com/Retasusan/janus-backend)をクローンします。
クローンは、以下のコマンドで行えます。

```bash
cd リポジトリを置きたいディレクトリ
git clone https://github.com/Retasusan/janus-backend.git
```

次に、クローンしたディレクトリに移動し、必要なgemをインストールします。

```bash
cd janus-backend
bundle install
```

次に、起動に必要な環境変数を設定します。`.env.local`ファイルを作成して環境変数を設定してください。環境変数は、[Retasusan](https://github.com/Retasusan)にコンタクトをとって、共有してもらってください。

最後に、サーバーを起動します。

```bash
rails server
```

ポート番号を8000に変えているので、サーバの起動はそのポートにアクセスして確認してください。
