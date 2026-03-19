# Product API + UI (Express + MongoDB, fallback in-memory)

> Lưu ý: Dự án này được cung cấp làm nền tảng tham khảo cho sinh viên thực hiện bài presentation giữa kỳ trong môn 502094 - Software Deployment, Operations And Maintenance (biên soạn: ThS. Mai Văn Mạnh). Sinh viên không bắt buộc phải sử dụng đúng dự án này — có thể tự chọn hoặc xây dựng một project tương đương (hoặc phức tạp hơn), sử dụng ngôn ngữ hoặc framework khác nếu muốn.

Đây là một project mẫu tổ chức theo mô hình MVC (Model — View — Controller) xây dựng bằng Node.js + Express, dùng MongoDB (Mongoose) để lưu trữ dữ liệu sản phẩm. Nếu server không kết nối được tới MongoDB trong lần khởi động (timeout 3s), ứng dụng sẽ tự động chuyển sang dùng một datastore `in-memory` và tiếp tục chạy.

**Tính năng chính**
- API REST đầy đủ cho quản lý Product: CRUD (GET/POST/PUT/PATCH/DELETE).
- UI server-side render bằng `EJS` kết hợp `Bootstrap` để quản lý sản phẩm (giao diện ở `/`).
- Mỗi response JSON kèm theo thông tin `hostname` và `source` (dữ liệu đang lấy từ `mongodb` hay `in-memory`).
- Hỗ trợ upload ảnh cho sản phẩm: ảnh được lưu trên đĩa trong `public/uploads/` và trường `imageUrl` trong product lưu đường dẫn tương đối (`/uploads/<filename>`).
- Khi cập nhật hoặc xóa product, file ảnh cũ (nằm trong `/uploads/`) sẽ bị xóa khỏi đĩa.
- Khi khởi động và nếu kết nối MongoDB thành công và collection rỗng, ứng dụng sẽ tự seed 10 sản phẩm Apple mẫu vào MongoDB.

**Cấu trúc chính**
- `main.js` — entrypoint: kết nối MongoDB (timeout 3s), fallback in-memory, khởi chạy Express.
- `models/product.js` — Mongoose schema (`name`, `price`, `color`, `description`, `imageUrl`).
- `services/dataSource.js` — lớp trừu tượng giữa MongoDB và in-memory (seed, CRUD, xóa file khi cần).
- `controllers/` — controller xử lý logic request/response.
- `routes/` — route cho API (`/products`) và UI (`/`).
- `views/` — `EJS` templates cho UI.
- `public/` — tệp tĩnh: CSS, JS, `uploads/` (ảnh được lưu ở đây).

**Yêu cầu & cấu hình**
- Node.js 16+ (hoặc phiên bản tương thích) và `npm`.
- File môi trường `.env` (đã có file mẫu trong repo):

```text
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

Nếu bạn muốn kết nối MongoDB có username/password, chỉnh `MONGO_URI` tương ứng.

**Cài đặt & chạy trên máy local**
1. Cài dependencies:

```bash
cd C:\Users\PC1\Documents\Zalo Received Files\GK_MVM
npm install
```

2. Khởi động server:

```bash
# Chạy production (node)
npm start

# Hoặc chế độ phát triển với nodemon
npm run dev
```

3. Mở trình duyệt vào: `http://localhost:3000/` — trang UI sẽ hiển thị danh sách sản phẩm và cung cấp các thao tác Add / Edit / Delete.

**API (JSON) — endpoints chính**
- `GET /products` — lấy danh sách sản phẩm.
- `GET /products/:id` — lấy chi tiết 1 sản phẩm.
- `POST /products` — tạo mới. Được hỗ trợ multipart form-data để upload ảnh (field file: `imageFile`) và các field text: `name`, `price`, `color`, `description`.
- `PUT /products/:id` — thay thế toàn bộ product. Hỗ trợ upload file theo multipart.
- `PATCH /products/:id` — cập nhật một phần. Hỗ trợ upload file theo multipart.
- `DELETE /products/:id` — xóa product và xóa file ảnh tương ứng nếu ảnh được lưu trong `/uploads/`.

Ví dụ tạo product (curl, upload file):

```bash
curl -X POST -F "name=My Device" -F "price=199" -F "color=black" -F "description=Note" -F "imageFile=@/path/to/photo.jpg" http://localhost:3000/products
```

Lưu ý: UI trên trang chủ sử dụng fetch + FormData để gửi file, nên bạn không cần thay đổi gì nếu dùng giao diện.

**Behavior quan trọng**
- Khi khởi động, `main.js` cố gắng connect tới MongoDB với `serverSelectionTimeoutMS: 3000`. Nếu thất bại, ứng dụng sẽ in log và dùng `in-memory` suốt vòng đời process.
- Khi MongoDB thành công và collection `products` rỗng, repo sẽ seed 10 sản phẩm Apple mẫu (có `name`, `price`, `color`, `description`, `imageUrl` mặc định rỗng).
- Ảnh được lưu trên đĩa tại `public/uploads/` và được phục vụ tĩnh bởi Express; đường dẫn lưu trong DB là tương đối (`/uploads/<filename>`).
- Khi cập nhật ảnh mới cho một product, file cũ nếu có và nằm trong `/uploads/` sẽ bị xóa.

