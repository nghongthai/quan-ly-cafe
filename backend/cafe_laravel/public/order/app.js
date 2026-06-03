/**
 * ZaDa Café – Customer Web App
 * Redesigned to match Figma: Blue theme, List layout
 */

const CONFIG = {
  API_BASE: `${window.location.origin}/api`,
};

// Emoji fallback cho sản phẩm
const EMOJIS = ['☕','🧋','🍵','🥤','🍰','🧁','🥐','🍩','🫖','🍫','🥛','🍹','🧃','🍪','🎂','🥧'];
const getEmoji = (id) => EMOJIS[(id || 0) % EMOJIS.length];

// Danh mục theo tên sản phẩm (nếu backend chưa có trường category)
function guessCategory(name) {
  const n = name.toLowerCase();
  if (n.includes('cafe') || n.includes('cà phê') || n.includes('cappuccino') || n.includes('cold brew') || n.includes('espresso')) return 'Coffee';
  if (n.includes('sinh tố') || n.includes('sinh to')) return 'Sinh tố';
  if (n.includes('nước ép') || n.includes('nuoc ep') || n.includes('cam') || n.includes('dưa')) return 'Nước ép';
  if (n.includes('trà') || n.includes('tra') || n.includes('oolong') || n.includes('matcha')) return 'Trà';
  if (n.includes('sữa chua') || n.includes('sua chua') || n.includes('yaourt')) return 'Sữa chua';
  if (n.includes('soda')) return 'Soda';
  return 'Khác';
}

/* ============ STATE ============ */
const State = {
  tableId: null,
  tableName: null,
  products: [],
  filtered: [],
  activeCategory: 'all',
  searchQuery: '',
  cart: {}, // { productId: { product, quantity } }

  get cartItems() { return Object.values(this.cart); },
  get cartCount() { return this.cartItems.reduce((s, i) => s + i.quantity, 0); },
  get cartTotal() { return this.cartItems.reduce((s, i) => s + i.product.price * i.quantity, 0); },
};

/* ============ HELPERS ============ */
function fmt(price) {
  return Number(price).toLocaleString('vi-VN') + 'đ';
}

function showScreen(id) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const el = document.getElementById(id);
  if (el) el.classList.add('active');
}

