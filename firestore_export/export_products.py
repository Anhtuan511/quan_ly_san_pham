
import json
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore

# Đường dẫn đến khóa Firebase
key_path = r"D:\firebase_private\serviceAccountKey.json"

# Kết nối Firebase
cred = credentials.Certificate(key_path)
firebase_admin.initialize_app(cred)

db = firestore.client()

# Đọc dữ liệu từ collection products
products = []

for doc in db.collection("products").stream():
    data = doc.to_dict()

    products.append({
        "name": data.get("name", ""),
        "price": data.get("price", 0),
        "soluong": data.get("soluong", 0),
        "image": data.get("image", "")
    })

# Đường dẫn lưu file JSON
output = Path(
    r"D:\quan_ly_san_pham\firestore_export\products.json"
)

# Xuất dữ liệu thành JSON
with open(output, "w", encoding="utf-8") as file:
    json.dump(products, file, ensure_ascii=False, indent=4)

print(f"Xuất thành công {len(products)} sản phẩm!")
print(f"File JSON được lưu tại: {output}")
