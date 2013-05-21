#これは
Twitterのイベント検出ライブラリです。
Retwets, Direct messags, mentions を検出通知します。ネットワーク環境にあわせて、REST APIとStreaming APIの適したものを選択します。3G環境ではREST APIを、WiFi環境ではStreaming APIを利用します。

#動作環境
これらのプロジェクトはXcode4.6でビルドできることを確認しています。
動作する端末は、iOS6を搭載したApple社製品です。

#設定
iOSから取得できるクレデンシャルには、ダイレクトメッセージの読み込み権限がありません。このため、ダイレクトメッセージの検出には、ダイレクトメッセージの権限があるアプリケーションキー/シークレットを、開発者自身で取得して設定しなければなりません。
キー/シークレットは、 src/WFSocialListenerDemo/WFSocialListenerDemo/TwitterAPI_APP_TOKEN.h の定義に記述します。
```
 #define kAppKey    @""
 #define kAppSecret @""
```

#コミット時にアプリケーション・トークンを取り除く設定
自分のアプリケーション・トークンを、コミット時に空文字列に置換するGitの設定を述べます。以下の内容の、ファイル WFSocialListener/.git/info/attributes を作ります。
```
TwitterAPI_APP_TOKEN.h filter=emptyString
```
次に、configファイル WFSocialListener/.git/config に以下のテキストを追加します。
```
[filter "emptyString"]
	clean = sed -e 's/@\".*\"/@\"\"/g'
```
TwitterAPI_APP_TOKEN.h のトークンは、コミット時にsedのワンライナで、空文字列に置換されます。
	
#動作の説明
* Twitterには、リアルタイムに更新を受け取るストリーミングAPIと、クライアントから一定時間ごとに接続して更新を取り出すREST APIの、2つのAPIがあります。
** TwitterはストリーミングAPIは安定したネットワーク環境で利用するべし、と説明しています。このライブラリはWiFi接続時にストリーミングAPI、3G接続時にREST APIを使います。
* 利用しているのが、ストリーミングAPIかREST APIで、通知機能に違いがあります。
** FavoritedはPollingではREST APIではできません。これは取得APIがないためです。Streaming時のみ有効です。


#ライセンス
このリポジトリのファイル群は、(合)わふう、が開発し著作権を有しています。
THE MIT Licenseのもとで提供されます。

Copyright 2013 WA-FU-U, LLC.

The MIT License (MIT)
Copyright (c) 2013 WA-FU-U, LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#連絡先
(合)わふう
上原 昭宏
e-mail: u-akihiro@wa-fu-u.com
