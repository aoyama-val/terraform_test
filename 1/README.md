```
VPC
    public subnet1 / public subnet2
        EC2
    private subnet1 / private subnet2
        RDS
```

という構成を作成する設定のサンプル。

実行前に最低限terraform.tfvarsの

```
aws_key_name = "val00362_keypair"
```

の部分だけ変更しといてください。

このディレクトリで

```
terraform apply
```

をすると、それらが作成される。
ネットワークだけを作成したい場合は、 rds.tf を一時的に他の拡張子にリネームするなどして実行する。

terraform.tfvars に書いてある `system_name` の部分を変えれば他のシステムにも流用できるはず。
