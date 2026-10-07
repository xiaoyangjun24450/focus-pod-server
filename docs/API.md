# FocusBod API接口

统一约定：  
- 请求头：`Content-Type: application/json`；需要登录的接口加 `Authorization: Bearer <token>`。  
- 响应统一外层：`{ "code": 0, "message": "success", "data": { ... } }`，`code=0` 成功。  

## 账户相关

### 1.1 `POST /api/register/send-code`
**功能**：注册前发送邮箱验证码。校验识别码有效且未使用，然后向邮箱发送 6 位验证码。  
**输入**：
```json
{
  "email": "user@example.com",
  "inviteCode": "VIP-2026-ABCD"
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "success": true,
    "expireIn": 300
  }
}
```
说明：`expireIn` 为验证码有效期（秒）。需做频率限制，如同一邮箱 60 秒内只能发一次。

### 1.2 `POST /api/register`
**功能**：提交注册。校验邮箱验证码、识别码、密码；创建用户，入库；赠送 5000 积分。  
**输入**：
```json
{
  "email": "user@example.com",
  "inviteCode": "VIP-2026-ABCD",
  "password": "MyPass123!",
  "emailCode": "123456"
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "inviteCode": "VIP-2026-ABCD",
      "email": "user@example.com",
      "points": 5000
    }
  }
}
```

### 2.1 `POST /api/login/send-code`
**功能**：登录前发送邮箱验证码。仅对已注册邮箱发送，用于验证码登录。需做频率限制，如同一邮箱 60 秒内只能发一次；邮箱未注册时返回统一提示，避免用户枚举。  
**输入**：
```json
{
  "email": "user@example.com"
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "success": true
  }
}
```

### 2.2 `POST /api/login`
**功能**：登录接口，支持两种方式：  
- 密码登录：`type = "password"`，传 `email` + `password`  
- 验证码登录：`type = "code"`，传 `email` + `emailCode`  

登录成功返回 token 和用户信息。  
**输入（密码登录）**：
```json
{
  "type": "password",
  "email": "user@example.com",
  "password": "MyPass123!"
}
```
**输入（验证码登录）**：
```json
{
  "type": "code",
  "email": "user@example.com",
  "emailCode": "123456"
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1001,
      "email": "user@example.com",
      "points": 5000
    }
  }
}
```

### 3. `GET /api/me`
**功能**：获取当前登录用户信息，包含积分余额，以及持有的学习计划及每个计划的进度。  
**输入**：无（需 `Authorization: Bearer <token>`）  
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1001,
    "email": "user@example.com",
    "points": 4582,
    "plans": [
      {
        "planId": 501,
        "name": "每日英语30分钟",
        "status": "active",
        "totalTasks": 30,
        "completedTasks": 18
      },
      {
        "planId": 502,
        "name": "数学基础复习",
        "status": "active",
        "totalTasks": 20,
        "completedTasks": 5
      }
    ]
  }
}
```

### 4.1 `POST /api/orders`
**功能**：根据充值积分创建订单，返回支付参数给客户端调起支付。  
**输入**：
```json
{
  "packageId": 2000
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "orderId": "ORD202610070001",
    "payParams": {
      "appId": "wx123456",
      "timeStamp": "1728292800",
      "nonceStr": "abc123",
      "package": "prepay_id=wx...",
      "signType": "RSA",
      "paySign": "..."
    }
  }
}
```
说明：订单状态初始为“待支付”；支付参数由支付渠道生成；需记录订单与用户、套餐的关联。

### 4.2 `POST /api/payment/callback`
**功能**：支付平台异步回调接口。验签、幂等处理后，将订单置为“已支付”，并给用户增加对应积分。  
**输入**（支付平台发送，示例简化）：
```json
{
  "orderId": "ORD202610070001",
  "tradeNo": "420000123420261007123456",
  "amount": 45.00,
  "status": "SUCCESS",
  "sign": "支付平台签名"
}
```
**输出**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "success": true
  }
}
```

## 课程计划相关