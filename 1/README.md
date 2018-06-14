VPC
    public subnet1
    public subnet2
    private subnet1
    private subnet2
    RDS
を作成する設定のサンプル。

このディレクトリで

```
terraform apply
```

をすると、それらが作成される。
ネットワークだけを作成したい場合は、 rds.tf を一時的に他の拡張子にリネームするなどして実行する。

terraform.tfvars に書いてある `system_name` の部分を変えれば他のシステムにも流用できるはず。