function showToast(msg, ms = 1800) {
  let t = document.getElementById('app-toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'app-toast';
    t.className = 'toast';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(t._t);
  t._t = setTimeout(() => t.classList.remove('show'), ms);
}

function showSubmitting(show) {
  const id = 'submitting-overlay';
  if (show) {
    if (document.getElementById(id)) return;
    const el = document.createElement('div');
    el.id = id;
    el.className = 'submitting-overlay';
    el.innerHTML = `<div class="submitting-box"><div class="loading-spinner"></div><p>Đang gửi đơn hàng...</p></div>`;
    document.body.appendChild(el);
  } else {
    document.getElementById(id)?.remove();
  }
}

async function apiFetch(path, opts = {}) {
  const res = await fetch(CONFIG.API_BASE + path, {
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    ...opts,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || `HTTP ${res.status}`);
  }
  return res.json();
}

/* ============ API ============ */
async function fetchProducts() {
  const data = await apiFetch('/products');
  return Array.isArray(data) ? data : (data.data || []);
}

async function postAddProduct(tableId, productId, quantity) {
  return apiFetch('/order/add-product', {
    method: 'POST',
    body: JSON.stringify({ table_id: tableId, product_id: productId, quantity }),
  });
}

/* ============ RENDER ============ */

// Skeleton loading
function renderSkeletons() {
  const list = document.getElementById('product-list');
  list.innerHTML = Array(6).fill(0).map(() => `
    <div class="skeleton-row">
      <div class="skel skel-img"></div>
      <div class="skel-text">
        <div class="skel skel-name"></div>
        <div class="skel skel-price"></div>
      </div>
    </div>
  `).join('');
}

// Category chips
function renderCategories() {
  const bar = document.getElementById('category-bar');
  let cats = [...new Set(State.products.map(p => p.category || guessCategory(p.name)))];

  // Sắp xếp đưa danh mục 'Khác' xuống cuối cùng
  if (cats.includes('Khác')) {
    cats = cats.filter(c => c !== 'Khác');
    cats.push('Khác');
  }

  bar.innerHTML = `<button class="cat-chip active" data-cat="all" onclick="App.filterCategory('all',this)">Tất cả</button>`
    + cats.map(c =>
        `<button class="cat-chip" data-cat="${c}" onclick="App.filterCategory('${c}',this)">${c}</button>`
      ).join('');
}

// Lọc sản phẩm theo category + search
function getFiltered() {
  let list = State.products;
  if (State.activeCategory !== 'all') {
    list = list.filter(p => (p.category || guessCategory(p.name)) === State.activeCategory);
  }
  if (State.searchQuery) {
    const q = State.searchQuery.toLowerCase();
    list = list.filter(p => p.name.toLowerCase().includes(q));
  }
  return list;
}

// Render danh sách sản phẩm
function renderProducts() {
  const list = document.getElementById('product-list');
  const items = getFiltered();

  if (!items.length) {
    list.innerHTML = `<div style="padding:40px 0;text-align:center;color:#999;font-size:14px;">Không tìm thấy sản phẩm</div>`;
    return;
  }

  list.innerHTML = items.map((p, i) => {
    const inCart = State.cart[p.id];
    const qty = inCart ? inCart.quantity : 0;
    const emoji = getEmoji(p.id || i);

    const imgUrl = p.image && (p.image.startsWith('http') || p.image.startsWith('/') || p.image.startsWith('data:'))
      ? p.image
      : `assets/images/${p.image}`;

    const imgEl = p.image
      ? `<div class="product-img"><img src="${imgUrl}" alt="${p.name}" onerror="this.parentElement.innerHTML='<span style=font-size:32px>${emoji}</span>'"/></div>`
      : `<div class="product-img-placeholder">${emoji}</div>`;

    const qtyCtrl = qty > 0
      ? `<div class="row-qty" id="qty-${p.id}">
           <button class="qty-btn-circle" onclick="App.dec(${p.id})">−</button>
           <span class="qty-num-row">${qty}</span>
           <button class="qty-btn-circle add" onclick="App.inc(${p.id})">+</button>
         </div>`
      : `<div class="row-qty" id="qty-${p.id}">
           <button class="qty-btn-circle add" onclick="App.inc(${p.id})">+</button>
         </div>`;

    return `
      <div class="product-row" style="animation-delay:${i * 0.04}s">
        ${imgEl}
        <div class="product-info">
          <div class="product-name">${p.name}</div>
          <div class="product-price">${fmt(p.price)}</div>
        </div>
        ${qtyCtrl}
      </div>`;
  }).join('');
}

// Cập nhật số lượng 1 sản phẩm (không re-render toàn bộ)
function updateQtyEl(productId) {
  const el = document.getElementById(`qty-${productId}`);
  if (!el) return;
  const inCart = State.cart[productId];
  const qty = inCart ? inCart.quantity : 0;

  if (qty === 0) {
    el.innerHTML = `<button class="qty-btn-circle add" onclick="App.inc(${productId})">+</button>`;
  } else {
    el.innerHTML = `
      <button class="qty-btn-circle" onclick="App.dec(${productId})">−</button>
      <span class="qty-num-row">${qty}</span>
      <button class="qty-btn-circle add" onclick="App.inc(${productId})">+</button>`;
  }
}

// Cart bar
function updateCartBar() {
  const bar = document.getElementById('cart-bar');
  const n = State.cartCount;
  if (n === 0) { bar.classList.add('hidden'); return; }
  bar.classList.remove('hidden');
  document.getElementById('cart-count').textContent = n;
  document.getElementById('cart-total').textContent = fmt(State.cartTotal);
}

// Render giỏ hàng panel
function renderCart() {
  const wrap = document.getElementById('cart-items');
  const btn = document.getElementById('btn-order');
  const items = State.cartItems;

  if (!items.length) {
    wrap.innerHTML = `<div class="cart-empty-state">🛒 Giỏ hàng trống<br><span style="font-size:12px">Hãy thêm món yêu thích!</span></div>`;
    btn.disabled = true;
    return;
  }

  btn.disabled = false;
  wrap.innerHTML = items.map(({ product: p, quantity }) => {
    const emoji = getEmoji(p.id);
    const imgUrl = p.image && (p.image.startsWith('http') || p.image.startsWith('/') || p.image.startsWith('data:'))
      ? p.image
      : `assets/images/${p.image}`;

    const imgEl = p.image
      ? `<img src="${imgUrl}" alt="${p.name}" onerror="this.style.display='none'"/><span>${emoji}</span>`
      : emoji;
    return `
      <div class="cart-item-row">
        <div class="cart-item-img">${imgEl}</div>
        <div class="cart-item-info">
          <div class="cart-item-name">${p.name}</div>
          <div class="cart-item-price">${fmt(p.price * quantity)}</div>
        </div>
        <div class="row-qty">
          <button class="qty-btn-circle" onclick="App.dec(${p.id});renderCart()">−</button>
          <span class="qty-num-row">${quantity}</span>
          <button class="qty-btn-circle add" onclick="App.inc(${p.id});renderCart()">+</button>
        </div>
      </div>`;
  }).join('');

  document.getElementById('cart-footer-total').textContent = fmt(State.cartTotal);
}

// Render xác nhận
function renderConfirm() {
  document.getElementById('confirm-table-name').textContent = State.tableName || `Bàn ${State.tableId}`;
  document.getElementById('confirm-total').textContent = fmt(State.cartTotal);

  document.getElementById('confirm-list').innerHTML = State.cartItems.map(({ product: p, quantity }) => `
    <div class="confirm-item">
      <span>${p.name}<span class="confirm-item-qty">x${quantity}</span></span>
      <span class="confirm-item-price">${fmt(p.price * quantity)}</span>
    </div>`).join('');
}

/* ============ APP CONTROLLER ============ */
const App = {

  async init() {
    showScreen('screen-loading');

    const params = new URLSearchParams(window.location.search);
    let tableId = params.get('table') || params.get('table_id');

    // Phương án 1: Tự động chọn Bàn 1 mặc định khi chạy thử nghiệm (Không có ?table= trên link)
    if (!tableId) {
      console.warn("Không tìm thấy tham số '?table=...' trên URL. Tự động gán Bàn 1 để chạy thử nghiệm.");
      tableId = '1';
    }

    State.tableId = tableId;
    State.tableName = `Bàn ${tableId}`;

    try {
      renderSkeletons();
      showScreen('screen-menu');

      const products = await fetchProducts();
      // Gán category nếu chưa có
      State.products = products.map(p => ({ ...p, category: p.category || guessCategory(p.name) }));

      renderCategories();
      renderProducts();
    } catch (err) {
      console.error(err);
      showScreen('screen-error');
      document.getElementById('error-message').textContent = `Lỗi: ${err.message}`;
    }
  },

  onSearch(val) {
    State.searchQuery = val.trim();
    renderProducts();
  },

  filterCategory(cat, btn) {
    State.activeCategory = cat;
    document.querySelectorAll('.cat-chip').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderProducts();
  },

  inc(productId) {
    const product = State.products.find(p => p.id === productId);
    if (!product) return;
    if (State.cart[productId]) {
      State.cart[productId].quantity++;
    } else {
      State.cart[productId] = { product, quantity: 1 };
      showToast(`✓ Thêm ${product.name}`);
    }
    updateQtyEl(productId);
    updateCartBar();
  },

  dec(productId) {
    if (!State.cart[productId]) return;
    State.cart[productId].quantity--;
    if (State.cart[productId].quantity <= 0) delete State.cart[productId];
    updateQtyEl(productId);
    updateCartBar();
  },

  openCart() {
    renderCart();
    document.getElementById('cart-overlay').classList.remove('hidden');
    document.getElementById('cart-panel').classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  },

  closeCart() {
    document.getElementById('cart-overlay').classList.add('hidden');
    document.getElementById('cart-panel').classList.add('hidden');
    document.body.style.overflow = '';
  },

  openConfirm() {
    if (!State.cartCount) return;
    App.closeCart();
    renderConfirm();
    setTimeout(() => {
      document.getElementById('confirm-overlay').classList.remove('hidden');
      document.getElementById('confirm-panel').classList.remove('hidden');
      document.body.style.overflow = 'hidden';
    }, 200);
  },

  closeConfirm() {
    document.getElementById('confirm-overlay').classList.add('hidden');
    document.getElementById('confirm-panel').classList.add('hidden');
    document.body.style.overflow = '';
  },

  async submitOrder() {
    const btn = document.getElementById('btn-confirm');
    btn.disabled = true;
    showSubmitting(true);

    try {
      for (const { product, quantity } of State.cartItems) {
        await postAddProduct(State.tableId, product.id, quantity);
      }

      showSubmitting(false);
      App.closeConfirm();

      const total = State.cartTotal;
      const count = State.cartItems.length;
      document.getElementById('success-info').textContent =
        `${State.tableName} · ${fmt(total)} · ${count} món`;

      State.cart = {};
      updateCartBar();
      renderProducts();
      showScreen('screen-success');

    } catch (err) {
      showSubmitting(false);
      btn.disabled = false;
      showToast(`❌ ${err.message}`, 3000);
    }
  },

  goBackToMenu() {
    showScreen('screen-menu');
  },
};

document.addEventListener('DOMContentLoaded', () => App.init());
