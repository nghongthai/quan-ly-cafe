# Customer Web App – ZaDa Café

Giao diện đặt món cho khách hàng khi quét QR tại bàn.

## Cách hoạt động

1. Nhân viên tạo QR code cho mỗi bàn (URL có kèm `?table=ID`)
2. Khách quét QR → trình duyệt mở trang web
3. Khách chọn món → đặt hàng → nhân viên nhận đơn trong app Flutter

## Cấu trúc

```
customer-web/
├── index.html   ← Giao diện chính
├── style.css    ← CSS mobile-first
├── app.js       ← Logic, API calls, quản lý giỏ hàng
└── README.md    ← Hướng dẫn này
```

## Cài đặt & Chạy

### 1. Đảm bảo backend đang chạy
```bash
cd backend/cafe_laravel
php artisan serve
# → http://localhost:8000
```

### 2. Bật CORS cho Laravel

Trong file `config/cors.php`, đảm bảo có:
```php
'paths' => ['api/*'],
'allowed_origins' => ['*'],  // Hoặc chỉ định domain cụ thể
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

### 3. Mở web app

**Cách A – Mở thẳng file (local test):**
```
Mở trình duyệt → Kéo file index.html vào
URL: file:///path/to/customer-web/index.html?table=1
```

> ⚠️ Lưu ý: Nếu mở thẳng file (`file://`), browser sẽ block API call do CORS.
> Dùng Live Server (VS Code extension) hoặc cách B bên dưới.

**Cách B – Dùng VS Code Live Server (khuyến nghị khi dev):**
1. Cài extension "Live Server" trong VS Code
2. Click chuột phải vào `index.html` → "Open with Live Server"
3. Truy cập: `http://127.0.0.1:5500/customer-web/index.html?table=1`

**Cách C – Đặt vào thư mục public của Laravel:**
```bash
# Copy toàn bộ customer-web vào public/
cp -r customer-web/ backend/cafe_laravel/public/order/
# Truy cập: http://localhost:8000/order/index.html?table=1
```

## Tạo QR Code cho từng bàn

Dùng website tạo QR miễn phí như [qr-code-generator.com](https://www.qr-code-generator.com/) hoặc [goqr.me](https://goqr.me/):

| Bàn | URL để tạo QR |
|-----|---------------|
| Bàn 1 | `http://YOUR_DOMAIN/order/index.html?table=1` |
| Bàn 2 | `http://YOUR_DOMAIN/order/index.html?table=2` |
| Bàn 3 | `http://YOUR_DOMAIN/order/index.html?table=3` |

## Thay đổi API URL

Khi deploy lên server thật, sửa dòng đầu trong `app.js`:
```js
const CONFIG = {
  API_BASE: 'http://YOUR_SERVER_IP/api',  // ← Sửa ở đây
};
```

## API sử dụng

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/products` | Lấy danh sách món ăn |
| POST | `/api/order/add-product` | Thêm món vào đơn hàng |

**Body của POST `/api/order/add-product`:**
```json
{
  "table_id": 1,
  "product_id": 3,
  "quantity": 2
}
```
