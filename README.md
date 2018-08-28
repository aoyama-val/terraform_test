参考にしたページ 
https://tech.recruit-mp.co.jp/infrastructure/post-10665/

# Terraformのインストール

```
brew install terraform
terraform version
terraform init
```

# 実行方法

`./1/README.md` を読んでください。

# terraformのコマンド

```
# dry run
terraform plan

# 実行
terraform apply
# 実行（y/nで聞かれるところを全部yにする）
terraform apply -auto-approve

# 全削除
terraform destroy

# terraform importで既存リソースをインポートできるらしい

# terraform workspaceで複数環境を切り替えられるらしい
# しかし terraform.tfvars で system_name に -staging などとつけるだけでいいという気も…
# 
# https://qiita.com/takachan/items/73407a54c0b5e1dbb48d
# terraform envはterraform workspaceの古い名前でdeprecated
```
