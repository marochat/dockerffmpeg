# dockerffmpeg
## 概要
docker環境の勉強を兼ねて、最新のFFmpegをビルドして利用する環境の構築

## 使い方
- ビルド： $ docker build -t dockerffmpeg:local .
- 実行： $ docker run -it --rm --name dockerffmpeg -v \${PWD}:/tmp dokerffmpeg:local ffmpeg ....
- 実行時間やログを残したい場合は、ffmpegの部分を下記に変更
    - /bin/bash -c ‘(time ffmpeg ....) |& tee logfile’
- ToDo : 上記をシェルコマンド化するなど

## 特徴
- スナップショットから最新のFFmpegをビルドする
- SVT-AV1のコーデックを利用 (https://github.com/AOMediaCodec/SVT-AV1.git)
- Debian slim版をベースにビルド後に余分なライブラリやツールを削除した軽量なイメージを目指す

## Tips
- DebianにはFDK-aacのパッケージが存在しないので、下記よりダウンロードしてビルド
    - https://downloads.sourceforge.net/opencore-amr/fdk-aac-2.0.2.tar.gz