-- Drop foreign key constraints first
ALTER TABLE order_items DROP CONSTRAINT fk_order_items_flash_sale_event_product;
ALTER TABLE order_items DROP CONSTRAINT fk_order_items_product;
ALTER TABLE order_items DROP CONSTRAINT fk_order_items_order;
ALTER TABLE product_discounts DROP CONSTRAINT fk_product_discounts_discount;
ALTER TABLE product_discounts DROP CONSTRAINT fk_product_discounts_product;
ALTER TABLE flash_sale_event_products DROP CONSTRAINT fk_flash_sale_event_products_product;
ALTER TABLE flash_sale_event_products DROP CONSTRAINT fk_flash_sale_event_products_event;
ALTER TABLE basket_items DROP CONSTRAINT fk_basket_items_product;
ALTER TABLE basket_items DROP CONSTRAINT fk_basket_items_basket;
ALTER TABLE orders DROP CONSTRAINT fk_orders_user;
ALTER TABLE baskets DROP CONSTRAINT fk_baskets_user;

-- Drop tables in reverse order of creation
DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE basket_items;
DROP TABLE baskets;
DROP TABLE flash_sale_event_products;
DROP TABLE flash_sale_events;
DROP TABLE product_discounts;
DROP TABLE discounts;
DROP TABLE products;
DROP TABLE users;

-- Drop ENUM types
DROP TYPE user_role_enum;
DROP TYPE event_type_enum;
DROP TYPE flash_sale_event_status_enum;
DROP TYPE basket_status_enum;
DROP TYPE order_status_enum;
DROP TYPE discount_type_enum;
DROP TYPE product_type_enum; 