**Giới hạn & khuyến nghị**
- Hiện tại server cho phép upload file và lưu trực tiếp trên đĩa — phù hợp cho demo và môi trường dev, nhưng không tối ưu cho production (về backup, scale và băng thông). Với môi trường production, nên dùng lưu trữ cloud (S3/Cloudinary) và chỉ lưu URL trong DB.
- Thêm giới hạn kích thước file và kiểm tra MIME type nếu bạn muốn an toàn hơn. Tôi có thể thêm cấu hình `multer` để giới hạn kích thước (ví dụ 2MB) và whitelist `image/*`.

**Một số lệnh tiện ích**
- Cài thêm `nodemon` global (nếu muốn): `npm i -g nodemon`.
- Xem log server (stdout) để biết liệu app đang dùng `mongodb` hay `in-memory`.

**Tôi có thể giúp tiếp**
- Thêm giới hạn kích thước file và kiểm tra MIME type.
- Hoặc chuyển lưu trữ ảnh sang S3/Cloudinary (cần credentials).
- Thêm trang chi tiết sản phẩm hoặc phân trang cho danh sách.

Nếu bạn muốn tôi cập nhật README để ghi rõ cách migrate dữ liệu, cách reset uploads hoặc ví dụ cụ thể hơn, cho biết yêu cầu cụ thể và tôi sẽ bổ sung.

**PHẦN 2: TÀI LIỆU TRIỂN KHAI ĐỒ ÁN (DEPLOYMENT)**
Dự án này không chỉ dừng lại ở mức phát triển ứng dụng (Development) mà còn áp dụng các tiêu chuẩn DevOps để triển khai lên môi trường Production thực tế. Hệ thống được chia thành 3 giai đoạn (Phases) tăng tiến:

*1. Cấu trúc Repository (Phase 1)*
    Mã nguồn được tổ chức lại theo chuẩn để dễ dàng quản lý hạ tầng và mã nguồn:

    src/: Chứa toàn bộ mã nguồn ứng dụng Node.js (từ project gốc).

    scripts/: Chứa file setup.sh tự động hóa cài đặt môi trường.

    phase2/ & phase3/: Chứa các tài liệu, cấu hình Nginx, Dockerfile và docker-compose riêng biệt cho từng giai đoạn.

    Quy trình Git: Nhánh main được áp dụng Branch Protection. Mọi thay đổi code đều phải thông qua Pull Request (PR) và được thành viên khác review (Approve) trước khi Merge.

*2. Triển khai Host-based (Phase 2)*
    Ở giai đoạn này, ứng dụng được chạy trực tiếp trên máy chủ vật lý/máy ảo (AWS EC2 Ubuntu).

    Tự động hóa cài đặt: Sử dụng scripts/setup.sh để cài đặt Node.js, MongoDB, PM2 và Nginx chỉ với 1 lệnh.

    Quản lý tiến trình (PM2): Thay vì chạy bằng lệnh node thông thường, hệ thống sử dụng PM2 để đảm bảo ứng dụng luôn sống (High Availability). PM2 được cấu hình tự động khởi chạy lại ứng dụng ngay cả khi máy chủ bị sập nguồn (Reboot).

    ```Bash
    cd src
    pm2 start npm --name "midterm-app" -- start
    pm2 save
    ```
    Bảo mật & Điều hướng (Nginx Reverse Proxy): * Ứng dụng Node.js chạy ngầm ở Port 3000.

    Nginx được thiết lập làm người gác cổng, nhận traffic từ Port 80 (HTTP) và 443 (HTTPS) rồi forward an toàn vào Port 3000.

    Tích hợp chứng chỉ SSL/TLS (Certbot) để mã hóa dữ liệu.

*3. Triển khai Containerization (Phase 3 - Docker)*
    Để giải quyết bài toán "Works on my machine" và cách ly môi trường, hệ thống được nâng cấp lên kiến trúc Container.

    Đóng gói Image: Ứng dụng Node.js được build thành Docker Image tối ưu (dùng node:20-alpine) và đẩy lên Docker Hub.

    Orchestration (Docker Compose): Khởi chạy toàn bộ stack (Web App + MongoDB) chỉ bằng một tệp docker-compose.yml.

    ```Bash
    cd phase3
    docker compose up -d
    ```
    Bảo vệ dữ liệu (Persistent Volumes): Vì ứng dụng có tính năng upload ảnh (lưu vào đĩa tại public/uploads/), nếu Container bị xóa, ảnh sẽ mất. Nhóm đã cấu hình Docker Volumes để ánh xạ thư mục upload và dữ liệu MongoDB ra ngoài máy Host. Đảm bảo dữ liệu tồn tại vĩnh viễn dù Container có bị khởi động lại hay xóa bỏ.

# Trích xuất từ docker-compose.yml
volumes:
  - uploads_data:/app/src/public/uploads
  - mongo_data:/data/db
Tự phục hồi: Các container được cấu hình chính sách restart: always, tự động đứng dậy sau sự cố crash hoặc khi máy chủ khởi động lại.
