# 「アルゴリズム入門」(2023A) の課題作成キット

## 準備

### ソフトウェア環境

* `sh` や `make` が使えるUnix環境．
  + WSL2上のUbuntu 22.04 (LTS)で動作確認済み．
* Python環境：
  + Python 3.8以上（コマンド `python3` で呼び出せるようにする）
  + [`ipykernel`](https://pypi.org/project/ipykernel/)
  + 模範解答が用いるパッケージ（例：[`ita`](https://pypi.org/project/ita/)）

### ワーキングディレクトリ

1. このリポジトリをcloneする．
2. submoduleの `plags-scripts` リポジトリの中身を取ってくる．

```sh
git submodule update --init
```

以降では，このリポジトリのトップレベルディレクトリが，カレントディレクトリであると仮定する．

## 課題作成の手順

### ビルド

1. `masters` に問題文のみを記述したipynbファイル（master）を置く．
   * 以降ではmasterを `${exercise_name}.ipynb` とし，課題名を `${exercise_name}` とする．
   * `${exercise_name}` は正規表現 `[a-zA-Z0-9_-]{1,64}` にマッチする文字列であるとする．
2. `make` を実行．
   * `masters/${exercise_name}.py` が無ければ作られる．
      + 解答セルに最初から入っている（prefill）コード．
   * 自動評価のテストモジュール用ディレクトリ `tests/${exercise_name}` が無ければ作られる．
3. Prefillコード `masters/${exercise_name}.py` を編集（必要に応じて）．
4. テストモジュールを設置．
   * `tests/${exercise_name}` に設置するPythonモジュールの名前は自由．
   * 複数設置すると，モジュール名の順にステージ化して実行される．
5. `make` を実行．
   * 受講生に配布するform `forms/${exercise_name}.ipynb` が作られる．
   * PLAGS UTにアップロード可能な `conf.zip` が作られる．

#### Tips

ビルドの試行には `plags-scripts/exercises` を使うと手際が良い．

```
cp plags-scripts/exercises/as-is/ex2.ipynb masters/
make
cp plags-scripts/exercises/as-is/test_ex2.py tests/ex2/
make
```

### テスト

6. `make test` を実行．
   * `answers/${exercise_name}.py` が無ければ作られる．
7. 解答例 `answers/${exercise_name}.py` を編集．
8. `make test` を実行．
   * 解答例のテスト結果をまとめた `results/${exercise_name}.ipynb` が作られる．
   * 全課題のテスト結果をまとめた `results/results.json` も作られる．これは機械処理用の半構造化データである．
   * スクリプトの便宜上 `{exercise_name}.ipynb` と `results.json` を独立に作って出力しているので，振舞いが決定的でない場合は，結果が異なり得る．

#### Tips

`answers` には模範解答を置き，誤答例を別ディレクトリ（例えば `wrong_answers`）に置くと便利である．
このとき，誤答例をテストするときには `make ANSWER_DIR=wrong_answers test` を実行すればよい．

### 自動評価に係る留意事項

PLAGS UTは，**解答セルの中身のみ**を**自己完結したPythonプログラム**として扱う．
`%...` や `!...` などのJupyter（Colab）用コマンドは，構文エラーになる．
また，問題文（master）中のコードセルの実行を前提とした答案は，自己完結していないので，エラーになる．
import文などの既定のコードは，masterではく，prefillコードに記述することが想定されている．

PLAGS UT上の自動評価のPython環境は，ColabのPython環境とは異なる．
Colabでimportできるモジュール（例えば `numpy`）も，自動評価環境には入っていない．
基本的に，標準モジュールと `ita` モジュールしか使えないもの想定するべきである．
加えて，サンドボックスの都合で使えないモジュールもある．
したがって，少なくとも模範解答については，PLAGS UT上で自動評価結果を確認すべきである．

尚，サポートされていないモジュールが使われていた場合，課題共通のテストモジュールによって，`UMI` タグが付けられ `FE` となる．

## 課題のデプロイ手順

前述の手順で作成した `conf.zip` をPLAGS UTのコースにアップロードすれば，課題が登録されて，提出可能になる．
しかし，それだけではanswer form欄にOpen in Colabリンクが作られないので，受講生が演習可能な状態ではない．
課題のデプロイには，PLAGS UT上の課題に，配布されるformを関連付けることが必要である．
具体的な手順は，次の通り．

1. `forms/*.ipynb` を適当なGoogle Drive上にアップロード．
   * 以下ではフォルダ `shared/forms` に置くものとする．
   * ECCSクラウドDriveを推奨．
2. `shared/forms/*.ipynb` の閲覧権限を受講生に付与．
   * ECCSクラウドDriveであれば，学内限定で閲覧可能にできる．
3. `drive.json` を更新．
    * 課題名をキー，formのDrive ID/URLを値とした辞書．
    * 例： `{"${exericse_name}": "${DriveID}"}`
      + `${DriveID}` の代わりに `https://colab.research.google.com/drive/${DriveID}` や `https://drive.google.com/file/d/${DriveID}/` でも良い．
    * 作成を支援するGoogle Apps Scriptが `plags-scripts/README.md` にある．
4. `make` を実行．
   * `drive.json` の内容が，各masterに埋め込まれる．
5. `conf.zip` をPLAGS UTにアップロード．
   * `drive.json` の内容に従ってOpen in Colabリンクが生成される．

### master改訂時の更新

6. `make` を実行．
   * 問題文が更新された `conf.zip` が作成される．
7. `conf.zip` をPLAGS UTにアップロード．
   * PLAGS UT上での問題文が更新される．
8. Drive上の `shared/forms/*.ipynb` を**上書き更新**．
   * 上書きならば，URL（Drive ID）が変更されない．
   * 結果として，`drive.json` やOpen in Colabリンクは更新する必要はない．

### Tips

ブラウザ上の課題設定からでもColabリンクを設定できる．しかし，同課題を再度アップロードすると，ブラウザ上で設定したリンクが空に上書きされて消えてしまう．課題の漸次追加や更新を想定するなら，`drive.json` に Drive ID/URL を記述しておく方が扱いやすい．

`shared/forms/*.ipynb` を更新する権限を持つということは，PLGAS UTからOpen in Colabで開いたformをうっかり編集して学生にバラまくリスクがあるということである．
ECCSクラウドDriveにアップロードした場合，デフォルトのGoogleアカウントを，ECCSではなく個人用にすることで，事故を予防することができる．
このとき，`shared/forms/*.ipynb` の閲覧権限を，デフォルトの個人アカウントに付与すれば，他の利用者と同様の使用感になる．

## 管理者指定ファイル

* `judge_env.json`: 自動評価に関するサーバ側の設定が記述されているファイル．**変更禁止**．
* `rawcheck_ita.py`: 課題共通のテストモジュール．**変更禁止**．
