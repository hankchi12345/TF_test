# 雙AZ 日本與台灣購物網站 - Terragrunt 配置

這個項目使用 Terragrunt 管理 Terraform 配置，建立一個高可用性、高併發的購物網站，部署在日本東京和台灣台北的雙可用區架構。

## 架構特點

- **多區域部署**：東京 (ap-northeast-1) 和台北 (ap-northeast-3)
- **雙AZ架構**：每個區域使用多個可用區確保高可用性
- **高可用性**：
  - RDS MySQL 數據庫啟用多AZ
  - Auto Scaling Group 自動擴展 (1-10 實例)
  - Application Load Balancer 分散流量
- **高併發**：Auto Scaling Group 根據需求自動擴展
- **全球分發**：CloudFront CDN
- **模塊化設計**：使用 Terragrunt 模塊化管理

## 目錄結構

```
TF_test/
├── terragrunt.hcl          # Terragrunt 配置
├── main.tf                 # 主配置 (使用模塊)
├── variables.tf            # 變數定義
├── outputs.tf              # 輸出定義
├── locals.tf               # 本地變數
├── terraform.tfvars        # 變數值
├── observability.tf        # 新增觀測性設置 (CloudWatch/X-Ray/CloudTrail/EventBridge/SNS)
├── modules/                # 模塊目錄
│   ├── vpc/               # VPC 模塊
│   ├── database/          # 數據庫模塊
│   ├── web/               # Web 服務器模塊
│   └── networking/        # 網路模塊 (ALB)
└── .gitignore
```

## 安全注意事項

⚠️ **生產環境注意**：
- 數據庫密碼目前硬編碼，應使用 AWS Secrets Manager
- 考慮使用 AWS KMS 加密敏感數據
- 設置適當的 IAM 權限和角色
- 啟用 CloudTrail 和 Config 用於審計

## 使用步驟

### 1. 安裝 Terragrunt
```bash
# 已安裝在系統中
terragrunt --version
```

### 2. 配置 AWS 憑證
```bash
aws configure
```

### 3. 初始化並部署
```bash
cd /usr/AWSdoc/TF_test

# 初始化
terragrunt init

# 計劃
terragrunt plan

# 部署
terragrunt apply
```

### 4. 銷毀資源 (小心使用)
```bash
terragrunt destroy
```

## 輸出

部署後，您將獲得：
- `tokyo_alb_dns`: 東京 ALB DNS 名稱
- `taipei_alb_dns`: 台北 ALB DNS 名稱
- `cloudfront_domain`: CloudFront 分發域名
- 數據庫端點 (敏感信息)

## 自定義配置

### 修改實例類型
編輯 `terraform.tfvars`:
```hcl
instance_type = "t3.small"
db_instance_class = "db.t3.small"
```

### 調整 Auto Scaling
```hcl
min_size = 2
max_size = 20
desired_capacity = 4
```

### 添加環境
為不同環境創建子目錄，如 `prod/` 或 `staging/`，並複製 `terragrunt.hcl`。

## 故障排除

- 確保 AWS 憑證正確配置
- 檢查區域可用性 (東京和台北)
- 驗證 S3 桶名稱的唯一性
- 監控 AWS 服務配額

## 成本考慮

- EC2 實例：按使用量計費
- RDS：按實例小時計費
- CloudFront：按數據傳輸計費
- S3：按存儲和請求計費

使用完畢後記得銷毀資源以避免不必要的費用。

## Observability（觀測性）新增內容

新增文件：`observability.tf`

包含：
- SNS 告警主題 + Email 訂閱
- CloudWatch 日誌組：應用、ALB、RDS、VPC Flow Logs、Lambda
- VPC Flow Logs（東京 & 台北）
- X-Ray 採樣規則 (default / high-traffic)
- CloudTrail (多區域、日誌驗證、S3 加密)
- EventBridge 事件規則：EC2 實例狀態、RDS 事件
- CloudWatch 儀表板與告警：高CPU、高回應時間、不健康主機、錯誤率

變數變更：
- `alert_email`
- `log_retention_days`
- `enable_vpc_flow_logs`
- `enable_cloudtrail`
- `enable_xray`
- `xray_sampling_rate`

輸出變更：
- `sns_alerts_topic_arn`
- `cloudwatch_dashboard_url`
- `cloudtrail_s3_bucket`
- `cloudtrail_name`
- `vpc_flow_logs_log_group_tokyo`
- `vpc_flow_logs_log_group_taipei`
- `xray_sampling_rule`
- `application_log_group`
- `alb_log_group`
- `rds_log_group`