# Customer Web App – ZaDa Café

Giao diện đặt món cho khách hàng khi quét QR tại bàn.

## Cách hoạt động

1. Nhân viên tạo QR code cho mỗi bàn (URL có kèm `?table=ID`)
2. Khách quét QR → trình duyệt mở trang web
3. Khách chọn món → đặt hàng → nhân viên nhận đơn trong app Flutter

## Cấu trúc

```
customer-web/
├── assets/
│   └── images/  ← Chứa các file ảnh sản phẩm (.png) đồng bộ từ app
├── index.html   ← Giao diện chính (Đã tối ưu cuộn Sticky Header)
├── style.css    ← CSS mobile-first
├── app.js       ← Logic, API, tự động chọn Bàn 1 mặc định khi test
└── README.md    ← Hướng dẫn này
```

## Cài đặt & Chạy

### 1. Khởi động MySQL và Apache trên XAMPP
Hãy bật XAMPP Control Panel và nhấn **Start** cho cả Apache và MySQL để đảm bảo cơ sở dữ liệu đã sẵn sàng hoạt động.

### 2. Đảm bảo backend Laravel đang chạy
Mở Terminal trong VS Code và gõ:
```bash
cd backend/cafe_laravel
php artisan serve
# → Server running on [http://127.0.0.1:8000]
```
*(Hãy giữ nguyên tab Terminal này chạy, không tắt đi khi đang test).*

### 3. Mở web app & Cơ chế bàn mặc định

> 💡 **Cải tiến thông minh cho lập trình viên:** 
> Hệ thống đã được tích hợp **Phương án 1 (Tự động gán Bàn 1 mặc định)**. Nếu link URL không chứa tham số `?table=...` (ví dụ khi bạn mở thẳng từ Live Server), hệ thống sẽ tự động gán là `Bàn 1` để hiển thị menu ngay lập tức thay vì báo lỗi.

**Cách A – Dùng VS Code Live Server (Khuyến nghị số 1 cho nhà phát triển):**
1. Cài extension "Live Server" trong VS Code.
2. Click vào nút **`Go Live`** màu hồng ở thanh trạng thái dưới cùng bên phải màn hình VS Code (hoặc click chuột phải vào file `index.html` ➡️ chọn `Open with Live Server`).
3. Trình duyệt sẽ tự động mở trang web tại địa chỉ: `http://127.0.0.1:5500/customer-web/index.html` (Vào thẳng **Bàn 1** mặc định!).
4. Để giả lập bàn khác (ví dụ bàn 5), chỉ cần thêm đuôi: `http://127.0.0.1:5500/customer-web/index.html?table=5`

**Cách B – Mở trực tiếp bằng trình duyệt Chrome (Local test):**
1. Mở thư mục `customer-web/` trên máy tính.
2. Click chuột phải vào file `index.html` ➡️ Chọn **Open with** ➡️ **Google Chrome**.
3. Trình duyệt sẽ tự động chạy file local. Hệ thống sẽ tự nhận dạng **Bàn 1** làm mặc định để bạn test menu ngay.
4. Bạn có thể thay đổi số bàn bằng cách thêm đuôi: `.../index.html?table=2`

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
