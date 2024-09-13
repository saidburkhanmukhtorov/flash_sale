-- Create ENUM types (no dependencies)
CREATE TYPE product_type_enum AS ENUM ('REGULAR', 'FLASH_SALE', 'DISCOUNT');
CREATE TYPE discount_type_enum AS ENUM ('PERCENTAGE', 'FIXED_AMOUNT');
CREATE TYPE order_status_enum AS ENUM ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED');
CREATE TYPE basket_status_enum AS ENUM ('OPEN', 'CHECKED_OUT');
CREATE TYPE flash_sale_event_status_enum AS ENUM ('UPCOMING', 'ACTIVE', 'ENDED');
CREATE TYPE event_type_enum AS ENUM ('FLASH_SALE', 'PROMOTION');
CREATE TYPE user_role_enum AS ENUM ('user', 'admin');


-- Users (no dependencies)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    date_of_birth DATE,
    role user_role_enum NOT NULL DEFAULT 'user', -- Possible values: 'user', 'admin'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
);


-- Products (no dependencies)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_price NUMERIC(10, 2) NOT NULL,
    current_price NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    stock_quantity INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0 -- Add deleted_at field for soft delete
);

-- Discounts (no dependencies)
CREATE TABLE discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type discount_type_enum NOT NULL, -- Possible values: 'PERCENTAGE', 'FIXED_AMOUNT'
    discount_value NUMERIC(10, 2) NOT NULL, 
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0 -- Add deleted_at field for soft delete
);

-- Flash Sale Events (no dependencies)
CREATE TABLE flash_sale_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status flash_sale_event_status_enum NOT NULL DEFAULT 'UPCOMING', -- Possible values: 'UPCOMING', 'ACTIVE', 'ENDED'
    event_type event_type_enum NOT NULL DEFAULT 'FLASH_SALE', -- Possible values: 'FLASH_SALE', 'PROMOTION'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0 -- Add deleted_at field for soft delete
);


-- Product Discounts (depends on Products and Discounts)
CREATE TABLE product_discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    discount_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_product_discounts_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_product_discounts_discount FOREIGN KEY (discount_id) REFERENCES discounts(id)
);

-- Flash Sale Event Products (depends on Flash Sale Events and Products)
CREATE TABLE flash_sale_event_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL,
    product_id UUID NOT NULL,
    discount_percentage NUMERIC(5, 2) NOT NULL,
    sale_price NUMERIC(10, 2) NOT NULL,
    available_quantity INT NOT NULL,
    original_stock INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_flash_sale_event_products_event FOREIGN KEY (event_id) REFERENCES flash_sale_events(id),
    CONSTRAINT fk_flash_sale_event_products_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Baskets (depends on Users)
CREATE TABLE baskets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    status basket_status_enum NOT NULL DEFAULT 'OPEN', -- Possible values: 'OPEN', 'CHECKED_OUT'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_baskets_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Basket Items (depends on Baskets and Products)
CREATE TABLE basket_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    basket_id UUID NOT NULL,
    product_id UUID NOT NULL,
    flash_sale_event_product_id UUID, 
    discount_product_id UUID,
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    product_type product_type_enum NOT NULL, -- Possible values: 'REGULAR', 'FLASH_SALE', 'DISCOUNT'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_basket_items_basket FOREIGN KEY (basket_id) REFERENCES baskets(id),
    CONSTRAINT fk_basket_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_basket_items_flash_sale_event_product FOREIGN KEY (flash_sale_event_product_id) REFERENCES flash_sale_event_products(id),
    CONSTRAINT fk_basket_items_discount_product FOREIGN KEY (discount_product_id) REFERENCES product_discounts(id)
);

-- Orders (depends on Users)
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL,
    delivery_latitude NUMERIC(10, 6) NOT NULL,
    delivery_longitude NUMERIC(10, 6) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    status order_status_enum NOT NULL DEFAULT 'PENDING', -- Possible values: 'PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_orders_user FOREIGN KEY (client_id) REFERENCES users(id)
);

-- Order Items (depends on Orders, Products, and Flash Sale Event Products)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    flash_sale_event_product_id UUID, 
    discount_product_id UUID,        
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    discount_applied NUMERIC(10, 2) DEFAULT 0,
    product_type product_type_enum NOT NULL, -- Possible values: 'REGULAR', 'FLASH_SALE', 'DISCOUNT'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at BIGINT DEFAULT 0, -- Add deleted_at field for soft delete
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_order_items_flash_sale_event_product FOREIGN KEY (flash_sale_event_product_id) REFERENCES flash_sale_event_products(id),
    CONSTRAINT fk_order_items_discount_product FOREIGN KEY (discount_product_id) REFERENCES product_discounts(id)
);