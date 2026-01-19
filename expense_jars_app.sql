-- SQLite
1. USERS (Đăng nhập)
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
2. CATEGORIES (Danh mục thu / chi)
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('INCOME','EXPENSE')),
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
3. INCOMES (Khoản thu)
CREATE TABLE incomes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  amount REAL NOT NULL CHECK (amount > 0),
  note TEXT,
  date TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
4. EXPENSES (Khoản chi)
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  amount REAL NOT NULL CHECK (amount > 0),
  note TEXT,
  date TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
5. CUSTOMERS (Khách hàng)
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  note TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
6. PRODUCTS (Hàng hóa / kho)
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  import_price REAL NOT NULL CHECK (import_price >= 0),
  sell_price REAL NOT NULL CHECK (sell_price >= 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  low_stock_alert INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
7. SALES (Giao dịch bán hàng)
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  customer_id INTEGER,
  total_amount REAL NOT NULL CHECK (total_amount >= 0),
  paid_amount REAL NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  status TEXT NOT NULL CHECK (status IN ('PAID','DEBT','PARTIAL')),
  date TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
8. SALE_ITEMS (Chi tiết bán hàng)
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price REAL NOT NULL CHECK (price >= 0),
  FOREIGN KEY (sale_id) REFERENCES sales(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
9. DEBTS (Công nợ)
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL UNIQUE,
  customer_id INTEGER NOT NULL,
  total_debt REAL NOT NULL CHECK (total_debt >= 0),
  remaining_debt REAL NOT NULL CHECK (remaining_debt >= 0),
  FOREIGN KEY (sale_id) REFERENCES sales(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
10. DEBT_PAYMENTS (Thanh toán nợ)
CREATE TABLE debt_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  debt_id INTEGER NOT NULL,
  amount REAL NOT NULL CHECK (amount > 0),
  date TEXT NOT NULL,
  FOREIGN KEY (debt_id) REFERENCES debts(id)
);
11. Index (tăng hiệu năng – nên có)
CREATE INDEX idx_categories_user ON categories(user_id);
CREATE INDEX idx_incomes_user ON incomes(user_id);
CREATE INDEX idx_expenses_user ON expenses(user_id);
CREATE INDEX idx_sales_user ON sales(user_id);
CREATE INDEX idx_products_user ON products(user_id);