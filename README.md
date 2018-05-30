参考にしたページ 
https://tech.recruit-mp.co.jp/infrastructure/post-10665/

# Terraformのインストール

```
brew install terraform
terraform version
terraform init
```


```
# dry run
terraform plan

# 実行
terraform apply
terraform apply -auto-approve

# 全削除
terraform destroy

# terraform importで既存リソースをインポートできるらしい

# terraform workspaceで複数環境を切り替えられるらしい
# https://qiita.com/takachan/items/73407a54c0b5e1dbb48d
# terraform envはterraform workspaceの古い名前でdeprecated
```
