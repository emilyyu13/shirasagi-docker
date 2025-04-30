## docker-composeでビルドして起動
```
docker-compose up --build
```

## サンプルデータを入れる（ローカルで実行する）
```
sh etc/init.sh
```

## サイトの確認

#### 管理画面
http://localhost:3000/.mypage にアクセスするとログイン画面が表示されます。
サイト名のリンクをクリックすると、登録したデモデータを確認・編集することができます。

[ ユーザーID： sys@example.jp , パスワード： pass ]

#### 公開画面
http://localhost:3000にアクセスすると登録したデモサイトが表示されます。
